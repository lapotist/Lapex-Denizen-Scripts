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
                                                   +--> teams, charges, mobility
                                                   +--> deployable registry
                                                            |
                                                            +--> models, health,
                                                                 loops, damage,
                                                                 cleanup, rehydrate

admin input --> commands and validators

map commands --> map registry --> terrain and POI build tasks --> world files

arena command --> session/round controller --> loot + Ring + native bot actors

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
| `lapex_deployables.dsc` | Physical-object sessions, health, global kind index, damage, extras, cleanup, and rehydration. |
| `lapex_deployable_items.dsc` | Visual-only model items for physical legend devices. |
| `lapex_mobility.dsc` | Ash transit, Octane launch/double jump, Axle steering, and transient movement cleanup. |
| `lapex_support_devices.dsc` | Dome geometry/projectiles plus D.O.C. and Halo loops. |
| `lapex_commands.dsc` | Operator commands and the gun/legend registry validator. |
| `lapex_map_data.dsc` | World constants, POIs, build units, and signatures. |
| `lapex_map_engine.dsc` | World lifecycle, build scheduling, common geometry, and map validation. |
| `lapex_map_terrain.dsc` | Deterministic island terrain. |
| `lapex_map_pois_*.dsc` | Deterministic landmark geometry. |
| `lapex_arena_data.dsc` | Foundry bounds, spawns, loot anchors, navigation graph, cover nodes, timers, and scoring constants. |
| `lapex_arena_map.dsc` | Foundry world lifecycle, resumable build, anti-grief rules, commands, and signatures. |
| `lapex_arena_geometry.dsc` | Dense three-lane Foundry structures, cover, staging, and loot pads. |
| `lapex_arena_match.dsc` | Session authority, roster snapshots, prep/live phases, elimination, Ring, scoring, restoration, and HUD. |
| `lapex_arena_loot.dsc` | Atomic script-owned supply/care claims and Arena healing items. |
| `lapex_arena_bots.dsc` | Session-bound native husk navigation, targeting, gunfire, Ring enforcement, and cleanup. |
| `build_resource_pack.py` | Stable model-ID map, PNG/JSON generation, device models, and item dispatcher. |
| `resource_pack_weapons.py` | Authoritative named gun blueprints, four-color surfaces, and class display scales. |
| `render_weapon_catalog.py` | Dependency-free SVG preview built from the generated cuboids and PNG atlas colors. |
| `render_kings_canyon.py` | Read-only Anvil map renderer. |

## Weapon Pipeline

Right-click item use is the fire entry point. Arm swing toggles ADS, while
separate events cancel block mining and vanilla melee for held guns.

```text
right-click use packet
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
   |  apply team, Arena-session, protection, hit-zone, mark, and special rules
   v
scripted projectile damage
   |  compare health, absorption, or virtual HP before/after
   v
confirmed damage sound, Apex damage number, remaining HP, and ammo display
```

Important contracts:

- Item flag `lapex.id` is weapon identity.
- Item flag `lapex.ammo` belongs to that physical item.
- The first automatic-use packet fires one round and arms `auto_probe`. Only a
  repeated packet inside six ticks creates the held `trigger` lease.
- Fractional RPM intervals carry their remainder in `fire_phase`; fixed upward
  rounding would make many weapons slower than their registry value.
- A delayed queue rechecks the held item ID before changing ammo or state.
- Recoil changes yaw and pitch only. It never teleports or pushes the shooter.
- `recoil_scale` multiplies presentation kick after per-weapon values and patterns.
- `player_raysize` expands living-target hitboxes by `0.30` blocks for
  player-fired rays; a special weapon's `homing_raysize` remains an override.
- Target velocity is restored after scripted damage to avoid unwanted knockback.
- A ray target is checked and snapshotted before zone math, then checked again
  immediately before damage so another queue cannot leave a stale entity tag.
- Hit feedback and combat telemetry require a positive authoritative HP delta.
- Confirmed damage holds `damage_feedback_lock` for 25 ticks so the Arena HUD
  cannot erase the accepted damage and remaining-HP display immediately.
- A short `lapex.damage_transaction` source flag prevents generic event telemetry
  from recording a hit before the weapon-owned comparison completes.
- Crypto body pellets preserve source/weapon metadata and confirm from a health
  snapshot around the delayed real-player damage. Mixed-source batches suppress
  shooter attribution; Arena's one-HP elimination sentinel resolves to zero.
- Arena actors accept gun damage only from the same active live session.
- Bot rays revalidate the actor or deployable owner they actually intersect, so
  an outsider crossing a valid line of fire cannot take Arena damage.
