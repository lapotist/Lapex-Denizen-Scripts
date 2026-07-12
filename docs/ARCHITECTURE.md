# Lapex Architecture

This page explains the system from the outside in. Read it before changing a
shared event, helper, state flag, or generated asset.

## System Map

```text
player input
   |
   +--> weapon events --> weapon registry --> hitscan, damage, recoil, reload
   |                                                |
   |                                                +--> legend combat flags
   |
   +--> legend input --> legend registry --> passive / tactical / ultimate
                                                   |
                                                   +--> shared team and zone helpers

admin input --> commands and validators

map commands --> map registry --> terrain and POI build tasks --> world files

item model ID --> generated item dispatch --> 3D model --> generated texture
```

Registries describe what exists. Engines decide how it behaves. Item and model
files decide what a player holds and sees.

## Canonical Source

`scripts/` is the source of truth. The local path
`server/plugins/Denizen/scripts/lapex/` is only a deployed test copy. It is not
tracked because the server folder also contains private and changing runtime data.

The safe workflow is:

```text
edit scripts/ -> deploy changed files -> reload -> test -> commit scripts/
```

Never solve drift by copying the whole server directory into Git.

## File Ownership

| File | Owns |
| --- | --- |
| `apex_weapon_data.dsc` | Weapon IDs, categories, damage, timing, recoil, spread, and special data. |
| `apex_weapon_items.dsc` | The 32 item scripts, initial ammo, lore, and custom model IDs. |
| `lapex_weapon_engine.dsc` | Fire input, ADS, trigger modes, hitscan, damage, recoil, tracers, and reload. |
| `lapex_legend_data.dsc` | Legend IDs, names, classes, cooldowns, and player-facing implementation notes. |
| `lapex_legend_core.dsc` | Selection, Q input, cooldown gate, teams, proxy routing, and shared helpers. |
| `lapex_legend_passives.dsc` | Passive events and the shared once-per-second passive loop. |
| `lapex_legend_tacticals.dsc` | Tactical dispatcher and tactical tasks. |
| `lapex_legend_ultimates.dsc` | Ultimate dispatcher and ultimate tasks. |
| `lapex_commands.dsc` | Operator commands and the gun/legend registry validator. |
| `lapex_map_data.dsc` | World constants, POIs, build units, and signatures. |
| `lapex_map_engine.dsc` | World lifecycle, build scheduling, common geometry, and map validation. |
| `lapex_map_terrain.dsc` | Deterministic island terrain. |
| `lapex_map_pois_*.dsc` | Deterministic landmark geometry. |
| `build_resource_pack.py` | Authoritative weapon-model map and generated model/texture design. |
| `render_kings_canyon.py` | Read-only Anvil map renderer. |

## Weapon Pipeline

The arm-swing event is the one fire entry point. Separate events cancel block
mining and vanilla melee for held guns.

```text
ARM_SWING
   |
   v
lapex_weapon_trigger
   |  validate item ID, legend-only gun, locks, and ammo
   v
mode task: auto / semi / burst / spin-up / charge
   |
   v
lapex_weapon_fire_once
   |  spend ammo and save eye location
   |  send camera-only recoil
   |  calculate spread and pellet rays
   |  render selected tracer paths
   |  apply team, protection, hit-zone, mark, and special rules
   v
scripted projectile damage and ammo display
```

Important contracts:

- Item flag `lapex.id` is weapon identity.
- Item flag `lapex.ammo` belongs to that physical item.
- A delayed queue rechecks the held item ID before changing ammo or state.
- Recoil changes yaw and pitch only. It never teleports or pushes the shooter.
- Target velocity is restored after scripted damage to avoid unwanted knockback.
- Hot input tasks use `debug: false`.

## ADS Pipeline

Right-click use input refreshes `lapex.ads` for a short time and writes a new
`lapex.ads_token`. The release task waits seven ticks. It restores FOV only when
its token still matches, so an old release cannot end a newer hold.

Holding a different item, joining, and quitting all restore FOV to `1` and clear
the ADS state.

## Legend Pipeline

