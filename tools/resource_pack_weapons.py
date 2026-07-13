"""Original low-poly Lapex gun geometry and material direction.

The shapes use Apex gameplay footage only as proportion and silhouette study.
They are intentionally simplified Minecraft adaptations and contain no copied
game meshes or textures. Keep every model inside the practical -16..32 item
model coordinate range so all display contexts remain renderable.
"""

from __future__ import annotations


RGB = tuple[int, int, int]
Surface = tuple[RGB, RGB, RGB, RGB, str]


# body, dark hardware, painted accent, bright detail, material treatment
WEAPON_SURFACES: dict[str, Surface] = {
    "havoc": ((48, 67, 68), (20, 28, 30), (49, 156, 161), (104, 239, 226), "energy"),
    "flatline": ((67, 61, 55), (27, 28, 28), (151, 101, 63), (215, 167, 91), "industrial"),
    "hemlok_breach": ((54, 57, 61), (23, 27, 30), (130, 43, 48), (224, 83, 70), "industrial"),
    "r301": ((178, 183, 180), (39, 45, 48), (55, 119, 148), (224, 145, 67), "precision"),
    "nemesis": ((166, 157, 137), (27, 34, 40), (43, 149, 165), (93, 235, 241), "energy"),
    "alternator": ((76, 74, 68), (30, 31, 31), (189, 145, 73), (238, 197, 108), "industrial"),
    "prowler": ((52, 48, 47), (22, 23, 24), (128, 86, 58), (201, 140, 78), "polymer"),
    "r99": ((197, 202, 199), (38, 43, 45), (68, 118, 139), (238, 165, 63), "precision"),
    "volt": ((174, 184, 181), (25, 35, 39), (39, 150, 160), (81, 229, 234), "energy"),
    "car": ((48, 49, 47), (20, 23, 24), (137, 113, 73), (211, 181, 108), "industrial"),
    "devotion": ((45, 58, 61), (19, 27, 29), (45, 151, 158), (83, 229, 233), "energy"),
    "lstar": ((72, 50, 52), (29, 24, 27), (174, 50, 49), (244, 91, 76), "energy"),
    "spitfire": ((78, 73, 62), (29, 31, 29), (172, 133, 67), (231, 191, 104), "industrial"),
    "rampage": ((62, 52, 47), (28, 27, 25), (179, 79, 38), (244, 135, 60), "industrial"),
    "g7_scout": ((154, 153, 143), (39, 42, 40), (168, 126, 54), (229, 188, 93), "precision"),
    "triple_take": ((44, 61, 65), (19, 27, 30), (41, 145, 155), (77, 222, 226), "energy"),
    "repeater_3030": ((72, 55, 43), (31, 29, 27), (145, 93, 49), (202, 148, 78), "legacy"),
    "bocek": ((52, 43, 37), (24, 25, 25), (38, 139, 132), (82, 211, 194), "legacy"),
    "charge_rifle": ((176, 180, 174), (42, 47, 49), (185, 83, 37), (244, 146, 63), "energy"),
    "longbow": ((43, 47, 52), (19, 23, 27), (49, 105, 145), (92, 168, 210), "precision"),
    "kraber": ((54, 43, 44), (23, 23, 26), (139, 40, 39), (216, 75, 66), "industrial"),
    "sentinel": ((183, 187, 182), (39, 46, 52), (46, 105, 157), (89, 169, 219), "precision"),
    "eva8": ((55, 49, 49), (24, 25, 27), (161, 45, 43), (224, 87, 70), "industrial"),
    "mastiff": ((77, 76, 71), (28, 30, 31), (161, 51, 42), (224, 91, 68), "industrial"),
    "mozambique": ((75, 75, 70), (29, 31, 32), (184, 88, 37), (235, 146, 62), "polymer"),
    "peacekeeper": ((50, 67, 65), (24, 29, 31), (163, 48, 47), (231, 91, 76), "industrial"),
    "re45_burst": ((45, 49, 55), (20, 24, 29), (43, 101, 151), (86, 168, 219), "precision"),
    "p2020": ((48, 49, 47), (21, 24, 25), (142, 116, 66), (211, 178, 105), "polymer"),
    "wingman": ((63, 61, 60), (24, 24, 26), (139, 42, 39), (211, 80, 66), "industrial"),
    "sheila": ((61, 48, 47), (25, 25, 28), (164, 43, 42), (233, 84, 67), "industrial"),
    "a13_sentry": ((190, 191, 183), (39, 44, 48), (157, 38, 52), (228, 79, 91), "precision"),
    "whistler": ((180, 172, 149), (24, 26, 27), (160, 116, 49), (235, 99, 47), "industrial"),
}

