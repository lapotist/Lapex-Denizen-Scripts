#!/usr/bin/env python3
"""Render a north-up, one-pixel-per-block overview from a Minecraft world.

The reader only opens world files in binary read mode. It understands Anvil
region headers, modern NBT section palettes, both palette bit-packing layouts,
external chunks, and the standard gzip/zlib/raw/LZ4 compression identifiers.

The default bounds are the 640 by 640 Lapex Kings Canyon play area:
coordinates x=-320..319 and z=-320..319. North (negative z) is at the top.
"""

from __future__ import annotations

import argparse
import colorsys
import hashlib
import math
import os
from pathlib import Path
import struct
import sys
import time
import zlib
from array import array
from collections import Counter
from dataclasses import dataclass, field
from typing import Any, Iterable

from PIL import Image, PngImagePlugin


DEFAULT_DIMENSION = Path(
    "/tmp/lapex-map-test/bootstrap/dimensions/minecraft/lapex_kings_canyon"
)
DEFAULT_OUTPUT = Path("artifacts/kings_canyon_topdown.png")
EMPTY_Y = -32768
MAX_NBT_ALLOCATION = 64 * 1024 * 1024
MAX_NBT_DEPTH = 128


class RenderError(Exception):
    """A recoverable world, region, chunk, or NBT error."""


class NBTReader:
    """Small, bounds-checked parser for the complete Java Edition NBT grammar."""

    def __init__(self, data: bytes):
        self.data = memoryview(data)
        self.pos = 0

    def take(self, size: int) -> memoryview:
        if size < 0 or self.pos + size > len(self.data):
            raise RenderError(
                f"truncated NBT at byte {self.pos}: wanted {size}, "
                f"have {len(self.data) - self.pos}"
            )
        value = self.data[self.pos : self.pos + size]
        self.pos += size
        return value

    def unpack(self, fmt: str) -> Any:
        size = struct.calcsize(fmt)
        return struct.unpack(fmt, self.take(size))[0]

    def string(self) -> str:
        length = self.unpack(">H")
        raw = bytes(self.take(length))
        # Palette names and NBT keys are ASCII-compatible. Replacement keeps a
        # malformed optional string from preventing the terrain from rendering.
        return raw.decode("utf-8", errors="replace")

    def sized_length(self, unit_size: int, label: str) -> int:
        length = self.unpack(">i")
        if length < 0:
            raise RenderError(f"negative {label} length {length}")
        if length * unit_size > MAX_NBT_ALLOCATION:
            raise RenderError(f"unreasonable {label} allocation: {length}")
        return length

    def payload(self, tag_type: int, depth: int = 0) -> Any:
        if depth > MAX_NBT_DEPTH:
            raise RenderError("NBT nesting is too deep")
        if tag_type == 0:
            return None
        if tag_type == 1:
            return self.unpack(">b")
        if tag_type == 2:
            return self.unpack(">h")
        if tag_type == 3:
            return self.unpack(">i")
        if tag_type == 4:
            return self.unpack(">q")
        if tag_type == 5:
            return self.unpack(">f")
        if tag_type == 6:
            return self.unpack(">d")
        if tag_type == 7:
            length = self.sized_length(1, "byte array")
            return bytes(self.take(length))
        if tag_type == 8:
            return self.string()
        if tag_type == 9:
            item_type = self.unpack(">B")
            length = self.sized_length(1, "list")
            if item_type == 0 and length:
                raise RenderError("non-empty NBT list has TAG_End item type")
            return [self.payload(item_type, depth + 1) for _ in range(length)]
        if tag_type == 10:
            result: dict[str, Any] = {}
            while True:
                child_type = self.unpack(">B")
                if child_type == 0:
                    return result
                name = self.string()
                result[name] = self.payload(child_type, depth + 1)
        if tag_type == 11:
            length = self.sized_length(4, "int array")
            if not length:
                return ()
            return struct.unpack(f">{length}i", self.take(length * 4))
        if tag_type == 12:
            length = self.sized_length(8, "long array")
            if not length:
                return ()
            return struct.unpack(f">{length}q", self.take(length * 8))
        raise RenderError(f"unknown NBT tag type {tag_type} at byte {self.pos - 1}")

    def root(self) -> dict[str, Any]:
        root_type = self.unpack(">B")
        if root_type != 10:
            raise RenderError(f"NBT root is tag {root_type}, expected compound (10)")
        self.string()  # Root name, usually empty for chunk NBT.
        value = self.payload(root_type)
        if not isinstance(value, dict):
            raise RenderError("NBT root payload is not a compound")
        return value


