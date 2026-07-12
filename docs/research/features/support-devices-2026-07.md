# Feature: Gibraltar and Lifeline Devices, July 2026

## Status

- Research date: 2026-07-13
- Scope: Gibraltar Dome, Lifeline D.O.C., Lifeline Halo
- Fidelity goal: visible devices with correct membership and counterplay

## Sources

- [Official Gibraltar page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/gibraltar)
- [Official Lifeline page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/lifeline)
- [Official From the Rift update](https://www.ea.com/games/apex-legends/apex-legends/news/from-the-rift-season-updates)
- [Official Takeover notes](https://www.ea.com/games/apex-legends/apex-legends/news/takeover-patch-notes)
- [Official Showdown notes](https://www.ea.com/games/apex-legends/apex-legends/news/showdown-patch-notes)
- [Community Gibraltar mechanics](https://apexlegends.wiki.gg/wiki/Gibraltar)
- [Community Lifeline mechanics](https://apexlegends.wiki.gg/wiki/Lifeline)

The official sources establish the important rules: Dome blocks attacks going in
or out, D.O.C. heals nearby allies and may follow an assigned ally, and Halo is
thrown, indestructible, and speeds health and shield consumables for every
player, including enemies. Halo has enemy-facing visual color.

Community documentation was used only to cross-check unpublished details. Dome
radius `6` and duration `12s`, plus D.O.C. radius `6`, healing `8` Apex HP each
second, and duration `20s`, are treated as Minecraft tuning until a current
primary source publishes those exact values.

Source record: Electronic Arts publishes the official pages and notes; wiki.gg
publishes the labeled community cross-checks. All were checked on 2026-07-13.
Only rules directly supported by the official pages are called official here.

## Gibraltar Dome

The Dome is a boundary, not an ally invulnerability buff.

- A shot beginning outside and ending inside stops at the shell.
- A shot beginning inside and ending outside stops at the shell.
- A shot crossing the whole Dome from outside also stops.
- A shot whose start and end are inside the same Dome continues.
- Team does not change any of these rules.
- Players and melee may cross the boundary normally.

Lapex places one visible, invulnerable emitter and draws a stable six-block
upper shell for 12 seconds. The hitscan engine must find the earliest visible-shell crossing
before it draws the tracer, creates a Whistler trap, or damages a target.

Official notes also establish current Dome destruction interactions with Crypto
EMP and Mad Maggie's Wrecking Ball. Those counters should route through shared
deployable cleanup, never a special orphan-removal path.

## Lifeline D.O.C.

Lapex places one visible, invulnerable heal drone for 20 seconds. Each second it
heals allied combat players within six blocks by `1.6` Minecraft HP, which maps
to `8` Apex HP at the current `0.2` scale.

Pressing tactical again while D.O.C. exists reassigns it without consuming a
new cooldown. An aimed ally is selected; aiming at empty space makes D.O.C.
follow Lifeline, while aiming at an enemy shows an error and keeps the old
target. The device follows the selected player's combat anchor. This
means a piloting Crypto is represented by the vulnerable body, not the remote
spectator camera.

D.O.C. pauses healing while malfunctioning in Nox gas and is removed by Crypto
EMP. These are community-aligned interactions and are labeled as such until a
current official note verifies them.

## Lifeline Halo

Halo is an open healing station, not a shield bubble.

- It is ray-placed on safe ground and cannot be shot.
- Friends and enemies may use it.
- It never grants invulnerability, regeneration, or slow falling by itself.
- Its purpose is shorter health and shield consumable use time.
- Friendly viewers see a cool color; enemies see a warning color.

Lapex uses a 25-block placement range, radius `8`, and duration `25s` as explicit
tuning. Exact half-time consumables require a tested custom consumable component
system. If the installed Paper/Denizen build cannot support that safely, Halo
remains visibly placed and the gameplay gap stays documented instead of being
replaced with an unrelated protection buff.

The missing thrown projectile arc is an intentional Minecraft adaptation.

## Required Tests

- Dome shots in both directions, outside-through-outside, and both endpoints inside.
- Multiple Domes choose the nearest boundary and never check teams.
- Tracers stop at the visible shell and Whistler does not create a mine there.
- D.O.C. heals allies, not enemies, follows reassignment, and uses Crypto's body.
- D.O.C. stops following invalid or cross-world targets without leaking a queue.
- Halo membership includes enemies and overlapping Halos do not multiply speed.
- All three clean up on death, quit, world change, legend switch, and reload.

The server reload, registry, deployable lifecycle, and upper-shell geometry
tests pass. Projectile timing, D.O.C. assignment, Halo membership, colors, and
all two-player cases remain pending.
