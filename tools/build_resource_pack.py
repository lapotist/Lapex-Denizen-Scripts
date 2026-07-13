#!/usr/bin/env python3
"""Build the Minecraft 26.1 Lapex weapon resource pack without dependencies."""

from __future__ import annotations

import json
import struct
import zlib
from pathlib import Path

if __package__:
    from .resource_pack_weapons import Surface, WEAPON_SURFACES, validate_weapon_blueprints, weapon_model_for
else:
    from resource_pack_weapons import Surface, WEAPON_SURFACES, validate_weapon_blueprints, weapon_model_for


ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "resource-pack"

# Stable gameplay item mapping. Geometry and four-color surfaces live in the
# companion visual module so reorderings cannot silently redesign a gun.
WEAPONS = [
    ("havoc", 1001, "ar"),
    ("flatline", 1002, "ar"),
    ("hemlok_breach", 1003, "ar"),
    ("r301", 1004, "ar"),
    ("nemesis", 1005, "ar"),
    ("alternator", 1006, "smg"),
    ("prowler", 1007, "smg"),
    ("r99", 1008, "smg"),
    ("volt", 1009, "smg"),
    ("car", 1010, "smg"),
    ("devotion", 1011, "lmg"),
    ("lstar", 1012, "lmg"),
    ("spitfire", 1013, "lmg"),
    ("rampage", 1014, "lmg"),
    ("g7_scout", 1015, "marksman"),
    ("triple_take", 1016, "marksman"),
    ("repeater_3030", 1017, "marksman"),
    ("bocek", 1018, "bow"),
    ("charge_rifle", 1019, "sniper"),
    ("longbow", 1020, "sniper"),
    ("kraber", 1021, "sniper"),
    ("sentinel", 1022, "sniper"),
    ("eva8", 1023, "shotgun"),
    ("mastiff", 1024, "shotgun"),
    ("mozambique", 1025, "pistol"),
    ("peacekeeper", 1026, "shotgun"),
    ("re45_burst", 1027, "pistol"),
    ("p2020", 1028, "pistol"),
    ("wingman", 1029, "pistol"),
    ("sheila", 1030, "minigun"),
    ("a13_sentry", 1031, "sniper"),
    ("whistler", 1032, "pistol"),
]

# Visual-only models equipped by physical legend proxies. These IDs live in a
# separate range so adding a weapon cannot silently remap a placed device.
DEVICES = [
    ("caustic_trap", 1101, (76, 88, 46), (194, 224, 57)),
    ("horizon_newt", 1102, (55, 48, 70), (185, 88, 230)),
    ("octane_pad", 1103, (48, 66, 53), (104, 224, 75)),
    ("axle_gate", 1104, (39, 63, 70), (66, 218, 236)),
    ("ash_portal", 1105, (53, 43, 67), (179, 88, 232)),
    ("gibraltar_dome", 1106, (44, 67, 76), (74, 174, 238)),
    ("lifeline_doc", 1107, (57, 71, 66), (82, 222, 161)),
    ("lifeline_halo", 1108, (68, 68, 72), (96, 207, 238)),
]


