# Testing Guide

Automated validation finds broken data and missing scripts. A live player test
finds input, camera, entity, and visual bugs. Lapex needs both.

## Test Levels

1. **File checks:** JSON, Python, Git whitespace, and secret scans.
2. **Denizen reload:** parser and static-tag checks.
3. **Registry validation:** all guns, legends, and map tasks resolve.
4. **Live-client smoke test:** controls and the changed feature work for one player.
5. **Multiplayer test:** ally, enemy, proxy damage, and shared devices work.
6. **Cleanup test:** quit, death, reload, and legend changes leave no entities or flags.

## File Checks

Run from the repository root:

```text
python3 -m py_compile tools/build_resource_pack.py tools/render_kings_canyon.py
python3 tools/build_resource_pack.py
find resource-pack -type f \( -name '*.json' -o -name 'pack.mcmeta' \) -print0 | xargs -0 -n1 jq -e . >/dev/null
git diff --check
```

Confirm there are 40 model files and 40 texture files: 32 weapons and eight
legend devices.

```text
find resource-pack/assets/lapex/models/item -name '*.json' | wc -l
find resource-pack/assets/lapex/textures/item -name '*.png' | wc -l
```

Before a commit, inspect staged paths. No path may start with `server/` or `dist/`.

## Server Checks

Deploy the canonical `scripts/` files under the local Denizen scripts folder.
From the Paper console, run:

```text
ex reload scripts_now
ex run lapex_validate
ex run lapex_map_validate
ex run lapex_arena_validate
ex run lapex_arena_match_validate
ex run lapex_arena_loot_smoke
ex run lapex_arena_bots_smoke
ex run lapex_arena_bots_runtime_smoke
ex run lapex_deployable_smoke def.owner:<server.offline_players.first> def.location:<world[world].spawn_location.above[4]>
ex run lapex_dome_geometry_smoke def.center:<world[world].spawn_location.above[2]>
ex run lapex_charge_smoke def.target:<server.offline_players.first>
```

The deployable and charge smokes need one known player profile. On a new server,
join once or replace `<server.offline_players.first>` with a known PlayerTag.

Expected lines:

```text
Lapex validation passed: 32 guns and 28 legends resolved.
Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved.
Lapex deployable smoke passed: native proxies, extras, register, replace, and cleanup.
Lapex Dome geometry smoke passed: upper shell, both directions, internal shot, and lower-half rejection.
Lapex charge smoke passed: due ordering, charge cap, and test-flag rollback.
Lapex arena validation passed: 9 units, 10 unique spawns, 6 mirrored loot anchors, and all signatures present.
Arena match validation passed: phase contract, score paths, 5v5 spawns, loadout items, and integrations.
Arena loot smoke passed: six atomic bins, one progressive care box, and standard rewards.
Arena bot smoke passed: 5v5 spawns, navigation graph, and four registry-backed loadouts.
Arena bot runtime smoke passed: ten native bots spawned, acquired targets, and fired.
```

The reload is not successful if the console also shows an invalid event, tag,
mechanism, material, or command error.

The loot and bot static smokes validate registries and contracts. The runtime
bot smoke proves native spawning, targeting, firing, and rollback. Capacity
clicks, a full round, a five-minute tick soak, and ten real clients remain
separate live tests; do not claim those from a static smoke result.

## Shooting Checklist

- [ ] Left-click fires in air, at a block, and at an entity.
- [ ] A gun swing does not mine a block or add vanilla melee damage.
- [ ] Holding an automatic gun fires repeatedly at its configured limit.
- [ ] Right-click holds ADS; releasing it restores normal FOV quickly.
- [ ] Switching items during ADS resets FOV.
- [ ] F reloads without swapping the gun away.
- [ ] Empty and non-empty reload times are different where configured.
- [ ] Head, body, and leg damage differ correctly.
- [ ] An ally is not hurt by team-aware gunfire.
- [ ] A phased or protected target is not hurt.
- [ ] Shotgun pellet patterns and damage are plausible.
- [ ] Long tracers remain visible near the far impact.
- [ ] Fast automatic fire does not flood the console.

## Stationary Recoil Test

This test protects the original shooting bug from returning.

1. Stand still on a marked block.
2. Record exact player X, Y, Z, and velocity.
3. Fire a full magazine without pressing movement keys.
4. Record X, Y, Z, and velocity again.
5. Repeat while ADS.
6. Repeat at a world coordinate far from zero.

Pass condition: only yaw and pitch change because of recoil. Position must not
become `0, 0, 0`, and the script must not add velocity.

## Resource-Pack Checklist

- [ ] The client accepts the pack with no compatibility warning on 26.1.2.
- [ ] `/lapex giveall` shows all 32 models.
- [ ] No gun looks like the next gun in model-ID order.
- [ ] First-person models do not cover the crosshair.
- [ ] Third-person models sit in the correct hand.
- [ ] Inventory and dropped-item models fit their space.
- [ ] ADS FOV does not clip the model badly.
- [ ] Muzzle particles start near the visible muzzle.
- [ ] Bright and dark tracer colors remain readable.
- [ ] All eight device models align with their armor-stand hitboxes or emitter points.
- [ ] Flat pads do not look upright; gates and portals face the placement yaw.

JSON validation cannot replace this test. A model can be valid and still look
wrong in the client.

## Crypto Drone Checklist

Use two players on different Lapex teams.

