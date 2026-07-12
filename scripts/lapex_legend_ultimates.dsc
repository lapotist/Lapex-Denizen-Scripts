# Ultimate dispatcher and all 28 ultimate implementations.

lapex_legend_ultimate:
    type: task
    definitions: id
    script:
    - choose <[id]>:
        - case alter:
            - run lapex_ultimate_alter
        - case ash:
            - run lapex_ultimate_ash
        - case axle:
            - run lapex_ultimate_axle
        - case ballistic:
            - run lapex_ultimate_ballistic
        - case bangalore:
            - run lapex_ultimate_bangalore
        - case bloodhound:
            - run lapex_ultimate_bloodhound
        - case catalyst:
            - run lapex_ultimate_catalyst
        - case caustic:
            - run lapex_ultimate_caustic
        - case conduit:
            - run lapex_ultimate_conduit
        - case crypto:
            - run lapex_ultimate_crypto
        - case fuse:
            - run lapex_ultimate_fuse
        - case gibraltar:
            - run lapex_ultimate_gibraltar
        - case horizon:
            - run lapex_ultimate_horizon
        - case lifeline:
            - run lapex_ultimate_lifeline
        - case loba:
            - run lapex_ultimate_loba
        - case mad_maggie:
            - run lapex_ultimate_mad_maggie
        - case mirage:
            - run lapex_ultimate_mirage
        - case newcastle:
            - run lapex_ultimate_newcastle
        - case octane:
            - run lapex_ultimate_octane
        - case pathfinder:
            - run lapex_ultimate_pathfinder
        - case rampart:
            - run lapex_ultimate_rampart
        - case revenant:
            - run lapex_ultimate_revenant
        - case seer:
            - run lapex_ultimate_seer
        - case sparrow:
            - run lapex_ultimate_sparrow
        - case valkyrie:
            - run lapex_ultimate_valkyrie
        - case vantage:
            - run lapex_ultimate_vantage
        - case wattson:
            - run lapex_ultimate_wattson
        - case wraith:
            - run lapex_ultimate_wraith

lapex_ultimate_alter:
    type: task
    script:
    - define nexus <player.location>
    - define allies <proc[lapex_legend_allies_near].context[<[nexus]>|8|<player>]>
    - foreach <[allies]> as:target:
        - flag <[target]> lapex.void_nexus:<[nexus]> expire:30s
        - flag <[target]> lapex.void_nexus_used:!
    - playsound <[nexus]> sound:block.respawn_anchor.set_spawn pitch:0.8 volume:1
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:reverse_portal at:<[nexus].above[1]> offset:1.3 quantity:16
        - foreach <[allies]> as:target:
            - if <[target].is_online||false> && <[target].has_flag[lapex.void_nexus]> && !<[target].has_flag[lapex.void_nexus_used]> && <[target].health.div[<[target].health_max>]> <= 0.35:
                - flag <[target]> lapex.void_nexus_used
                - teleport <[target]> <[nexus]>
                - cast resistance duration:2s amplifier:4 <[target]>
                - playeffect effect:portal at:<[target].location.above[1]> offset:0.5 quantity:30
        - wait 1s

