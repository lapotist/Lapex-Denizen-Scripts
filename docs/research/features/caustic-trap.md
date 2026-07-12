# Feature: Caustic Nox Gas Trap

## Status

- Research date: 2026-07-13
- Fidelity goal: closer Minecraft adaptation with visible counterplay
- Runtime status: implemented; live multiplayer verification still required

## Source

The [official Caustic page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/caustic)
establishes the important player contract: Caustic places gas canisters, enemies
trigger them by approaching or shooting them, and the released gas damages and
slows enemies. Current patch notes should be used before changing exact values.

Source record: Electronic Arts publishes the live character page; it does not
show a stable per-revision date or the numeric values used by Lapex. It was
checked on 2026-07-13 for the Season 29 review. Every number below is therefore
labeled Lapex tuning rather than an official value.

## What Players Should Understand

Think of the trap as a can that watches a small circle.

1. Caustic places a visible can.
2. It needs a short moment to arm.
3. An enemy entering the circle, or a gunshot after arming, starts the gas.
4. The gas hurts and grounds enemies but does not stack several damage ticks
   from the same Caustic at once.
5. Enemies can shoot the can. Its name shows remaining scripted health.
6. Caustic may own six traps. Placing a seventh replaces the oldest one.

## Lapex Tuning

The current `225` Apex HP, `0.8` second arm time, `22` second gas life, three
block trigger radius, and damage ramp from `10` to `15` are explicit Lapex
tuning values. They are not presented as unpublished EA internals.

## Lifecycle Contract

- Owner, kind, and random session must agree on both the player and proxy.
- One guarded transition changes `active` into `triggered`; duplicate queues
  cannot start a second gas cloud.
- Death, quit, world change, team change, legend change, and script reload use
  the shared idempotent cleanup path.
- Chunk-load reconciliation resumes a valid active session and removes stale
  or expired proxies.

## Known Gaps

- Placement still needs common liquid, protected-area, border, and blocked-space
  rejection.
- The low-poly model requires in-client alignment testing.
- Exact health, gas geometry, and damage timing remain adapted for Minecraft.

## Verification Status

The shared native-proxy lifecycle smoke and registry validation pass. Arming,
overlap, damage, model alignment, and two-player cleanup still need live tests.
