# Lapex Weapon-Specific 3D Arsenal

This pack targets Minecraft 26.1.2 resource format 84.0. It maps the Lapex
carrot-on-a-stick custom model data range 1001 through 1032 to 32 low-poly 3D
weapons. Visual-only legend devices use 1101 through 1108 for Caustic, Horizon,
Octane, Axle, Ash, Gibraltar, and Lifeline objects.

Every gun has its own named cuboid blueprint and 32 by 32 material atlas. The
large parts do the recognition work: barrel count, receiver width, magazine
position, stock, scope, drum, lever, energy core, or bow limb. The art is an
original Minecraft adaptation informed by gameplay videos. No Apex image,
frame, mesh, logo, or texture is included.

Install the `resource-pack` directory as a client resource pack, or zip its
contents so `pack.mcmeta` is at the root of the archive. Regenerate every model
and texture from the repository root with:

```text
python3 tools/build_resource_pack.py
```

`tools/resource_pack_weapons.py` owns gun shapes, palettes, and class display
scales. `tools/build_resource_pack.py` owns model IDs, PNG/JSON output, legend
devices, and dispatch generation. Do not hand-edit generated files under
`assets/lapex`; the next build replaces them.

Render all generated gun cuboids and atlas colors into one reviewable SVG with:

```text
python3 tools/render_weapon_catalog.py artifacts/weapon_catalog.svg
```

See the [visual research note](../docs/research/features/weapon-resource-pack-2026-07.md)
for sources, fidelity labels, and the remaining live-client checklist.
