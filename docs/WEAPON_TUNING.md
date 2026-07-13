# Weapon Tuning Guide

This guide explains how one click becomes a Lapex shot and how to change balance
without breaking controls or player movement.

## Source Files

- `scripts/apex_weapon_data.dsc`: weapon numbers and roster lists
- `scripts/apex_weapon_items.dsc`: item names, lore, model IDs, and starting ammo
- `scripts/lapex_weapon_engine.dsc`: input, firing, damage, recoil, tracers, and reloads
- `tools/build_resource_pack.py`: model-ID map, geometry, and texture generation

Keep the same weapon ID in all four places.

## Shot Flow

```text
right-click use packet
      |
      v
validate held gun and action state
      |
      v
choose auto, semi, burst, spin-up, or charge path
      |
      v
spend one round -> move camera -> build ray(s)
      |
      v
draw tracer -> find target -> apply zone and special multipliers
      |
      v
hurt target -> restore target velocity -> update ammo display
```

The engine saves the eye location before recoil. The ray uses that saved aim, so
the current shot does not jump twice when the camera kick is sent.

Lapex uses carrot-on-a-stick right-click input because the client repeats those
use packets while the button is held. The first packet fires one automatic round
and arms a six-tick probe. Only a later packet inside that window confirms the
hold and refreshes the trigger lease. One auto loop then owns the magazine and
stops when that lease is no longer refreshed. Semi, burst, and charge actions
still pass through their own locks. Fractional tick remainder is carried between
shots and bursts so rates such as 810 RPM alternate integer delays instead of
becoming 600 RPM.
Server-controlled Arena bots use the same cadence procedure.

## Shared Numbers

| Key | Meaning |
| --- | --- |
| `damage_scale` | Converts Apex health values to Minecraft health. The current value is `0.2`. |
| `recoil_scale` | Multiplies every weapon's camera kick after its individual values. The current playtest value is `1.55`. |
| `player_raysize` | Expands ordinary player-shot hitboxes for Minecraft-scale aim tolerance. The current value is `0.30` blocks. Special homing weapons may override it. |
| `head_zone` | Height fraction at or above which a hit counts as a head hit. |
| `leg_zone` | Height fraction at or below which a hit counts as a leg hit. |
| `mark_bonus` | Damage multiplier against a Vantage-marked target for other guns. |
| `vantage_followup_multiplier` | A-13 follow-up multiplier. |

Minecraft armor applies after the scripted damage request. Test naked and
armored targets separately.

The shared recoil scale is presentation tuning, not an Apex balance statistic.
Keep per-weapon pitch, yaw, and sourced direction patterns relative to one
another. Change the shared scale only after firing several low-RPM and high-RPM
weapons without moving the mouse.

## Weapon Fields

| Field | Meaning | Review rule |
| --- | --- | --- |
| `name` | Display name | Match current terminology. |
| `class` | Weapon family | Used by passives, tracer style, and roster output. |
| `ammo` | Display ammo type | This test-range pack does not consume reserve items. |
| `mode` | `auto`, `semi`, `burst`, or `charge` | Spin-up is an optional field on an automatic weapon. |
| `damage` | Apex body damage per pellet or shot | Multiplied by `damage_scale`. |
| `head_mult` | Head multiplier | Applied after base damage. |
| `leg_mult` | Leg multiplier | Applied after base damage. |
| `rpm` | Rounds per minute | The engine starts from `1200 / rpm` ticks per round. |
| `mag` | Base magazine size | Item starting ammo must match. |
| `reload` | Tactical reload time | Used when rounds remain. |
| `empty_reload` | Empty reload time | Used at zero rounds. |
| `range` | Hitscan range in blocks | Tracer visibility supports up to 256 blocks. |
| `hip_spread` | Random yaw and pitch size without ADS | Larger means less accurate. |
| `ads_spread` | Random yaw and pitch size during ADS | Usually much smaller than hip spread. |
| `recoil_pitch` | Upward camera kick in degrees | The engine multiplies it by `-1`. |
| `recoil_yaw` | Horizontal kick envelope | Scales deterministic direction or unmeasured random kick. |
| `recoil_pattern` | Optional signed segment lengths | Positive is right, negative is left; only add sourced patterns. |
| `tracer` | RGB color | Must be readable against bright and dark blocks. |
| `sound_pitch` | Pitch of the shared shot sound | Keep it positive and test repeated fire. |

Optional fields cover pellets, horizontal patterns, burst size, charge time,
spin-up, shell reloads, and named special behavior. Search the engine for a
field before adding a new one. A data key with no reader does nothing.