- Shotgun pellets aggregate into one confirmed-damage response per trigger.
- Hot input tasks use `debug: false`.

## ADS Pipeline

One left-click toggles the weapon-scoped `lapex.ads` flag. Turning ADS off calls
the same cancellation task used by every lifecycle cleanup path. There is no
release timer or delayed monitor.

Holding a different item, reloading, changing worlds, joining, quitting, dying,
and reloading scripts clear ADS. Denizen restores the client default only when
`fov_multiplier` is adjusted with no value; `fov_multiplier:1` is not a reset.

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

The generic gate starts a simple cooldown or spends one stored charge before
dispatch. A task that cannot start must refund the matching transaction. Charge
due times are persistent lists; the secondly loop restores every elapsed due
time after a reload or reconnect. Crypto is a separate lifecycle: successful
launch clears its tactical cooldown and drone destruction begins recovery.

## Deployable Pipeline

```text
ability validates safe placement
        |
        v
native proxy spawn -> equip visual-only model -> set kind state
        |
        v
lapex_deployable_register
   | owner session list
   | exact owner <-> entity authority
   | global kind index
   | optional extra visual entities
        |
        +--> kind loop: trigger, pull, launch, shield, heal, or display
        +--> shared damage router for shootable devices
        +--> one idempotent cleanup task
```

Paper 26.1 rejects the tested Denizen adapter spawn for some entity types. The
native spawn helpers summon with a unique scoreboard tag, wait for Paper to
track the entity, and bind only that exact result. Never select "the closest"
untagged entity when simultaneous casts are possible.

## Team Contract

`lapex_legend_is_ally` is the shared authority. A source is always allied with
itself. Two combat actors are allies only when they have the same non-empty
`lapex.team` flag. Arena humans and bots receive the same session-specific team
value; do not compare `red` and `blue` outside the shared procedure.

Damage, scans, shields, and heals should use the shared procedure. A new task
must not invent a second team rule.

Crypto body and drone proxies resolve to their real owner only when their
session matches the owner's active session. Shared scans and ally zones query
living entities, discard the remote spectator camera, and deduplicate by the
resolved combat player. This makes the mannequin body the combat anchor.

## State Groups

Flags act like internal APIs between scripts.

| Group | Main flags | Lifetime |
| --- | --- | --- |
| Player identity | `lapex.legend`, `lapex.team` | Persistent until changed. |
| Item identity | item `lapex.id`, item `lapex.ammo` | Stored on each gun. |
| Weapon transaction | `trigger`, `auto_probe`, `auto_loop`, `fire_phase`, `recoil_shot`, `spinup`, `spinup_ready`, `action_lock`, `burst`, `charging`, `reloading`, `secondary` | Short action state. |
| View | `ads` | Toggled for the currently held gun. |
| Shared combat | `legend_protected`, `pylon_protected`, `phased`, `legend_silenced`, `tempest`, `amped_cover` | Timed ability state. |
| Combat telemetry | `last_target`, `last_attacker`, `last_shot_location`, `last_damage_location`, `low_health`, `threatened_by`, `damage_feedback_lock` | Short evidence for passives and readable confirmed damage. |
| Crypto session | `crypto_active`, `crypto_origin`, `crypto_gamemode`, body/drone entity, body chunk, drone health | From launch through one cleanup path. |
| Deployable session | owner `deployable.*`, `deployable_sessions.*`; entity owner/kind/session/health/state; server `deployable_index.*` | Placement through cleanup or stale reconciliation. |
| Mobility | `octane_launch_token`, `octane_double_ready`, `octane_fall_safe`, `nitro_token`, `slide_source`, `ash_transit_active`, `ash_invisibility` | One ride, slide, landing, or transit; always tokenized and cleanup-owned. |
| Stored charges | `charges.*`, `charge_due.*`, `charge_groups`, short `charge_transaction.*` | Persistent count and due times; transaction expires after dispatch. |
| Item special state | item `sentinel_amped`, item `rampage_amped`; player `a13_regen_due` | Physical item expiry or background round restoration. |
| Private scan | `scan_token.*` | Tokenized per viewer and target. |
| Map build | `lapex.map.v1.complete`, `lapex.map.v1.units.*` | Versioned server checkpoints. |
| Arena map build | `lapex.arena_map.v1.complete`, `lapex.arena_map.v1.units.*` | Separate Foundry checkpoints. |
| Arena match | server `lapex.arena.session`, `state`, `round`, `score.*`, `players.*`, `bots.*`; actor `arena_session`, `arena_team`, `arena_eliminated` | One match UUID through idempotent cleanup. |
| Arena bot | `arena_bot`, `arena_bot_session`, `arena_bot_team`, `arena_bot_weapon`, `arena_bot_ammo` | One native actor in one live round. |

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

