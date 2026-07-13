# Lapex weapon registry.
#
# Damage values are Apex HP and are scaled to Minecraft HP by the engine. The
# defaults target the current Season 29 / Overclocked roster. All balance values
# live here so a server owner can update a patch without changing engine code.
# Recoil pattern entries are signed shot counts. Positive entries move right;
# negative entries move left. Recoil strength still comes from recoil_yaw.

lapex_weapon_data:
    type: data
    damage_scale: 0.2
    head_zone: 0.78
    leg_zone: 0.35
    mark_bonus: 1.15
    vantage_followup_multiplier: 2.0
    whistler_overheat_shots: 5
    whistler_overheat_damage: 50
    whistler_trap_damage: 35

    standard_ids:
    - havoc
    - flatline
    - hemlok_breach
    - r301
    - nemesis
    - alternator
    - prowler
    - r99
    - volt
    - car
    - devotion
    - lstar
    - spitfire
    - rampage
    - g7_scout
    - triple_take
    - repeater_3030
    - bocek
    - charge_rifle
    - longbow
    - kraber
    - sentinel
    - eva8
    - mastiff
    - mozambique
    - peacekeeper
    - re45_burst
    - p2020
    - wingman
    legend_ids:
    - sheila
    - a13_sentry
    - whistler
    all_ids:
    - havoc
    - flatline
    - hemlok_breach
    - r301
    - nemesis
    - alternator
    - prowler
    - r99
    - volt
    - car
    - devotion
    - lstar
    - spitfire
    - rampage
    - g7_scout
    - triple_take
    - repeater_3030
    - bocek
    - charge_rifle
    - longbow
    - kraber
    - sentinel
    - eva8
    - mastiff
    - mozambique
    - peacekeeper
    - re45_burst
    - p2020
    - wingman
    - sheila
    - a13_sentry
    - whistler

    categories:
        assault_rifles: havoc|flatline|hemlok_breach|r301|nemesis
        submachine_guns: alternator|prowler|r99|volt|car
        light_machine_guns: devotion|lstar|spitfire|rampage
        marksman: g7_scout|triple_take|repeater_3030|bocek
        snipers: charge_rifle|longbow|kraber|sentinel
        shotguns: eva8|mastiff|mozambique|peacekeeper
        pistols: re45_burst|p2020|wingman
        legend_weapons: sheila|a13_sentry|whistler

    weapons:
        havoc:
            name: HAVOC Rifle
            class: Assault Rifle
            ammo: Energy
            mode: auto
            damage: 20
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 672
            mag: 18
            reload: 3.2s
            empty_reload: 3.2s
            range: 100
            hip_spread: 1.35
            ads_spread: 0.12
            recoil_pitch: 0.62
            recoil_yaw: 0.42
            recoil_pattern:
            - 5
            - -5
            - 7
            - -12
            spinup_ticks: 8
            tracer: 120,255,245
            sound_pitch: 1.15
        flatline:
            name: VK-47 Flatline
            class: Assault Rifle
            ammo: Heavy
            mode: auto
            damage: 20
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 600
            mag: 19
            reload: 2.4s
            empty_reload: 3.1s
            range: 100
            hip_spread: 1.45
            ads_spread: 0.14
            recoil_pitch: 0.7
            recoil_yaw: 0.58
            recoil_pattern:
            - -7
            - 5
            - -10
            - 7
            tracer: 195,155,110
            sound_pitch: 0.85
        hemlok_breach:
            name: Hemlok Breach AR
            class: Assault Rifle
            ammo: Heavy
            mode: auto
            damage: 22
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 462
            mag: 18
            reload: 2.3s
            empty_reload: 2.55s
            range: 105
            hip_spread: 1.2
            ads_spread: 0.1
            recoil_pitch: 0.48
            recoil_yaw: 0.25
            special: breach
            breach_damage: 38
            breach_radius: 3.5
            breach_cooldown: 25s
            tracer: 190,150,100
            sound_pitch: 0.75
        r301:
            name: R-301 Carbine
            class: Assault Rifle
            ammo: Light
            mode: auto
            damage: 15
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 810
            mag: 21
            reload: 2.4s
            empty_reload: 3.2s
            range: 100
            hip_spread: 1.15
            ads_spread: 0.08
            recoil_pitch: 0.38
            recoil_yaw: 0.2
            recoil_pattern:
            - 12
            - -7
            - 12
            tracer: 255,225,150
            sound_pitch: 1.35
        nemesis:
            name: Nemesis Burst AR
            class: Assault Rifle
            ammo: Energy
            mode: burst
            damage: 17
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 1080
            burst_count: 4
            burst_lock_ticks: 11
            mag: 20
            reload: 2.7s
            empty_reload: 3.0s
            range: 105
            hip_spread: 1.25
            ads_spread: 0.09
            recoil_pitch: 0.4
            recoil_yaw: 0.22
            tracer: 115,240,255
            sound_pitch: 1.5
        alternator:
            name: Alternator SMG
            class: Submachine Gun
            ammo: Light
            mode: auto
            damage: 19
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 600
            mag: 20
            reload: 1.9s
            empty_reload: 2.23s
            range: 70
            hip_spread: 1.1
            ads_spread: 0.12
            recoil_pitch: 0.32
            recoil_yaw: 0.18
            recoil_pattern:
            - 15
            - -11
            - 4
            tracer: 255,220,145
            sound_pitch: 1.25
        prowler:
            name: Prowler Burst PDW
            class: Submachine Gun
            ammo: Heavy
            mode: burst
            damage: 16
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 579
            burst_count: 5
            burst_lock_ticks: 10
            mag: 20
            reload: 2.0s
            empty_reload: 2.6s
            range: 72
            hip_spread: 1.15
            ads_spread: 0.1
            recoil_pitch: 0.35
            recoil_yaw: 0.24
            tracer: 200,155,110
            sound_pitch: 1.05
        r99:
            name: R-99 SMG
            class: Submachine Gun
            ammo: Light
            mode: auto
            damage: 13
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 1080
            mag: 18
            reload: 1.8s
            empty_reload: 2.45s
            range: 75
            hip_spread: 1.2
            ads_spread: 0.11
            recoil_pitch: 0.52
            recoil_yaw: 0.34
            recoil_pattern:
            - 9
            - -5
            - 4
            - -5
            - 4
            tracer: 255,225,150
            sound_pitch: 1.9
        volt:
            name: Volt SMG
            class: Submachine Gun
            ammo: Energy
            mode: auto
            damage: 16
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 720
            mag: 20
            reload: 1.44s
            empty_reload: 2.03s
            range: 78
            hip_spread: 1.0
            ads_spread: 0.08
            recoil_pitch: 0.3
            recoil_yaw: 0.16
            recoil_pattern:
            - 11
            - -4
            - 4
            - -10
            tracer: 100,235,255
            sound_pitch: 1.55
        car:
            name: C.A.R. SMG
            class: Submachine Gun
            ammo: Light / Heavy
            mode: auto
            damage: 14
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 930
            mag: 20
            reload: 1.7s
            empty_reload: 2.13s
            range: 74
            hip_spread: 1.25
            ads_spread: 0.12
            recoil_pitch: 0.48
            recoil_yaw: 0.36
            recoil_pattern:
            - -9
            - 6
            - -3
            - 6
            - -6
            tracer: 245,205,145
            sound_pitch: 1.65
        devotion:
            name: Devotion LMG
            class: Light Machine Gun
            ammo: Energy
            mode: auto
            damage: 16
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 900
            mag: 36
            reload: 2.8s
            empty_reload: 3.63s
            range: 105
            hip_spread: 1.65
            ads_spread: 0.15
            recoil_pitch: 0.46
            recoil_yaw: 0.3
            recoil_pattern:
            - -20
            - 23
            - -5
            spinup_ticks: 14
            tracer: 105,240,255
            sound_pitch: 1.45
        lstar:
            name: L-STAR EMG
            class: Light Machine Gun
            ammo: Mythic Energy
            mode: auto
            damage: 20
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 600
            mag: 35
            reload: 2.45s
            empty_reload: 2.45s
            reload_label: Cooling
            range: 95
            hip_spread: 1.45
            ads_spread: 0.13
            recoil_pitch: 0.38
            recoil_yaw: 0.28
            recoil_pattern:
            - -4
            - 24
            tracer: 255,80,80
            sound_pitch: 1.25
        spitfire:
            name: M600 Spitfire
            class: Light Machine Gun
            ammo: Light
            mode: auto
            damage: 21
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 540
            mag: 35
            reload: 3.4s
            empty_reload: 4.2s
            range: 105
            hip_spread: 1.55
            ads_spread: 0.14
            recoil_pitch: 0.4
            recoil_yaw: 0.24
            recoil_pattern:
            - -7
            - 5
            - -10
            - 13
            - -11
            - 4
            tracer: 255,220,145
            sound_pitch: 0.8
        rampage:
            name: Rampage LMG
            class: Light Machine Gun
            ammo: Heavy
            mode: auto
            damage: 29
            head_mult: 1.3
            leg_mult: 0.75
            rpm: 300
            mag: 28
            reload: 3.1s
            empty_reload: 4.0s
            range: 110
            hip_spread: 1.65
            ads_spread: 0.12
            recoil_pitch: 0.58
            recoil_yaw: 0.32
            special: thermite_rounds
            tracer: 230,150,105
            sound_pitch: 0.65
        g7_scout:
            name: G7 Scout
            class: Marksman
            ammo: Light
            mode: semi
            damage: 37
            head_mult: 1.4
            leg_mult: 0.75
            rpm: 252
            mag: 20
            reload: 2.4s
            empty_reload: 3.0s
            range: 145
            hip_spread: 1.8
            ads_spread: 0.04
            recoil_pitch: 0.95
            recoil_yaw: 0.28
            tracer: 255,225,155
            sound_pitch: 0.8
        triple_take:
            name: Triple Take
            class: Marksman
            ammo: Energy
            mode: semi
            damage: 22
            pellets: 3
            pellet_spread: 0.34
            head_mult: 1.4
            leg_mult: 0.75
            rpm: 81
            mag: 12
            reload: 2.6s
            empty_reload: 3.4s
            range: 150
            hip_spread: 1.4
            ads_spread: 0.03
            recoil_pitch: 0.9
            recoil_yaw: 0.2
            tracer: 105,240,255
            sound_pitch: 0.7
        repeater_3030:
            name: 30-30 Repeater
            class: Marksman
            ammo: Heavy
            mode: semi
            damage: 43
            head_mult: 1.4
            leg_mult: 0.75
            rpm: 139
            mag: 6
            reload: 0.6s
            empty_reload: 0.6s
            reload_style: shell
            range: 150
            hip_spread: 1.65
            ads_spread: 0.04
            recoil_pitch: 1.05
            recoil_yaw: 0.24
            tracer: 205,160,110
            sound_pitch: 0.65
        bocek:
            name: Bocek Compound Bow
            class: Marksman
            ammo: Arrows
            mode: charge
            damage: 60
            head_mult: 1.4
            leg_mult: 0.8
            rpm: 60
            mag: 1
            reload: 0.55s
            empty_reload: 0.55s
            auto_reload: true
            charge_ticks: 11
            range: 160
            hip_spread: 1.6
            ads_spread: 0.03
            recoil_pitch: 0.2
            recoil_yaw: 0.08
            tracer: 220,210,160
            sound_pitch: 0.85
        charge_rifle:
            name: Charge Rifle
            class: Sniper Rifle
            ammo: Sniper
            mode: charge
            damage: 75
            head_mult: 1.8
            leg_mult: 0.7
            rpm: 26
            mag: 6
            reload: 3.5s
            empty_reload: 4.6s
            charge_ticks: 16
            range: 220
            hip_spread: 2.2
            ads_spread: 0.02
            recoil_pitch: 1.35
            recoil_yaw: 0.18
            special: charge_beam
            tracer: 130,245,255
            sound_pitch: 0.55
        longbow:
            name: Longbow DMR
            class: Sniper Rifle
            ammo: Sniper
            mode: semi
            damage: 60
            head_mult: 1.75
            leg_mult: 0.8
            rpm: 78
            mag: 6
            reload: 2.66s
            empty_reload: 3.66s
            range: 190
            hip_spread: 2.0
            ads_spread: 0.02
            recoil_pitch: 1.25
            recoil_yaw: 0.2
            tracer: 120,175,255
            sound_pitch: 0.55
        kraber:
            name: Kraber .50-Cal Sniper
            class: Sniper Rifle
            ammo: Mythic Sniper
            mode: semi
            damage: 150
            head_mult: 2.0
            leg_mult: 0.8
            rpm: 25
            mag: 4
            reload: 3.2s
            empty_reload: 4.3s
            range: 220
            hip_spread: 2.8
            ads_spread: 0.01
            recoil_pitch: 2.2
            recoil_yaw: 0.24
            tracer: 255,95,80
            sound_pitch: 0.35
        sentinel:
            name: Sentinel
            class: Sniper Rifle
            ammo: Sniper
            mode: semi
            damage: 70
            head_mult: 1.8
            leg_mult: 0.7
            rpm: 38
            mag: 4
            reload: 3.0s
            empty_reload: 4.0s
            range: 205
            hip_spread: 2.2
            ads_spread: 0.015
            recoil_pitch: 1.7
            recoil_yaw: 0.2
            special: amped
            tracer: 130,190,255
            sound_pitch: 0.42
        eva8:
            name: EVA-8 Auto
            class: Shotgun
            ammo: Shotgun Shells
            mode: auto
            damage: 7
            pellets: 8
            pellet_spread: 3.0
            head_mult: 1.25
            leg_mult: 0.9
            rpm: 120
            mag: 8
            reload: 2.75s
            empty_reload: 3.0s
            range: 38
            hip_spread: 0
            ads_spread: 0
            recoil_pitch: 1.0
            recoil_yaw: 0.35
            tracer: 255,190,120
            sound_pitch: 0.68
        mastiff:
            name: Mastiff Shotgun
            class: Shotgun
            ammo: Shotgun Shells
            mode: semi
            damage: 19
            pellets: 5
            pellet_spread: 2.4
            horizontal_pellets: true
            head_mult: 1.25
            leg_mult: 0.9
            rpm: 66
            mag: 5
            reload: 0.8s
            empty_reload: 0.8s
            reload_style: shell
            range: 42
            hip_spread: 0
            ads_spread: 0
            recoil_pitch: 1.45
            recoil_yaw: 0.34
            tracer: 255,185,115
            sound_pitch: 0.48
        mozambique:
            name: Mozambique Shotgun
            class: Shotgun
            ammo: Shotgun Shells
            mode: auto
            damage: 17
            pellets: 3
            pellet_spread: 1.8
            head_mult: 1.25
            leg_mult: 0.9
            rpm: 202
            mag: 5
            reload: 2.1s
            empty_reload: 2.6s
            range: 45
            hip_spread: 0
            ads_spread: 0
            recoil_pitch: 0.8
            recoil_yaw: 0.25
            tracer: 255,190,120
            sound_pitch: 0.9
        peacekeeper:
            name: Peacekeeper
            class: Shotgun
            ammo: Shotgun Shells
            mode: semi
            damage: 11
            pellets: 9
            pellet_spread: 2.6
            head_mult: 1.25
            leg_mult: 0.9
            rpm: 55
            mag: 5
            reload: 2.5s
            empty_reload: 3.5s
            range: 44
            hip_spread: 0
            ads_spread: 0
            recoil_pitch: 1.6
            recoil_yaw: 0.38
            tracer: 130,240,255
            sound_pitch: 0.42
        re45_burst:
            name: RE-45 Burst
            class: Pistol
            ammo: Energy
            mode: burst
            damage: 17
            head_mult: 1.5
            leg_mult: 0.9
            rpm: 780
            burst_count: 3
            burst_lock_ticks: 6
            mag: 15
            reload: 1.5s
            empty_reload: 1.95s
            range: 65
            hip_spread: 1.05
            ads_spread: 0.1
            recoil_pitch: 0.32
            recoil_yaw: 0.2
            tracer: 115,240,255
            sound_pitch: 1.75
        p2020:
            name: P2020
            class: Pistol
            ammo: Light
            mode: semi
            damage: 24
            head_mult: 1.5
            leg_mult: 0.9
            rpm: 420
            mag: 9
            reload: 1.5s
            empty_reload: 1.5s
            range: 68
            hip_spread: 1.05
            ads_spread: 0.08
            recoil_pitch: 0.44
            recoil_yaw: 0.18
            tracer: 255,225,150
            sound_pitch: 1.35
        wingman:
            name: Wingman
            class: Pistol
            ammo: Sniper
            mode: semi
            damage: 50
            head_mult: 1.5
            leg_mult: 0.9
            rpm: 168
            mag: 5
            reload: 2.1s
            empty_reload: 2.1s
            range: 105
            hip_spread: 1.25
            ads_spread: 0.04
            recoil_pitch: 1.15
            recoil_yaw: 0.25
            tracer: 130,185,255
            sound_pitch: 0.55
        sheila:
            name: Mobile Minigun Sheila
            class: Rampart Weapon
            ammo: Ultimate Rounds
            mode: auto
            damage: 14
            head_mult: 1.25
            leg_mult: 0.8
            rpm: 1200
            mag: 173
            reload: 3.0s
            empty_reload: 3.0s
            range: 110
            hip_spread: 2.2
            ads_spread: 0.22
            recoil_pitch: 0.28
            recoil_yaw: 0.32
            spinup_ticks: 20
            special: sheila
            tracer: 255,175,100
            sound_pitch: 1.9
        a13_sentry:
            name: A-13 Sentry
            class: Vantage Weapon
            ammo: Ultimate Rounds
            mode: semi
            damage: 50
            head_mult: 1.5
            leg_mult: 0.8
            rpm: 60
            mag: 6
            initial_ammo: 2
            reload: 40s
            empty_reload: 40s
            reload_style: shell
            range: 220
            hip_spread: 2.5
            ads_spread: 0.01
            recoil_pitch: 1.3
            recoil_yaw: 0.16
            special: vantage_mark
            tracer: 255,70,90
            sound_pitch: 0.45
        whistler:
            name: Whistler Smart Pistol
            class: Ballistic Weapon
            ammo: Tactical Charge
            mode: semi
            damage: 15
            head_mult: 1.0
            leg_mult: 1.0
            rpm: 60
            mag: 2
            reload: 25s
            empty_reload: 25s
            range: 95
            hip_spread: 0.5
            ads_spread: 0.1
            recoil_pitch: 0.2
            recoil_yaw: 0.1
            special: whistler
            homing_raysize: 1.25
            tracer: 255,145,80
            sound_pitch: 1.6