def _lz4_block(data: bytes, expected_size: int) -> bytes:
    """Decode a raw LZ4 block without requiring a third-party LZ4 package."""
    source = memoryview(data)
    pos = 0
    output = bytearray()
    while pos < len(source):
        token = source[pos]
        pos += 1

        literal_length = token >> 4
        if literal_length == 15:
            while True:
                if pos >= len(source):
                    raise RenderError("truncated LZ4 literal length")
                extension = source[pos]
                pos += 1
                literal_length += extension
                if extension != 255:
                    break
        if pos + literal_length > len(source):
            raise RenderError("truncated LZ4 literal data")
        output.extend(source[pos : pos + literal_length])
        pos += literal_length
        if pos == len(source):
            break
        if pos + 2 > len(source):
            raise RenderError("truncated LZ4 match offset")
        offset = source[pos] | (source[pos + 1] << 8)
        pos += 2
        if offset == 0 or offset > len(output):
            raise RenderError(f"invalid LZ4 match offset {offset}")

        match_length = token & 0x0F
        if match_length == 15:
            while True:
                if pos >= len(source):
                    raise RenderError("truncated LZ4 match length")
                extension = source[pos]
                pos += 1
                match_length += extension
                if extension != 255:
                    break
        match_length += 4
        start = len(output) - offset
        for index in range(match_length):
            output.append(output[start + index])
        if len(output) > MAX_NBT_ALLOCATION:
            raise RenderError("LZ4 block expands beyond the NBT safety limit")
    if len(output) != expected_size:
        raise RenderError(
            f"LZ4 block produced {len(output)} bytes, expected {expected_size}"
        )
    return bytes(output)


def _lz4_stream(data: bytes) -> bytes:
    """Decode the LZ4Block stream used by Anvil compression identifier 4."""
    magic = b"LZ4Block"
    pos = 0
    output = bytearray()
    while True:
        if pos + 21 > len(data) or data[pos : pos + 8] != magic:
            raise RenderError("invalid or truncated LZ4Block stream")
        token = data[pos + 8]
        compressed_length = int.from_bytes(data[pos + 9 : pos + 13], "little")
        original_length = int.from_bytes(data[pos + 13 : pos + 17], "little")
        # Bytes 17..20 are an xxHash checksum. Structural and length checks are
        # still enforced here without adding a non-stdlib hash dependency.
        pos += 21
        if compressed_length == 0 and original_length == 0:
            return bytes(output)
        if compressed_length <= 0 or original_length <= 0:
            raise RenderError("invalid LZ4Block lengths")
        if pos + compressed_length > len(data):
            raise RenderError("truncated LZ4Block payload")
        block = data[pos : pos + compressed_length]
        pos += compressed_length
        method = token & 0xF0
        if method == 0x10:
            if compressed_length != original_length:
                raise RenderError("raw LZ4Block has mismatched lengths")
            decoded = block
        elif method == 0x20:
            decoded = _lz4_block(block, original_length)
        else:
            raise RenderError(f"unknown LZ4Block method 0x{method:02x}")
        output.extend(decoded)
        if len(output) > MAX_NBT_ALLOCATION:
            raise RenderError("LZ4 stream expands beyond the NBT safety limit")


def decompress_chunk(compression: int, payload: bytes) -> bytes:
    try:
        if compression == 1:
            result = zlib.decompress(payload, zlib.MAX_WBITS | 16)
        elif compression == 2:
            result = zlib.decompress(payload)
        elif compression == 3:
            result = payload
        elif compression == 4:
            result = _lz4_stream(payload)
        else:
            raise RenderError(f"unsupported Anvil compression identifier {compression}")
    except zlib.error as exc:
        raise RenderError(f"compressed chunk is corrupt: {exc}") from exc
    if len(result) > MAX_NBT_ALLOCATION:
        raise RenderError(f"chunk NBT is unexpectedly large: {len(result)} bytes")
    return result


