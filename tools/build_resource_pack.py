#!/usr/bin/env python3
"""Build the Minecraft 26.1 Lapex weapon resource pack without dependencies."""

from __future__ import annotations

import json
import struct
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "resource-pack"

# id, custom model data, family, body RGB, accent RGB
WEAPONS = [
    ("havoc", 1001, "ar", (48, 67, 68), (77, 226, 218)),
    ("flatline", 1002, "ar", (67, 61, 55), (183, 126, 75)),
    ("hemlok_breach", 1003, "ar", (54, 57, 61), (186, 142, 83)),
    ("r301", 1004, "ar", (191, 194, 188), (235, 142, 48)),
    ("nemesis", 1005, "ar", (44, 53, 61), (61, 210, 225)),
    ("alternator", 1006, "smg", (76, 74, 68), (224, 177, 83)),
    ("prowler", 1007, "smg", (52, 48, 47), (160, 113, 72)),
    ("r99", 1008, "smg", (205, 207, 199), (239, 167, 53)),
    ("volt", 1009, "smg", (39, 62, 65), (48, 205, 220)),
    ("car", 1010, "smg", (48, 49, 47), (181, 151, 91)),
    ("devotion", 1011, "lmg", (45, 58, 61), (58, 213, 220)),
    ("lstar", 1012, "lmg", (72, 50, 52), (223, 65, 62)),
    ("spitfire", 1013, "lmg", (78, 73, 62), (217, 173, 82)),
    ("rampage", 1014, "lmg", (62, 52, 47), (213, 105, 48)),
    ("g7_scout", 1015, "marksman", (161, 157, 141), (223, 174, 72)),
    ("triple_take", 1016, "marksman", (44, 61, 65), (53, 199, 210)),
    ("repeater_3030", 1017, "marksman", (72, 55, 43), (180, 128, 67)),
    ("bocek", 1018, "bow", (52, 43, 37), (54, 190, 178)),
    ("charge_rifle", 1019, "sniper", (176, 180, 174), (231, 122, 47)),
    ("longbow", 1020, "sniper", (43, 47, 52), (64, 137, 190)),
    ("kraber", 1021, "sniper", (54, 43, 44), (180, 53, 48)),
    ("sentinel", 1022, "sniper", (183, 187, 182), (55, 133, 204)),
    ("eva8", 1023, "shotgun", (55, 49, 49), (199, 60, 56)),
    ("mastiff", 1024, "shotgun", (77, 76, 71), (195, 70, 55)),
    ("mozambique", 1025, "pistol", (75, 75, 70), (221, 120, 47)),
    ("peacekeeper", 1026, "shotgun", (50, 67, 65), (204, 65, 61)),
    ("re45_burst", 1027, "pistol", (45, 49, 55), (51, 132, 202)),
    ("p2020", 1028, "pistol", (48, 49, 47), (190, 157, 91)),
    ("wingman", 1029, "pistol", (63, 61, 60), (177, 57, 51)),
    ("sheila", 1030, "minigun", (61, 48, 47), (207, 56, 51)),
    ("a13_sentry", 1031, "sniper", (190, 191, 183), (204, 48, 62)),
    ("whistler", 1032, "pistol", (52, 50, 47), (229, 111, 45)),
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


def weapon_texture(path: Path, body: tuple[int, int, int], accent: tuple[int, int, int], seed: int) -> None:
    """Build four reusable material tiles with deterministic panel details."""
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


def model_for(family: str, variant: int) -> dict:
    """Build a family silhouette plus deterministic per-weapon geometry accents."""
    display = {
        "thirdperson_righthand": {"rotation": [0, -90, 15], "translation": [0, 2.5, 1], "scale": [0.7, 0.7, 0.7]},
        "thirdperson_lefthand": {"rotation": [0, 90, -15], "translation": [0, 2.5, 1], "scale": [0.7, 0.7, 0.7]},
        "firstperson_righthand": {"rotation": [0, -92, 4], "translation": [1.25, 3.2, 1.4], "scale": [0.92, 0.92, 0.92]},
        "firstperson_lefthand": {"rotation": [0, 92, -4], "translation": [1.25, 3.2, 1.4], "scale": [0.92, 0.92, 0.92]},
        "gui": {"rotation": [25, 145, 0], "translation": [0, 0, 0], "scale": [0.9, 0.9, 0.9]},
        "ground": {"translation": [0, 2, 0], "scale": [0.5, 0.5, 0.5]},
        "fixed": {"rotation": [0, 90, 0], "scale": [0.8, 0.8, 0.8]},
    }
    if family == "bow":
        elements = [
            cube([7.2, 3, 6.5], [8.8, 13, 8.5], "body"),
            cube([6.2, 12, 6.8], [9.8, 14.2, 8.2], "accent", {"origin": [8, 12, 8], "axis": "z", "angle": 22.5}),
            cube([6.2, 1.8, 6.8], [9.8, 4, 8.2], "accent", {"origin": [8, 4, 8], "axis": "z", "angle": -22.5}),
            cube([7.6, 7, 0], [8.4, 8, 14], "light"),
        ]
    elif family == "pistol":
        barrel_start = -1 - (variant % 3) * 0.45
        elements = [
            cube([5, 7, 4], [11, 11, 13], "body"),
            cube([6.4, 8, barrel_start], [9.6, 9.5, 5], "dark"),
            cube([6.2, 2.5, 8], [9.8, 7.5, 11], "dark", {"origin": [8, 7.5, 10], "axis": "x", "angle": -22.5}),
            cube([6, 10.8, 6.5], [10, 11.8, 9], "accent"),
        ]
        if variant % 2 == 0:
            elements.append(cube([7.1, 11.7, 7], [8.9, 12.6, 9], "light"))
        else:
            elements.append(cube([5.2, 8.2, 10.5], [6, 10.2, 12.5], "accent"))
    elif family == "minigun":
        elements = [
            cube([3.5, 6, 5], [12.5, 12.5, 14], "body"),
            cube([5, 4, 8], [11, 7, 12], "dark"),
            cube([4.8, 7, -1], [6.1, 8.2, 6], "dark"),
            cube([7.3, 9, -1], [8.7, 10.2, 6], "accent"),
            cube([9.9, 7, -1], [11.2, 8.2, 6], "dark"),
            cube([5.5, 12.5, 7], [10.5, 14, 10], "accent"),
        ]
    else:
        dimensions = {
            "smg": (5.0, 11.0, 12.5, 2.8, False),
            "ar": (4.5, 11.5, 13.5, 3.2, True),
            "lmg": (3.8, 12.2, 14.5, 4.2, True),
            "marksman": (4.6, 11.4, 14.5, 2.4, True),
            "sniper": (4.3, 11.7, 15.5, 2.2, True),
            "shotgun": (4.0, 12.0, 14.0, 4.6, True),
        }
        x1, x2, rear, barrel, stock = dimensions[family]
        rear += (variant % 3) * 0.3
        barrel += (variant % 2) * 0.35
        elements = [
            cube([x1, 7, 5], [x2, 11.5, rear], "body"),
            cube([8 - barrel / 2, 8.1, -1], [8 + barrel / 2, 9.6, 6], "dark"),
            cube([6.5, 3, 7], [9.5, 7.5, 10], "dark", {"origin": [8, 7.5, 9], "axis": "x", "angle": -22.5}),
            cube([6, 4.2, 5.7], [10, 7.2, 8.2], "accent", {"origin": [8, 7, 7], "axis": "x", "angle": 22.5}),
            cube([6.4, 11.4, 7], [9.6, 13, 10.5], "light"),
        ]
        if stock:
            elements.append(cube([5.2, 7.4, rear - 0.5], [10.8, 10.7, 16], "dark"))
        if family in ("marksman", "sniper"):
            elements.append(cube([5.5, 12.4, 5.8], [10.5, 14.2, 11.5], "accent"))
        if family == "shotgun":
            elements.append(cube([4.5, 6.1, 5.3], [11.5, 7.2, 12.5], "accent"))
        sight_style = variant % 3
        if sight_style == 0:
            elements.append(cube([7.2, 12.8, 6.8], [8.8, 14.2, 9.2], "light"))
        elif sight_style == 1:
            elements.extend([
                cube([5.6, 12.5, 6.5], [6.5, 13.7, 7.5], "light"),
                cube([9.5, 12.5, 6.5], [10.4, 13.7, 7.5], "light"),
            ])
        else:
            elements.append(cube([6.2, 12.5, 7], [9.8, 13.4, 11], "accent"))
        signature_x = 4.3 + (variant % 5) * 0.45
        elements.append(cube([signature_x, 8, 5.2], [signature_x + 0.55, 10.5, 8.8], "accent"))
    return {"credit": "Generated by Lapex", "ambientocclusion": False, "gui_light": "front", "textures": {"layer0": ""}, "elements": elements, "display": display}


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
    write_json(PACK / "pack.mcmeta", {"pack": {"description": "Lapex 3D Arsenal and Legend Devices for Minecraft 26.1.2", "min_format": [84, 0], "max_format": [84, 0]}})
    # Remove obsolete generated entries before rebuilding so renames cannot
    # leave client-visible models behind.
    obsolete_items = PACK / "assets/lapex/items"
    if obsolete_items.exists():
        for generated in obsolete_items.glob("*.json"):
            generated.unlink()
        obsolete_items.rmdir()
    entries = []
    generated_ids = {weapon_id for weapon_id, *_ in WEAPONS} | {device_id for device_id, *_ in DEVICES}
    for generated in (PACK / "assets/lapex/models/item").glob("*.json"):
        if generated.stem not in generated_ids:
            generated.unlink()
    for generated in (PACK / "assets/lapex/textures/item").glob("*.png"):
        if generated.stem not in generated_ids:
            generated.unlink()
    for index, (weapon_id, custom_model_data, family, body, accent) in enumerate(WEAPONS):
        entries.append({"threshold": custom_model_data, "model": {"type": "minecraft:model", "model": f"lapex:item/{weapon_id}"}})
        model = model_for(family, index)
        model["textures"]["layer0"] = f"lapex:item/{weapon_id}"
        write_json(PACK / "assets/lapex/models/item" / f"{weapon_id}.json", model)
        weapon_texture(PACK / "assets/lapex/textures/item" / f"{weapon_id}.png", body, accent, index)
    entries.append({"threshold": 1033, "model": {"type": "minecraft:model", "model": "minecraft:item/carrot_on_a_stick"}})
    for index, (device_id, custom_model_data, body, accent) in enumerate(DEVICES):
        entries.append({"threshold": custom_model_data, "model": {"type": "minecraft:model", "model": f"lapex:item/{device_id}"}})
        model = device_model_for(device_id)
        model["textures"]["layer0"] = f"lapex:item/{device_id}"
        write_json(PACK / "assets/lapex/models/item" / f"{device_id}.json", model)
        weapon_texture(PACK / "assets/lapex/textures/item" / f"{device_id}.png", body, accent, 100 + index)
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