## Recoil Invariant

Recoil is camera movement only.

Allowed:

```text
look <player> yaw:<new_yaw> pitch:<new_pitch>
```

Not allowed:

- teleporting the shooter, even with relative axes;
- changing the shooter's velocity;
- moving the player to an eye location;
- using a world position as a rotation packet workaround.

After a recoil change, record the player's location and velocity before and
after a full magazine. X, Y, Z, and velocity must stay unchanged unless normal
player input or another ability moves them.

EA patch notes do not normally publish the full internal recoil table. Use them
to verify the direction of a change. Treat Lapex's numeric camera kick as a
measured approximation unless a current, repeatable source provides exact data.

## ADS

One left-click toggles ADS on. The next left-click toggles it off. While the
weapon-scoped `lapex.ads` flag matches the held gun:

- FOV multiplier is `0.72`;
- `ads_spread` replaces `hip_spread`;
- shotgun pellet spread is multiplied by `0.45`.

ADS does not use a release timer. Item changes, reloads, world changes, join,
quit, death, respawn, and script reloads all call the same cancellation task.
Denizen's `fov_multiplier` mechanism must be sent with no value to restore the
client default. Sending `fov_multiplier:1` leaves a packet-level override and
must not be used as cleanup.

## Confirmed Damage Feedback

The weapon engine snapshots health and absorption immediately around the
synchronous `hurt` request. It converts only the accepted difference back to
Apex HP by dividing by `damage_scale`. Red numbers are health damage, aqua
numbers are absorption damage, and the final number is remaining combined HP.

Do not play the normal hit-confirm sound before this comparison. Damage can be
canceled by Arena phase ownership, teams, protection abilities, creative mode,
or another event. Deployables and Crypto's drone use authoritative virtual HP.
Crypto's body stores source and weapon metadata with its pellet batch, snapshots
health immediately around the delayed real-player damage, then confirms only
after armor and absorption. If two different sources contribute in the same
tick, damage still applies but shooter-specific numbers, marks, and debuffs are
suppressed rather than falsely credited to the last source.
Arena's internal one-HP elimination sentinel is reported as zero remaining HP.
Shotgun pellets are accumulated once per trigger before the ammo actionbar is sent.

The source carries `lapex.damage_transaction` only while an authoritative
hitscan `hurt` event is running. Generic passive telemetry yields to that token;
the weapon, bot, or Crypto flush writes attacker and threat flags only after its
before/after comparison succeeds.

## Tracers

Tracers use colored dust along the ray. Precision shots add end rods. Charge
shots add electric sparks. Shotguns draw representative first, center, and last
pellet paths instead of every pellet path.

Automatic guns draw a full tracer every second round. Sheila draws one every
fourth round. This keeps the particle cost bounded. Every tracer layer uses a
256-block visibility radius so the far end of a long shot is not cut off by the
default particle distance.

Before a tracer or hit is accepted, the engine asks the shared Gibraltar Dome
geometry for the first shell crossing. A blocked tracer ends at that exact
point. The shot cannot damage, mark, or create a Whistler mine behind it.

Test tracers from the side as another player. A shooter-only test cannot prove
that other players see the correct path.

## Special Weapon State

- Sentinel amp and Rampage rev flags live on the physical gun item. Swapping to
  another copy does not transfer the charge.
- Rampage reads its rev state before every automatic-fire interval, so RPM returns to base
  as soon as the item flag expires.
- Whistler carries two rounds, refreshes heat to 15 seconds, and uses 50 Apex
  overheat damage. Independent tactical recharge is still a known gap.
- A-13 manual reload is blocked. A carried item starts at two rounds and gains
  one every 40 seconds until six; Vantage team tracking adds fractional progress.
- Charge Rifle remains delayed hitscan with range scaling. Projectile travel,
  drop, and current select-fire behavior are not simulated.

EA does not publish complete recoil sequences. The current signed direction
segments come from the [July 2026 weapon input and recoil research
record](research/features/weapon-input-recoil-2026-07.md); `recoil_pitch` and
`recoil_yaw` strength remain Lapex approximations even when current damage and
multiplier changes have an official source.

## Safe Balance Change

1. Create or update a research note.
2. Change the smallest set of data fields.
3. Run `/lapex validate`.
4. Test one full magazine in hip fire and ADS.
5. Test tactical and empty reloads.
6. Test head, body, and leg hits at close and maximum range.
7. Test an ally, an enemy, armor, Vantage marks, Amped Cover, and phase protection.
8. Watch the console and server tick time during the fastest automatic gun.
9. Record any value that is an approximation.
