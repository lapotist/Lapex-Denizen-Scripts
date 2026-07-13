# Feature: Weapon Input, Cadence, and Recoil, July 2026

## Status

- Research date: 2026-07-13
- Scope: weapon input, firing cadence, ADS cleanup, and horizontal recoil direction
- Apex season or event: Season 29 / Overclocked
- Fidelity goal: measured direction patterns with honest input and 20 TPS limits

## Player Story

Right-click should support held automatic fire. Left-click should provide a
discrete ADS toggle that cannot strand the player's field of view. Recoil should
move only the camera, with a repeatable shape that a player can learn.

`RPM` means rounds per minute. A gun at 600 RPM fires ten bullets each second.
Minecraft runs twenty server ticks each second, so that gun fires once every two
ticks. Some Apex timings land between whole ticks; Lapex must alternate nearby
tick delays or select the closest safe whole-tick burst lock.

## Vanilla Left-Click Constraint

The installed Minecraft 26.1.2 client, Paper API, and Denizen runtime were
audited together. A physical attack press sends one swing/attack packet. While
the button remains down, the client continues real-block destruction, but it
does not send a general held or release state for air or entity aim. Paper's
`Input` exposes forward, backward, left, right, jump, sneak, and sprint only.

A resource pack cannot add network input. A server timer also cannot tell a
left-click tap from a hold. Lapex therefore uses the available control remap:
right-click item-use packets refresh a short automatic-trigger lease, while a
discrete left-click toggles ADS. The lease has a small release tail because the
server learns that the button was released only when repeated packets stop.
The first packet fires one round but does not start continuous fire. A second
packet inside the six-tick probe window confirms the hold, preventing an
ordinary tap from being interpreted as a burst.

The installed Denizen runtime documents a second important constraint:
`fov_multiplier` with no value restores the client's normal FOV. A value of `1`
is still an override and is not the reset operation.

## Sources

