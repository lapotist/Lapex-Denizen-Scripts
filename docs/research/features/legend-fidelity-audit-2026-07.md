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

1. Eight placed objects now use the shared model/session lifecycle. Most other
   deployables remain undamageable particle locations without health or hitboxes.
2. Persistent independent charge storage now covers Conduit, Pathfinder, and
   Octane. Other charge-like powers still need kit-specific review.
3. Downed players, revives, death boxes, loot containers, beacons, and
   consumable timing do not have full shared subsystems.
4. Ash now uses voluntary entry. Alter, Loba, and Valkyrie still remove important
   player choice or provide no selection interface.
5. Many team mechanics require explicit Lapex team assignment.
6. `/legend info` must describe current implementation, not an unbuilt target.

## Priority Order

1. Continue restoring player choice for Alter, Loba, Valkyrie, and support targeting.
2. Migrate the next ranked deployables through the existing shared lifecycle.
3. Add a tested custom consumable subsystem before calling Halo functional.
4. Add downed/revive, loot, and beacon subsystems only after separate research.
5. Continue replacing passives whose Minecraft analogue no longer matches the
   official ability concept.

## July Implementation Checkpoint

- Camera-only recoil, right-click ADS, special-gun state, and improved tracers
  passed static and server validation. The stationary live-client test remains pending.
- Crypto now uses exact session-bound native proxies, shotgun damage collection,
  reconnect origin recovery, and body-aware scan/support selectors.
- Caustic, Horizon, Ash, Octane, Axle, Gibraltar, and Lifeline gained visible
  shared-lifecycle objects with generated low-poly models.
- Gibraltar Dome uses an exact segment/sphere boundary solution for both shot
  directions. D.O.C. follows assigned allies; Halo no longer grants unrelated buffs.
- Catalyst's unrelated personal damage reduction was replaced by a three-hit
  reinforced-door analogue. Newcastle's unsupported landing damage was removed.

## Acceptance Rule

The guide's analogue/adapted labels describe how closely the current code maps
the researched idea; they are not test certification. A change is not called
verified or one-to-one until its research note, automated validation,
live-client test, multiplayer test, and cleanup test all pass.
