# Lapex Installation

Lapex was runtime-tested with Paper 26.1.2 and Denizen 1.3.3 build
7294-DEV. The archive does not include the Paper or Denizen plugin JARs.

## Prebuilt World (Recommended)

1. Stop the Paper server completely.
2. Install Denizen, then start and stop the server once if its directories do
   not exist yet.
3. Copy `plugins/Denizen/scripts/lapex` from the archive into the same path
   under the server root.
4. Find the primary `level-name` in `server.properties`. Its default is
   `world`.
5. Copy `prebuilt-dimension/lapex_kings_canyon` from the archive to:

   ```text
   <level-name>/dimensions/minecraft/lapex_kings_canyon
   ```

6. Start the server. Do not rename the `lapex_kings_canyon` directory.
7. Run these checks from the console:

   ```text
   ex reload scripts_now
   ex run lapex_validate
   ex run lapex_map_validate
   ```

   The expected final lines are:

   ```text
   Lapex validation passed: 32 guns and 28 legends resolved.
   Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved.
   ```

8. Join the server and use `/lapexmap tp staging`.

9. Install `resource-pack` as a client resource pack, or distribute
   `dist/lapex-resource-pack-26.1.2.zip`. The pack targets format 84.0 and must
   not be reused on older Minecraft clients without conversion.

The completed staging beacon contains a persistent marker. On first startup,
Lapex reads it and restores the lightweight completion and POI checkpoint flags
for the copied world.

## Generate From Scripts

Install the scripts as above, but do not copy `prebuilt-dimension`. Start the
server and run:

```text
/lapexmap create
/lapexmap build
```

Run a full build during a maintenance window. Terrain and structures are
generated over multiple ticks with a 45 ms edit budget; generation takes
several minutes and intentionally prioritizes completing the one-time build.
The builder saves and checkpoints terrain units and each landmark, so a later
`/lapexmap build` resumes incomplete work.

Use `/lapexmap status` to follow progress. When it reports `17/17` and
`complete true`, run `/lapexmap validate`. Use `/lapexmap rebuild confirm` only
when you intend to repair all generated geometry.

## Permissions

- `lapex.admin`: weapon, legend, team, and map administration commands
- `lapex.team.manage`: player self-service team assignment
- `lapex.map.edit`: block breaking and placement inside Kings Canyon

Operators receive `lapex.admin` by default. Ordinary players can select and use
legends without it.

## Preview

`artifacts/kings_canyon_topdown.png` is a north-up, one-pixel-per-block render
of the included 640x640 dimension. To regenerate it from a server copy:

```text
python3 tools/render_kings_canyon.py /path/to/lapex_kings_canyon
```

The renderer is read-only and requires Python 3 plus Pillow.