SURFACE_STYLES = {"energy", "industrial", "precision", "polymer", "legacy"}


PATCH_UVS = {
    "body": [0, 0, 8, 8],
    "dark": [8, 0, 16, 8],
    "accent": [0, 8, 8, 16],
    "light": [8, 8, 16, 16],
}


def clean_number(value: float) -> int | float:
    """Keep generated JSON readable after fractional coordinate arithmetic."""
    rounded = round(value, 3)
    return int(rounded) if float(rounded).is_integer() else rounded


def clean_vector(values: list[float]) -> list[int | float]:
    return [clean_number(value) for value in values]


def rotation(axis: str, angle: float, origin: list[float]) -> dict:
    """Return one legal vanilla item-model element rotation."""
    return {"origin": clean_vector(origin), "axis": axis, "angle": angle}


def cube(start: list[float], end: list[float], patch: str = "body", turn: dict | None = None) -> dict:
    """Create a textured cuboid used by one weapon blueprint."""
    uv = PATCH_UVS[patch]
    result = {
        "from": clean_vector(start),
        "to": clean_vector(end),
        "faces": {face: {"uv": uv, "texture": "#layer0"} for face in ("north", "east", "south", "west", "up", "down")},
    }
    if turn:
        result["rotation"] = turn
    return result


def barrel(z_front: float, z_back: float, width: float = 2.4, height: float = 1.5, y: float = 8.8, patch: str = "dark", x: float = 8) -> dict:
    """Create a centered rectangular barrel or one member of a barrel cluster."""
    return cube([x - width / 2, y - height / 2, z_front], [x + width / 2, y + height / 2, z_back], patch)


def grip(z: float = 10, width: float = 3.2, patch: str = "dark", angle: float = -22.5) -> dict:
    """Create the common swept pistol grip."""
    return cube(
        [8 - width / 2, 2.5, z - 1.1],
        [8 + width / 2, 7.6, z + 1.1],
        patch,
        rotation("x", angle, [8, 7.5, z]),
    )


def magazine(z: float, width: float = 4, depth: float = 2.4, patch: str = "accent", angle: float = 22.5, bottom: float = 3.4) -> dict:
    """Create a forward-swept detachable magazine."""
    return cube(
        [8 - width / 2, bottom, z - depth / 2],
        [8 + width / 2, 7.3, z + depth / 2],
        patch,
        rotation("x", angle, [8, 7.2, z]),
    )


def rail(z_front: float, z_back: float, width: float = 3, y: float = 11.5, patch: str = "dark") -> dict:
    """Create a low top rail that reads clearly in first person."""
    return cube([8 - width / 2, y, z_front], [8 + width / 2, y + 0.8, z_back], patch)


def scope(z_front: float, z_back: float, width: float = 4, y: float = 12.1, patch: str = "accent") -> list[dict]:
    """Create a blocky scope with bright front and rear lens markers."""
    return [
        cube([8 - width / 2, y, z_front], [8 + width / 2, y + 1.8, z_back], patch),
        cube([8 - width * 0.33, y + 0.25, z_front - 0.3], [8 + width * 0.33, y + 1.55, z_front + 0.25], "light"),
        cube([8 - width * 0.38, y + 0.15, z_back - 0.25], [8 + width * 0.38, y + 1.65, z_back + 0.3], "dark"),
    ]


def solid_stock(z_front: float = 12.5, z_back: float = 17, width: float = 5.2, patch: str = "dark") -> dict:
    """Create a full shoulder stock."""
    return cube([8 - width / 2, 7.3, z_front], [8 + width / 2, 10.8, z_back], patch)


def skeleton_stock(z_front: float = 12.5, z_back: float = 17, width: float = 5.2, patch: str = "dark") -> list[dict]:
    """Create an open-frame stock from two struts and a butt plate."""
    return [
        cube([8 - width / 2, 9.8, z_front], [8 + width / 2, 10.8, z_back], patch),
        cube([8 - width / 2, 7.2, z_front], [8 + width / 2, 8.1, z_back], patch),
        cube([8 - width / 2, 6.9, z_back - 0.8], [8 + width / 2, 11.2, z_back], "body"),
    ]


