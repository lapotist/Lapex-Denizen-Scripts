# Feature: Weapon Resource-Pack Visual Pass, July 2026

## Status

- Research date: 2026-07-13
- Scope: all 32 Lapex gun models, gun textures, and item display scale
- Apex season or event: Season 29 / Overclocked, with older introduction
  trailers used where they show a weapon more clearly
- Fidelity goal: recognizable original low-poly adaptations with no copied game
  assets

## Player Story

Each gun should look different before a player reads its name. A small pistol
should not fill the screen like a Kraber. A Triple Take should show three rails,
an Alternator should show two barrels, and a Bocek should look like a bow.

Minecraft cannot load an Apex mesh or play its first-person weapon animations
from a normal resource pack. Lapex therefore studies the large shapes, where a
magazine sits, how long the barrel looks, and where bright material appears.
Those observations become new cuboids and new pixel materials made for Lapex.

## Source Record

| Source | Publisher and date | What it was used for |
| --- | --- | --- |
| [EA gun and weapon guide](https://help.ea.com/en/articles/apex-legends/guns-and-weapons/) | Electronic Arts, current help article, checked 2026-07-13 | Official class and current-roster cross-check, including Bocek 2.0 and RE-45 Burst. |
| [Apex Legends Gameplay Deep Dive](https://www.youtube.com/watch?v=cEReUkZjjN4) | PlayApex, 2019, checked 2026-07-13 | Neutral first-person presentation for the original core arsenal. |
| [Apex Legends: Prodigy](https://www.ea.com/en/games/apex-legends/apex-legends/seasons/prodigy) and its [official gameplay trailer](https://www.youtube.com/watch?v=hg0_PBw1OMI) | Electronic Arts / PlayApex, Season 25, checked 2026-07-13 | Current Bocek presentation, bow limbs, held scale, and first-person clearance. |
| [Apex Legends: Revelry Gameplay Trailer](https://www.youtube.com/watch?v=vgRpFAeEAn4) | PlayApex, February 2023, checked 2026-07-13 | Nemesis receiver, energy chamber, front prongs, and held footprint at introduction. |
| [Battle Charge](https://www.youtube.com/watch?v=zsUd40fvFm8), [Meltdown](https://www.youtube.com/watch?v=C3q_SibAOc4), [Assimilation](https://www.youtube.com/watch?v=DFY_scgPl80), and [Boosted](https://www.youtube.com/watch?v=SCUXdRb5abU) gameplay trailers | PlayApex, Seasons 2, 3, 4, and 6, checked 2026-07-13 | Introduction views for L-STAR, Charge Rifle, Sentinel, Sheila, and Volt. |
| [Mayhem](https://www.youtube.com/watch?v=Z-xDoDSDM2Y), [Legacy](https://www.youtube.com/watch?v=ChZaqqoNg-0), [Emergence](https://www.youtube.com/watch?v=bOD88NwyShM), and [Escape](https://www.youtube.com/watch?v=N-7j2ejytyI) gameplay trailers | PlayApex, Seasons 8 through 11, checked 2026-07-13 | Introduction views for 30-30, Bocek, Rampage, and C.A.R. |
| [Hunted](https://www.youtube.com/watch?v=Jcr8qmrnOKE), [Meet Ballistic](https://www.youtube.com/watch?v=piOCG6ETQzI), [Breach](https://www.youtube.com/watch?v=XRNJoZD_nvQ), and [Aftershock](https://www.youtube.com/watch?v=DGnH8MfyTf0) | PlayApex, checked 2026-07-13 | A-13 scale and scope, Whistler launcher proportions, current RE-45 Burst presentation, and Hemlok Breach suppressor/launcher shape. |
| [All-weapon evolution and effect showcase](https://www.bilibili.com/video/BV1aGCoBXEvN/) | Community capture, published 2025-11-20, checked 2026-07-13 | Inspect and firing views for 28 standard guns. Skins were used only to understand persistent silhouette; skin art was not reproduced. |
| [All Weapon Showcase in 2026, 4K](https://www.youtube.com/watch?v=Uk4JT-DSR4c) | EXILAS, community capture, 2026, checked 2026-07-13 | Structured gap check when an official trailer cut away too quickly. |
| [All-gun recoil practice and pattern video](https://www.youtube.com/watch?v=8QQJAwUaRi0) | Do_ASAP, published 2026-01-28, checked 2026-07-13 | Neutral firing posture, visible muzzle location, gun size around the crosshair, and class-to-class scale. |
| [Nemesis viewmodel animation showcase](https://spacepirate.artstation.com/projects/lDB9Z5) | Allan Zhang, Respawn weapon animator portfolio, checked 2026-07-13 | Close view of the Nemesis moving parts and the difference between dark casing and cyan energy details. |
| [Weapon index](https://apexlegends.wiki.gg/wiki/Weapon) | Maintained community reference, checked 2026-07-13 | Roster names, class grouping, and side-profile cross-checks where a moving frame was unclear. |

The community videos and wiki are visual references, not official geometry or
color data. A future clearer official capture can replace an observation without
changing the custom-model-data contract.

## Visual Observations

| Group | Shapes that must remain readable in Lapex |
| --- | --- |
| Assault rifles | HAVOC has an exposed energy channel; Flatline is heavy and angular; Hemlok has a long suppressor and underbarrel breach device; R-301 is slim with an open stock; Nemesis has a light upper shell, dark belly, cyan core, and split front. |
| SMGs | Alternator has two barrels; Prowler has a rear magazine and bullpup mass; R-99 is narrow with a long magazine; Volt has a pale shell and three bright side cells; C.A.R. is compact and rectangular. |
| LMGs | Devotion has a long energy assembly; L-STAR is a broad red heat weapon; Spitfire has a conventional long barrel and box magazine; Rampage is chunky with an orange heat canister. |
| Marksman weapons | G7 is a light conventional rifle; Triple Take has three rails; 30-30 has a long barrel and wood-like stock; Bocek has separated limbs and a visible arrow line. |
| Snipers | Charge Rifle has two side rails around a bright center; Longbow is long and narrow; Kraber is the largest rifle with a large optic; Sentinel is long, pale, and blue; A-13 uses a pale rail-rifle shape with a red canted sensor. |
| Shotguns | EVA-8 has a drum; Mastiff has a very wide muzzle; Mozambique has three short barrels; Peacekeeper has a broad receiver and lower lever. |
| Pistols and legend guns | RE-45 is a machine pistol with a long magazine; P2020 is deliberately plain; Wingman has a large cylinder; Sheila has a barrel cluster; Whistler is an ivory, black, and gold smart launcher with a hot projectile chamber. |

These are shape observations, not exact measurements. The model dimensions and
colors are Lapex art direction chosen to remain readable at Minecraft scale.

## Implementation Decisions

- Preserve custom model data `1001..1032` exactly. Visual work must never remap
  an existing item.
- Give every gun a named blueprint. Roster order no longer changes geometry or
  texture noise.
- Use 6 to 13 cuboids per gun. This leaves enough geometry for signature parts
  without making held items needlessly expensive to render.
- Use a 32 by 32 atlas with four 16-pixel material cells: body panel, dark
  hardware, painted accent, and bright detail.
- Use five original surface treatments: energy, industrial, precision, polymer,
  and legacy. They add seams, grip ridges, wear, glow-like centers, or wood-like
  lines without importing an outside image.
- Scale first-person and third-person models by weapon family. Long snipers and
  Sheila are smaller in hand than pistols so the crosshair remains visible.
- Keep the eight legend-device textures unchanged. This pass is only about guns.

## Fidelity Labels

| Part | Label | Reason |
| --- | --- | --- |
| Overall silhouette and major signature parts | Adapted | The identity is retained with axis-aligned Minecraft cuboids. Curves and fine parts are simplified. |
| Color blocking and material families | Adapted | Palettes follow broad visual roles but are newly chosen pixel colors, not sampled or copied textures. |
| Surface texture | Analogue | Procedural seams, ridges, wear, and bright cores stand in for detailed materials. |
| First-person scale | Adapted | Class-specific transforms prioritize crosshair clearance and hand fit in Minecraft. |
| Reload, inspect, spin-up, charge, choke, and cooling animation | Not implemented | One static item model cannot reproduce these states without additional item-state plumbing or a client mod. |
| Separate ADS model and optic view | Not implemented | ADS currently changes camera FOV only. |

## Asset Provenance

No outside image, video frame, mesh, UV map, logo, or game texture is stored in
the repository or generated pack. Every JSON model and PNG pixel is produced by
`tools/build_resource_pack.py` and `tools/resource_pack_weapons.py`. The source
links above document observation only; they do not grant redistribution rights
and are not redistributed.

## Test Cases

- [x] Builder resolves exactly 32 weapon blueprints and four-color surfaces.
- [x] Every gun has 5 to 20 valid cuboids inside the practical item-model range.
- [x] Every element rotation uses a vanilla-supported angle.
- [x] All generated JSON parses.
- [x] All 32 gun textures are 32 by 32 RGBA PNGs.
- [x] All eight legend-device textures remain 16 by 16 RGBA PNGs.
- [x] Offline catalog render shows a separate silhouette for every gun. Rebuild
  it with `python3 tools/render_weapon_catalog.py /tmp/lapex-weapon-catalog.svg`.
- [ ] Minecraft 26.1.2 accepts the rebuilt ZIP without a warning.
- [ ] A live client checks all 32 guns in first person, third person, GUI, fixed,
  and dropped-item views.
- [ ] A live client checks ADS clearance and visible muzzle alignment for every
  weapon family.

The live checks remain open because the server was intentionally left stopped.
