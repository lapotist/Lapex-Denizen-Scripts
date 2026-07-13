# Legend Guide and Current Status

Every legend has a passive, tactical, and ultimate route in Lapex. That does not
mean every route is a perfect copy. This guide says what the original idea is,
what Lapex does today, and what is still missing.

The words are simple on purpose. The linked EA pages are the source for the Apex
idea. Exact numbers need a current patch note or a repeatable test; a character
page often explains behavior without publishing all numbers.

## Fidelity Key

- **Closer adaptation:** the main flow and counterplay are recognizable.
- **Adapted:** the main idea is present, but an important rule or choice changed.
- **Analogue:** Lapex uses a simpler Minecraft substitute.

No legend is marked one-to-one yet. That label requires the full live-client
checklist in [Testing](TESTING.md).

## Assault Legends

### Ballistic

- **Apex idea:** carry a third Sling gun, overheat one enemy gun with Whistler,
  and give the squad fast reloads and unlimited ammo with Tempest.
- **Lapex today:** the Sling uses the offhand, Whistler is a two-round special
  gun with heat and trap behavior, and Tempest grants team ammo and reload help.
- **Status:** adapted.
- **Still missing:** independently recharging tactical charges, one-weapon heat
  ownership, and a real gold Sling upgrade.
- [Official Ballistic page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/ballistic)

### Bangalore

- **Apex idea:** run faster when attacked, launch a smoke wall, and call creeping artillery.
- **Lapex today:** sprinting damage gives speed, smoke makes a round blindness
  cloud, and delayed explosions move across a line.
- **Status:** adapted and easy to recognize.
- **Still missing:** threat-direction checks, a wall-shaped smoke canister, and
  physical artillery markers.
- [Official Bangalore page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/bangalore)

### Fuse

- **Apex idea:** carry and throw grenades better, fire a repeating sticky
  cluster, and scatter explosives with Motherlode.
- **Lapex today:** Fuse takes less explosion and fire damage, fires a repeating
  burst at one point, and creates a ring of fire.
- **Status:** analogue.
- **Still missing:** grenade inventory rules, sticky behavior, the current
  Motherlode pattern, and its ADS cover-piercing mode.
- [Official Fuse page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/fuse)

### Mad Maggie

- **Apex idea:** mark enemies she hurts, move well with shotguns, drill through
  cover, and roll a ball that leaves sprint pads.
- **Lapex today:** marks and shotgun speed work, while the drill burns around an
  impact and the ultimate draws a damaging path with short speed boosts.
- **Status:** adapted.
- **Still missing:** true far-side cover damage, a bouncing ball entity, enemy
  trigger rules, and reusable sprint pads.
- [Official Mad Maggie page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/mad-maggie)

### Revenant

- **Apex idea:** hunt weak enemies, climb and crouch better, charge a pounce, and
  gain a shadow shield that can refresh after a knock.
- **Lapex today:** weak enemies are outlined, tactical pushes forward once, and
  the ultimate gives timed absorption, speed, and resistance.
- **Status:** analogue.
- **Still missing:** climb and crouch movement, hold-to-charge distance, a
  regenerating shadow shield, and knock refresh.
- [Official Revenant page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/revenant)

## Skirmisher Legends

### Alter

- **Apex idea:** take selected loot from a death box, make a passage through a
  surface, and place a nexus that allies choose to return to.
- **Lapex today:** sneaking pulls the nearest loose item, tactical ray-teleports,
  and the nexus automatically recalls nearby low-health allies.
- **Status:** analogue.
- **Still missing:** death-box selection, real surface passage geometry, a
  placed nexus object, and each ally's choice to return.
- [Official Alter page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/alter)

### Ash

- **Apex idea:** air dash, tether the first enemy hit by Arc Snare, and open a
  targeted one-way portal.
- **Lapex today:** air dash works, Arc Snare is still a slow area, and Phase
  Breach is a visible 100-block one-way portal. Ash travels first; other players
  choose whether to enter its origin.