def write_json(path: Path, value: object) -> None:
    """Write stable, human-readable generated JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def png(path: Path, width: int, height: int, pixels: list[tuple[int, int, int, int]]) -> None:
    """Write a dependency-free RGBA PNG from row-major pixels."""
    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    rows = bytearray()
    for y in range(height):
        rows.append(0)
        for pixel in pixels[y * width : (y + 1) * width]:
            rows.extend(pixel)
    payload = b"\x89PNG\r\n\x1a\n"
    payload += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    payload += chunk(b"IDAT", zlib.compress(bytes(rows), 9))
    payload += chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(payload)


def shade(rgb: tuple[int, int, int], factor: float) -> tuple[int, int, int, int]:
    return tuple(max(0, min(255, round(channel * factor))) for channel in rgb) + (255,)


def stable_seed(identifier: str) -> int:
    """Derive repeatable texture variation without depending on roster order."""
    return sum((index + 1) * ord(character) for index, character in enumerate(identifier))


def denizen_weapon_model_data(path: Path) -> dict[str, int]:
    """Extract the strict item-script subset that owns gun IDs and model data."""
    result: dict[str, int] = {}
    container = ""
    weapon_id = ""
    model_data: int | None = None
    context: dict[int, str] = {}

    def finish_container() -> None:
        nonlocal weapon_id, model_data
        if not weapon_id and model_data is None:
            weapon_id = ""
            model_data = None
            return
        if not weapon_id or model_data is None:
            raise ValueError(f"{container} must define lapex.id and custom_model_data")
        if container != f"apex_{weapon_id}":
            raise ValueError(f"{container} disagrees with lapex.id {weapon_id}")
        if weapon_id in result:
            raise ValueError(f"Duplicate Denizen weapon ID: {weapon_id}")
        result[weapon_id] = model_data
        weapon_id = ""
        model_data = None

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        if raw_line and not raw_line[0].isspace() and raw_line.endswith(":"):
            finish_container()
            container = raw_line[:-1]
            context.clear()
            continue
        indentation = len(raw_line) - len(raw_line.lstrip(" "))
        key, separator, value = raw_line.strip().partition(":")
        if not separator:
            continue
        for level in [level for level in context if level >= indentation]:
            del context[level]
        if not value.strip():
            context[indentation] = key
        if key == "id" and context.get(4) == "flags" and context.get(8) == "lapex":
            weapon_id = value.strip()
        elif key == "custom_model_data" and context.get(4) == "mechanisms":
            model_data = int(value.strip())
    finish_container()
    return result


def validate_weapon_item_contract() -> None:
    """Keep client model dispatch IDs equal to the issued Denizen items."""
    expected = {weapon_id: model_data for weapon_id, model_data, _ in WEAPONS}
    actual = denizen_weapon_model_data(ROOT / "scripts" / "apex_weapon_items.dsc")
    if actual != expected:
        mismatches = {
            weapon_id: {"pack": expected.get(weapon_id), "item": actual.get(weapon_id)}
            for weapon_id in sorted(set(expected) | set(actual))
            if expected.get(weapon_id) != actual.get(weapon_id)
        }
        raise ValueError(f"Weapon item/model-data mismatch: {mismatches}")


def palette_texture(path: Path, body: tuple[int, int, int], accent: tuple[int, int, int], seed: int) -> None:
    """Build the compact legacy palette used by placed legend devices."""
    colors = [shade(body, 1.0), shade(body, 0.55), shade(accent, 1.0), shade(accent, 1.35)]
    pixels: list[tuple[int, int, int, int]] = []
    for y in range(16):
        for x in range(16):
            quadrant = (x // 8) + 2 * (y // 8)
            local_x = x % 8
            local_y = y % 8
            color = list(colors[quadrant])
            variation = ((x * 5 + y * 3 + seed) % 5 - 2) * 3
            for index in range(3):
                color[index] = max(0, min(255, color[index] + variation))
            if local_x in (0, 7) or local_y in (0, 7):
                color[:3] = [round(channel * 0.72) for channel in color[:3]]
            elif local_y == 1:
                color[:3] = [min(255, round(channel * 1.12)) for channel in color[:3]]
            elif quadrant < 2 and local_y in (4, 5) and (local_x + seed) % 3 == 0:
                color[:3] = [round(channel * 0.55) for channel in color[:3]]
            elif quadrant >= 2 and (local_x + local_y + seed) % 7 == 0:
                color[:3] = [min(255, round(channel * 1.18)) for channel in color[:3]]
            pixels.append(tuple(color))
    png(path, 16, 16, pixels)


def weapon_texture(path: Path, surface: Surface, seed: int) -> None:
    """Build a 32px four-material atlas with weapon-specific surface cues."""
    body, dark, accent, light, style = surface
    colors = [body, dark, accent, light]
    pixels: list[tuple[int, int, int, int]] = []
    for y in range(32):
        for x in range(32):
            quadrant = (x // 16) + 2 * (y // 16)
            local_x = x % 16
            local_y = y % 16
            color = list(colors[quadrant])
            variation = ((x * 11 + y * 7 + seed * 5) % 9 - 4) * 2
            color = [max(0, min(255, channel + variation)) for channel in color]

            if local_x in (0, 15) or local_y in (0, 15):
                color = [round(channel * 0.64) for channel in color]
            elif local_y == 1:
                color = [min(255, round(channel * 1.16)) for channel in color]
            elif quadrant == 0:
                seam_x = 5 + seed % 5
                if local_x == seam_x or (local_y == 10 and 2 < local_x < 14):
                    color = [round(channel * 0.68) for channel in color]
                elif (local_x, local_y) in ((2, 3), (13, 3), (2, 13), (13, 13)):
                    color = [min(255, round(channel * 1.3)) for channel in color]
                elif style == "precision" and local_y in (4, 5):
                    color = [min(255, round(channel * 1.08)) for channel in color]
                elif style == "legacy" and (local_y + seed) % 5 == 0:
                    color = [round(channel * 0.84) for channel in color]
            elif quadrant == 1:
                if (local_x + seed) % 4 == 0:
                    color = [round(channel * 0.72) for channel in color]
                elif local_y in (4, 11):
                    color = [min(255, round(channel * 1.12)) for channel in color]
            elif quadrant == 2:
                if style == "industrial" and (local_x + local_y + seed) % 8 in (0, 1):
                    color = [round(channel * 0.66) for channel in color]
                elif style == "energy" and (local_x == 7 or local_y == 8):
                    color = [min(255, round(channel * 1.22)) for channel in color]
                elif style == "precision" and local_x in (4, 11):
                    color = [min(255, round(channel * 1.16)) for channel in color]
                elif style == "polymer" and (local_x + local_y) % 5 == 0:
                    color = [round(channel * 0.78) for channel in color]
                elif style == "legacy" and local_y in (5, 9):
                    color = [round(channel * 0.75) for channel in color]
            else:
                if style == "energy":
                    distance = abs(local_x - 7.5) + abs(local_y - 7.5)
                    factor = max(0.72, 1.38 - distance * 0.055)
                    color = [min(255, round(channel * factor)) for channel in color]
                    if local_x in (3, 12) or local_y in (3, 12):
                        color = [round(channel * 0.78) for channel in color]
                elif (local_x - local_y + seed) % 9 in (0, 1):
                    color = [min(255, round(channel * 1.16)) for channel in color]
            pixels.append((*color, 255))
    png(path, 32, 32, pixels)


def cube(start: list[float], end: list[float], patch: str = "body", rotation: dict | None = None) -> dict:
    """Return one Minecraft model element using a named texture quadrant."""
    uv = {"body": [0, 0, 8, 8], "dark": [8, 0, 16, 8], "accent": [0, 8, 8, 16], "light": [8, 8, 16, 16]}[patch]
    result = {
        "from": start,
        "to": end,
        "faces": {face: {"uv": uv, "texture": "#layer0"} for face in ("north", "east", "south", "west", "up", "down")},
    }
    if rotation:
        result["rotation"] = rotation
    return result


def device_model_for(device_id: str) -> dict:
    """Build a compact placed-device silhouette with a usable head transform."""
    display = {
        "thirdperson_righthand": {"rotation": [0, 45, 0], "translation": [0, 2, 0], "scale": [0.65, 0.65, 0.65]},
        "thirdperson_lefthand": {"rotation": [0, -45, 0], "translation": [0, 2, 0], "scale": [0.65, 0.65, 0.65]},
        "firstperson_righthand": {"rotation": [0, 45, 0], "translation": [0, 2, 0], "scale": [0.75, 0.75, 0.75]},
        "firstperson_lefthand": {"rotation": [0, -45, 0], "translation": [0, 2, 0], "scale": [0.75, 0.75, 0.75]},
        "gui": {"rotation": [25, 145, 0], "translation": [0, 0, 0], "scale": [0.85, 0.85, 0.85]},
        "ground": {"translation": [0, 2, 0], "scale": [0.65, 0.65, 0.65]},
        "fixed": {"rotation": [0, 45, 0], "scale": [0.8, 0.8, 0.8]},
    }
    if device_id == "caustic_trap":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -24, 0], "scale": [1.0, 1.0, 1.0]}
        elements = [
            cube([3.5, 0, 3.5], [12.5, 2, 12.5], "dark"),
            cube([5, 2, 5], [11, 12, 11], "body"),
            cube([4.5, 12, 4.5], [11.5, 14, 11.5], "dark"),
            cube([5.5, 14, 5.5], [10.5, 15, 10.5], "accent"),
            cube([4.4, 4, 4.2], [5.2, 11, 5], "accent"),
            cube([10.8, 4, 11], [11.6, 11, 11.8], "accent"),
            cube([2.5, 6, 6.5], [5, 9, 9.5], "light"),
            cube([11, 6, 6.5], [13.5, 9, 9.5], "light"),
        ]
    elif device_id == "horizon_newt":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -6, 0], "scale": [1.0, 1.0, 1.0]}
        elements = [
            cube([5, 5, 5], [11, 11, 11], "body"),
            cube([6.5, 6.5, 3], [9.5, 9.5, 13], "accent"),
            cube([3, 6.5, 6.5], [13, 9.5, 9.5], "accent"),
            cube([6.5, 3, 6.5], [9.5, 13, 9.5], "dark"),
            cube([1.5, 7, 7], [4.5, 9, 9], "light"),
            cube([11.5, 7, 7], [14.5, 9, 9], "light"),
            cube([7, 7, 1.5], [9, 9, 4.5], "light"),
            cube([7, 7, 11.5], [9, 9, 14.5], "light"),
            cube([7, 7, 7], [9, 9, 9], "light"),
        ]
    elif device_id == "octane_pad":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -9, 0], "scale": [1.35, 1.35, 1.35]}
        elements = [
            cube([1, 1, 3], [15, 3, 13], "dark"),
            cube([2, 3, 4], [14, 4.5, 12], "body"),
            cube([3, 4.5, 5], [13, 5.4, 11], "accent"),
            cube([5, 5.4, 6.3], [11, 6.1, 9.7], "light"),
            cube([1.3, 0, 4], [3, 1.5, 6], "body"),
            cube([13, 0, 10], [14.7, 1.5, 12], "body"),
        ]
    elif device_id == "axle_gate":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -15, 0], "scale": [1.15, 1.15, 1.15]}
        elements = [
            cube([1, 0, 6], [4, 14, 10], "body"),
            cube([12, 0, 6], [15, 14, 10], "body"),
            cube([3, 12, 6], [13, 15, 10], "dark"),
            cube([4, 2, 7], [5, 12, 9], "accent"),
            cube([11, 2, 7], [12, 12, 9], "accent"),
            cube([5, 12, 7], [11, 13.5, 9], "light"),
            cube([0, 0, 5], [5, 2, 11], "dark"),
            cube([11, 0, 5], [16, 2, 11], "dark"),
        ]
    elif device_id == "ash_portal":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -14, 0], "scale": [1.15, 1.15, 1.15]}
        elements = [
            cube([1, 1, 6], [4, 6, 10], "dark"),
            cube([1, 10, 6], [4, 15, 10], "dark"),
            cube([12, 1, 6], [15, 6, 10], "dark"),
            cube([12, 10, 6], [15, 15, 10], "dark"),
            cube([3, 0, 6.5], [13, 3, 9.5], "body"),
            cube([3, 13, 6.5], [13, 16, 9.5], "body"),
            cube([2.5, 5, 7], [4.5, 11, 9], "accent"),
            cube([11.5, 5, 7], [13.5, 11, 9], "accent"),
            cube([7, 0.5, 5.5], [9, 3.5, 10.5], "light"),
            cube([7, 12.5, 5.5], [9, 15.5, 10.5], "light"),
        ]
    elif device_id == "gibraltar_dome":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -10, 0], "scale": [1.25, 1.25, 1.25]}
        elements = [
            cube([3, 0, 3], [13, 2, 13], "dark"),
            cube([5, 2, 5], [11, 7, 11], "body"),
            cube([6, 7, 6], [10, 11, 10], "accent"),
            cube([7, 11, 7], [9, 14, 9], "light"),
            cube([1.5, 1, 6.5], [5, 4, 9.5], "body"),
            cube([11, 1, 6.5], [14.5, 4, 9.5], "body"),
        ]
    elif device_id == "lifeline_doc":
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -7, 0], "scale": [1.3, 1.3, 1.3]}
        elements = [
            cube([4, 5, 4], [12, 11, 12], "body"),
            cube([5.5, 6.5, 2], [10.5, 9.5, 14], "dark"),
            cube([2, 6, 6], [5, 10, 10], "accent"),
            cube([11, 6, 6], [14, 10, 10], "accent"),
            cube([6.5, 11, 6.5], [9.5, 13.5, 9.5], "light"),
            cube([6.5, 2.5, 6.5], [9.5, 5, 9.5], "dark"),
        ]
    else:
        display["head"] = {"rotation": [0, 180, 0], "translation": [0, -14, 0], "scale": [1.2, 1.2, 1.2]}
        elements = [
            cube([2, 0, 2], [14, 2, 14], "dark"),
            cube([5, 2, 5], [11, 13, 11], "body"),
            cube([3, 11, 3], [13, 14, 13], "accent"),
            cube([1, 13, 6.5], [15, 15, 9.5], "light"),
            cube([6.5, 13, 1], [9.5, 15, 15], "light"),
            cube([6.5, 15, 6.5], [9.5, 16, 9.5], "accent"),
        ]
    return {"credit": "Generated by Lapex", "ambientocclusion": False, "gui_light": "front", "textures": {"layer0": ""}, "elements": elements, "display": display}


def pack_icon() -> None:
    """Create the small Lapex pack icon without storing a source bitmap."""
    pixels = []
    for y in range(64):
        for x in range(64):
            edge = min(x, y, 63 - x, 63 - y)
            base = (26, 30, 34) if edge > 2 else (196, 58, 49)
            mark = (14 <= x <= 22 and 13 <= y <= 50) or (22 <= x <= 48 and 43 <= y <= 51) or (39 <= x <= 48 and 34 <= y <= 43)
            pixels.append((*((224, 75, 58) if mark else base), 255))
    png(PACK / "pack.png", 64, 64, pixels)


def main() -> None:
    write_json(PACK / "pack.mcmeta", {"pack": {"description": "Lapex Weapon-Specific 3D Arsenal for Minecraft 26.1.2", "min_format": [84, 0], "max_format": [84, 0]}})
    # Remove obsolete generated entries before rebuilding so renames cannot
    # leave client-visible models behind.
    obsolete_items = PACK / "assets/lapex/items"
    if obsolete_items.exists():
        for generated in obsolete_items.glob("*.json"):
            generated.unlink()
        obsolete_items.rmdir()
    entries = []
    weapon_ids = {weapon_id for weapon_id, *_ in WEAPONS}
    validate_weapon_item_contract()
    validate_weapon_blueprints(weapon_ids)
    generated_ids = weapon_ids | {device_id for device_id, *_ in DEVICES}
    for generated in (PACK / "assets/lapex/models/item").glob("*.json"):
        if generated.stem not in generated_ids:
            generated.unlink()
    for generated in (PACK / "assets/lapex/textures/item").glob("*.png"):
        if generated.stem not in generated_ids:
            generated.unlink()
    for weapon_id, custom_model_data, family in WEAPONS:
        entries.append({"threshold": custom_model_data, "model": {"type": "minecraft:model", "model": f"lapex:item/{weapon_id}"}})
        model = weapon_model_for(weapon_id, family)
        write_json(PACK / "assets/lapex/models/item" / f"{weapon_id}.json", model)
        weapon_texture(PACK / "assets/lapex/textures/item" / f"{weapon_id}.png", WEAPON_SURFACES[weapon_id], stable_seed(weapon_id))
    entries.append({"threshold": 1033, "model": {"type": "minecraft:model", "model": "minecraft:item/carrot_on_a_stick"}})
    for index, (device_id, custom_model_data, body, accent) in enumerate(DEVICES):
        entries.append({"threshold": custom_model_data, "model": {"type": "minecraft:model", "model": f"lapex:item/{device_id}"}})
        model = device_model_for(device_id)
        model["textures"]["layer0"] = f"lapex:item/{device_id}"
        write_json(PACK / "assets/lapex/models/item" / f"{device_id}.json", model)
        palette_texture(PACK / "assets/lapex/textures/item" / f"{device_id}.png", body, accent, 100 + index)
    entries.append({"threshold": max(custom_model_data for _, custom_model_data, *_ in DEVICES) + 1, "model": {"type": "minecraft:model", "model": "minecraft:item/carrot_on_a_stick"}})
    write_json(
        PACK / "assets/minecraft/items/carrot_on_a_stick.json",
        {
            "model": {
                "type": "minecraft:range_dispatch",
                "property": "minecraft:custom_model_data",
                "index": 0,
                "entries": entries,
                "fallback": {"type": "minecraft:model", "model": "minecraft:item/carrot_on_a_stick"},
            }
        },
    )
    pack_icon()
    print(f"Built {len(WEAPONS)} weapon and {len(DEVICES)} device models in {PACK}")


if __name__ == "__main__":
    main()