- [Denizen PlayerTag source](https://github.com/DenizenScript/Denizen/blob/dev/plugin/src/main/java/com/denizenscript/denizen/objects/PlayerTag.java),
  checked 2026-07-13. The `fov_multiplier` mechanism explicitly uses an empty
  value to reset its packet override.
- [Denizen block/air click event](https://meta.denizenscript.com/Docs/Events/player%20right%20clicks%20block),
  checked 2026-07-13. The event covers clicks on blocks and in air and warns
  that duplicate events should be rate-limited.
- [Apex Legends Wiki weapon comparison](https://apexlegends.wiki.gg/wiki/Weapon),
  checked 2026-07-13. This community-maintained table provides current fire
  modes and effective rates.
- [Apex Legends Wiki Nemesis page](https://apexlegends.wiki.gg/wiki/Nemesis_Burst_AR),
  checked 2026-07-13. Its advanced statistics list 18 rounds per second inside
  each burst, a 0.31-second uncharged delay between bursts, and a 0.19-second
  fully charged delay.
- [Do_ASAP recoil practice and all-gun pattern video](https://www.youtube.com/watch?v=8QQJAwUaRi0),
  published 2026-01-28 and checked 2026-07-13. The chapter overlays show shot
  counts for each left/right section of a magazine.

The wiki is not an official Electronic Arts source. The video is a visual
measurement, not game data. These sources are useful for implementation, but a
future Apex patch or a better instrumented capture can replace them.

## Sourced Cadence Facts

| Weapon | Current evidence | Registry decision |
| --- | --- | --- |
| Nemesis | 18 shots/second inside a four-round burst; effective rate rises from 451 to 582 RPM with charge | Set intra-burst `rpm` to 1080; keep the existing 11-tick base burst lock until charge is implemented |
| Prowler | 579 effective RPM in five-round burst mode | Use a 10-tick burst lock, the closest whole-tick choice (600 effective RPM rather than the old 667) |
| G7 Scout | 252 RPM | Set `rpm` to 252 |
| Triple Take | 81 RPM | Set `rpm` to 81 |
| Sentinel | 38 RPM | Set `rpm` to 38 |
| Mozambique | Automatic, 202 RPM | Set `mode` to `auto` and `rpm` to 202 |

The registry already matched the reviewed current rates for HAVOC, Flatline,
Hemlok Breach, R-301, Alternator, R-99, Volt, C.A.R., Devotion, L-STAR,
Spitfire, Rampage, 30-30, Charge Rifle, Longbow, Kraber, P2020, and base
Mastiff cadence.

## Recoil Direction Mapping

The registry stores each observed horizontal segment as a signed shot count:

- A positive number means the camera moves right.
- A negative number means the camera moves left.
- `[12, -7, 12]` means 12 shots right, then 7 left, then 12 right.
- `recoil_yaw` still controls strength. The video supports direction and segment
  length, not an exact Minecraft camera angle.

| Weapon | Video chapter | Registry pattern |
| --- | --- | --- |
| HAVOC | 3:18 | `[5, -5, 7, -12]` |
| Flatline | 2:41 | `[-7, 5, -10, 7]` |
| R-301 | 2:06 | `[12, -7, 12]` |
| Alternator | 7:00 | `[15, -11, 4]` |
| R-99 | 6:34 | `[9, -5, 4, -5, 4]` |
| Volt | 7:49 | `[11, -4, 4, -10]` |
| C.A.R. | 7:28 | `[-9, 6, -3, 6, -6]` |
| Devotion | 5:52 | `[-20, 23, -5]` |
| L-STAR | 6:07 | `[-4, 24]` |
| Spitfire | 5:03 | `[-7, 5, -10, 13, -11, 4]` |

These are direction envelopes, not frame-by-frame mouse instructions. A small
amount of camera jitter can sit inside the envelope, but it must not reverse the
listed direction or move the player's body.

## Deliberately Unchanged Values

- EVA-8, Mastiff, and Peacekeeper comparison rates depend on Shotgun Bolt level;
  Lapex does not model that attachment yet.
- Bocek rate depends on charge state, so its single registry number cannot be
  replaced safely from the max-charge table value.
- The current RE-45 Burst page labels its overall rate unknown. Its advanced
  13-round-per-second value does not establish windup and inter-burst timing.
- Wingman sources disagree between the individual page and comparison table.
- Rampage, Hemlok, Nemesis, Prowler, and RE-45 video overlays were not clear
  enough to encode as high-confidence direction segments in this pass.
- The Nemesis auto-trigger and charge meter still need engine state. Changing
  data alone cannot reproduce their ramp from 451 to 582 effective RPM.

## Test Cases

- [ ] Tap every automatic weapon once; exactly one round should leave the gun.
- [ ] Hold right-click on every automatic weapon; cadence must match registry RPM.
- [ ] Release right-click; the automatic loop must stop when its short lease ends.
- [ ] Fire the Nemesis once; four fast rounds should leave in one burst.
- [ ] Click the Prowler through four bursts and verify the lock is ten ticks.
- [ ] Repeat-click the Mozambique and verify its cap is about 202 RPM.
- [ ] Fire each patterned weapon into a wall without mouse input and compare the
  left/right turns to the table above.
- [ ] Confirm recoil changes camera yaw and pitch without changing player
  position or velocity.
- [ ] Toggle ADS off, swap items, reload, change worlds, reload scripts, die,
  and disconnect; camera FOV
  must return to normal every time.
- [ ] Confirm the server console shows no script errors during every test.

## Known Gaps

The engine now consumes `recoil_pattern`, keeps small jitter inside its sourced
direction, and changes camera yaw/pitch only. Recoil strength is still Lapex
tuning. Attachment cadence, Nemesis charge, and RE-45 windup/auto-trigger remain
separate work. Held-left automatic fire remains blocked by the vanilla protocol;
Lapex now uses held right-click item input instead.

The 2026-07-13 playtest reported that the first camera-kick calibration was too
small. Lapex now applies a shared `1.55` presentation scale after each weapon's
existing pitch, yaw, and sourced direction pattern. This number is explicitly a
Minecraft feel adjustment, not a claimed Apex internal recoil value; recheck the
stationary full-magazine matrix before changing it again.