- **Status:** adapted ultimate with live verification pending; tactical remains analogue.
- **Still missing:** first-target tether distance, a visible snare object, and
  final multiplayer portal timing tests.
- [Official Ash page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/ash)

### Axle

- **Apex idea:** control fast slides, place a team-neutral Nitro Gate, and send a
  destructible drone that hunts and displaces an enemy.
- **Lapex today:** sprinting Sneak starts a steerable Drift, two visible 100 HP
  team-neutral gates grant a five-second steerable slide, and Sneak cancels it.
  The ultimate still directly strikes the nearest enemy.
- **Status:** adapted passive/tactical with live verification pending; ultimate remains analogue.
- **Still missing:** a visible seeking Kickstart drone, reveal, destruction
  counterplay, and velocity-based knockback.
- [Official Axle page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/axle)

### Horizon

- **Apex idea:** control the air, place a gravity lift, and throw a black-hole
  device called N.E.W.T.
- **Lapex today:** jumping gives slow fall and speed, the lift raises living
  entities, and one visible 225 HP N.E.W.T. pulls and slows enemies for six
  seconds without an unsupported final damage blast.
- **Status:** adapted, with final N.E.W.T. live verification pending.
- **Still missing:** real air steering, a Gravity Lift model and exit boost, and
  live model/hitbox alignment testing.
- [Official Horizon page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/horizon)

### Octane

- **Apex idea:** heal out of combat, spend health for Stim, press Stim again for
  Surge, and place a reusable double-jump pad.
- **Lapex today:** healing works, Stim costs tuned health, and a second tactical
  input triggers a zero-cost six-second Surge with scaling Swift Mend. Octane
  stores two pad charges; visible 200 HP pads launch anyone and Sneak redirects
  one airborne double jump.
- **Status:** adapted, with pad and Surge live verification pending.
- **Still missing:** held-input Surge buffering, exact unpublished speed/cost
  numbers, Daredevil extension, and final pad movement tuning.
- [Official Octane page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/octane)

### Pathfinder

- **Apex idea:** use scans to recharge and improve Zipline, store two grapples,
  and place a protected rideable zipline.
- **Lapex today:** Minecraft beacons shorten the current ultimate cooldown, two
  independently recharging grapple charges pull the player, and a timed particle line
  pushes riders.
- **Status:** analogue.
- **Still missing:** current scan math, a physical reusable bidirectional
  zipline, rider control, and incoming-damage reduction.
- [Official Pathfinder page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/pathfinder)

### Wraith

- **Apex idea:** warn before danger, phase safely, and link two portals for 45 seconds.
- **Lapex today:** warns after a threat flag is created, phase blocks damage and
  Lapex attacks, and two portal points work in both directions for 45 seconds.
- **Status:** adapted, with portal live verification pending.
- **Still missing:** pre-shot aim warning, broader vanilla interaction blocking,
  and physical endpoint models.
- [Official Wraith page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/wraith)

## Recon Legends

### Bloodhound

- **Apex idea:** read clues and White Ravens, scan forward through structures,
  and hunt with speed and refreshed scans.
- **Lapex today:** recent damage and shots leave clues, tactical scans players in
  a circle, and ultimate gives speed and threat outlines.
- **Status:** adapted.
- **Still missing:** ravens, interaction clues, a forward scan shape, trap scans,
  squad-shared details, and knock-based refresh and extension.
- [Official Bloodhound page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/bloodhound)

### Crypto

- **Apex idea:** pilot a 50 HP drone, share nearby detections, use remote map
  interactions, cloak while piloting, and EMP shields and traps.
- **Lapex today:** spectator flight controls a visible 50 HP drone while a
  session-bound damageable mannequin body stays behind. Body shotgun pellets
  are collected before returning Crypto. Proxy-aware scan, support, and
  shield-only EMP behavior use the body instead of the remote camera.
- **Status:** adapted, with two-player drone verification pending.
- **Still missing:** cloak, remote beacon/banner/respawn actions, trap
  destruction, and final live-client input and proxy-damage testing.
