# Feature: Placed Mobility, July 2026

## Status

- Research date: 2026-07-13
- Scope: Ash Phase Breach, Axle Drift and Nitro Gate, Octane Launch Pad
- Fidelity goal: preserve player choice and steering with visible objects

## Sources

- [Official Ash page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/ash)
- [Official Takeover notes](https://www.ea.com/games/apex-legends/apex-legends/news/takeover-patch-notes)
- [Official Prodigy notes](https://www.ea.com/games/apex-legends/apex-legends/news/prodigy-patch-notes)
- [Official Axle page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/axle)
- [Official Overclocked notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-patch-notes)
- [Official Overclocked midseason notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-midseason-patch-notes)
- [Official Octane page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/octane)

These sources verify Ash's targeted one-way portal and current 100 meter range,
Axle's faster steerable slide plus team-neutral five-second Nitro boost and two
100 HP gate limit, and Octane's reusable launch with one airborne double jump.
EA's current public pages do not publish every duration, pad-health, or movement
velocity value.

Source record: Electronic Arts publishes every linked page. They were checked
on 2026-07-13 for the Season 29 review. The pages and notes support the behavior
and explicitly listed current values; Minecraft impulses, pad health, portal
life, and unlisted timing remain labeled Lapex tuning.

## Shared Input Rule

A fresh Sneak press is one input and must do only one job. Lapex handles it in
this order:

1. Consume a ready Octane-pad double jump.
2. Cancel an active Nitro slide.
3. Try the selected legend's own midair or slide passive.

This prevents an Ash riding an Octane pad from double-jumping and air-dashing
on the same key press.

## Ash Phase Breach

- Aim at a safe exit up to 100 blocks away.
- Ash travels automatically after opening it.
- Other non-spectator players choose whether to enter the visible origin.
- The exit is never an entrance, so travel is one-way.
- A per-player latch prevents one entry from starting twice.
- Transit is phased and retains the player's camera direction.

The current 15-second portal life and Minecraft transit timing are documented
Lapex tuning. Nearby allies must never be collected and forced through.

## Octane Launch Pad

- The pad is a visible, shootable object on valid ground.
- It is team-neutral: any normal player may use it.
- Entry gives a horizontal and upward velocity impulse without rotating camera.
- One airborne Sneak press redirects the second jump toward current camera yaw.
- Pad-owned landing safety prevents fall damage from either launch.
- The double-jump token ends on use, landing, death, world change, or timeout.

Until a current primary source publishes pad health and owner limits, Lapex uses
`200` Apex HP and at most four active pads as explicit adaptation values. Pads
remain until destroyed, replaced, or owner cleanup rather than using a hidden
45-second particle timer.

## Axle Drift and Nitro Gate

- Axle begins Drift by sneaking while sprinting on the ground.
- A placed Nitro Gate is team-neutral, visible, has `100` HP, and has an owner
  limit of two.
- Entering starts a tokenized slide for up to five seconds.
- Existing horizontal movement blends toward camera-facing direction. Axle gets
  stronger steering than other riders.
- Sneak cancels an active boost. Jumping preserves vertical motion.
- Destroying a gate prevents new entries but does not cancel a rider already in
  motion.

The exact Minecraft impulse and Drift-only duration are tuning values. Movement
uses short velocity updates, not a long `push` command, so players keep camera
and steering control.

## Cleanup and Tests

Transient movement flags clear on death, quit, world change, token replacement,
landing, and script reload. Physical pad and gate entities use the shared
deployable session registry and its stale-proxy reconciliation.

Required live tests include cross-legend Sneak priority, two simultaneous
riders, gate destruction during a ride, double jump toward a new camera yaw,
invalid placement cooldown refund, and no camera or position reset.

Server loading, registry validation, and proxy lifecycle smoke pass. Every live
movement case in the paragraph above remains pending.