Kings Canyon and Arena Foundry have independent worlds and checkpoint
namespaces. Foundry reuses the low-lag cuboid/stair primitives but owns its own
registry, signatures, and nine build units. A match must never begin until
`lapex.arena_map.v1.complete` exists.

## Arena Match Pipeline

```text
lobby -> 30-second prep -> live -> round end
  ^                               |
  +-------------------------------+  until match decision
                                  |
                                  +-> match end -> restore and cleanup
```

Every delayed phase, Ring, and bot task receives the match UUID and rechecks
it. Loot claims synchronously read the authoritative current session and round
before writing their claim. Human inventory, location, health, food, potion
effects, team, gamemode, cooldowns, and stored charges are snapshotted before
joining. Cleanup stops linked legend queues, removes Arena entities and loot,
restores the snapshot, and clears the session flags.

Bot pathfinding is supplied by native husks through Denizen's entity `walk`,
`look`, and `attack` commands. Denizen owns target selection and hitscan. Bots
only choose visible enemies, use imperfect aim, share the gun registry, respect
Dome and combat protection, and delete themselves when a stale chunk reloads.

For native entities, Denizen's `walk speed:` is the raw movement attribute, not
a multiplier where `1.0` means normal speed. Patrol uses `0.21`, still below a
vanilla husk's `0.23`; combat pursuit starts beyond 18 blocks and stops inside
12 to avoid path restarts every decision tick. Each roster slot first receives
a lane-aligned exit, then graph choices prefer progress toward the opposing side.
Behind cover, a strategic selector prefers graph edges which reduce distance
to the nearest live opponent without granting permission to shoot through the
wall. A per-second progress token cancels and retries stalled native paths
instead of leaving a bot under a long navigation lock. Generic husks can still
accept a partial path at a clear doorway, so the opening leg uses a smooth,
slot-aligned velocity guide at normal running speed. A twelve-second,
session-bound watchdog moves only any unresolved actor to the verified floor
block beyond its assigned door, then returns control to graph pursuit.

After spawn egress, a moving bot may use an eight-tick slide toward a distant
path goal. It starts at `0.32`, decays to `0.18`, and has a random five-to-eight
second cooldown. Every tick samples the floor, feet, headroom, nearby actors,
and arena bounds ahead; a failed sample brakes the bot. Sliding is disabled during doorway
escort, reaction, firing, reload, melee, and close-range holds, so it changes
rotation pressure without changing aim accuracy or first-shot timing.

Target acquisition has a 7-15 tick reaction window. Bots fire readable groups
of 4-8 rounds with 6-13 tick pauses and use a per-actor variant of the shared
5.0 by 3.6 degree aim-error cone centered on the torso. Player and bot guns
both call `lapex_weapon_cadence_step`, so fractional registry RPM must not be
rounded independently in either loop.

## Resource-Pack Pipeline

`tools/build_resource_pack.py` combines the stable item map with the gun visual
module and produces:

```text
custom model data 1001..1032 and 1101..1108
        |
        v
assets/minecraft/items/carrot_on_a_stick.json
        |
        v
assets/lapex/models/item/<weapon-or-device>.json
        |
        v
assets/lapex/textures/item/<weapon-or-device>.png
```

Generated models and textures are committed so servers can distribute the pack.
Change `tools/resource_pack_weapons.py` for gun art or
`tools/build_resource_pack.py` for the pipeline, then rebuild, validate, and
review the output. Do not hand-edit one generated weapon file because the next
build will replace it. Gun texture noise is seeded from the gun ID, so reordering
the registry cannot silently redesign existing assets.

## Known Architecture Gaps

- The validator checks registry resolution, not full behavior.
- Eight placed objects use the shared lifecycle. Catalyst spikes, Conduit
  jammers, Loba market, Newcastle shields, Pathfinder zipline, Rampart cover,
  Seer Exhibit, Sparrow devices, and Wattson nodes still need migration.
- Halo has correct visible/team-neutral membership but no tested custom
  consumable-time subsystem yet.
- Several roster counts and help lines are hard-coded.
- Model JSON validity does not prove that a model looks correct in Minecraft.
- Input, camera, multiplayer, and cleanup behavior still need live clients.

See [Deployable Design](DEPLOYABLE_DESIGN.md) for the implemented contract and
the remaining rollout before expanding placed abilities.
