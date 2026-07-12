# Feature: Crypto Surveillance Drone

## Status

- Research date: 2026-07-13
- Fidelity goal: pilotable, visible, damageable remote camera with a vulnerable body
- Runtime status: implemented; two-player client verification still required

## Sources

- [Official Crypto page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/crypto)
- [Official Shockwave patch notes](https://www.ea.com/games/apex-legends/apex-legends/news/shockwave-patch-notes)

The character page establishes drone piloting, team detection, and EMP purpose.
The patch notes are the source for the current 30-second drone recovery window.

Source record: Electronic Arts publishes both pages. They were checked on
2026-07-13; the character page supplies behavior, while the Shockwave notes
supply the recovery change. The 200-block Minecraft range is Lapex tuning.

## What Players Should Understand

1. Tactical leaves a player-shaped body at Crypto's starting point.
2. The real player changes to spectator flight and controls the camera.
3. A glowing 50 HP drone proxy follows that camera, up to 200 blocks away.
4. Q or `/legend tactical` recalls the drone.
5. Shooting the drone damages the drone. Destroying it returns Crypto and starts
   recovery.
6. Shooting the fake body returns Crypto and forwards the accumulated hit damage
   to the real player. Shotgun pellets in one tick are collected before exit.
7. Team damage to the body and drone is blocked.

Vanilla spectator camera attachment is cancelled during piloting, so clicking
an entity cannot steal free-flight control. If an ability such as N.E.W.T.
moves the body, recall returns Crypto to the body's current location.

## Session Safety

The body, drone, and owner share one random session. A proxy is authoritative
only when it is also the exact entity recorded by the owner. Unique scoreboard
tags prevent two Cryptos deploying in the same place and tick from binding each
other's entities.

Quit records a one-use return location before proxy cleanup, preventing a player
from reconnecting at the remote spectator camera. Death, world or team change,
legend switch, reload, stale chunk load, and lost proxies all converge on the
same cleanup behavior.

## Paper Compatibility

Paper 26.1 accepts native summoned mannequins, armor stands, and allays in this
test environment while the corresponding Denizen spawn adapters rejected some
entities. Shared native spawn tasks use unique tags and bind the exact result
after Paper begins tracking it.

## Known Gaps

- Remote banners, respawn, beacon actions, and cloak are not implemented.
- EMP does not yet route through a general deployable disable policy.
- Shared scans, healing, protection, damage zones, and N.E.W.T. now use the
  body anchor; every remote-body interaction still needs live multiplayer verification.

## Verification Status

Session binding, cleanup, and script loading pass server tests. Camera input,
body/drone gun damage, shotgun collection, and reconnect need two live clients.
