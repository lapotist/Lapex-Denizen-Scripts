# Feature: Legend Special Weapons, July 2026

## Status

- Research date: 2026-07-13
- Scope: Ballistic Whistler, Vantage A-13 Sentry, Rampart Sheila, Sentinel,
  Rampage, and Charge Rifle special behavior
- Fidelity goal: honest current behavior with item-scoped state

## Sources

- [Official Ballistic page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/ballistic)
- [Official Vantage page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/vantage)
- [Official Overclocked notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-patch-notes)
- [Official Overclocked midseason notes](https://www.ea.com/games/apex-legends/apex-legends/news/overclocked-midseason-patch-notes)
- [Official Astral Anomaly notes](https://www.ea.com/games/apex-legends/apex-legends/news/astral-anomaly-event)

EA notes verify the current headline changes used here: Whistler has two rounds,
50 overheat damage, and a 15-second heat effect; current sniper hit multipliers
and Charge Rifle range direction come from the cited weapon notes. EA does not
publish complete per-shot recoil sequences, so Lapex recoil numbers remain
measured approximations.

Source record: all linked pages are published by Electronic Arts and were
checked on 2026-07-13. Character pages establish ability purpose; Overclocked
notes support Whistler and Vantage changes; Astral Anomaly supports the cited
weapon direction. Values not stated on those pages are labeled tuning.

## Current Lapex Behavior

- **Whistler:** the issued item holds two shots. Direct hits build weapon heat;
  misses create a proximity trap. The heat effect refreshes for 15 seconds and
  triggers 50 damage at the configured threshold. Lapex does not yet implement
  two independently recharging tactical charges.
- **A-13 Sentry:** starts with two rounds and regenerates one carried round in
  the background every 40 seconds until its six-round magazine is full. Marks
  are owner/team scoped. The 40-second interval is Lapex tuning.
- **Sheila:** spin-up and Rampart magazine behavior run through the normal gun
  engine. Only one copy of each legend weapon may be held.
- **Sentinel and Rampage:** charged state belongs to the physical item and
  expires there. Rampage rate of fire returns to normal as soon as rev ends.
- **Charge Rifle:** delayed hitscan preserves range-scaled damage. It does not
  yet simulate projectile travel, drop, or current select-fire behavior.

## Input and Movement Invariant

Left-click fires. Right-click alone holds ADS. Recoil sends relative yaw and
pitch camera movement; it must never teleport the shooter or change shooter
velocity. A full-magazine stationary test is required after every recoil edit.

## Known Gaps

- Shield Cell and Thermite item consumption are not implemented.
- Whistler charge recharge and A-13 targeting laser/canted sight are incomplete.
- Exact recoil patterns and several modern attachment behaviors are outside the
  current fixed camera-kick model.

## Verification Status

All 32 items resolve in the server validator. Item-scoped state and movement
invariants pass static review; full-magazine recoil, ADS release, damage, and
tracer visibility still need a live client.