def read_stable(path: Path, attempts: int = 5) -> tuple[bytes, bool]:
    """Take an immutable in-memory snapshot, retrying if a live file changes."""
    latest = b""
    for attempt in range(attempts):
        before = path.stat()
        with path.open("rb") as handle:
            latest = handle.read()
        after = path.stat()
        stable = (
            before.st_ino == after.st_ino
            and before.st_size == after.st_size == len(latest)
            and before.st_mtime_ns == after.st_mtime_ns
        )
        if stable:
            return latest, True
        if attempt + 1 < attempts:
            time.sleep(0.04)
    return latest, False


class Region:
    def __init__(self, path: Path, region_x: int, region_z: int):
        self.path = path
        self.region_x = region_x
        self.region_z = region_z
        try:
            self.data, self.stable = read_stable(path)
        except OSError as exc:
            raise RenderError(f"cannot read region {path}: {exc}") from exc
        if len(self.data) < 8192:
            raise RenderError(f"region {path} is shorter than its 8 KiB header")

    def chunk_root(self, chunk_x: int, chunk_z: int) -> dict[str, Any] | None:
        local_x = chunk_x & 31
        local_z = chunk_z & 31
        header_pos = (local_x + local_z * 32) * 4
        location = int.from_bytes(self.data[header_pos : header_pos + 3], "big")
        sector_count = self.data[header_pos + 3]
        if location == 0 or sector_count == 0:
            return None
        chunk_pos = location * 4096
        if chunk_pos + 5 > len(self.data):
            raise RenderError(
                f"chunk {chunk_x},{chunk_z} points outside {self.path.name}"
            )
        length = int.from_bytes(self.data[chunk_pos : chunk_pos + 4], "big")
        if length < 1:
            raise RenderError(f"chunk {chunk_x},{chunk_z} has invalid length {length}")
        type_byte = self.data[chunk_pos + 4]
        external = bool(type_byte & 0x80)
        compression = type_byte & 0x7F
        if external:
            external_path = self.path.parent / f"c.{chunk_x}.{chunk_z}.mcc"
            try:
                payload, _ = read_stable(external_path)
            except OSError as exc:
                raise RenderError(
                    f"cannot read external chunk {external_path.name}: {exc}"
                ) from exc
        else:
            if length + 4 > sector_count * 4096:
                raise RenderError(
                    f"chunk {chunk_x},{chunk_z} length exceeds allocated sectors"
                )
            end = chunk_pos + 4 + length
            if end > len(self.data):
                raise RenderError(f"chunk {chunk_x},{chunk_z} payload is truncated")
            payload = self.data[chunk_pos + 5 : end]
        return NBTReader(decompress_chunk(compression, payload)).root()


AIR_BLOCKS = {
    "air",
    "cave_air",
    "void_air",
    "structure_void",
    "light",
    "barrier",
}
WATER_BLOCKS = {"water", "bubble_column"}
FOLIAGE_EXACT = {
    "short_grass",
    "tall_grass",
    "grass",
    "fern",
    "large_fern",
    "dead_bush",
    "vine",
    "glow_lichen",
    "hanging_roots",
    "mangrove_roots",
    "muddy_mangrove_roots",
    "sugar_cane",
    "lily_pad",
    "cactus_flower",
    "firefly_bush",
    "bush",
    "dry_grass",
    "tall_dry_grass",
}
FOLIAGE_PARTS = (
    "_leaves",
    "_sapling",
    "_flower",
    "_tulip",
    "_orchid",
    "_mushroom",
    "seagrass",
    "kelp",
    "azalea",
    "dripleaf",
    "spore_blossom",
    "wildflowers",
    "leaf_litter",
)


def clean_name(name: Any) -> str:
    if not isinstance(name, str):
        return "air"
    return name.split(":", 1)[-1].lower()


def block_kind(name: str) -> int:
    """Return 0 for invisible, 1 for water, and 2 for a solid surface."""
    if name in AIR_BLOCKS:
        return 0
    if name in WATER_BLOCKS:
        return 1
    if name in FOLIAGE_EXACT or any(part in name for part in FOLIAGE_PARTS):
        return 0
    return 2


def section_list(root: dict[str, Any]) -> list[dict[str, Any]]:
    node = root.get("Level", root)
    if not isinstance(node, dict):
        return []
    sections: Any = None
    for key in ("sections", "Sections"):
        candidate = node.get(key)
        if isinstance(candidate, list):
            sections = candidate
            break
    if sections is None:
        return []
    return [section for section in sections if isinstance(section, dict)]


