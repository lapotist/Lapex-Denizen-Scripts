# Lapex legend registry.
#
# Base cooldowns target the current Season 29 / Overclocked roster. Notes give
# concise Minecraft implementation guidance while keeping behavior tunable here.

lapex_legend_data:
    type: data

    all_ids:
    - alter
    - ash
    - axle
    - ballistic
    - bangalore
    - bloodhound
    - catalyst
    - caustic
    - conduit
    - crypto
    - fuse
    - gibraltar
    - horizon
    - lifeline
    - loba
    - mad_maggie
    - mirage
    - newcastle
    - octane
    - pathfinder
    - rampart
    - revenant
    - seer
    - sparrow
    - valkyrie
    - vantage
    - wattson
    - wraith

    legends:
        alter:
            name: Alter
            class: Skirmisher
            passive: Gift from the Rift
            tactical: Void Passage
            ultimate: Void Nexus
            tactical_cooldown: 25s
            ultimate_cooldown: 2m
            passive_note: Sneak to pull one nearby dropped item through the Void every 10s.
            tactical_note: Teleport through the aimed surface or space up to 24 blocks.
            ultimate_note: Recall nearby allies to a nexus automatically when their health becomes critical.
        ash:
            name: Ash
            class: Skirmisher
            passive: Predator's Pursuit
            tactical: Arc Snare
            ultimate: Phase Breach
            tactical_cooldown: 20s
            ultimate_cooldown: 2.5m
            passive_note: Grant a directional midair dash with its own 10s cooldown.
            tactical_note: Launch a persistent snare zone that damages and slows hostiles.
            ultimate_note: Cut a one-way breach that moves nearby allies to the aimed location.
        axle:
            name: Axle
            class: Skirmisher
            passive: Drift
            tactical: Nitro Gate
            ultimate: Kickstart
            tactical_cooldown: 25s
            ultimate_cooldown: 1.5m
            passive_note: Sneak on the ground for a short forward slide-like push and speed boost.
            tactical_note: Place a team-neutral speed gate that launches anyone passing through.
            ultimate_note: Strike the nearest hostile after a delay, then damage, slow, and push it upward.
        ballistic:
            name: Ballistic
            class: Assault
            passive: Sling
            tactical: Whistler
            ultimate: Tempest
            tactical_cooldown: 25s
            ultimate_cooldown: 2m
            passive_note: Use sneak plus swap to rotate a Lapex gun through the offhand Sling slot.
            tactical_note: Deploy the Whistler smart pistol for lock-on heat rounds and proximity traps.
            ultimate_note: Give nearby allies infinite Lapex ammo, faster reloads, speed, and haste for 30s.
        bangalore:
            name: Bangalore
            class: Assault
            passive: Double Time
            tactical: Smoke Launcher
            ultimate: Rolling Thunder
            tactical_cooldown: 30s
            ultimate_cooldown: 3.5m
            passive_note: Grant a short speed burst when attacked while sprinting.
            tactical_note: Launch a smoke canister that blinds entities inside its persistent cloud.
            ultimate_note: Call a line of delayed rolling artillery explosions.
        bloodhound:
            name: Bloodhound
            class: Recon
            passive: Tracker
            tactical: Eye of the Allfather
            ultimate: Beast of the Hunt
            tactical_cooldown: 25s
            ultimate_cooldown: 2.5m
            passive_note: Show recent player tracks and interaction clues.
            tactical_note: Briefly outline nearby hostiles with a private radial scan.
            ultimate_note: Boost speed and night vision while repeatedly outlining nearby enemies for 30s.
        catalyst:
            name: Catalyst
            class: Controller
            passive: Barricade
            tactical: Piercing Spikes
            ultimate: Dark Veil
            tactical_cooldown: 20s
            ultimate_cooldown: 2.5m
            passive_note: Sneak-use a door to close it and gain a short reinforced damage state.
            tactical_note: Throw a persistent ferrofluid trap that slows and damages enemies.
            ultimate_note: Raise a long vision-blocking wall that hinders enemies crossing it.
        caustic:
            name: Caustic
            class: Controller
            passive: Field Research
            tactical: Nox Gas Trap
            ultimate: Nox Gas Grenade
            tactical_cooldown: 20s
            ultimate_cooldown: 2m
            passive_note: Earn a temporary absorption shield after repeated Nox ability damage.
            tactical_note: Place a temporary proximity point that emits damaging Nox gas when triggered.
            ultimate_note: Throw a grenade that fills its impact area with Nox gas.
        conduit:
            name: Conduit
            class: Support
            passive: Savior's Speed
            tactical: Radiant Transfer
            ultimate: Energy Barricade
            tactical_cooldown: 30s
            ultimate_cooldown: 2.5m
            passive_note: Gain speed while a teammate is more than 20 blocks away.
            tactical_note: Give Conduit and nearby allies temporary absorption shields.
            ultimate_note: Create a timed particle line that slows and damages enemies.
        crypto:
            name: Crypto
            class: Recon
            passive: Neurolink
            tactical: Surveillance Drone
            ultimate: Drone EMP
            tactical_cooldown: 30s
            ultimate_cooldown: 3m
            passive_note: Share enemies detected by the drone with the squad.
            tactical_note: Pilot a 50 HP scout drone while a damageable body remains behind.
            ultimate_note: Detonate the drone to strip 50 shield health, slow enemies, and reveal targets.
        fuse:
            name: Fuse
            class: Assault
            passive: Grenadier
            tactical: Knuckle Cluster
            ultimate: The Motherlode
            tactical_cooldown: 20s
            ultimate_cooldown: 2m
            passive_note: Take reduced explosion and fire damage as the Minecraft Grenadier analogue.
            tactical_note: Fire a sticky cluster charge that bursts repeatedly.
            ultimate_note: Bombard a target area with a persistent ring of fire.
        gibraltar:
            name: Gibraltar
            class: Support
            passive: Gun Shield and Momentum Boost
            tactical: Dome of Protection
            ultimate: Defensive Bombardment
            tactical_cooldown: 13s
            ultimate_cooldown: 3m
            passive_note: Sneak to block one incoming hit every 9s and build speed while sprinting empty-handed.
            tactical_note: Create a timed particle dome area that protects nearby allies from incoming damage.
            ultimate_note: Mark an area for a concentrated mortar bombardment.
        horizon:
            name: Horizon
            class: Skirmisher
            passive: Spacewalk
            tactical: Gravity Lift
            ultimate: Black Hole
            tactical_cooldown: 25s
            ultimate_cooldown: 3.5m
            passive_note: Gain slow falling and a short speed effect after jumping.
            tactical_note: Place a vertical gravity column that lifts players and entities.
            ultimate_note: Create a timed particle point that pulls enemies inward, then deals a final blast.
        lifeline:
            name: Lifeline
            class: Support
            passive: Combat Glide
            tactical: D.O.C. Heal Drone
            ultimate: D.O.C. Halo
            tactical_cooldown: 45s
            ultimate_cooldown: 3m
            passive_note: Sneak in midair to glide and periodically regenerate one nearby critical ally.
            tactical_note: Create a fixed particle point that heals nearby allies over time.
            ultimate_note: Create a timed zone that protects, heals, and slows the fall of nearby allies.
        loba:
            name: Loba
            class: Support
            passive: Eye for Quality
            tactical: Burglar's Best Friend
            ultimate: Black Market Boutique
            tactical_cooldown: 25s
            ultimate_cooldown: 2.5m
            passive_note: Mark nearby dropped item entities with visible end-rod particles.
            tactical_note: Throw a bracelet and teleport Loba to its landing point.
            ultimate_note: Pull two random Lapex guns from the Black Market weapon pool.
        mad_maggie:
            name: Mad Maggie
            class: Assault
            passive: Warlord's Ire
            tactical: Riot Drill
            ultimate: Wrecking Ball
            tactical_cooldown: 28s
            ultimate_cooldown: 2m
            passive_note: Mark recently damaged enemies and remove the shotgun movement penalty.
            tactical_note: Burn enemies repeatedly around the aimed impact point.
            ultimate_note: Trace a damaging path and give nearby allies short speed boosts along it.
        mirage:
            name: Mirage
            class: Support
            passive: Now You See Me
            tactical: Psyche Out
            ultimate: Life of the Party
            tactical_cooldown: 15s
            ultimate_cooldown: 1m
            passive_note: Sneak near a critical ally to briefly cloak both players and protect the ally.
            tactical_note: Send three moving particle decoys down diverging paths.
            ultimate_note: Cloak briefly and deploy a ring of moving particle decoys.
        newcastle:
            name: Newcastle
            class: Support
            passive: Retrieve the Wounded
            tactical: Mobile Shield
            ultimate: Castle Wall
            tactical_cooldown: 20s
            ultimate_cooldown: 2m
            passive_note: Sneak beside a critical ally to protect and regenerate them while moving slowly.
            tactical_note: Create a stationary particle shield area that protects nearby allies.
            ultimate_note: Leap to a target position and create a timed protective particle wall.
        octane:
            name: Octane
            class: Skirmisher
            passive: Swift Mend and Stim Surge
            tactical: Stim
            ultimate: Launch Pad
            tactical_cooldown: 0.7s
            ultimate_cooldown: 1.5m
            passive_note: Heal out of recent combat and auto-trigger extra regeneration once at low health.
            tactical_note: Spend health for six seconds of increased movement speed and slow resistance.
            ultimate_note: Create a timed launch point that pushes living entities forward and grants slow falling.
        pathfinder:
            name: Pathfinder
            class: Skirmisher
            passive: Insider Knowledge
            tactical: Grappling Hook
            ultimate: Zipline Gun
            tactical_cooldown: 20s
            ultimate_cooldown: 2m
            passive_note: Scan a beacon to remove 30 seconds from the current Zipline cooldown.
            tactical_note: Pull Pathfinder once to the aimed grapple point after each shared cooldown.
            ultimate_note: Create a 30-second particle route that pushes players from its start to its end.
        rampart:
            name: Rampart
            class: Controller
            passive: Battle Modder
            tactical: Amped Cover
            ultimate: Mobile Minigun Sheila
            tactical_cooldown: 20s
            ultimate_cooldown: 2m
            passive_note: Expand LMG and Sheila magazines by 15 percent and shorten reloads by 25 percent.
            tactical_note: Create one timed protection and damage-boost zone in front of Rampart.
            ultimate_note: Give mobile Sheila or refill it when already held.
        revenant:
            name: Revenant
            class: Assault
            passive: Assassin's Instinct
            tactical: Shadow Pounce
            ultimate: Forged Shadows
            tactical_cooldown: 20s
            ultimate_cooldown: 3m
            passive_note: Highlight nearby low-health enemies as the Assassin's Instinct combat analogue.
            tactical_note: Push Revenant directly toward the aimed point and grant short resistance.
            ultimate_note: Grant timed absorption, speed, resistance, and reduced incoming damage.
        seer:
            name: Seer
            class: Recon
            passive: Heart Seeker
            tactical: Focus of Attention
            ultimate: Exhibit
            tactical_cooldown: 20s
            ultimate_cooldown: 3m
            passive_note: Show directional heartbeat cues while aiming down sights.
            tactical_note: Damage, silence, and reveal enemies in a sphere at the aimed endpoint.
            ultimate_note: Create a timed particle sphere that repeatedly reveals enemies inside it.
        sparrow:
            name: Sparrow
            class: Recon
            passive: Double Jump
            tactical: Tracker Dart
            ultimate: Stinger Bolt
            tactical_cooldown: 35s
            ultimate_cooldown: 2.5m
            passive_note: Allow one midair jump and reset it after two seconds on the ground.
            tactical_note: Fire a tracker dart that repeatedly reveals hostiles around its landing point.
            ultimate_note: Fire a delayed bolt burst that damages, slows, and reveals its impact area.
        valkyrie:
            name: Valkyrie
            class: Recon
            passive: VTOL Jets
            tactical: Missile Swarm
            ultimate: Skyward Dive
            tactical_cooldown: 25s
            ultimate_cooldown: 2.5m
            passive_note: Sneak in midair for a short jet lift with a 6s recovery.
            tactical_note: Repeat missile explosions at one aimed point to damage and slow targets.
            ultimate_note: Force nearby allies upward, then grant slow falling and speed.
        vantage:
            name: Vantage
            class: Recon
            passive: Spotter's Lens
            tactical: Echo Relocation
            ultimate: Sniper's Mark
            tactical_cooldown: 17s
            ultimate_cooldown: 4m
            passive_note: Show health and range for the aimed hostile and mark one team spot every 10s.
            tactical_note: Push Vantage directly toward the aimed point and grant slow falling.
            ultimate_note: Deploy or refill A-13; its hits amplify follow-up damage against marked targets.
        wattson:
            name: Wattson
            class: Controller
            passive: Spark of Genius
            tactical: Perimeter Security
            ultimate: Interception Pylon
            tactical_cooldown: 4s
            ultimate_cooldown: 3m
            passive_note: Gain a short absorption shield while out of recent combat.
            tactical_note: Create one temporary particle fence line that damages and slows enemies.
            ultimate_note: Create a timed pylon area that protects allies from projectiles and explosions while restoring protection.
        wraith:
            name: Wraith
            class: Skirmisher
            passive: Voices from the Void
            tactical: Into the Void
            ultimate: Dimensional Rift
            tactical_cooldown: 15s
            ultimate_cooldown: 1.5m
            passive_note: Warn Wraith after combat telemetry marks a nearby threat.
            tactical_note: Enter a brief invulnerable phase that prevents attacking or interacting.
            ultimate_note: Link two temporary portals that players can traverse in either direction.