lapex_ultimate_ash:
    type: task
    debug: false
    script:
    - define origin <player.location>
    - define eye <player.eye_location>
    - define raw_destination <[eye].ray_trace[range=100;default=air]>
    - define destination <proc[lapex_legend_safe_destination].context[<[raw_destination]>|null]||null>
    - if <[destination]> == null || <[origin].distance[<[destination]>]> < 6:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>NO SAFE PHASE BREACH EXIT"
        - stop
    - define entrance_tag lapex_ash_entrance_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[origin]> def.tag:<[entrance_tag]> def.arms:false def.small:false def.marker:true
    - define entrance <server.flag[lapex.native_spawn_result.<[entrance_tag]>]||null>
    - flag server lapex.native_spawn_result.<[entrance_tag]>:!
    - define exit_tag lapex_ash_exit_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[destination]> def.tag:<[exit_tag]> def.arms:false def.small:false def.marker:true
    - define exit <server.flag[lapex.native_spawn_result.<[exit_tag]>]||null>
    - flag server lapex.native_spawn_result.<[exit_tag]>:!
    - if <[entrance]> == null || <[exit]> == null:
        - if <[entrance]> != null:
            - remove <[entrance]>
        - if <[exit]> != null:
            - remove <[exit]>
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>PHASE BREACH DEPLOY FAILED"
        - stop
    - foreach <list[<[entrance]>|<[exit]>]> as:portal:
        - adjust <[portal]> gravity:false
        - adjust <[portal]> silent:true
        - adjust <[portal]> visible:false
        - adjust <[portal]> base_plate:false
        - adjust <[portal]> collidable:false
        - equip <[portal]> head:<item[lapex_model_ash_portal]>
    - flag <[entrance]> lapex.deployable_invulnerable
    - flag <[entrance]> lapex.deployable_state:active
    - flag <[entrance]> lapex.ash_destination:<[destination]>
    - flag <[entrance]> lapex.ash_portal_active expire:15s
    - ~run lapex_deployable_register def.owner:<player> def.entity:<[entrance]> def.kind:ash_portal def.health:1 def.max_count:1 "def.label:<light_purple>PHASE BREACH"
    - run lapex_deployable_attach_extra def.owner:<player> def.primary:<[entrance]> def.extra:<[exit]>
    - define session <[entrance].flag[lapex.deployable_session]>
    - flag player lapex.ash_transit.<[session]> expire:16s
    - playsound <player> sound:entity.enderman.teleport pitch:0.55 volume:1
    - run lapex_ash_transit def.target:<player> def.destination:<[destination]> def.session:<[session]>

lapex_ultimate_axle:
    type: task
    script:
    - define target null
    - foreach <player.location.find_entities[player].within[35].exclude[<player>]> as:possible:
        - if !<proc[lapex_legend_is_ally].context[<player>|<[possible]>]> && !<[possible].has_flag[lapex.legend_protected]> && !<[possible].has_flag[lapex.phased]>:
            - define target <[possible]>
            - foreach stop
    - if <[target]> == null:
        - actionbar "<gray>KICKSTART FOUND NO TARGET"
        - flag player lapex.cooldown.ultimate:!
        - stop
    - define start <player.location.above[1]>
    - playeffect effect:electric_spark at:<[start].points_between[<[target].location.above[1]>].distance[1.5]> offset:0.1 quantity:2
    - playsound <[target]> sound:entity.firework_rocket.launch pitch:1.8 volume:0.8
    - wait 12t
    - if !<[target].is_spawned||false>:
        - stop
    - playeffect effect:explosion at:<[target].location.above[1]> offset:0.4 quantity:3
    - run lapex_legend_damage_sphere def.location:<[target].location> def.radius:3 def.damage:30 def.effect:slow
    - push <[target]> origin:<[target].location> destination:<[target].location.above[8]> speed:2.4 duration:12t no_damage

lapex_ultimate_ballistic:
    type: task
    script:
    - define allies <proc[lapex_legend_allies_near].context[<player.location>|20|<player>]>
    - foreach <[allies]> as:target:
        - flag <[target]> lapex.tempest expire:30s
        - cast speed duration:30s amplifier:1 <[target]>
        - cast haste duration:30s amplifier:1 <[target]>
        - playeffect effect:small_flame at:<[target].location.above[1]> offset:0.4 quantity:16
    - playsound <player> sound:item.totem.use pitch:1.4 volume:0.8

