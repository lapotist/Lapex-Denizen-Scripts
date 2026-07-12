# Research and Fidelity Guide

Lapex tries to feel like Apex, but a Minecraft server cannot copy every system.
Good work starts by separating facts from guesses.

## Research Before Code

For each new ability, weapon change, or visual change:

1. Copy [the feature template](research/FEATURE_TEMPLATE.md) into
   `docs/research/features/`.
2. Give it a short file name, such as `crypto-drone.md`.
3. Add the date and the Apex season or event.
4. Link the best source for every important rule or number.
5. Write the Minecraft plan in plain words.
6. Mark each part as exact, adapted, analogue, or not implemented.
7. Write the test cases before writing the feature code.
8. Ask for review when the plan changes team rules, damage, movement, or saved state.

The research note and code should be part of the same pull request. Review the
note first. Then review the implementation against it.

## Source Order

Use the strongest available source.

1. Current EA character pages, help pages, and patch notes.
2. Current statements from Respawn or an official Apex account.
3. Repeatable in-game testing with the game version and method written down.
4. A maintained community reference that links its evidence.
5. A clearly labeled inference when no measured fact is available.

Do not turn a trailer shot into an exact number. Do not call an old cooldown
current without checking a newer patch. Do not copy a community claim without
recording its date and game version.

## Source Record

Each research note should answer these questions:

- What page was checked?
- Who published it?
- When was the page published or updated?
- When did we check it?
- Which season, event, or patch does it describe?
- Does it state a number, or only describe behavior?
- Did a later source change the rule?

Official pages often describe recoil with words such as "improved" instead of
publishing the internal recoil table. In that case, record the direction of the
change and call Lapex's numeric value an approximation. Never present a made-up
number as an official value.

## Fidelity Labels

Use one label for every meaningful part of a feature.

| Label | Meaning | Example |
| --- | --- | --- |
| Exact | The player-facing rule matches within normal Minecraft precision. | Crypto's drone has 50 Apex HP, represented as 10 Minecraft health. |
| Adapted | The purpose matches, but input, timing, shape, or presentation changes. | A particle wall stands in for a large animated wall. |
| Analogue | Minecraft lacks the original system, so a documented substitute is used. | Fuse's grenade inventory passive uses explosion protection behavior. |
| Not implemented | The rule is missing or intentionally out of scope. | A feature must use this label until both code and tests exist. |

"One-to-one" is a release claim, not a goal statement. Use it only when the
research note has a current source and the live-client checklist passes.

## Minecraft Conversions

Lapex uses a few shared conversions:

- `damage_scale: 0.2` maps 100 Apex health to 20 Minecraft health.
- A distance in meters is usually treated as the same number of blocks when the
  arena scale supports it. Any exception belongs in the feature note.
- Apex seconds map to real server seconds. Minecraft runs at 20 ticks per second.
- Camera recoil uses yaw and pitch only. It must not change player position or velocity.
- Minecraft armor may reduce damage after Lapex calculates it. Note this in balance tests.

## Visual and Asset Rules

- Use original or properly licensed work. Do not copy game textures into the repository.
- Record the source and license for every outside asset.
- Prefer generated low-poly models and textures when no reusable asset is available.
- Show the real item or mechanic clearly. A decorative effect is not a substitute for a missing state.
- Test first person, third person, inventory, dropped item, ADS, firing, and reload views.

## Current Official Starting Points

- [EA mouse and keyboard controls](https://help.ea.com/en/articles/apex-legends/pc-and-controller-settings/)
- [EA Apex terms guide](https://help.ea.com/en/articles/apex-legends/terms-guide/)
- [EA legend hub](https://www.ea.com/games/apex-legends/apex-legends/characters-hub)
- [EA Crypto page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/crypto)
- [EA Shockwave patch notes](https://www.ea.com/games/apex-legends/apex-legends/news/shockwave-patch-notes)
- [EA current recoil and weapon changes](https://www.ea.com/games/apex-legends/apex-legends/news/astral-anomaly-event)

These links are starting points, not proof that a value is still current. Search
for later notes every time a balance value is changed.
