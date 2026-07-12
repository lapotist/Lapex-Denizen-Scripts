# Feature: Octane Stim and Stim Surge, July 2026

## Status

- Research date: 2026-07-13
- Fidelity goal: current second-input Surge instead of automatic low-health healing

## Sources

- [Official Octane page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/octane)
- [Official Winter Wipeout notes](https://www.ea.com/games/apex-legends/apex-legends/news/winter-wipeout-event)
- [Official Breach notes](https://www.ea.com/games/apex-legends/apex-legends/news/breach-patch-notes)
- [Official Apex Live Comms adjustment](https://x.com/ApexLiveComms/status/2026102651662827797)

## Verified Current Contract

- Base Stim lasts six seconds and has a 0.7-second reuse delay.
- The live card displays 35 walk speed and 45 sprint speed, but does not publish
  units or percent signs.
- A second tactical use while Stim is active refreshes Stim and triggers Surge.
- Surge lasts six seconds, costs zero health, and has its own 20-second cooldown.
- Surge triggers Swift Mend and lets that healing continue through incoming damage.
- Published Swift Mend endpoints are 3 Apex HP each second at high health and up
  to 9 at low health. The exact curve between those endpoints is unpublished.
- A February 24 adjustment removed the earlier Fortified bonus. Lapex must not
  keep damage reduction from that older version.
- Octane currently stores two Launch Pad ultimate charges.

Source record: Electronic Arts publishes the character and patch-note pages;
the official Apex Live Comms account publishes the linked adjustment. They were
checked on 2026-07-13. Published durations, cooldowns, charge count, and healing
endpoints are separated above from Lapex's unpublished cost and speed tuning.

## Lapex Mapping

Normal tactical use spends up to 20 Apex HP as an explicit Lapex tuning value
because the current source does not publish the exact cost. It never lowers
Octane below the half-heart floor; use at that floor is rejected. It grants six
seconds of Minecraft Speed. Using tactical again during that flag grants the
zero-cost Surge and linearly scales one-second healing pulses from 3 to 9 Apex
HP based on missing health.

Lapex does not yet buffer a held tactical input. The player presses Q or the
command a second time. The current Daredevil missing-health extension is also
not implemented.

Launch Pad uses the shared persistent charge system. Two placements are ready;
each spent charge receives its own 90-second Lapex recharge time. Two charges
mean stored uses, not an owner limit for active pad objects.

## Verification Status

The registry, independent charge timing, cap restoration, and script reload
tests pass. Base/Surge input, health floor, healing curve, and pad behavior still
need a live client.
