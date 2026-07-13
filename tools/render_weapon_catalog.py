#!/usr/bin/env python3
"""Render a dependency-free oblique catalog from generated weapon assets."""

from __future__ import annotations

import argparse
import json
import math
import struct
import zlib
from html import escape
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "resource-pack"
WIDTH = 2400
HEIGHT = 800
VIEW = (1.0, 0.18, 0.35)

# vertex indexes, outward normal, light factor
FACES = (
    ((0, 1, 3, 2), (0.0, 0.0, -1.0), 0.68),
    ((4, 6, 7, 5), (0.0, 0.0, 1.0), 0.90),
    ((0, 2, 6, 4), (-1.0, 0.0, 0.0), 0.70),
    ((1, 5, 7, 3), (1.0, 0.0, 0.0), 0.82),
    ((0, 4, 5, 1), (0.0, -1.0, 0.0), 0.58),
    ((2, 3, 7, 6), (0.0, 1.0, 0.0), 1.08),
)


def dot(left: tuple[float, float, float], right: tuple[float, float, float]) -> float:
    return sum(a * b for a, b in zip(left, right))


def turn_coordinates(coordinates: tuple[float, float, float], axis: str, angle: float) -> tuple[float, float, float]:
    """Rotate coordinates around zero using vanilla model rotation direction."""
    x, y, z = coordinates
    radians = math.radians(angle)
    cosine = math.cos(radians)
    sine = math.sin(radians)
    if axis == "x":
        y, z = y * cosine - z * sine, y * sine + z * cosine
    elif axis == "y":
        x, z = x * cosine + z * sine, -x * sine + z * cosine
    else:
        x, y = x * cosine - y * sine, x * sine + y * cosine
    return x, y, z


def rotate_point(point: tuple[float, float, float], turn: dict | None) -> tuple[float, float, float]:
    if not turn:
        return point
    origin = tuple(turn["origin"])
    relative = tuple(value - pivot for value, pivot in zip(point, origin))
    rotated = turn_coordinates(relative, turn["axis"], turn["angle"])
    return tuple(value + pivot for value, pivot in zip(rotated, origin))


def rotate_normal(normal: tuple[float, float, float], turn: dict | None) -> tuple[float, float, float]:
    if not turn:
        return normal
    return turn_coordinates(normal, turn["axis"], turn["angle"])


def project(point: tuple[float, float, float]) -> tuple[float, float]:
    x, y, z = point
    return (z - x * 0.35) * 8, (-y + x * 0.18) * 8


def read_png_palette(path: Path) -> dict[str, tuple[int, int, int]]:
    """Read the four atlas centers from the filter-zero RGBA PNGs we generate."""
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"Not a PNG: {path}")
    offset = 8
    width = height = 0
    compressed: list[bytes] = []
    while offset < len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        chunk_type = data[offset + 4 : offset + 8]
        payload = data[offset + 8 : offset + 8 + length]
        if chunk_type == b"IHDR":
            width, height, depth, color_type, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if (depth, color_type, compression, filtering, interlace) != (8, 6, 0, 0, 0):
                raise ValueError(f"Unsupported generated PNG layout: {path}")
        elif chunk_type == b"IDAT":
            compressed.append(payload)
        offset += length + 12
    if width != 32 or height != 32:
        raise ValueError(f"Weapon catalog expects a 32px atlas: {path}")
    pixels = zlib.decompress(b"".join(compressed))
    row_size = 1 + width * 4
    if any(pixels[row * row_size] != 0 for row in range(height)):
        raise ValueError(f"Weapon catalog expects filter-zero rows: {path}")

    def sample(x: int, y: int) -> tuple[int, int, int]:
        position = y * row_size + 1 + x * 4
        return tuple(pixels[position : position + 3])

    return {
        "body": sample(8, 8),
        "dark": sample(24, 8),
        "accent": sample(8, 24),
        "light": sample(24, 24),
    }


def patch_for(element: dict) -> str:
    u, v, *_ = element["faces"]["north"]["uv"]
    return {
        (0, 0): "body",
        (8, 0): "dark",
        (0, 8): "accent",
        (8, 8): "light",
    }[(u, v)]


def rgb(color: tuple[int, int, int], factor: float) -> str:
    channels = [max(0, min(255, round(channel * factor))) for channel in color]
    return f"rgb({','.join(str(channel) for channel in channels)})"


def weapon_ids() -> list[str]:
    dispatcher = json.loads((PACK / "assets/minecraft/items/carrot_on_a_stick.json").read_text(encoding="utf-8"))
    entries = dispatcher["model"]["entries"]
    return [
        entry["model"]["model"].split("/")[-1]
        for entry in entries
        if 1001 <= entry["threshold"] <= 1032
    ]


def element_vertices(element: dict) -> list[tuple[float, float, float]]:
    x1, y1, z1 = element["from"]
    x2, y2, z2 = element["to"]
    vertices = (
        (x1, y1, z1),
        (x2, y1, z1),
        (x1, y2, z1),
        (x2, y2, z1),
        (x1, y1, z2),
        (x2, y1, z2),
        (x1, y2, z2),
        (x2, y2, z2),
    )
    return [rotate_point(vertex, element.get("rotation")) for vertex in vertices]


def render(output: Path) -> None:
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">',
        f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#17191d"/>',
    ]
    for index, weapon_id in enumerate(weapon_ids()):
        model_path = PACK / "assets/lapex/models/item" / f"{weapon_id}.json"
        texture_path = PACK / "assets/lapex/textures/item" / f"{weapon_id}.png"
        model = json.loads(model_path.read_text(encoding="utf-8"))
        palette = read_png_palette(texture_path)
        faces: list[tuple[float, list[tuple[float, float, float]], str]] = []
        for element in model["elements"]:
            vertices = element_vertices(element)
            patch = patch_for(element)
            for indexes, normal, shade in FACES:
                turned_normal = rotate_normal(normal, element.get("rotation"))
                if dot(turned_normal, VIEW) <= 0:
                    continue
                points = [vertices[vertex] for vertex in indexes]
                depth = sum(dot(point, VIEW) for point in points) / len(points)
                faces.append((depth, points, rgb(palette[patch], shade)))
        faces.sort(key=lambda face: face[0])
        column = index % 8
        row = index // 8
        origin_x = column * 300 + 82
        origin_y = row * 200 + 142
        svg.append("<g>")
        for _, points, fill in faces:
            polygon = " ".join(
                f"{origin_x + projected_x:.1f},{origin_y + projected_y:.1f}"
                for projected_x, projected_y in (project(point) for point in points)
            )
            svg.append(
                f'<polygon points="{polygon}" fill="{fill}" stroke="#0c0e10" '
                'stroke-width="1" stroke-linejoin="round"/>'
            )
        label_x = column * 300 + 150
        label_y = row * 200 + 188
        svg.append(
            f'<text x="{label_x}" y="{label_y}" fill="#f2f4f5" font-family="sans-serif" '
            f'font-size="18" text-anchor="middle">{escape(weapon_id)}</text>'
        )
        svg.append("</g>")
    svg.append("</svg>")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(svg) + "\n", encoding="ascii")
    print(f"Rendered {len(weapon_ids())} weapon previews to {output}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "output",
        nargs="?",
        type=Path,
        default=ROOT / "artifacts" / "weapon_catalog.svg",
        help="SVG output path (default: artifacts/weapon_catalog.svg)",
    )
    render(parser.parse_args().output.resolve())


if __name__ == "__main__":
    main()