- [Official Crypto page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/crypto)

### Seer

- **Apex idea:** sense heartbeats while aiming, send a delayed wall-passing
  silence scan, and place a damageable movement-tracking Exhibit.
- **Lapex today:** active ADS reports a nearby enemy distance, tactical
  silences and scans one endpoint area without health damage, and an
  undamageable particle sphere scans everyone.
- **Status:** analogue.
- **Still missing:** true directional ADS cone cues, delayed tunnel geometry, a
  damageable Exhibit, movement/fire filters, and Seer's current double jump.
- [Official Seer page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/seer)

### Sparrow

- **Apex idea:** double jump from air or walls, carry more Bocek arrows, place a
  line-of-sight tracker dart, and anchor a charging shock bolt.
- **Lapex today:** a timed midair push acts as double jump, the dart scans a
  circle through blocks, and the bolt makes one delayed damaging scan blast.
- **Status:** analogue.
- **Still missing:** wall reset, Bocek capacity rules, line-of-sight scan,
  beacon action, visible dart health, and the full anchored charge sequence.
- [Official Sparrow page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/sparrow)

### Valkyrie

- **Apex idea:** fly with fuel, fire a rocket grid, and let willing squadmates
  join a steerable skydive with enemy scans.
- **Lapex today:** one short levitation pulse has a cooldown, missiles repeat at
  one point, and the ultimate lifts every nearby ally.
- **Status:** analogue.
- **Still missing:** a fuel loop and steering, threat vision, grid impacts,
  opt-in hook-in, skydive control, and enemy scans.
- [Official Valkyrie page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/valkyrie)

### Vantage

- **Apex idea:** read teams and bullet drop, position Echo, launch and double
  jump to Echo, and mark enemies with a custom sniper.
- **Lapex today:** active ADS shows one target's health and distance and
  tracking a team adds 70 percent of A-13 round progress. Tactical pushes toward
  the aimed point; A-13 regenerates rounds, marks, and amplifies follow-up damage.
- **Status:** adapted.
- **Still missing:** shield/team/drop data, persistent Echo position and recall,
  line-of-sight launch choices, double jump, targeting laser, and canted sight.
- [Official Vantage page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/vantage)

## Controller Legends

### Catalyst

- **Apex idea:** own reinforced doors, store persistent spike patches, and raise
  a wall that slows and blocks sight.
- **Lapex today:** sneak-use closes a door and gives it three reinforced break
  attempts for 30 seconds, while spikes and veil are timed particle zones.
- **Status:** analogue.
- **Still missing:** exact door health/rebuilding, charge and object limits,
  physical spikes, and a wall that truly blocks vision.
- [Official Catalyst page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/catalyst)

### Caustic

- **Apex idea:** earn current Field Research progress, store up to six shootable
  gas traps, and throw a large gas grenade.
- **Lapex today:** gas damage can grant absorption. Caustic places up to six
  visible 225 HP traps that arm, trigger from enemies or shots, emit 22 seconds
  of ramping non-stacking gas, ground enemies, and use shared cleanup.
- **Status:** adapted, with trap overlap and model verification pending.
- **Still missing:** current passive upgrade sources, exact placement rejection,
  a gas-grenade model, and final multiplayer overlap tests.
- [Official Caustic page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/caustic)

### Rampart

- **Apex idea:** improve LMGs and Sheila, build charged directional cover with
  health, and use Sheila as a mobile or shared placed turret.
- **Lapex today:** magazine and reload boosts work, cover is a timed protection
  and damage-buff area, and ultimate gives or reloads mobile Sheila.
- **Status:** adapted.
- **Still missing:** Evo cover health, three charges, direction and two-part
  damage, placement and repair, and a shared stationary turret.
- [Official Rampart page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/rampart)

### Wattson

- **Apex idea:** use accelerants well, store and connect fence nodes, and place a
  damageable pylon that destroys ordnance and restores shields.
