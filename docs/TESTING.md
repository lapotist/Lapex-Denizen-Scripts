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

Confirm there are 32 model files and 32 texture files:

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
```

Expected lines:

```text
Lapex validation passed: 32 guns and 28 legends resolved.
Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved.
```

The reload is not successful if the console also shows an invalid event, tag,
mechanism, material, or command error.

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

JSON validation cannot replace this test. A model can be valid and still look
wrong in the client.

## Crypto Drone Checklist

Use two players on different Lapex teams.

- [ ] Tactical leaves a player-shaped body at the exact start point.
- [ ] The real player enters spectator flight.
- [ ] A glowing drone marker follows the camera.
- [ ] Action bar shows drone HP, range, and recall help.
- [ ] The drone can travel close to 200 blocks without losing the body chunk.
- [ ] Crossing 200 blocks returns the camera to the last safe point.
- [ ] Crossing worlds does not produce a distance-tag error.
- [ ] Enemy gunfire reduces drone HP from 50 and can destroy it.
- [ ] Destroying the drone starts a 30-second tactical cooldown.
- [ ] Manual recall uses only the short recall cooldown.
- [ ] Enemy gunfire at the body hurts the real player and returns them.
- [ ] Ally gunfire cannot hurt the body or drone.
- [ ] EMP starts at the drone, not the body.
- [ ] EMP removes no more than 50 Apex shield HP and does not remove health.
- [ ] Q recall works when the client sends it.
- [ ] `/legend tactical` always recalls as a fallback.
- [ ] Quit, death, legend switch, and script reload remove both proxy entities.
- [ ] A stale proxy from an old session cannot hurt its owner.
- [ ] Two Crypto players starting in one chunk do not release each other's chunk ticket.

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