def weapon_elements(weapon_id: str) -> list[dict]:
    """Return the named silhouette blueprint for one playable gun."""
    if weapon_id == "havoc":
        return [
            cube([4.3, 7, 4.2], [11.7, 12, 13.2], "body"),
            cube([4.9, 7.4, 12], [11.1, 10.8, 16.4], "dark"),
            barrel(-2.4, 4.8, 2.5, 1.6),
            cube([6.2, 7.8, -2.8], [9.8, 10.2, -1.5], "accent"),
            grip(10.8),
            cube([5.1, 5.2, 4.8], [10.9, 7.1, 9.2], "accent"),
            cube([5.6, 8.1, 3.3], [10.4, 10.9, 6.1], "light"),
            rail(6.2, 12.2, 2.4, 12),
        ]
    if weapon_id == "flatline":
        return [
            cube([4.1, 7, 4.4], [11.9, 11.5, 13.6], "body"),
            barrel(-2.6, 5.1, 2.6, 1.5),
            cube([6.1, 8, -2.9], [9.9, 10.1, -1.6], "dark"),
            grip(10.2),
            magazine(6.7, 4.2, 2.7, "accent"),
            solid_stock(12.8, 17.2, 5.8, "body"),
            rail(4.8, 13, 3.4, 11.5),
            cube([4.3, 8, 5], [5.1, 10.7, 9], "accent"),
        ]
    if weapon_id == "hemlok_breach":
        return [
            cube([4.2, 7.2, 4.6], [11.8, 11.8, 14.2], "body"),
            barrel(-3.4, 5.2, 2.2, 1.4),
            cube([6.2, 7.8, -3.8], [9.8, 10, -2.5], "dark"),
            grip(9.2),
            magazine(12.2, 4.4, 2.5, "dark", -22.5),
            cube([4.8, 7.5, 13.2], [11.2, 10.7, 17], "dark"),
            rail(5, 13.6, 4, 11.8),
            cube([5.1, 5.1, 4.8], [10.9, 7, 8.8], "accent"),
            cube([6.1, 4, 3.8], [9.9, 5.7, 6.4], "light"),
        ]
    if weapon_id == "r301":
        return [
            cube([4.8, 7.4, 4.5], [11.2, 11.3, 13], "body"),
            barrel(-2.3, 5.2, 2, 1.35),
            cube([6.3, 7.8, 2.2], [9.7, 10.1, 5.6], "body"),
            grip(10.2),
            magazine(6.8, 3.6, 2.2, "accent"),
            *skeleton_stock(12.4, 17, 4.8),
            rail(5, 12.6, 2.8, 11.3, "accent"),
            cube([4.6, 8.2, 6.1], [5.2, 10.5, 9.2], "light"),
        ]
    if weapon_id == "nemesis":
        return [
            cube([4.1, 7, 4.5], [11.9, 12.1, 13.8], "body"),
            barrel(-1.8, 5, 3.3, 1.7, 8.8, "dark"),
            cube([4.8, 7.6, 2.4], [6.4, 10.3, 5.4], "accent"),
            cube([9.6, 7.6, 2.4], [11.2, 10.3, 5.4], "accent"),
            grip(10.5),
            magazine(7.1, 4.6, 2.8, "dark"),
            solid_stock(13, 17.2, 6, "dark"),
            cube([5, 8, 5.5], [11, 11, 8.3], "light"),
            rail(7, 13.3, 3.6, 12.1),
        ]
    if weapon_id == "alternator":
        return [
            cube([4.2, 7, 4.3], [11.8, 11.4, 13], "body"),
            barrel(-2.1, 5, 1.8, 1.6, 9.7, "dark", 6.1),
            barrel(-2.1, 5, 1.8, 1.6, 8.2, "dark", 9.9),
            cube([4.5, 7.6, 2.6], [11.5, 10.6, 5.4], "accent"),
            grip(10.1),
            magazine(7.4, 4.6, 2.7, "dark"),
            rail(6.2, 12.4, 2.6, 11.4),
            cube([5.2, 10.7, 11], [10.8, 12.2, 13.5], "light"),
        ]
    if weapon_id == "prowler":
        return [
            cube([4, 6.8, 4.2], [12, 11.6, 14.3], "body"),
            cube([4.8, 7.5, 2.1], [11.2, 10.5, 5.1], "dark"),
            barrel(-1.7, 2.7, 2.8, 1.6),
            grip(8.8),
            magazine(12.5, 4.4, 2.7, "accent", -22.5),
            cube([4.7, 7.1, 13.4], [11.3, 10.7, 16.2], "dark"),
            rail(5.4, 13.4, 3.2, 11.6),
            cube([4.1, 8, 5.6], [5, 10.5, 10], "accent"),
        ]
    if weapon_id == "r99":
        return [
            cube([5, 7.1, 4.1], [11, 11.7, 12.7], "body"),
            barrel(-2.2, 4.8, 1.8, 1.35),
            cube([6.2, 7.7, 2.2], [9.8, 10.2, 5.2], "dark"),
            grip(10.3, 2.8),
            cube([6.2, 1.2, 5.8], [9.8, 7.2, 8], "accent", rotation("x", 22.5, [8, 7, 7])),
            *skeleton_stock(12, 15.7, 4.2),
            rail(4.5, 12, 2.3, 11.7, "accent"),
            cube([5.1, 8.3, 5.4], [5.7, 10.8, 8.8], "light"),
        ]
    if weapon_id == "volt":
        return [
            cube([4.6, 7, 4.2], [11.4, 11.8, 13.5], "body"),
            cube([5.1, 7.6, 2.4], [10.9, 10.5, 5.1], "dark"),
            barrel(-1.8, 2.9, 2, 1.4),
            grip(10.4),
            magazine(6.8, 4.2, 2.6, "dark"),
            cube([4.9, 8, 5], [11.1, 10.9, 8.2], "accent"),
            cube([5.8, 8.4, 4.3], [10.2, 10.5, 6.3], "light"),
            cube([11.1, 8.3, 6.1], [11.9, 10.7, 7.2], "light"),
            cube([11.1, 8.3, 7.7], [11.9, 10.7, 8.8], "light"),
            cube([11.1, 8.3, 9.3], [11.9, 10.7, 10.4], "light"),
            rail(7.7, 13, 2.5, 11.8),
        ]
    if weapon_id == "car":
        return [
            cube([4.4, 7.1, 4.2], [11.6, 11.5, 13.5], "body"),
            barrel(-2, 4.9, 2.2, 1.4),
            cube([5.5, 7.6, 2.2], [10.5, 10.5, 5.3], "dark"),
            grip(10.5),
            magazine(7, 4, 2.5, "accent", -22.5),
            cube([5, 7.5, 12.8], [11, 10.6, 15.8], "dark"),
            rail(4.8, 13, 3, 11.5),
            cube([10.8, 8.1, 5.2], [11.7, 10.6, 9.7], "light"),
        ]
    if weapon_id == "devotion":
        return [
            cube([3.7, 6.7, 4.3], [12.3, 12, 14.5], "body"),
            barrel(-2.4, 5, 3.6, 1.8),
            cube([5, 7.5, 2], [11, 10.8, 5.6], "dark"),
            grip(10.8, 3.7),
            cube([4.7, 4.3, 4.8], [11.3, 7.1, 10.8], "accent"),
            cube([5.4, 5.1, 4], [10.6, 6.6, 8.2], "light"),
            solid_stock(13.5, 17.4, 6.5),
            rail(6, 13.6, 4, 12),
        ]
    if weapon_id == "lstar":
        return [
            cube([3.2, 6.5, 4.1], [12.8, 12.3, 14.3], "body"),
            cube([4.2, 7.3, 1.6], [11.8, 11.3, 5.2], "dark"),
            barrel(-2, 2.2, 4.8, 2.3, 9.2, "accent"),
            grip(11, 3.8),
            cube([3.6, 8, 5.2], [5, 11.3, 11.5], "accent"),
            cube([11, 8, 5.2], [12.4, 11.3, 11.5], "accent"),
            cube([5.3, 7.7, 4.6], [10.7, 11.2, 7.2], "light"),
            solid_stock(13.6, 17, 6.5, "dark"),
        ]
    if weapon_id == "spitfire":
        return [
            cube([4, 7, 4.8], [12, 11.7, 14.2], "body"),
            barrel(-3, 5.2, 2.4, 1.4),
            cube([6, 7.8, -3.3], [10, 10, -1.8], "dark"),
            grip(10.5, 3.5),
            cube([4.8, 2.7, 5.8], [11.2, 7.2, 9.1], "accent"),
            solid_stock(13.3, 17.5, 6, "body"),
            rail(5.4, 13.4, 3.6, 11.7),
            cube([4, 8, 10.3], [4.9, 10.7, 13.4], "light"),
        ]
    if weapon_id == "rampage":
        return [
            cube([3.8, 6.7, 4.5], [12.2, 12, 14.6], "body"),
            barrel(-2.7, 5.1, 3.2, 1.7),
            cube([5.3, 7.4, 2.4], [10.7, 10.6, 5.5], "dark"),
            grip(10.8, 3.6),
            cube([4.7, 3.6, 5.4], [11.3, 7.2, 9.6], "dark"),
            solid_stock(13.6, 17.5, 6.4),
            cube([4.4, 8, 5.2], [5.4, 11.1, 11.8], "accent"),
            cube([5.7, 5.2, 3.5], [10.3, 7, 6], "light"),
            rail(5, 13.5, 4.2, 12),
        ]
    if weapon_id == "g7_scout":
        return [
            cube([4.8, 7.3, 4.5], [11.2, 11.3, 14.1], "body"),
            barrel(-3.2, 5.1, 1.8, 1.2),
            grip(10.2, 3),
            magazine(6.7, 3.5, 2.1, "accent"),
            *skeleton_stock(13.1, 17.7, 5),
            rail(4.8, 13.4, 3, 11.3),
            cube([5.3, 8, 4.5], [6, 10.5, 9.8], "light"),
        ]
    if weapon_id == "triple_take":
        return [
            cube([4.1, 7.1, 4.3], [11.9, 11.8, 14.2], "body"),
            barrel(-3, 5, 1.25, 1.2, 8.8, "dark", 5.7),
            barrel(-3, 5, 1.25, 1.2, 9.4, "accent", 8),
            barrel(-3, 5, 1.25, 1.2, 8.8, "dark", 10.3),
            grip(10.7),
            magazine(7.1, 4.4, 2.5, "dark"),
            solid_stock(13.3, 17.5, 6, "dark"),
            cube([4.8, 8, 4.7], [11.2, 10.9, 7], "light"),
            *scope(6.5, 11.8, 4.2, 12, "accent"),
        ]
    if weapon_id == "repeater_3030":
        return [
            cube([5, 7.3, 4.8], [11, 11.2, 13.4], "body"),
            barrel(-3.4, 5.3, 1.8, 1.2),
            grip(10.5, 3, "dark"),
            solid_stock(12.6, 18, 5.8, "accent"),
            cube([5.5, 5.1, 6.8], [10.5, 7.3, 10.6], "accent"),
            cube([6.1, 3.3, 7.7], [9.9, 5.6, 10.3], "dark", rotation("x", -22.5, [8, 5.5, 9])),
            rail(5.5, 12.6, 2.5, 11.2),
            cube([4.8, 8.1, 5], [5.5, 10.4, 8.7], "light"),
        ]
    if weapon_id == "bocek":
        return [
            cube([7.1, 4.7, 5.8], [8.9, 11.4, 9.3], "body"),
            cube([6.2, 10.7, 6], [9.8, 16.5, 8], "accent", rotation("z", 22.5, [8, 11.2, 7])),
            cube([6.2, -0.4, 6], [9.8, 5.4, 8], "accent", rotation("z", -22.5, [8, 4.8, 7])),
            cube([7.6, 1.2, 7], [8.4, 15.2, 7.4], "light"),
            cube([7.5, 7.1, -2], [8.5, 8.1, 15], "dark"),
            cube([6.4, 6.2, 6.3], [9.6, 9.4, 8.7], "body"),
        ]
    if weapon_id == "charge_rifle":
        return [
            cube([4.2, 7.3, 4.1], [11.8, 11.8, 14.8], "body"),
            cube([4.9, 7.8, -3.2], [7.1, 10.3, 5], "dark"),
            cube([8.9, 7.8, -3.2], [11.1, 10.3, 5], "dark"),
            cube([6.8, 8.2, -2.8], [9.2, 9.9, 6.1], "light"),
            grip(10.8),
            cube([4.9, 4.5, 5.4], [11.1, 7.2, 10.4], "accent"),
            solid_stock(13.8, 18, 5.8),
            *scope(6.3, 12.4, 4.5, 11.8, "dark"),
        ]
    if weapon_id == "longbow":
        return [
            cube([4.7, 7.4, 4.5], [11.3, 11.4, 14.5], "body"),
            barrel(-3.8, 5.2, 1.8, 1.2),
            cube([6.2, 8, -4.1], [9.8, 9.9, -2.5], "dark"),
            grip(10.7),
            magazine(6.9, 3.8, 2.4, "dark"),
            *skeleton_stock(13.7, 18.2, 5.6),
            *scope(5.6, 12.6, 4.2, 11.7, "accent"),
            cube([4.6, 8.1, 5], [5.4, 10.7, 10], "light"),
        ]
    if weapon_id == "kraber":
        return [
            cube([3.8, 6.8, 4.5], [12.2, 12, 15], "body"),
            barrel(-4.4, 5.2, 3.3, 1.8),
            cube([5.2, 7.5, -4.8], [10.8, 10.5, -2.8], "dark"),
            grip(11.2, 3.8),
            magazine(7.3, 5, 3.1, "accent"),
            solid_stock(14, 18.8, 7, "dark"),
            *scope(5.1, 13.2, 5.5, 12, "accent"),
            cube([3.7, 8, 5.3], [4.8, 11.1, 11.4], "light"),
        ]
    if weapon_id == "sentinel":
        return [
            cube([4.5, 7.2, 4.4], [11.5, 11.7, 14.7], "body"),
            barrel(-4, 5.2, 2, 1.25),
            cube([6.2, 7.7, -4.3], [9.8, 10.1, -2.5], "body"),
            grip(10.8),
            magazine(7.1, 3.8, 2.3, "dark"),
            *skeleton_stock(13.9, 18.1, 5.2, "body"),
            cube([5, 8, 4.9], [11, 10.9, 7.1], "accent"),
            *scope(6.2, 12.9, 4.4, 11.8, "dark"),
            cube([5.8, 8.5, 4.1], [10.2, 10.4, 6.2], "light"),
        ]
    if weapon_id == "eva8":
        return [
            cube([4.2, 7.2, 4.2], [11.8, 11.8, 13.7], "body"),
            barrel(-1.8, 5, 4.8, 2.4, 9.1, "dark"),
            cube([4.7, 3.8, 8], [11.3, 10.3, 14.2], "dark"),
            cube([5, 4.1, 8.3], [11, 10, 13.9], "accent", rotation("x", 45, [8, 7.1, 11])),
            grip(11, 3.5),
            rail(5, 12.8, 3.6, 11.8),
            cube([5.4, 8, 4.6], [10.6, 10.9, 6.8], "light"),
        ]
    if weapon_id == "mastiff":
        return [
            cube([3.5, 7, 4.2], [12.5, 11.7, 14.2], "body"),
            cube([2.8, 7.5, -1.8], [13.2, 10.7, 5], "dark"),
            cube([3.8, 6, 3.8], [12.2, 7.4, 11.5], "accent"),
            grip(10.8, 3.8),
            solid_stock(13.2, 17.5, 6.6),
            rail(5.3, 13, 4, 11.7),
            cube([3.2, 8.2, -2.2], [12.8, 10, -1.2], "light"),
        ]
    if weapon_id == "mozambique":
        return [
            cube([5, 7, 4.2], [11, 11.3, 12.6], "body"),
            barrel(-1.8, 4.8, 1.45, 1.35, 9.7, "dark", 6.2),
            barrel(-1.8, 4.8, 1.45, 1.35, 9.7, "dark", 9.8),
            barrel(-1.8, 4.8, 1.55, 1.35, 7.9, "accent", 8),
            grip(10.1, 3.6),
            cube([5.2, 7.6, 3.3], [10.8, 10.8, 5.4], "accent"),
            rail(5.1, 10.3, 2.2, 11.3),
            cube([7.1, 11.2, 7], [8.9, 12.5, 9], "light"),
        ]
    if weapon_id == "peacekeeper":
        return [
            cube([3.8, 6.8, 4.2], [12.2, 12, 14.2], "body"),
            cube([4.4, 7.5, -1.9], [11.6, 10.7, 5], "dark"),
            barrel(-2.5, 4.8, 3.7, 2),
            grip(10.9, 3.8),
            solid_stock(13.2, 17.4, 6.2, "dark"),
            cube([4.5, 5.5, 5], [11.5, 7.2, 11.8], "accent"),
            cube([5.6, 3.3, 7.6], [10.4, 5.9, 10.6], "dark", rotation("x", -22.5, [8, 5.8, 9])),
            rail(5.2, 12.8, 3.4, 12),
            cube([5.3, 8, 4.5], [10.7, 11, 6.4], "light"),
        ]
    if weapon_id == "re45_burst":
        return [
            cube([5.2, 7.1, 4.2], [10.8, 11.5, 12.4], "body"),
            barrel(-2.5, 4.8, 1.8, 1.3),
            cube([6.2, 7.7, 1.9], [9.8, 10.2, 5], "dark"),
            grip(10.1, 3),
            cube([6.3, 1.7, 6.3], [9.7, 7.2, 8.4], "accent", rotation("x", 22.5, [8, 7, 7.4])),
            rail(4.8, 11.4, 2.2, 11.5, "accent"),
            cube([5.1, 8, 5.4], [5.8, 10.6, 9], "light"),
        ]
    if weapon_id == "p2020":
        return [
            cube([5.4, 7.2, 4.5], [10.6, 11.2, 11.9], "body"),
            barrel(-1.3, 5, 1.7, 1.25),
            grip(9.7, 3.1),
            cube([6.5, 4, 7.7], [9.5, 7.2, 9.8], "accent"),
            rail(5, 10.8, 1.8, 11.2, "dark"),
            cube([7.2, 11.1, 7], [8.8, 12.1, 8.6], "light"),
        ]
    if weapon_id == "wingman":
        return [
            cube([4.8, 7, 4.2], [11.2, 11.7, 12.8], "body"),
            barrel(-2.5, 4.9, 2.7, 1.5),
            cube([4.5, 6.7, 7.2], [11.5, 11.5, 11.3], "dark"),
            cube([5, 7.1, 7.5], [11, 11.1, 11], "accent", rotation("x", 45, [8, 9.1, 9.2])),
            grip(10.8, 3.8),
            rail(4.8, 11.8, 2.6, 11.7),
            cube([6.5, 11.6, 6.5], [9.5, 12.8, 8.8], "light"),
        ]
    if weapon_id == "sheila":
        elements = [
            cube([3, 6.2, 4.7], [13, 12.7, 14.8], "body"),
            cube([4.2, 3.7, 8], [11.8, 6.8, 13], "dark"),
            grip(12, 4.2),
            solid_stock(13.7, 18, 7.2, "dark"),
            cube([4.4, 11.8, 6], [11.6, 14, 10.2], "accent"),
        ]
        for x, y in ((5.2, 8), (8, 9.8), (10.8, 8)):
            elements.append(barrel(-3.4, 5.2, 1.35, 1.2, y, "dark", x))
        elements.append(cube([4.2, 7.2, -3.8], [11.8, 10.6, -2.4], "light"))
        return elements
    if weapon_id == "a13_sentry":
        return [
            cube([4.3, 7.2, 4.4], [11.7, 11.8, 14.8], "body"),
            barrel(-4, 5.2, 2.1, 1.2),
            cube([6.3, 7.6, -4.4], [9.7, 10.2, -2.6], "dark"),
            grip(10.9),
            magazine(7, 4.1, 2.5, "dark"),
            *skeleton_stock(13.8, 18, 5.8, "body"),
            *scope(5.8, 12.8, 4.3, 11.8, "dark"),
            cube([10.5, 12.2, 5.8], [12.2, 13.5, 8.2], "accent", rotation("z", -22.5, [10.7, 12.4, 7])),
            cube([10.7, 8, 4.8], [11.6, 10.8, 10.2], "light"),
        ]
    if weapon_id == "whistler":
        return [
            cube([4.8, 7, 4.1], [11.2, 11.6, 12.8], "body"),
            cube([4.5, 7.1, 1.8], [11.5, 11, 5.1], "accent"),
            barrel(-1.7, 2.5, 3.8, 2.2, 9, "dark"),
            grip(10.5, 3.5),
            cube([5.4, 4.5, 6.1], [10.6, 7.2, 9.4], "dark"),
            rail(4.8, 11.8, 3.2, 11.6),
            cube([6.1, 8, 3.2], [9.9, 10.4, 5.8], "light"),
            cube([5.1, 10.8, 10.5], [10.9, 12.5, 13.4], "accent"),
        ]
    raise KeyError(f"Missing weapon blueprint: {weapon_id}")


