# Feature: Full Legend Fidelity Audit, July 2026

## Status

- Owner: Lapex maintainers
- Research date: 2026-07-13
- Apex season or event: Season 29 / Overclocked and its June 22 midseason update
- Fidelity goal: document first, then improve one reviewed system at a time

## Sources

The behavior review used all 28 current official EA character pages from the
[legend hub](https://www.ea.com/games/apex-legends/apex-legends/characters-hub),
the [Overclocked patch notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-patch-notes),
and the [Overclocked midseason notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-midseason-patch-notes).

Character pages explain ability purpose but usually omit cooldown, damage,
range, duration, health, and charge numbers. Registry numbers remain
approximations unless a current patch note below supports them.

## Verified Current Numeric Overlay

- Ash air-dash cooldown: 10 seconds.
- Axle Nitro Gate effect: up to 5 seconds; maximum two deployed gates; 100 HP each.
- Ballistic Whistler: two base charges, 50 overheat damage, 15-second debuff.
- Conduit: two tactical charges; 30-second cooldown; regeneration is 10 per
  second for 8 seconds, totaling 80 ally and 56 self.
- Mad Maggie tactical cooldown: 28 seconds; Wrecking Ball pucks boost sprint only.
- Pathfinder: two tactical charges at a flat 20 seconds; ultimate is 2 minutes.
- Seer Exhibit: initial 2-second scan and 2-second scan for new entrants.
- Vantage tactical: 17 seconds, 21 meters per second, and 7-meter double jump;
  tracking a team restores 70 percent of one ultimate bullet per team on a
  10-second cooldown.

## Cross-Legend Findings

1. Most deployables are currently undamageable particle locations rather than
   entities. They have no health, hitbox, destruction, or shared lifecycle.
2. Cooldowns use one boolean expiry flag. Multi-charge tactical powers cannot
   work correctly without a charge system.
3. Downed players, revives, death boxes, loot containers, beacons, and
   consumable timing do not have full shared subsystems.
4. Alter, Ash, Loba, and Valkyrie remove important player choice in their
   current implementations.
5. Many team mechanics require explicit Lapex team assignment.
6. `/legend info` must describe current implementation, not an unbuilt target.

## Priority Order

1. Restore player choice for forced travel and target-selection mechanics.
2. Add a shared charge model.
3. Add the shared damageable deployable lifecycle.
4. Add downed/revive, loot, and beacon subsystems only after separate research.
5. Revisit passives whose current Minecraft analogue no longer matches the
   official ability concept.

## Acceptance Rule

No legend moves from analogue to adapted or from adapted to closer adaptation
until its research note, automated validation, live-client test, multiplayer
test, and cleanup test all pass.
