# Feature: Horizon N.E.W.T. Black Hole

## Status

- Research date: 2026-07-13
- Fidelity goal: damageable pull device without unsupported final damage
- Runtime status: implemented; live multiplayer verification still required

## Source

The [official Horizon page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/horizon)
describes N.E.W.T. as the device that creates a black hole and pulls nearby
players toward it. The character page does not publish every numeric rule.

Source record: Electronic Arts publishes the live character page; it exposes
no stable revision date or numeric contract for this review. It was checked on
2026-07-13. Health, duration, radius, and pull strength below are Lapex tuning.

## What Players Should Understand

1. Horizon aims and throws one visible N.E.W.T.
2. Nearby enemies are pulled toward it and slowed.
3. Allies are not pulled by Lapex's team-aware implementation.
4. Enemies can shoot the device and its name shows remaining health.
5. It expires on its own and placing another replaces the old one.

## Lapex Tuning

The current `225` Apex HP, `6` second duration, `10` block query radius, and
Minecraft push strength are Lapex tuning. N.E.W.T. does not add a final health
damage blast because that is not part of the sourced ability purpose.

## Runtime Rules

Each target receives an independent pull queue. This matters when several
players enter at once: one player's movement must not wait for another player's
movement to finish. Pulling also uses `no_rotate`, so the ability moves a player
without stealing camera control.

Crypto's spectator camera is skipped. Area effects resolve the damageable fake
body instead of treating the remote camera as Crypto's combat position.

## Known Gaps

- The throw is represented by immediate safe placement rather than a physical
  projectile arc.
- The model and hitbox need first-person and third-person client testing.
- Pull acceleration and obstruction behavior are Minecraft adaptations.

## Verification Status

Registry and shared deployable lifecycle tests pass. Concurrent player pulls,
Crypto-body movement, obstruction, and visual alignment still need live tests.