FIRST_PERSON_SCALE = {
    "ar": 0.86,
    "smg": 0.94,
    "lmg": 0.76,
    "marksman": 0.81,
    "bow": 0.88,
    "sniper": 0.73,
    "shotgun": 0.83,
    "pistol": 0.98,
    "minigun": 0.66,
}


def display_for(family: str) -> dict:
    """Scale each weapon class to preserve hands, crosshair, GUI, and drops."""
    first = FIRST_PERSON_SCALE[family]
    third = round(first * 0.76, 3)
    gui = min(0.94, round(first + 0.08, 3))
    ground = min(0.52, round(first * 0.6, 3))
    return {
        "thirdperson_righthand": {"rotation": [0, -90, 15], "translation": [0, 2.5, 1], "scale": [third, third, third]},
        "thirdperson_lefthand": {"rotation": [0, 90, -15], "translation": [0, 2.5, 1], "scale": [third, third, third]},
        "firstperson_righthand": {"rotation": [0, -92, 4], "translation": [1.25, 3.2, 1.4], "scale": [first, first, first]},
        "firstperson_lefthand": {"rotation": [0, 92, -4], "translation": [1.25, 3.2, 1.4], "scale": [first, first, first]},
        "gui": {"rotation": [25, 145, 0], "translation": [0, 0, 0], "scale": [gui, gui, gui]},
        "ground": {"translation": [0, 2, 0], "scale": [ground, ground, ground]},
        "fixed": {"rotation": [0, 90, 0], "scale": [min(0.8, first), min(0.8, first), min(0.8, first)]},
    }


