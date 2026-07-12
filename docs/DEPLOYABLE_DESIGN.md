# Deployable Legend Design

Many legend powers place a trap, wall, drone, pylon, market, pad, or scanner.
These are harder than a one-time blast because they stay in the world and other
players can touch or shoot them.

This page is the design gate for those features. It describes what must exist
before a placed power may be called complete.

## Current Warning

Several current Lapex powers are timed particle zones. A particle zone can show
an area and run effects, but it does not automatically provide:

- a visible physical object;
- a hitbox;
- health;
- destruction by enemies;
- stored charges;
- recall or reposition controls;
- persistence after the caster leaves the area;
- a shared cleanup registry.

The legend guide must call those versions adapted. `/legend info` must describe
what the code does today, not what a future deployable framework may do.

## Player-Facing Contract

Every placed object needs answers to these questions:

1. What is placed, and where?
2. What can the owner, allies, and enemies do with it?
3. Can it be shot? How much health does it have?
4. How long does it live?
5. Does it have charges or an owner limit?
6. Can it be recalled, moved, or replaced?
7. What shows its team, health, and active state?
8. What happens on death, quit, legend switch, reload, and restart?

Write the answers in a research note before implementation.

## Proposed Shared Record

Each deployed object should have one session record.

| Field | Purpose |
| --- | --- |
| `kind` | Stable ID such as `caustic_trap` or `wattson_pylon`. |
| `owner` | Player who placed it. |
| `team` | Team snapshot or owner-based team lookup rule. |
| `session` | Random UUID shared by owner state and every proxy entity. |
| `health` | Current scripted health in Minecraft health units. |
| `health_max` | Maximum scripted health. |
| `origin` | Authoritative world location. |
| `created_at` | Time used for duration and debugging. |
| `expires_at` | Optional expiry time. |
| `state` | Arming, active, triggered, disabled, destroyed, or expired. |
| `entities` | Hitbox and visible proxy entity IDs. |
| `chunks` | Any chunks kept loaded by this session. |

The owner should also keep a list of active session IDs. This supports charge
limits, recall, oldest-object replacement, and cleanup.

## Visual Entity and Hitbox

One entity type does not have to do every job.

- A display or equipped armor stand can show the object.
- A living proxy can provide a hitbox that the current gun ray trace can hit.
- Both proxies carry the same owner, kind, and session flags.
- The visible proxy should not run AI or move unless movement is the mechanic.
- The hitbox must match the visible shape closely enough for fair shots.

Do not use an invisible hitbox much larger than the model. Do not use a marker
armor stand when the marker setting removes the hitbox players need to shoot.

## Central Damage Router

A shared entity-damage event should handle all deployable proxies.

```text
proxy hit
   |
   v
read kind, owner, and session
   |
   +--> invalid or stale: remove proxy and stop
   |
   v
resolve attacker and team
   |
   +--> ally damage blocked when the official rule blocks it
   |
   v
subtract scripted health
   |
   +--> health remains: update name/effect
   |
   +--> zero: run the kind's one cleanup task
```

The router must compare the proxy entity with the owner's stored session. An old
entity with an owner flag is not proof that it is still valid.

## Placement

Placement should:

- ray trace from the eye when the original power is thrown or aimed;
- find solid support and enough free space;
- reject the wrong world, protected map area, liquid, void, or blocked volume;
- refund the cooldown or charge when no valid placement exists;
- show a short failure message;
- never place a player or entity inside a solid block.

Use one shared safe-placement helper when several legends need the same rule.

## Charges and Owner Limits

A cooldown and a stored charge are different.

- A cooldown says when one use returns.
- A charge count says how many uses may be ready at once.
- An owner limit says how many objects may stay active.

Model each rule explicitly. Do not write "two charges" in data when one generic
cooldown is the only state in code.

When the owner limit is reached, follow the researched rule: reject placement,
replace the oldest object, or recall a chosen object. Do not silently remove a
random object.

## Tick and Performance Budget

One repeat loop per object scales badly. Prefer one shared deployable heartbeat
that processes registered objects in batches.

Guidelines:

- use a slower interval when the rule does not need every tick;
- query only the needed radius;
- do not redraw a dense particle shape every tick;
- stop processing an unloaded, expired, or invalid session;
- keep high-frequency tasks at `debug: false`;
- measure with many simultaneous objects, not only one caster.

## Chunk Ownership

An object that must remain active outside player view needs a deliberate chunk
policy. Chunk tickets must be reference-safe when two objects share a chunk.

Before releasing a chunk, check whether another active session still owns a
ticket there. Always release tickets during cleanup. After a crash or reload,
load the recorded chunk long enough to find and remove stale proxies.

## Cleanup State Machine

```text
created -> arming -> active -> triggered -> expired
                      |           |
                      +-----------+--> destroyed
                      |
                      +--> recalled

every final state -> remove proxies -> release chunks -> clear owner record
```

The final cleanup should be idempotent, which means calling it twice is safe.
Use a `cleaning` or final-state guard when two hits can destroy an object in the
same tick.

## EMP and Disable Rules

Crypto EMP should not claim to disable traps until deployables have a shared
registry and disabled state. When that state exists, EMP can query registered
enemy objects within range, apply the researched behavior, and let each kind
decide whether "disable" means destroy, pause, or suppress an effect.

## Rollout Order

Build and test the shared lifecycle with a simple object first. Then move more
complex abilities onto it.

Suggested order:

1. One health-based stationary device.
2. Caustic trap arming and trigger state.
3. Wattson pylon and fence-node links.
4. Horizon, Seer, and Conduit damageable ultimate devices.
5. Rampart cover with directional health regions.
6. Mobile shields and moving devices.
7. Multi-object choice interfaces such as Loba's Black Market.

Each migration needs its own research note and live multiplayer test.

## Required Tests

- [ ] Valid and invalid placement.
- [ ] Arm, active, trigger, expire, recall, and destroy states.
- [ ] Owner, ally, enemy, mob, projectile, and Lapex hits.
- [ ] Health display and exact destruction threshold.
- [ ] Two owners in one place.
- [ ] One owner at the maximum active-object count.
- [ ] Death, quit, world change, legend switch, script reload, and restart.
- [ ] Shared chunk ownership.
- [ ] Server performance with the expected maximum object count.
- [ ] Visual and hitbox alignment from first and third person.