- **Lapex today:** passive gives timed absorption, tactical creates one temporary
  damaging line, and pylon protection is a timed particle area around allies.
- **Status:** analogue.
- **Still missing:** accelerant input, stored node pairs, door links, physical
  fence objects, projectile interception, Arc Star conversion, pylon health, and owner limits.
- [Official Wattson page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/wattson)

## Support Legends

### Conduit

- **Apex idea:** run toward distant team needs, regenerate shields for one
  teammate and herself, and throw a destructible jammer array.
- **Lapex today:** distant allies grant speed, two independently recharging
  tactical charges give instant absorption to all nearby allies, and ultimate
  is an undamageable slowing damage line.
- **Status:** analogue.
- **Still missing:** banner and beacon paths, target choice, regeneration over
  time, exact self/ally amounts, and damageable jammer objects.
- [Official Conduit page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/conduit)

### Gibraltar

- **Apex idea:** raise a shield while ADS, gain sustained empty-hand sprint
  momentum, place a two-way shot-blocking dome, and call a bombardment.
- **Lapex today:** active ADS blocks one hit every nine seconds, empty-hand
  sprint grants speed, and a visible 12-second Dome stops hitscan and projectile
  attacks crossing either direction for every team. Bombardment makes random blasts.
- **Status:** adapted, with live Dome projectile and overlap verification pending.
- **Still missing:** exact Gun Shield health, full projectile-plugin coverage,
  and physical bombardment markers.
- [Official Gibraltar page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/gibraltar)

### Lifeline

- **Apex idea:** glide and let D.O.C. revive, send a healing drone that can
  follow an ally, and place Halo where everyone uses healing items faster.
- **Lapex today:** midair Sneak gives slow fall and low-health allies receive an
  analogue heal. A visible D.O.C. heals allies and can be reassigned to follow
  one. Halo is visible, indestructible, team-neutral, and enemy-colored, but no
  longer grants unrelated protection or regeneration.
- **Status:** D.O.C. is adapted; passive and Halo remain partial analogues.
- **Still missing:** downed/revive state and tested custom health/shield items
  whose use time Halo can actually shorten.
- [Official Lifeline page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/lifeline)

### Loba

- **Apex idea:** see valuable loot, throw a teleport bracelet, and place a shared
  market where players choose nearby loot.
- **Lapex today:** all nearby dropped items get particles, bracelet ray-teleports
  after a delay, and the ultimate gives only Loba two random standard guns.
- **Status:** analogue.
- **Still missing:** rarity and container rules, private highlights, a visible
  shared market, nearby-loot inventory, player choice, ammo/medicine, banners,
  limits, and destruction.
- [Official Loba page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/loba)

### Mirage

- **Apex idea:** cloak during revives and beacon use, control one hologram, and
  deploy a team of controllable holograms.
- **Lapex today:** sneaking near a low-health ally grants short invisibility and
  protection, while tactical and ultimate draw moving particle decoys.
- **Status:** analogue.
- **Still missing:** downed/revive state, beacon hooks, visible player-like
  decoy entities, control, copying movement, hit feedback, and scan interactions.
- [Official Mirage page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/mirage)

### Newcastle

- **Apex idea:** drag and shield a downed ally, move a shield drone, and leap to
  build an electrified stronghold.
- **Lapex today:** sneaking by a low-health ally gives protection and healing,
  tactical is a stationary protection point, and ultimate pushes Newcastle to a particle wall.
- **Status:** analogue.
- **Still missing:** downed dragging and revive, a visible movable shield with
  health, target selection, a physical fortified wall, full stronghold geometry,
  wall health, and electrified enemy crossing behavior.
- [Official Newcastle page](https://www.ea.com/games/apex-legends/apex-legends/characters-hub/newcastle)

## Research Notes

Current numeric changes that have official Season 29 support are recorded in
the [legend fidelity audit](research/features/legend-fidelity-audit-2026-07.md).
When a later patch changes a legend, update that research note before updating
this beginner guide or the code.