```text
Q/drop or /legend command
        |
        v
lapex_legend_activate
   |  selected legend, silence, phase, action lock, cooldown
   v
tactical or ultimate dispatcher
        |
        v
legend-specific task
        |
        +--> shared ally procedure
        +--> safe destination procedure
        +--> damage sphere helper
        +--> scan and private outline helpers
```

The generic gate starts the cooldown before dispatch. A task that cannot start
must refund that cooldown. Crypto is a special case: the drone cooldown is
cleared after a successful launch and begins when the drone is destroyed.

## Team Contract

`lapex_legend_is_ally` is the shared authority. A source is always allied with
itself. Two players are allies only when they have the same non-empty
`lapex.team` flag.

Damage, scans, shields, and heals should use the shared procedure. A new task
must not invent a second team rule.

Crypto body and drone proxies resolve to their real owner only when their
session matches the owner's active session.

## State Groups

Flags act like internal APIs between scripts.

| Group | Main flags | Lifetime |
| --- | --- | --- |
| Player identity | `lapex.legend`, `lapex.team` | Persistent until changed. |
| Item identity | item `lapex.id`, item `lapex.ammo` | Stored on each gun. |
| Weapon transaction | `trigger`, `auto_loop`, `spinup`, `action_lock`, `burst`, `charging`, `reloading`, `secondary` | Short action state. |
| View | `ads`, `ads_token` | Refreshed while ADS is held. |
| Shared combat | `legend_protected`, `pylon_protected`, `phased`, `legend_silenced`, `tempest`, `amped_cover` | Timed ability state. |
| Combat telemetry | `last_target`, `last_attacker`, `last_shot_location`, `last_damage_location`, `low_health`, `threatened_by` | Short evidence for passives. |
| Crypto session | `crypto_active`, `crypto_origin`, `crypto_gamemode`, body/drone entity, body chunk, drone health | From launch through one cleanup path. |
| Private scan | `scan_token.*` | Tokenized per viewer and target. |
| Map build | `lapex.map.v1.complete`, `lapex.map.v1.units.*` | Versioned server checkpoints. |

When a flag becomes a cross-file contract, add it to this table.

## Delayed Work Rules

Denizen queues can finish after the player changes items, legends, worlds, or
sessions. Every delayed or repeating task should recheck what it depends on.

Common checks are:

- player is online;
- entity is spawned;
- held item ID still matches;
- token or session still matches;
- world still matches before measuring distance;
- target is still an enemy and not phased or protected.

Use a random UUID session for a long-lived object. Store it on the owner and on
the object. Reject damage or cleanup from a mismatched session.

## Cleanup Rules

Any feature that changes gamemode, FOV, camera state, chunks, entities, or blocks
needs one cleanup task that owns every exit path.

Cover:

- normal finish or recall;
- object destroyed;
- owner damaged or killed;
- owner quits and rejoins;
- legend switch;
- world change;
- script reload;
- server restart recovery.

Cleanup must be safe to call twice. Missing entities and cleared flags are normal
conditions, not errors.

## Map Builder

The map builder uses a registry of deterministic build units and versioned
checkpoints. Long edits load needed chunks, use a bounded edit budget, save the
unit, and then release chunks. A completed unit is not rebuilt during a normal
resume.

`build force` and `rebuild confirm` are repair paths. Do not add an unconfirmed
command that clears map checkpoints or geometry.

## Resource-Pack Pipeline

`tools/build_resource_pack.py` produces:

```text
custom model data 1001..1032
        |
        v
assets/minecraft/items/carrot_on_a_stick.json
        |
        v
assets/lapex/models/item/<weapon>.json
        |
        v
assets/lapex/textures/item/<weapon>.png
```

Generated models and textures are committed so servers can distribute the pack.
Change the generator, rebuild, validate, and review the output. Do not hand-edit
one generated weapon file because the next build will replace it.

## Known Architecture Gaps

- The validator checks registry resolution, not full behavior.
- Many placed legend abilities are currently task-local particle zones, not a
  shared damageable deployable system.
- Several roster counts and help lines are hard-coded.
- Model JSON validity does not prove that a model looks correct in Minecraft.
- Input, camera, multiplayer, and cleanup behavior still need live clients.

See [Deployable Design](DEPLOYABLE_DESIGN.md) for the planned shared lifecycle
before expanding placed abilities.