lapex_ultimate_bangalore:
    type: task
    script:
    - define center <player.eye_location.ray_trace[range=55;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - define facing <[center].with_yaw[<player.location.yaw>]>
    - playsound <player> sound:entity.firework_rocket.launch pitch:0.65 volume:0.8
    - repeat 9 as:wave:
        - define strike <[facing].forward[<[wave].sub[5].mul[3]>]>
        - playeffect effect:large_smoke at:<[strike]> offset:4 quantity:18
        - wait 8t
        - playeffect effect:explosion at:<[strike]> offset:3 quantity:5
        - playsound <[strike]> sound:entity.generic.explode pitch:0.8 volume:1
        - run lapex_legend_damage_sphere def.location:<[strike]> def.radius:6 def.damage:18 def.effect:slow def.pylon_blockable:true

lapex_ultimate_bloodhound:
    type: task
    script:
    - flag player lapex.beast_of_hunt expire:30s
    - cast speed duration:30s amplifier:2 <player>
    - cast night_vision duration:30s amplifier:0 <player>
    - playsound <player> sound:entity.wolf.howl pitch:0.65 volume:1
    - repeat 15:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<player.location.above[1]> offset:0.7 quantity:12 special_data:[size=0.8;color=255,40,35]
        - run lapex_legend_scan def.location:<player.location> def.radius:40 def.duration:2.2s
        - wait 2s

lapex_ultimate_catalyst:
    type: task
    script:
    - define origin <player.location.above[1]>
    - define end <player.eye_location.ray_trace[range=42;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - define veil <[origin].points_between[<[end]>].distance[2]>
    - playsound <player> sound:block.sculk_shrieker.shriek pitch:0.6 volume:0.8
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:portal at:<[veil]> offset:1.2 quantity:6
        - foreach <[veil]> as:node:
            - foreach <[node].find_entities[player].within[1.8]> as:target:
                - if !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[target].has_flag[lapex.phased]>:
                    - cast blindness duration:2s amplifier:0 <[target]>
                    - cast slowness duration:2s amplifier:1 <[target]>
        - wait 1s

lapex_ultimate_caustic:
    type: task
    script:
    - define gas <player.eye_location.ray_trace[range=42;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playsound <[gas]> sound:block.fire.extinguish pitch:0.55 volume:1
    - repeat 20:
        - if !<player.is_online>:
            - stop
        - playeffect effect:cloud at:<[gas]> offset:6 quantity:60
        - run lapex_caustic_gas_pulse def.location:<[gas]> def.radius:7 def.damage:6 def.owner:<player>
        - wait 1s

lapex_ultimate_conduit:
    type: task
    script:
    - define center <player.eye_location.ray_trace[range=35;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - define left <[center].with_yaw[<player.location.yaw.add[90]>].forward[8]>
    - define right <[center].with_yaw[<player.location.yaw.sub[90]>].forward[8]>
    - define nodes <[left].points_between[<[right]>].distance[2]>
    - playsound <[center]> sound:block.conduit.activate pitch:0.8 volume:1
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:electric_spark at:<[nodes]> offset:0.6 quantity:5
        - foreach <[nodes]> as:node:
            - run lapex_legend_damage_sphere def.location:<[node]> def.radius:2 def.damage:4 def.effect:slow def.pylon_blockable:true
        - wait 1s

lapex_ultimate_crypto:
    type: task
    script:
    - define drone <player.flag[lapex.crypto_drone_entity]||null>
    - if <[drone]> == null || !<[drone].is_spawned||false>:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>DRONE LINK LOST"
        - stop
    - define center <[drone].location>
    - playsound <[center]> sound:entity.lightning_bolt.thunder pitch:1.8 volume:0.8
    - playeffect effect:electric_spark at:<[center]> offset:15 quantity:160
    - define affected <list>
    - foreach <[center].find_entities[living].within[30]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> != null && !<[affected].contains[<[combat_player]>]> && !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[combat_player].has_flag[lapex.phased]>:
            - define affected <[affected].include[<[combat_player]>]>
            - define shields <[combat_player].absorption_health||0>
            - adjust <[combat_player]> absorption_health:<[shields].sub[<[shields].min[10]>]>
            - cast slowness duration:4s amplifier:2 <[combat_player]>
    - ~run lapex_destroy_indexed_deployables def.location:<[center]> def.radius:30 def.kinds:<list[gibraltar_dome|lifeline_doc]> def.source:<player> def.enemies_only:true
    - run lapex_legend_scan def.location:<[center]> def.radius:30 def.duration:8s

lapex_ultimate_fuse:
    type: task
    script:
    - define center <player.eye_location.ray_trace[range=60;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - define ring <list>
    - repeat 12 as:index:
        - define node <[center].with_yaw[<[index].mul[30]>].forward[7]>
        - define ring <[ring].include[<[node]>]>
    - playsound <[center]> sound:entity.generic.explode pitch:0.65 volume:1
    - repeat 18:
        - if !<player.is_online>:
            - stop
        - playeffect effect:flame at:<[ring]> offset:0.8 quantity:8
        - foreach <[ring]> as:node:
            - run lapex_legend_damage_sphere def.location:<[node]> def.radius:2 def.damage:5 def.effect:burn def.pylon_blockable:true
        - wait 1s

lapex_ultimate_gibraltar:
    type: task
    script:
    - define center <player.eye_location.ray_trace[range=55;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playsound <player> sound:entity.firework_rocket.launch pitch:0.6 volume:0.8
    - repeat 16:
        - define dx <util.random_decimal.mul[14].sub[7]>
        - define dz <util.random_decimal.mul[14].sub[7]>
        - define strike <[center].add[<[dx]>,0,<[dz]>]>
        - playeffect effect:large_smoke at:<[strike].above[6]> offset:0.5 quantity:8
        - wait 6t
        - playeffect effect:explosion at:<[strike]> offset:1.5 quantity:4
        - playsound <[strike]> sound:entity.generic.explode pitch:0.75 volume:1
        - run lapex_legend_damage_sphere def.location:<[strike]> def.radius:5 def.damage:16 def.effect:slow def.pylon_blockable:true

lapex_ultimate_horizon:
    type: task
    debug: false
    script:
    - define raw <player.eye_location.ray_trace[range=45;default=air]>
    - define center <proc[lapex_legend_safe_destination].context[<[raw]>|null]||null>
    - if <[center]> == null:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>NO SAFE N.E.W.T. LOCATION"
        - stop
    - define spawn_tag lapex_horizon_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[center]> def.tag:<[spawn_tag]> def.arms:false
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>N.E.W.T. DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> arms:false
    - adjust <[device]> collidable:false
    - equip <[device]> head:<item[lapex_model_horizon_newt]>
    - flag <[device]> lapex.horizon_newt_active expire:6s
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:horizon_newt def.health:225 def.max_count:1 "def.label:<light_purple>N.E.W.T."
    - playsound <[device]> sound:block.end_portal.spawn pitch:1.6 volume:0.75

lapex_ultimate_lifeline:
    type: task
    debug: false
    script:
    - define raw <player.eye_location.ray_trace[range=25;default=air]>
    - define halo <proc[lapex_legend_safe_destination].context[<[raw]>|null]||null>
    - if <[halo]> == null:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>NO SAFE HALO LOCATION"
        - stop
    - define spawn_tag lapex_halo_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[halo]> def.tag:<[spawn_tag]> def.arms:false def.small:false def.marker:true
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>HALO DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> collidable:false
    - equip <[device]> head:<item[lapex_model_lifeline_halo]>
    - flag <[device]> lapex.deployable_invulnerable
    - flag <[device]> lapex.deployable_state:active
    - flag <[device]> lapex.lifeline_halo_active expire:25s
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:lifeline_halo def.health:1 def.max_count:1 "def.label:<aqua>D.O.C. HALO"
    - playsound <[halo]> sound:block.beacon.activate pitch:1.2 volume:1

lapex_ultimate_loba:
    type: task
    script:
    - define ids <script[lapex_weapon_data].data_key[all_ids].exclude[sheila].exclude[a13_sentry].exclude[whistler]>
    - define first <[ids].random>
    - define second <[ids].exclude[<[first]>].random>
    - give <item[apex_<[first]>]>
    - give <item[apex_<[second]>]>
    - playsound <player> sound:block.ender_chest.open pitch:1.25 volume:0.8
    - playeffect effect:witch at:<player.location.above[1]> offset:2 quantity:35
    - narrate "<gold>Black Market <gray>- pulled <white><script[lapex_weapon_data].data_key[weapons.<[first]>.name]><gray> and <white><script[lapex_weapon_data].data_key[weapons.<[second]>.name]><gray>."

lapex_ultimate_mad_maggie:
    type: task
    script:
    - define origin <player.location.above[1]>
    - define destination <player.eye_location.ray_trace[range=55;entities=living;ignore=<player>;raysize=0.5;default=air]>
    - define path <[origin].points_between[<[destination]>].distance[2]>
    - define previous <[origin]>
    - playsound <player> sound:entity.firework_rocket.launch pitch:0.7 volume:0.9
    - foreach <[path]> as:node:
        - ~run lapex_destroy_dome_crossed def.start:<[previous]> def.end:<[node]>
        - playeffect effect:explosion at:<[node]> offset:0.4 quantity:2
        - playeffect effect:small_flame at:<[node]> offset:1 quantity:6
        - run lapex_legend_damage_sphere def.location:<[node]> def.radius:2.5 def.damage:8 def.effect:slow def.pylon_blockable:true
        - foreach <proc[lapex_legend_allies_near].context[<[node]>|2.5|<player>]> as:target:
            - cast speed duration:4s amplifier:2 <[target]>
        - define previous <[node]>
        - wait 2t

lapex_ultimate_mirage:
    type: task
    script:
    - define origin <player.location>
    - cast invisibility duration:5s amplifier:0 <player> no_ambient hide_particles
    - playsound <player> sound:entity.illusioner.mirror_move pitch:0.8 volume:1
    - repeat 30 as:step:
        - if !<player.is_online>:
            - stop
        - repeat 8 as:clone:
            - define decoy <[origin].with_yaw[<[clone].mul[45]>].forward[<[step].mul[0.55]>].above[1]>
            - playeffect effect:dust at:<[decoy]> offset:0.35 quantity:5 special_data:[size=0.9;color=70,170,255]
        - wait 2t

lapex_ultimate_newcastle:
    type: task
    script:
    - define destination <player.eye_location.ray_trace[range=35;entities=living;ignore=<player>;raysize=0.3;default=air].above[1]>
    - push <player> origin:<player.location> destination:<[destination]> speed:2 duration:2s no_damage
    - wait 1s
    - define left <[destination].with_yaw[<player.location.yaw.add[90]>].forward[7]>
    - define right <[destination].with_yaw[<player.location.yaw.sub[90]>].forward[7]>
    - define wall <[left].points_between[<[right]>].distance[1.5]>
    - playeffect effect:electric_spark at:<[wall]> offset:0.5 quantity:8
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[wall]> offset:1 quantity:5 special_data:[size=1.2;color=60,120,255]
        - foreach <[wall]> as:node:
            - foreach <proc[lapex_legend_allies_near].context[<[node]>|2|<player>]> as:target:
                - flag <[target]> lapex.legend_protected expire:1.3s
        - wait 1s

lapex_ultimate_octane:
    type: task
    debug: false
    script:
    - define desired <player.location.forward[2]>
    - define pad <proc[lapex_legend_safe_destination].context[<[desired]>|null]||null>
    - if <[pad]> == null:
        - run lapex_legend_refund_charge def.target:<player> def.id:octane def.slot:ultimate
        - actionbar "<red>NO SAFE LAUNCH PAD LOCATION"
        - stop
    - define spawn_tag lapex_octane_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[pad]> def.tag:<[spawn_tag]> def.arms:false def.small:true
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - run lapex_legend_refund_charge def.target:<player> def.id:octane def.slot:ultimate
        - actionbar "<red>LAUNCH PAD DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> collidable:false
    - teleport <[device]> <[pad].with_yaw[<player.location.yaw>]>
    - equip <[device]> head:<item[lapex_model_octane_pad]>
    - flag <[device]> lapex.deployable_state:active
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:octane_pad def.health:200 def.max_count:4 "def.label:<green>LAUNCH PAD"
    - playsound <[device]> sound:block.piston.extend pitch:1.6 volume:0.8

lapex_ultimate_pathfinder:
    type: task
    script:
    - define origin <player.location>
    - define destination <player.eye_location.ray_trace[range=80;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - define line <[origin].above[1].points_between[<[destination]>].distance[2]>
    - playsound <player> sound:block.chain.place pitch:1.2 volume:0.9
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:crit at:<[line]> offset:0.04 quantity:2
        - foreach <[origin].find_entities[player].within[3]> as:rider:
            - if !<[rider].has_flag[lapex.zipline]>:
                - flag <[rider]> lapex.zipline expire:5s
                - push <[rider]> origin:<[origin]> destination:<[destination]> speed:2.2 duration:5s no_damage
        - wait 1s

lapex_ultimate_rampart:
    type: task
    script:
    - if <player.item_in_hand.flag[lapex.id]||null> == sheila:
        - inventory flag slot:hand lapex.ammo:<script[lapex_weapon_data].data_key[weapons.sheila.mag]>
        - actionbar "<gold>Sheila reloaded"
    - else if <proc[lapex_player_has_weapon].context[<player>|sheila]>:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<gray>Sheila is already in your inventory"
        - stop
    - else:
        - give <item[apex_sheila]>
        - narrate "<gold>Mobile Minigun Sheila deployed."
    - playsound <player> sound:block.respawn_anchor.charge pitch:0.7 volume:1

lapex_ultimate_revenant:
    type: task
    script:
    - flag player lapex.forged_shadows expire:25s
    - cast absorption duration:25s amplifier:4 <player>
    - cast speed duration:25s amplifier:1 <player>
    - cast resistance duration:25s amplifier:0 <player>
    - playeffect effect:large_smoke at:<player.location.above[1]> offset:1 quantity:35
    - playsound <player> sound:entity.wither.spawn pitch:1.8 volume:0.65

lapex_ultimate_seer:
    type: task
    script:
    - define exhibit <player.eye_location.ray_trace[range=35;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - playsound <[exhibit]> sound:block.beacon.activate pitch:1.7 volume:0.8
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[exhibit]> offset:12 quantity:45 special_data:[size=0.55;color=70,205,255]
        - run lapex_legend_scan def.location:<[exhibit]> def.radius:20 def.duration:1.3s
        - wait 1s

lapex_ultimate_sparrow:
    type: task
    script:
    - define bolt <player.eye_location.ray_trace[range=60;entities=living;ignore=<player>;raysize=0.4;default=air]>
    - playeffect effect:end_rod at:<player.eye_location.forward[0.8].points_between[<[bolt]>].distance[2]> offset:0.05 quantity:2
    - playsound <player> sound:entity.arrow.shoot pitch:0.65 volume:1
    - repeat 8:
        - playeffect effect:electric_spark at:<[bolt]> offset:3 quantity:18
        - wait 5t
    - playeffect effect:explosion at:<[bolt]> offset:2 quantity:5
    - playsound <[bolt]> sound:entity.lightning_bolt.thunder pitch:1.6 volume:0.8
    - run lapex_legend_damage_sphere def.location:<[bolt]> def.radius:8 def.damage:50 def.effect:slow def.pylon_blockable:true
    - run lapex_legend_scan def.location:<[bolt]> def.radius:12 def.duration:10s

lapex_ultimate_valkyrie:
    type: task
    script:
    - define riders <proc[lapex_legend_allies_near].context[<player.location>|8|<player>]>
    - playsound <player> sound:entity.firework_rocket.launch pitch:0.55 volume:1
    - foreach <[riders]> as:target:
        - cast levitation duration:3s amplifier:6 <[target]>
        - cast resistance duration:4s amplifier:2 <[target]>
    - wait 3s
    - foreach <[riders]> as:target:
        - cast slow_falling duration:15s amplifier:0 <[target]>
        - cast speed duration:15s amplifier:1 <[target]>

lapex_ultimate_vantage:
    type: task
    script:
    - if <player.item_in_hand.flag[lapex.id]||null> == a13_sentry:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<gray>A-13 rounds regenerate automatically"
        - stop
    - else if <proc[lapex_player_has_weapon].context[<player>|a13_sentry]>:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<gray>A-13 is already in your inventory"
        - stop
    - else:
        - give <item[apex_a13_sentry]>
        - narrate "<red>A-13 Sentry deployed. <gray>Hits mark targets for amplified follow-up damage."
    - playsound <player> sound:block.beacon.power_select pitch:1.9 volume:0.75

lapex_ultimate_wattson:
    type: task
    script:
    - define pylon <player.location.forward[2].above[1]>
    - playsound <[pylon]> sound:block.beacon.activate pitch:1.8 volume:0.8
    - repeat 45:
        - if !<player.is_online>:
            - stop
        - playeffect effect:electric_spark at:<[pylon]> offset:1 quantity:16
        - foreach <proc[lapex_legend_allies_near].context[<[pylon]>|9|<player>]> as:target:
            - flag <[target]> lapex.pylon_protected expire:1.3s
            - cast absorption duration:2s amplifier:0 <[target]>
            - cast regeneration duration:2s amplifier:0 <[target]>
        - wait 1s

lapex_ultimate_wraith:
    type: task
    debug: false
    script:
    - define origin <player.location>
    - define eye <player.eye_location>
    - define raw_destination <[eye].ray_trace[range=60;default=air]>
    - define destination <proc[lapex_legend_safe_destination].context[<[raw_destination]>|<[origin]>]>
    - if <[origin].distance[<[destination]>]> < 6:
        - flag player lapex.cooldown.ultimate:!
        - actionbar "<red>PORTAL EXIT IS TOO CLOSE"
        - stop
    - define portal_id <util.random_uuid>
    - define transiting <list[<player>]>
    - playeffect effect:portal at:<[origin].above[1].points_between[<[destination]>].distance[2]> offset:0.08 quantity:2
    - flag player lapex.rift_transit.<[portal_id]> expire:50s
    - teleport <player> <[destination]>
    - cast resistance duration:2s amplifier:4 <player>
    - playsound <player> sound:entity.enderman.teleport pitch:0.75 volume:0.9
    - repeat 450:
        - if !<player.is_online>:
            - stop
        - playeffect effect:portal at:<list[<[origin].above[1]>|<[destination].above[1]>]> offset:0.6 quantity:12
        - foreach <[origin].find_entities[player].within[2.2]> as:traveler:
            - if !<[traveler].has_flag[lapex.rift_transit.<[portal_id]>]>:
                - flag <[traveler]> lapex.rift_transit.<[portal_id]> expire:50s
                - define transiting <[transiting].include[<[traveler]>].deduplicate>
                - teleport <[traveler]> <[destination]>
        - foreach <[destination].find_entities[player].within[2.2]> as:traveler:
            - if !<[traveler].has_flag[lapex.rift_transit.<[portal_id]>]>:
                - flag <[traveler]> lapex.rift_transit.<[portal_id]> expire:50s
                - define transiting <[transiting].include[<[traveler]>].deduplicate>
                - teleport <[traveler]> <[origin]>
        # A traveler must leave both endpoint hitboxes before this portal can
        # accept them again. A fixed timer caused endless destination bounce.
        - foreach <[transiting]> as:traveler:
            - if !<[traveler].is_online||false>:
                - define transiting <[transiting].exclude[<[traveler]>]>
            - else if <[traveler].world> != <[origin].world>:
                - flag <[traveler]> lapex.rift_transit.<[portal_id]>:!
                - define transiting <[transiting].exclude[<[traveler]>]>
            - else if <[traveler].location.distance[<[origin]>]> > 2.8 && <[traveler].location.distance[<[destination]>]> > 2.8:
                - flag <[traveler]> lapex.rift_transit.<[portal_id]>:!
                - define transiting <[transiting].exclude[<[traveler]>]>
        - wait 2t
    - foreach <[transiting]> as:traveler:
        - if <[traveler].is_online||false>:
            - flag <[traveler]> lapex.rift_transit.<[portal_id]>:!