def palette_and_data(section: dict[str, Any]) -> tuple[list[str], tuple[int, ...]] | None:
    states = section.get("block_states")
    if not isinstance(states, dict):
        states = section.get("BlockStates")
    if isinstance(states, dict):
        palette = states.get("palette", states.get("Palette"))
        data = states.get("data", states.get("Data", ()))
    else:
        # Legacy flattened section layout, retained for older generated worlds.
        palette = section.get("Palette")
        data = section.get("BlockStates", ())
    if not isinstance(palette, list) or not palette:
        return None
    names: list[str] = []
    for item in palette:
        if isinstance(item, dict):
            names.append(clean_name(item.get("Name", item.get("name", "air"))))
        else:
            names.append(clean_name(item))
    if not isinstance(data, (tuple, list)):
        data = ()
    return names, tuple(int(value) for value in data)


class PaletteIndices:
    def __init__(self, palette_size: int, packed: tuple[int, ...]):
        self.palette_size = palette_size
        self.packed = tuple(value & 0xFFFFFFFFFFFFFFFF for value in packed)
        self.bits = max(4, (palette_size - 1).bit_length())
        values_per_long = 64 // self.bits
        padded_length = math.ceil(4096 / values_per_long)
        contiguous_length = math.ceil(4096 * self.bits / 64)
        if not packed and palette_size == 1:
            self.layout = "single"
        elif len(packed) == padded_length:
            self.layout = "padded"
        elif len(packed) == contiguous_length:
            self.layout = "contiguous"
        else:
            alternatives = []
            for bits in range(max(4, (palette_size - 1).bit_length()), 17):
                padded = math.ceil(4096 / (64 // bits))
                contiguous = math.ceil(4096 * bits / 64)
                if len(packed) == padded:
                    alternatives.append((bits, "padded"))
                if len(packed) == contiguous:
                    alternatives.append((bits, "contiguous"))
            if not alternatives:
                raise RenderError(
                    f"block-state array has {len(packed)} longs for "
                    f"a {palette_size}-entry palette"
                )
            self.bits, self.layout = alternatives[0]
        self.mask = (1 << self.bits) - 1
        self.values_per_long = 64 // self.bits

    def __getitem__(self, index: int) -> int:
        if self.layout == "single":
            return 0
        if self.layout == "padded":
            long_index, within = divmod(index, self.values_per_long)
            value = (self.packed[long_index] >> (within * self.bits)) & self.mask
        else:
            bit_index = index * self.bits
            long_index, shift = divmod(bit_index, 64)
            value = self.packed[long_index] >> shift
            spill = shift + self.bits - 64
            if spill > 0:
                value |= self.packed[long_index + 1] << (self.bits - spill)
            value &= self.mask
        if value >= self.palette_size:
            raise RenderError(
                f"block-state palette index {value} exceeds size {self.palette_size}"
            )
        return value


@dataclass
class ChunkSurface:
    names: list[str | None] = field(default_factory=lambda: [None] * 256)
    heights: list[int] = field(default_factory=lambda: [EMPTY_Y] * 256)
    water_heights: list[int] = field(default_factory=lambda: [EMPTY_Y] * 256)
    ground_names: list[str | None] = field(default_factory=lambda: [None] * 256)
    ground_heights: list[int] = field(default_factory=lambda: [EMPTY_Y] * 256)


def extract_surface(root: dict[str, Any]) -> ChunkSurface:
    result = ChunkSurface()
    unresolved = set(range(256))
    ordered: list[tuple[int, list[str], tuple[int, ...]]] = []
    for section in section_list(root):
        y_value = section.get("Y", section.get("y"))
        if not isinstance(y_value, int):
            continue
        parsed = palette_and_data(section)
        if parsed is not None:
            ordered.append((y_value, parsed[0], parsed[1]))
    ordered.sort(key=lambda item: item[0], reverse=True)

    for section_y, palette, packed in ordered:
        if not unresolved:
            break
        kinds = [block_kind(name) for name in palette]
        if all(kind == 0 for kind in kinds):
            continue
        indices = PaletteIndices(len(palette), packed)
        base_y = section_y * 16

        if len(palette) == 1:
            kind = kinds[0]
            if kind == 1:
                top_y = base_y + 15
                for column in unresolved:
                    if result.water_heights[column] == EMPTY_Y:
                        result.water_heights[column] = top_y
                continue
            if kind == 2:
                top_y = base_y + 15
                for column in tuple(unresolved):
                    name = palette[0]
                    if result.water_heights[column] != EMPTY_Y:
                        result.names[column] = "water"
                        result.heights[column] = result.water_heights[column]
                        result.ground_names[column] = name
                        result.ground_heights[column] = top_y
                    else:
                        result.names[column] = name
                        result.heights[column] = top_y
                    unresolved.remove(column)
                continue

        for local_y in range(15, -1, -1):
            if not unresolved:
                break
            world_y = base_y + local_y
            for column in tuple(unresolved):
                local_x = column & 15
                local_z = column >> 4
                block_index = (local_y << 8) | (local_z << 4) | local_x
                palette_index = indices[block_index]
                kind = kinds[palette_index]
                if kind == 0:
                    continue
                if kind == 1:
                    if result.water_heights[column] == EMPTY_Y:
                        result.water_heights[column] = world_y
                    continue
                name = palette[palette_index]
                if result.water_heights[column] != EMPTY_Y:
                    result.names[column] = "water"
                    result.heights[column] = result.water_heights[column]
                    result.ground_names[column] = name
                    result.ground_heights[column] = world_y
                else:
                    result.names[column] = name
                    result.heights[column] = world_y
                unresolved.remove(column)

    for column in unresolved:
        if result.water_heights[column] != EMPTY_Y:
            result.names[column] = "water"
            result.heights[column] = result.water_heights[column]
    return result


DYE_COLORS: dict[str, tuple[int, int, int]] = {
    "white": (207, 213, 214),
    "orange": (224, 97, 1),
    "magenta": (169, 48, 159),
    "light_blue": (36, 137, 199),
    "yellow": (241, 175, 21),
    "lime": (94, 168, 24),
    "pink": (214, 101, 143),
    "gray": (55, 58, 62),
    "light_gray": (125, 125, 115),
    "cyan": (21, 119, 136),
    "purple": (100, 32, 156),
    "blue": (44, 46, 143),
    "brown": (96, 59, 31),
    "green": (73, 91, 36),
    "red": (142, 33, 33),
    "black": (21, 23, 25),
}

EXACT_COLORS: dict[str, tuple[int, int, int]] = {
    "water": (48, 105, 176),
    "bubble_column": (48, 105, 176),
    "lava": (241, 91, 15),
    "grass_block": (94, 124, 58),
    "moss_block": (91, 117, 45),
    "dirt": (128, 91, 58),
    "coarse_dirt": (116, 81, 49),
    "rooted_dirt": (144, 103, 76),
    "dirt_path": (151, 125, 76),
    "mud": (61, 57, 68),
    "packed_mud": (141, 106, 78),
    "mud_bricks": (137, 103, 79),
    "sand": (219, 207, 160),
    "red_sand": (190, 101, 33),
    "sandstone": (216, 202, 151),
    "smooth_sandstone": (221, 209, 169),
    "cut_sandstone": (211, 197, 146),
    "red_sandstone": (178, 90, 37),
    "smooth_red_sandstone": (188, 100, 44),
    "stone": (126, 126, 126),
    "smooth_stone": (158, 158, 158),
    "cobblestone": (113, 113, 113),
    "mossy_cobblestone": (100, 112, 82),
    "stone_bricks": (122, 121, 122),
    "mossy_stone_bricks": (108, 117, 91),
    "granite": (151, 104, 86),
    "polished_granite": (155, 107, 90),
    "diorite": (190, 190, 190),
    "polished_diorite": (199, 198, 196),
    "andesite": (135, 135, 136),
    "polished_andesite": (144, 146, 146),
    "gravel": (128, 123, 121),
    "clay": (160, 166, 179),
    "terracotta": (152, 94, 68),
    "calcite": (225, 222, 212),
    "bone_block": (225, 221, 177),
    "quartz_block": (235, 230, 223),
    "smooth_quartz": (238, 234, 227),
    "bricks": (151, 75, 62),
    "deepslate": (81, 81, 84),
    "cobbled_deepslate": (76, 76, 80),
    "polished_deepslate": (72, 72, 75),
    "deepslate_bricks": (70, 70, 72),
    "deepslate_tiles": (55, 55, 58),
    "tuff": (108, 113, 106),
    "blackstone": (44, 37, 43),
    "polished_blackstone": (53, 48, 56),
    "basalt": (77, 73, 78),
    "smooth_basalt": (73, 73, 78),
    "obsidian": (32, 24, 49),
    "bedrock": (84, 84, 84),
    "iron_block": (218, 218, 214),
    "iron_bars": (151, 150, 146),
    "gold_block": (247, 208, 57),
    "sea_lantern": (172, 199, 190),
    "beacon": (126, 220, 213),
    "barrel": (115, 83, 48),
    "glass": (181, 207, 210),
    "tinted_glass": (57, 52, 64),
    "ice": (138, 180, 250),
    "packed_ice": (115, 166, 245),
    "blue_ice": (76, 126, 242),
    "snow": (238, 243, 243),
    "snow_block": (238, 243, 243),
    "magma_block": (142, 63, 31),
}

WOOD_COLORS: dict[str, tuple[int, int, int]] = {
    "oak": (157, 126, 75),
    "spruce": (108, 78, 48),
    "birch": (196, 179, 123),
    "jungle": (155, 111, 69),
    "acacia": (169, 91, 55),
    "dark_oak": (67, 43, 22),
    "mangrove": (118, 54, 48),
    "cherry": (216, 151, 147),
    "pale_oak": (196, 190, 180),
    "bamboo": (174, 166, 76),
    "crimson": (111, 48, 70),
    "warped": (43, 104, 99),
}


def _scale(rgb: tuple[int, int, int], factor: float) -> tuple[int, int, int]:
    return tuple(max(0, min(255, round(channel * factor))) for channel in rgb)


def material_color(name: str) -> tuple[tuple[int, int, int], bool]:
    if name in EXACT_COLORS:
        return EXACT_COLORS[name], True
    for dye, rgb in DYE_COLORS.items():
        if name.startswith(dye + "_") and any(
            token in name
            for token in (
                "concrete",
                "terracotta",
                "wool",
                "carpet",
                "stained_glass",
                "glazed_terracotta",
            )
        ):
            if "terracotta" in name:
                rgb = _scale(rgb, 0.78)
            elif "stained_glass" in name:
                rgb = _scale(rgb, 0.88)
            return rgb, True
    for wood, rgb in WOOD_COLORS.items():
        if name.startswith(wood + "_") and any(
            token in name
            for token in (
                "log",
                "wood",
                "planks",
                "slab",
                "stairs",
                "fence",
                "door",
                "trapdoor",
                "pressure_plate",
            )
        ):
            if "log" in name or "wood" in name:
                rgb = _scale(rgb, 0.82)
            return rgb, True
    if "copper" in name:
        if "oxidized" in name:
            return (82, 157, 142), True
        if "weathered" in name:
            return (99, 145, 117), True
        if "exposed" in name:
            return (161, 126, 91), True
        return (194, 108, 76), True
    if "prismarine" in name:
        return (94, 157, 143), True
    if "nether_brick" in name:
        return (72, 39, 45), True
    if name.endswith("_ore"):
        return (112, 109, 105), True
    if "stone" in name:
        return (105, 103, 107), True

    # Keep unknown future blocks distinguishable without producing neon noise.
    digest = hashlib.sha256(name.encode("utf-8")).digest()
    hue = int.from_bytes(digest[:2], "big") / 65535.0
    saturation = 0.24 + digest[2] / 255.0 * 0.20
    value = 0.48 + digest[3] / 255.0 * 0.20
    rgb_float = colorsys.hsv_to_rgb(hue, saturation, value)
    return tuple(round(channel * 255) for channel in rgb_float), False


def pack_rgb(rgb: tuple[int, int, int]) -> int:
    return (rgb[0] << 16) | (rgb[1] << 8) | rgb[2]


def unpack_rgb(value: int) -> tuple[int, int, int]:
    return (value >> 16, (value >> 8) & 255, value & 255)


@dataclass
class RenderStats:
    chunks_requested: int = 0
    chunks_present: int = 0
    chunks_rendered: int = 0
    chunks_missing: int = 0
    unstable_regions: set[str] = field(default_factory=set)
    errors: list[str] = field(default_factory=list)
    unknown_blocks: Counter[str] = field(default_factory=Counter)
    visible_pixels: int = 0
    water_pixels: int = 0


def is_within(child: Path, parent: Path) -> bool:
    try:
        child.relative_to(parent)
        return True
    except ValueError:
        return False


def render(
    dimension: Path,
    output: Path,
    min_x: int,
    min_z: int,
    width: int,
    height_pixels: int,
    quiet: bool,
) -> RenderStats:
    dimension = dimension.resolve(strict=True)
    region_dir = dimension / "region"
    if not region_dir.is_dir():
        raise RenderError(f"dimension has no region directory: {region_dir}")
    output = output.resolve(strict=False)
    if is_within(output, dimension):
        raise RenderError("refusing to write the PNG inside the source dimension")

    total_pixels = width * height_pixels
    heights = array("h", [EMPTY_Y]) * total_pixels
    colors = array("I", [0]) * total_pixels
    ground_colors = array("I", [0]) * total_pixels
    water_depths = array("H", [0]) * total_pixels
    stats = RenderStats()
    color_cache: dict[str, tuple[int, bool]] = {}

    def color_for(name: str) -> int:
        cached = color_cache.get(name)
        if cached is None:
            rgb, known = material_color(name)
            cached = (pack_rgb(rgb), known)
            color_cache[name] = cached
        if not cached[1]:
            stats.unknown_blocks[name] += 1
        return cached[0]

    max_x = min_x + width - 1
    max_z = min_z + height_pixels - 1
    min_chunk_x, max_chunk_x = min_x // 16, max_x // 16
    min_chunk_z, max_chunk_z = min_z // 16, max_z // 16
    regions: dict[tuple[int, int], Region | None] = {}

    for chunk_z in range(min_chunk_z, max_chunk_z + 1):
        for chunk_x in range(min_chunk_x, max_chunk_x + 1):
            stats.chunks_requested += 1
            region_key = (chunk_x // 32, chunk_z // 32)
            if region_key not in regions:
                region_path = region_dir / f"r.{region_key[0]}.{region_key[1]}.mca"
                if not region_path.exists():
                    regions[region_key] = None
                else:
                    try:
                        regions[region_key] = Region(
                            region_path, region_key[0], region_key[1]
                        )
                        if not regions[region_key].stable:
                            stats.unstable_regions.add(region_path.name)
                    except RenderError as exc:
                        stats.errors.append(str(exc))
                        regions[region_key] = None
            region = regions[region_key]
            if region is None:
                stats.chunks_missing += 1
                continue
            try:
                root = region.chunk_root(chunk_x, chunk_z)
                if root is None:
                    stats.chunks_missing += 1
                    continue
                stats.chunks_present += 1
                surface = extract_surface(root)
                stats.chunks_rendered += 1
            except (RenderError, OSError, ValueError, IndexError) as exc:
                stats.errors.append(f"chunk {chunk_x},{chunk_z}: {exc}")
                continue

            for local_z in range(16):
                world_z = chunk_z * 16 + local_z
                if not min_z <= world_z <= max_z:
                    continue
                image_y = world_z - min_z
                for local_x in range(16):
                    world_x = chunk_x * 16 + local_x
                    if not min_x <= world_x <= max_x:
                        continue
                    column = (local_z << 4) | local_x
                    name = surface.names[column]
                    if name is None:
                        continue
                    image_x = world_x - min_x
                    pixel = image_y * width + image_x
                    heights[pixel] = max(
                        -32767, min(32767, surface.heights[column])
                    )
                    colors[pixel] = color_for(name)
                    stats.visible_pixels += 1
                    if name == "water":
                        stats.water_pixels += 1
                        ground_name = surface.ground_names[column]
                        ground_y = surface.ground_heights[column]
                        if ground_name is not None:
                            ground_colors[pixel] = color_for(ground_name)
                            depth = max(1, surface.heights[column] - ground_y)
                        else:
                            ground_colors[pixel] = pack_rgb((25, 44, 63))
                            depth = 24
                        water_depths[pixel] = min(65535, depth)

            if not quiet and stats.chunks_rendered % 200 == 0:
                print(
                    f"Read {stats.chunks_rendered}/{stats.chunks_requested} chunks...",
                    file=sys.stderr,
                )

    pixels = bytearray(total_pixels * 3)
    empty_color = (18, 23, 27)
    water_rgb = EXACT_COLORS["water"]
    for image_y in range(height_pixels):
        for image_x in range(width):
            pixel = image_y * width + image_x
            y_value = heights[pixel]
            if y_value == EMPTY_Y:
                rgb = empty_color
            else:
                rgb = unpack_rgb(colors[pixel])
                depth = water_depths[pixel]
                if depth:
                    ground = unpack_rgb(ground_colors[pixel])
                    # Keep even one-block shallows visibly aquatic while still
                    # letting beaches and riverbeds influence their color.
                    water_alpha = min(0.90, 0.55 + depth * 0.025)
                    shallow = tuple(
                        round(ground[channel] * (1.0 - water_alpha)
                              + water_rgb[channel] * water_alpha)
                        for channel in range(3)
                    )
                    rgb = shallow

                west_index = pixel - 1 if image_x else pixel
                north_index = pixel - width if image_y else pixel
                west_y = heights[west_index]
                north_y = heights[north_index]
                if west_y == EMPTY_Y:
                    west_y = y_value
                if north_y == EMPTY_Y:
                    north_y = y_value
                relief = (y_value - west_y) * 0.012 + (y_value - north_y) * 0.016
                elevation = max(-0.10, min(0.12, (y_value - 62) * 0.0012))
                brightness = max(0.72, min(1.24, 0.96 + relief + elevation))
                rgb = _scale(rgb, brightness)
            offset = pixel * 3
            pixels[offset : offset + 3] = bytes(rgb)

    image = Image.frombytes("RGB", (width, height_pixels), bytes(pixels))
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text("Software", "Lapex read-only Anvil renderer")
    metadata.add_text(
        "Description",
        "North-up Minecraft surface map; negative Z is up and X increases right",
    )
    metadata.add_text(
        "Bounds", f"x={min_x}..{max_x}, z={min_z}..{max_z}, 1 pixel per block"
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_name(output.name + ".tmp")
    try:
        image.save(temporary, format="PNG", optimize=True, pnginfo=metadata)
        os.replace(temporary, output)
    finally:
        try:
            temporary.unlink()
        except FileNotFoundError:
            pass
    return stats


def parse_args(argv: Iterable[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Render a read-only, north-up PNG from modern Minecraft Anvil chunks."
        )
    )
    parser.add_argument(
        "dimension",
        nargs="?",
        type=Path,
        default=DEFAULT_DIMENSION,
        help=f"dimension directory (default: {DEFAULT_DIMENSION})",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"output PNG outside the dimension (default: {DEFAULT_OUTPUT})",
    )
    parser.add_argument("--min-x", type=int, default=-320)
    parser.add_argument("--min-z", type=int, default=-320)
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--quiet", action="store_true", help="hide progress messages")
    return parser.parse_args(argv)


def main(argv: Iterable[str] | None = None) -> int:
    args = parse_args(argv)
    if not 1 <= args.width <= 8192 or not 1 <= args.height <= 8192:
        print("error: width and height must be between 1 and 8192", file=sys.stderr)
        return 2
    try:
        stats = render(
            args.dimension,
            args.output,
            args.min_x,
            args.min_z,
            args.width,
            args.height,
            args.quiet,
        )
    except (RenderError, OSError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    output = args.output.resolve(strict=False)
    print(
        f"Rendered {args.width}x{args.height} PNG to {output}\n"
        f"Chunks: {stats.chunks_rendered} rendered, "
        f"{stats.chunks_missing} missing, {len(stats.errors)} failed; "
        f"surface pixels: {stats.visible_pixels}, water: {stats.water_pixels}"
    )
    if stats.unstable_regions:
        print(
            "Warning: live region files changed while being read: "
            + ", ".join(sorted(stats.unstable_regions)),
            file=sys.stderr,
        )
    if stats.errors:
        print("Chunk warnings:", file=sys.stderr)
        for message in stats.errors[:20]:
            print(f"  {message}", file=sys.stderr)
        if len(stats.errors) > 20:
            print(f"  ... {len(stats.errors) - 20} more", file=sys.stderr)
    if stats.unknown_blocks:
        details = ", ".join(
            f"{name} ({count})" for name, count in stats.unknown_blocks.most_common(12)
        )
        print(f"Fallback colors used for: {details}", file=sys.stderr)
    return 0 if stats.chunks_rendered else 1


if __name__ == "__main__":
    raise SystemExit(main())