def weapon_model_for(weapon_id: str, family: str) -> dict:
    """Build one complete vanilla item model from its named blueprint."""
    return {
        "credit": "Original low-poly model generated by Lapex",
        "ambientocclusion": False,
        "gui_light": "front",
        "textures": {"layer0": f"lapex:item/{weapon_id}"},
        "elements": weapon_elements(weapon_id),
        "display": display_for(family),
    }


def validate_weapon_blueprints(expected_ids: set[str]) -> None:
    """Fail the build when a roster entry or vanilla geometry rule drifts."""
    if set(WEAPON_SURFACES) != expected_ids:
        missing = sorted(expected_ids - set(WEAPON_SURFACES))
        extra = sorted(set(WEAPON_SURFACES) - expected_ids)
        raise ValueError(f"Weapon surface mismatch; missing={missing}, extra={extra}")
    for weapon_id in sorted(expected_ids):
        *colors, style = WEAPON_SURFACES[weapon_id]
        if style not in SURFACE_STYLES:
            raise ValueError(f"{weapon_id} uses an unsupported surface style: {style}")
        if any(
            len(color) != 3
            or any(not isinstance(channel, int) or not 0 <= channel <= 255 for channel in color)
            for color in colors
        ):
            raise ValueError(f"{weapon_id} has an invalid RGB surface color")
        elements = weapon_elements(weapon_id)
        if not 5 <= len(elements) <= 20:
            raise ValueError(f"{weapon_id} has an unsafe element count: {len(elements)}")
        for element in elements:
            start = element["from"]
            end = element["to"]
            if any(low >= high for low, high in zip(start, end)):
                raise ValueError(f"{weapon_id} has a zero or negative cuboid: {start} -> {end}")
            if any(value < -16 or value > 32 for value in (*start, *end)):
                raise ValueError(f"{weapon_id} leaves the practical item-model range: {start} -> {end}")
            if "rotation" in element:
                turn = element["rotation"]
                if set(turn) != {"origin", "axis", "angle"}:
                    raise ValueError(f"{weapon_id} has incomplete rotation data")
                if turn["axis"] not in ("x", "y", "z"):
                    raise ValueError(f"{weapon_id} uses an unsupported rotation axis")
                if turn["angle"] not in (-45, -22.5, 0, 22.5, 45):
                    raise ValueError(f"{weapon_id} uses an unsupported element angle")
                origin = turn["origin"]
                if not isinstance(origin, list) or len(origin) != 3:
                    raise ValueError(f"{weapon_id} has an invalid rotation origin")
                if any(not isinstance(value, (int, float)) or isinstance(value, bool) for value in origin):
                    raise ValueError(f"{weapon_id} has a non-numeric rotation origin")
