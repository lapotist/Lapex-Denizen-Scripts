# Contributing to Lapex

Thank you for helping. This guide keeps changes easy to understand, test, and
review.

## Start Here

1. Read [the player guide](docs/PLAYER_GUIDE.md) so you know what players expect.
2. Read [the architecture guide](docs/ARCHITECTURE.md) before changing shared code.
3. Read [the research guide](docs/RESEARCH_AND_FIDELITY.md) before changing gameplay.
4. Create a feature research note before implementation.
5. Keep one pull request focused on one feature or one connected group of fixes.

## Repository Boundaries

The tracked `scripts/` directory is the source of truth. A local test server may
have a copy under `server/plugins/Denizen/scripts/lapex/`, but `server/` is
ignored because it contains worlds, player data, logs, JAR files, and secrets.

Never commit:

- `server/` or any server properties file;
- Paper or plugin JAR files;
- worlds, player data, logs, profiler files, or caches;
- private keys, tokens, passwords, or management secrets;
- generated release ZIP files from `dist/`.

Release archives belong on a GitHub Release. The reproducible resource-pack
source belongs in `resource-pack/`.

## Change Workflow

1. Update from `main` and make a short-lived branch.
2. Add or update the research note first.
3. Change canonical files under `scripts/`, `tools/`, `resource-pack/`, or `docs/`.
4. Deploy only the changed scripts to a local Paper test server.
5. Reload and run the automated validators.
6. Run the live-client checklist for the changed behavior.
7. Read the server console for errors and noisy debug output.
8. Run `git diff --check` and inspect every staged path.
9. Explain fidelity decisions and known gaps in the pull request.

## Denizen Style

- Use two levels of four-space indentation, matching nearby scripts.
- Keep registries in data containers and behavior in tasks or world events.
- Use `snake_case` for script names, definitions, IDs, and flags.
- Prefix persistent or cross-script state with `lapex.`.
- Add `debug: false` to hot loops and high-frequency input tasks.
- Check that players and entities are online, spawned, and still own the same session.
- Give delayed work a token or session ID so an old queue cannot change new state.
- Clean up on normal completion, death, quit, legend switch, and script reload.
- Add a short comment before a non-obvious invariant. Do not narrate simple lines.
- Keep user-facing text short. Put detailed help in these guides.

## Adding or Updating a Gun

1. Research its current damage, fire mode, rate, magazine, reload, range, spread,
   recoil direction, and special rules.
2. Add or update one entry in `scripts/apex_weapon_data.dsc`.
3. Keep its ID in `standard_ids`, `legend_ids`, `all_ids`, and the correct category.
4. Add or update its item in `scripts/apex_weapon_items.dsc`.
5. Use `carrot_on_a_stick`, a unique `custom_model_data`, and matching `lapex.id`.
6. Update `tools/build_resource_pack.py` and rebuild the pack.
7. Run `/lapex validate`, then test hip fire, ADS, reload, empty reload, every fire
   mode, damage zones, recoil, tracers, item swaps, and legacy-item migration.

Do not move the shooter to create recoil. Recoil changes camera yaw and pitch only.

## Adding or Updating a Legend

1. Research all passive, tactical, and ultimate rules, including charges and upgrades.
2. Update the registry in `scripts/lapex_legend_data.dsc`.
3. Add routing in the matching passive, tactical, or ultimate script.
4. Put shared input, cooldown, team, and cleanup behavior in `lapex_legend_core.dsc`.
5. Add session checks for any damageable proxy or long-running task.
6. Document exact, adapted, analogue, and missing parts in the legend guide.
7. Test with an ally and an enemy, then repeat after death, quit, legend switch,
   script reload, and a second player using the same legend.

## Required Checks

From the Paper console:

```text
ex reload scripts_now
ex run lapex_validate
ex run lapex_map_validate
```

Expected results:

```text
Lapex validation passed: 32 guns and 28 legends resolved.
Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved.
```

For the resource pack:

```text
python3 tools/build_resource_pack.py
find resource-pack -type f \( -name '*.json' -o -name 'pack.mcmeta' \) -print0 | xargs -0 -n1 jq -e . >/dev/null
```

Read [the full testing guide](docs/TESTING.md) for live-client cases.

## Pull Request Notes

Include:

- what changed for players;
- links to research notes and official sources;
- fidelity labels and known gaps;
- automated test output;
- live-client cases tested;
- screenshots or short video for visual work;
- cleanup and multiplayer cases tested.

Do not describe a feature as complete when a listed test is still missing.