- [ ] Tactical leaves a player-shaped body at the exact start point.
- [ ] The real player enters spectator flight.
- [ ] Left-clicking an entity does not attach the spectator camera to it.
- [ ] A glowing drone marker follows the camera.
- [ ] Action bar shows drone HP, range, and recall help.
- [ ] The drone can travel close to 200 blocks without losing the body chunk.
- [ ] Crossing 200 blocks returns the camera to the last safe point.
- [ ] Crossing worlds does not produce a distance-tag error.
- [ ] Enemy gunfire reduces drone HP from 50 and can destroy it.
- [ ] Destroying the drone starts a 30-second tactical cooldown.
- [ ] Manual recall uses only the short recall cooldown.
- [ ] Enemy gunfire at the body hurts the real player and returns them.
- [ ] One shotgun hit forwards every pellet accumulated in that server tick.
- [ ] Ally gunfire cannot hurt the body or drone.
- [ ] EMP starts at the drone, not the body.
- [ ] EMP removes no more than 50 Apex shield HP and does not remove health.
- [ ] Q recall works when the client sends it.
- [ ] `/legend tactical` always recalls as a fallback.
- [ ] Quit, death, legend switch, and script reload remove both proxy entities.
- [ ] Quit and reconnect returns Crypto to the saved body origin, not the remote camera.
- [ ] A heal/scan/Dome near the body affects the body owner, not the spectator camera.
- [ ] N.E.W.T. can move the body and recall returns Crypto to its new location.
- [ ] A stale proxy from an old session cannot hurt its owner.
- [ ] Two Crypto players starting in one chunk do not release each other's chunk ticket.

## Physical Device Checklist

- [ ] Caustic can own six traps; the seventh replaces the oldest.
- [ ] A trap cannot trigger before arming or run two gas loops.
- [ ] Overlapping gas from one Caustic does not multiply each damage tick.
- [ ] N.E.W.T. pulls several enemies at the same time without rotating cameras.
- [ ] N.E.W.T. pulls a piloting Crypto's body, not the remote camera.
- [ ] Ash enters automatically; every other player chooses at the origin only.
- [ ] Ash transit preserves view direction and never permits a return through the exit.
- [ ] A player in Ash transit cannot move, shoot, use an ability, or deal vanilla damage.
- [ ] Octane pad launch leaves camera control; Sneak redirects one double jump.
- [ ] Landing from either Octane-pad jump does not deal fall damage.
- [ ] Axle and non-Axle riders get the correct steering; Sneak cancels Nitro.
- [ ] Destroying a gate stops new riders but does not cancel an existing slide.
- [ ] Dome blocks outside-in, inside-out, and outside-through-outside shots.
- [ ] Two players whose shot stays inside the same Dome can still fight.
- [ ] Tracers stop on the shell and Whistler does not leave a mine there.
- [ ] Arrows and other vanilla projectiles stop on the shell.
- [ ] D.O.C. heals allies only and follows the chosen ally or Crypto body.
- [ ] Nox gas pauses enemy D.O.C.; enemy Crypto EMP destroys D.O.C. and Dome.
- [ ] Halo colors friends and enemies differently and grants no fake protection.
- [ ] Damageable model health, name, visual size, and hitbox agree.
- [ ] Owner death, quit, world/legend/team change, reload, and restart leave no proxy.

## Charge Checklist

- [ ] Conduit and Pathfinder start with two tactical charges.
- [ ] Octane starts with two ultimate charges.
- [ ] Spending both charges starts two independent due times.
- [ ] `/legend status` shows the current count.
- [ ] An invalid Octane pad placement refunds exactly one charge.
- [ ] Reload and reconnect restore every already-due charge once, not twice.
- [ ] `/lapex resetcooldowns` restores the default full count.

## Legend Checklist

For every changed power:

- [ ] Read `/legend info` and compare it with the research note.
- [ ] Test passive, tactical, and ultimate separately.
- [ ] Test no target, invalid target, blocked path, and maximum range.
- [ ] Test ally and enemy behavior.
- [ ] Test cooldown start, end, charges, and recall rules.
- [ ] Test death, quit, legend switch, and script reload.
- [ ] Test two casters at once.
- [ ] Check that particles, sounds, names, and action-bar text match the state.
- [ ] Record every intentional Minecraft adaptation.

## Arena Foundry Checklist

- [ ] `/arena join` refuses an unloaded or incomplete Foundry before changing player state.
- [ ] Red and blue each use five unique safe starts with no direct spawn sightline.
- [ ] Prep lasts 30 seconds; movement stays in the start area and guns/abilities remain locked.
- [ ] Empty slots fill to exactly five actors on both teams.
- [ ] `lapex_arena_bots_runtime_smoke` creates ten native actors, observes combat, and leaves no active session or bot behind.
- [ ] Human-to-bot, bot-to-human, and bot-to-bot friendly fire is blocked for allies.
- [ ] Bots only shoot visible enemies and continue moving when one route is blocked.
- [ ] Bot tracers, RPM, magazines, reload pauses, misses, Dome hits, and damage are readable.
- [ ] A piloting Crypto is targeted at the body, never the spectator camera.
- [ ] Lethal human damage enters spectator without showing the death screen.
- [ ] Eliminated humans and bots never return during the current round.
- [ ] Six barrels allow two claims each; the center care box allows three claims.
- [ ] Claims cannot be duplicated by double-clicking, hoppers, reconnecting, or stale blocks.
- [ ] The Ring damages humans and bots and guarantees that an all-bot round can finish.
- [ ] Scores `3-0`, `3-1`, `3-2`, `4-2`, `4-3`, and round nine follow the win contract.
- [ ] Stop, quit, reload, restart, and match completion remove bots/loot and restore player state.
- [ ] A stale persistent bot removes itself when its chunk loads.
- [ ] Ten bots can fight for five minutes without console errors or sustained tick loss.
- [ ] The top-down render shows three connected lanes, dense cover, both elevations, and clear symmetry.

## Report Template

```text
Build:
Minecraft client:
Paper:
Denizen:
Players used:
Feature:
Research note:
Steps:
Expected:
Actual:
Console errors:
Screenshot or video:
```
