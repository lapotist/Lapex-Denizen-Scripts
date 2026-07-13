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
5. Copy both prebuilt dimensions from the archive to:

   ```text
   <level-name>/dimensions/minecraft/lapex_kings_canyon
   <level-name>/dimensions/minecraft/lapex_arena_foundry
   ```

6. Set `max-players=10` or higher in `server.properties` for a fully human 5v5
   match. Start the server. Do not rename either dimension directory.
7. Run these checks from the console:

   ```text
   ex reload scripts_now
   ex run lapex_validate
   ex run lapex_map_validate
   ex run lapex_arena_validate
   ex run lapex_arena_match_validate
   ex run lapex_arena_loot_smoke
   ex run lapex_arena_bots_smoke
   ex run lapex_arena_bots_runtime_smoke
   ```

   The expected final lines are:

   ```text
   Lapex validation passed: 32 guns and 28 legends resolved.
   Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved.
   Lapex arena validation passed: 9 units, 10 unique spawns, 6 mirrored loot anchors, and all signatures present.
   Arena match validation passed: phase contract, score paths, 5v5 spawns, loadout items, and integrations.
   Arena loot smoke passed: six atomic bins, one progressive care box, and standard rewards.
   Arena bot smoke passed: 5v5 spawns, navigation graph, and four registry-backed loadouts.
   Arena bot runtime smoke passed: ten native bots spawned, acquired targets, and fired.
   ```

   The runtime bot smoke briefly creates a private all-bot session in the built
   Foundry and then rolls it back. It refuses to run while a match is active.

8. Join the server and use `/lapexmap tp staging` for Kings Canyon, or
   `/arena join` and `/arena start` for Arena Foundry.

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
/lapexarena create
/lapexarena build
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
- `lapex.arena.play`: joining, leaving, and choosing an Arena loadout
- `lapex.arena.edit`: block changes inside Arena Foundry
- `lapex.team.manage`: player self-service team assignment
- `lapex.map.edit`: block breaking and placement inside Kings Canyon

Operators receive `lapex.admin` by default. Grant `lapex.arena.play` to players
who should enter 5v5 matches. Ordinary players can select and use legends
without the admin permission.

## Preview

`artifacts/kings_canyon_topdown.png` is a north-up, one-pixel-per-block render
of the included 640x640 dimension. To regenerate it from a server copy:

```text
python3 tools/render_kings_canyon.py /path/to/lapex_kings_canyon
```

Arena Foundry uses the same read-only renderer with explicit compact bounds:

```text
python3 tools/render_kings_canyon.py /path/to/lapex_arena_foundry \
  -o artifacts/arena_foundry_topdown.png --min-x -112 --min-z -80 \
  --width 224 --height 160
```

The renderer is read-only and requires Python 3 plus Pillow.
