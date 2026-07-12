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
left-click swing
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

## Shared Numbers

| Key | Meaning |
| --- | --- |
| `damage_scale` | Converts Apex health values to Minecraft health. The current value is `0.2`. |
| `head_zone` | Height fraction at or above which a hit counts as a head hit. |
| `leg_zone` | Height fraction at or below which a hit counts as a leg hit. |
| `mark_bonus` | Damage multiplier against a Vantage-marked target for other guns. |
| `vantage_followup_multiplier` | A-13 follow-up multiplier. |

Minecraft armor applies after the scripted damage request. Test naked and
armored targets separately.

## Weapon Fields

| Field | Meaning | Review rule |
| --- | --- | --- |
| `name` | Display name | Match current terminology. |
| `class` | Weapon family | Used by passives, tracer style, and roster output. |
| `ammo` | Display ammo type | This test-range pack does not consume reserve items. |
| `mode` | `auto`, `semi`, `burst`, `spinup`, or `charge` | Test the matching trigger path. |
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
| `recoil_yaw` | Horizontal kick envelope | Current code picks a value within half this width. |
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

Carrot-on-a-stick use packets refresh a short `lapex.ads` flag. While the flag
matches the held gun:

- FOV multiplier is `0.72`;
- `ads_spread` replaces `hip_spread`;
- shotgun pellet spread is multiplied by `0.45`.

The release task uses a token. An old task cannot turn off a newer ADS hold.
Item changes, join, and quit reset FOV to `1`.

## Tracers

Tracers use colored dust along the ray. Precision shots add end rods. Charge
shots add electric sparks. Shotguns draw representative first, center, and last
pellet paths instead of every pellet path.

Automatic guns draw a full tracer every second round. Sheila draws one every
fourth round. This keeps the particle cost bounded. Every tracer layer uses a
256-block visibility radius so the far end of a long shot is not cut off by the
default particle distance.

Test tracers from the side as another player. A shooter-only test cannot prove
that other players see the correct path.

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
