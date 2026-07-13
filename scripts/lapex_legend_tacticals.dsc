# Tactical dispatcher and all 28 tactical implementations. Persistent objects
# are server-side effect zones, so they require no Citizens NPCs or armor-stand
# cleanup and remain safe across script reloads.

lapex_legend_tactical:
    type: task
    definitions: id
    script:
    - choose <[id]>:
        - case alter:
            - run lapex_tactical_alter
        - case ash:
            - run lapex_tactical_ash
        - case axle:
            - run lapex_tactical_axle
        - case ballistic:
            - run lapex_tactical_ballistic
        - case bangalore:
            - run lapex_tactical_bangalore
        - case bloodhound:
            - run lapex_tactical_bloodhound
        - case catalyst:
            - run lapex_tactical_catalyst
        - case caustic:
            - run lapex_tactical_caustic
        - case conduit:
            - run lapex_tactical_conduit
        - case crypto:
            - run lapex_tactical_crypto
        - case fuse:
            - run lapex_tactical_fuse
        - case gibraltar:
            - run lapex_tactical_gibraltar
        - case horizon:
            - run lapex_tactical_horizon
        - case lifeline:
            - run lapex_tactical_lifeline
        - case loba:
            - run lapex_tactical_loba
        - case mad_maggie:
            - run lapex_tactical_mad_maggie
        - case mirage:
            - run lapex_tactical_mirage
        - case newcastle:
            - run lapex_tactical_newcastle
        - case octane:
            - run lapex_tactical_octane
        - case pathfinder:
            - run lapex_tactical_pathfinder
        - case rampart:
            - run lapex_tactical_rampart
        - case revenant:
            - run lapex_tactical_revenant
        - case seer:
            - run lapex_tactical_seer
        - case sparrow:
            - run lapex_tactical_sparrow
        - case valkyrie:
            - run lapex_tactical_valkyrie
        - case vantage:
            - run lapex_tactical_vantage
        - case wattson:
            - run lapex_tactical_wattson
        - case wraith:
            - run lapex_tactical_wraith

lapex_tactical_alter:
    type: task
    script:
    - define eye <player.eye_location>
    - define raw_destination <[eye].ray_trace[range=24;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - define destination <proc[lapex_legend_safe_destination].context[<[raw_destination]>|<player.location>]>
    - playeffect effect:portal at:<[eye].forward[0.8].points_between[<[destination]>].distance[1.5]> offset:0.08 quantity:2
    - playsound <player> sound:entity.enderman.teleport pitch:0.65 volume:0.8
    - wait 4t
    - teleport <player> <[destination].with_yaw[<[eye].yaw>].with_pitch[<[eye].pitch>]>
    - cast resistance duration:1s amplifier:4 <player>
    - playeffect effect:reverse_portal at:<player.location.above[1]> offset:0.45 quantity:28

lapex_tactical_ash:
    type: task
    script:
    - define eye <player.eye_location>
    - define impact <[eye].ray_trace[range=36;entities=living;ignore=<player>;raysize=0.35;default=air]>
    - playeffect effect:electric_spark at:<[eye].forward[0.8].points_between[<[impact]>].distance[2]> offset:0.05 quantity:2
    - playsound <[impact]> sound:block.chain.place pitch:1.7 volume:0.8
    - repeat 8:
        - if !<player.is_online>:
            - stop
        - playeffect effect:electric_spark at:<[impact]> offset:2 quantity:10
        - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:4 def.damage:6 def.effect:slow def.pylon_blockable:true
        - wait 8t

lapex_tactical_axle:
    type: task
    debug: false
    script:
    - define desired <player.location.forward[4]>
    - define gate <proc[lapex_legend_safe_destination].context[<[desired]>|null]||null>
    - if <[gate]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NO SAFE NITRO GATE LOCATION"
        - stop
    - define spawn_tag lapex_axle_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[gate]> def.tag:<[spawn_tag]> def.arms:false def.small:false
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NITRO GATE DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> collidable:false
    - teleport <[device]> <[gate].with_yaw[<player.location.yaw>]>
    - equip <[device]> head:<item[lapex_model_axle_gate]>
    - flag <[device]> lapex.deployable_state:active
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:axle_gate def.health:100 def.max_count:2 "def.label:<aqua>NITRO GATE"
    - playsound <[device]> sound:block.beacon.activate pitch:1.7 volume:0.8

lapex_tactical_ballistic:
    type: task
    script:
    - if <player.item_in_hand.flag[lapex.id]||null> == whistler:
        - inventory flag slot:hand lapex.ammo:<script[lapex_weapon_data].data_key[weapons.whistler.mag]>
        - actionbar "<gold>Whistler reloaded"
    - else if <proc[lapex_player_has_weapon].context[<player>|whistler]>:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<gray>Whistler is already in your inventory"
        - stop
    - else:
        - give <item[apex_whistler]>
        - narrate "<gold>Whistler deployed. <gray>Equip it and fire to tag or trap a target."
    - playsound <player> sound:block.conduit.activate pitch:1.8 volume:0.7

lapex_tactical_bangalore:
    type: task
    script:
    - define eye <player.eye_location>
    - define impact <[eye].ray_trace[range=60;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - playeffect effect:smoke at:<[eye].forward[0.8].points_between[<[impact]>].distance[2]> offset:0.08 quantity:2
    - playsound <player> sound:entity.firework_rocket.launch pitch:0.75 volume:0.8
    - wait 8t
    - repeat 18:
        - if !<player.is_online>:
            - stop
        - playeffect effect:large_smoke at:<[impact]> offset:4 quantity:55
        - foreach <[impact].find_entities[player].within[5]> as:target:
            - cast blindness duration:1.5s amplifier:0 <[target]>
        - wait 1s

lapex_tactical_bloodhound:
    type: task
    script:
    - playeffect effect:dust at:<player.location.above[1]> offset:2 quantity:35 special_data:[size=1;color=255,70,45]
    - playsound <player> sound:block.respawn_anchor.charge pitch:1.8 volume:0.8
    - run lapex_legend_scan def.location:<player.location> def.radius:35 def.duration:8s

lapex_tactical_catalyst:
    type: task
    script:
    - define impact <player.eye_location.ray_trace[range=28;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playsound <[impact]> sound:block.sculk_shrieker.shriek pitch:1.5 volume:0.6
    - repeat 24:
        - if !<player.is_online>:
            - stop
        - playeffect effect:portal at:<[impact]> offset:2.5 quantity:16
        - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:3.5 def.damage:5 def.effect:slow def.pylon_blockable:true
        - wait 10t

lapex_tactical_caustic:
    type: task
    debug: false
    script:
    - define raw <player.eye_location.ray_trace[range=18;default=air]>
    - define trap <proc[lapex_legend_safe_destination].context[<[raw]>|null]||null>
    - if <[trap]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NO SAFE TRAP LOCATION"
        - stop
    - define spawn_tag lapex_caustic_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[trap]> def.tag:<[spawn_tag]> def.arms:false
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NOX TRAP DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> arms:false
    - adjust <[device]> collidable:false
    - equip <[device]> head:<item[lapex_model_caustic_trap]>
    - flag <[device]> lapex.deployable_state:arming
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:caustic_trap def.health:225 def.max_count:6 "def.label:<green>NOX TRAP"
    - playsound <[device]> sound:block.iron_trapdoor.close pitch:0.7 volume:0.8
    - actionbar "<green>NOX TRAP DEPLOYED <gray>- arming"

lapex_tactical_conduit:
    type: task
    script:
    - define allies <proc[lapex_legend_allies_near].context[<player.location>|20|<player>]>
    - foreach <[allies]> as:target:
        - cast absorption duration:12s amplifier:1 <[target]>
        - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.35 quantity:12
    - playsound <player> sound:block.conduit.activate pitch:1.5 volume:0.8

lapex_tactical_crypto:
    type: task
    script:
    - if <player.has_flag[lapex.crypto_active]>:
        - run lapex_crypto_exit def.owner:<player> def.reason:manual
        - stop
    - define owner <player>
    - define origin <[owner].location>
    - define session <util.random_uuid>
    - define body_tag lapex_crypto_<[session]>
    # Paper exposes mannequins as native player-shaped living entities, but the
    # current Denizen spawn adapter cannot construct them directly. Summon in
    # the correct dimension, then bind the entity back into Denizen.
    - define dimension minecraft:<[origin].world.name>
    - if <[origin].world.name> == world:
        - define dimension minecraft:overworld
    - else if <[origin].world.name> == world_nether:
        - define dimension minecraft:the_nether
    - else if <[origin].world.name> == world_the_end:
        - define dimension minecraft:the_end
    - execute as_server "execute in <[dimension]> run summon minecraft:mannequin <[origin].x> <[origin].y> <[origin].z> {Tags:['<[body_tag]>'],profile:{name:'<[owner].name>'}}" silent
    - wait 2t
    - define body null
    - foreach <[origin].find_entities[mannequin].within[0.75]> as:candidate:
        - if <[candidate].scoreboard_tags.contains[<[body_tag]>]>:
            - define body <[candidate]>
            - foreach stop
    - if <[body]> == null:
        - ~run lapex_native_spawn_armor_stand def.location:<[origin]> def.tag:<[body_tag]> def.arms:true
        - define body <server.flag[lapex.native_spawn_result.<[body_tag]>]||null>
        - flag server lapex.native_spawn_result.<[body_tag]>:!
        - if <[body]> != null:
            - adjust <[body]> arms:true
            - adjust <[body]> base_plate:false
    - if <[body]> == null:
        - flag <[owner]> lapex.cooldown.tactical:!
        - actionbar "<red>DRONE DEPLOY FAILED" targets:<[owner]>
        - stop
    - adjust <[body]> gravity:true
    - adjust <[body]> silent:true
    - adjust <[body]> custom_name:<gold><[owner].name>
    - adjust <[body]> custom_name_visible:true
    - flag <[body]> lapex.crypto_body_owner:<[owner]>
    - flag <[body]> lapex.crypto_session:<[session]>
    - define gear <[owner].equipment_map>
    - equip <[body]> hand:<[owner].item_in_hand> head:<[owner].skull_item> chest:<[gear].get[chestplate]||air> legs:<[gear].get[leggings]||air> boots:<[gear].get[boots]||air>

    - define drone_tag lapex_crypto_drone_<[session]>
    - ~run lapex_native_spawn_allay def.location:<[origin].above[1.35]> def.tag:<[drone_tag]>
    - define drone <server.flag[lapex.native_spawn_result.<[drone_tag]>]||null>
    - flag server lapex.native_spawn_result.<[drone_tag]>:!
    - if <[drone]> == null:
        - remove <[body]>
        - flag <[owner]> lapex.cooldown.tactical:!
        - actionbar "<red>DRONE DEPLOY FAILED" targets:<[owner]>
        - stop
    - adjust <[drone]> has_ai:false
    - adjust <[drone]> gravity:false
    - adjust <[drone]> silent:true
    - adjust <[drone]> glowing:true
    - adjust <[drone]> "custom_name:<aqua>DRONE <white>50"
    - adjust <[drone]> custom_name_visible:true
    - flag <[drone]> lapex.crypto_drone_owner:<[owner]>
    - flag <[drone]> lapex.crypto_session:<[session]>

    - flag <[owner]> lapex.crypto_active:<[session]>
    - flag <[owner]> lapex.crypto_origin:<[origin]>
    - flag <[owner]> lapex.crypto_gamemode:<[owner].gamemode>
    - flag <[owner]> lapex.crypto_body_entity:<[body]>
    - flag <[owner]> lapex.crypto_drone_entity:<[drone]>
    - flag <[owner]> lapex.crypto_body_chunk:<[origin].chunk>
    - flag <[owner]> lapex.crypto_drone:<[drone].location> expire:2s
    - flag <[owner]> lapex.crypto_drone_health:10
    # Drone recovery begins on destruction, not launch. Keep the body chunk
    # loaded so the full 200-block flight does not invalidate its proxy.
    - flag <[owner]> lapex.cooldown.tactical:!
    - chunkload <[origin].chunk>
    - adjust <[owner]> gamemode:spectator
    - teleport <[owner]> <[origin].above[1.35]>
    - playsound <[origin]> sound:block.beacon.activate pitch:1.8 volume:0.65
    - actionbar "<aqua>DRONE ONLINE <gray>| <white>Q OR /LEGEND TACTICAL TO RECALL" targets:<[owner]>
    - run lapex_crypto_pilot def.owner:<[owner]> def.session:<[session]>

lapex_crypto_pilot:
    type: task
    debug: false
    definitions: owner|session
    script:
    - define last_safe <[owner].flag[lapex.crypto_origin].above[1.35]>
    - define pulse 0
    - while <[owner].is_online||false> && <[owner].flag[lapex.crypto_active]||null> == <[session]>:
        - define pulse <[pulse].add[1]>
        - if !<[owner].is_online||false>:
            - stop
        - if <[owner].flag[lapex.crypto_active]||null> != <[session]>:
            - stop
        - define body <[owner].flag[lapex.crypto_body_entity]||null>
        - define drone <[owner].flag[lapex.crypto_drone_entity]||null>
        - if <[body]> == null || !<[body].is_spawned||false> || <[drone]> == null || !<[drone].is_spawned||false>:
            - run lapex_crypto_exit def.owner:<[owner]> def.reason:destroyed
            - stop
        - if <[owner].gamemode> != SPECTATOR:
            - run lapex_crypto_exit def.owner:<[owner]> def.reason:gamemode
            - stop
        - define origin <[owner].flag[lapex.crypto_origin]>
        - if <[owner].world> != <[origin].world>:
            - teleport <[owner]> <[last_safe]>
            - playsound <[owner]> sound:block.dispenser.fail pitch:0.8 volume:0.55
        - else if <[owner].location.distance[<[origin]>]> > 200:
            - teleport <[owner]> <[last_safe]>
            - playsound <[owner]> sound:block.dispenser.fail pitch:0.8 volume:0.55
        - else if <[owner].eye_location.material.is_solid>:
            - teleport <[owner]> <[last_safe]>
        - else:
            - define last_safe <[owner].location>
        - define drone_location <[owner].location.backward[0.55].below[0.15]>
        - teleport <[drone]> <[drone_location]>
        - flag <[owner]> lapex.crypto_drone:<[drone_location]> expire:2s
        - if <[pulse].mod[2]> == 0:
            - playeffect effect:electric_spark at:<[drone_location]> offset:0.28 quantity:3
        - define health <[owner].flag[lapex.crypto_drone_health]||0>
        - define range <[owner].location.distance[<[origin]>].round>
        - actionbar "<aqua>DRONE <white><[health].mul[5].round>/50 <dark_gray>| <gray>RANGE <white><[range]>/200 <dark_gray>| <gray>Q OR /LEGEND TACTICAL" targets:<[owner]>
        - wait 5t

lapex_crypto_body_hit:
    type: task
    debug: false
    definitions: owner|damage|attacker|cause|session|proxy
    script:
    # A shotgun routes one event per pellet in the same tick. Collect all of
    # them before leaving drone view so later pellets are not lost when the
    # first event clears the Crypto session.
    - if !<[owner].is_online||false> || <[damage]||0> <= 0:
        - stop
    - if <[owner].flag[lapex.crypto_active]||null> != <[session]> || <[owner].flag[lapex.crypto_body_entity]||null> != <[proxy]>:
        - stop
    - define body_protected <[owner].has_flag[lapex.phased]>
    - if <[attacker]||null> != null && <[attacker]> != <[owner]> && <[owner].has_flag[lapex.legend_protected]>:
        - define body_protected true
    - if <[body_protected]>:
        - stop
    - flag <[owner]> lapex.crypto_body_pending_damage.<[session]>:+:<[damage]>
    - flag <[owner]> lapex.crypto_body_pending_cause.<[session]>:<[cause]||CUSTOM>
    - if <[attacker]||null> != null:
        - flag <[owner]> lapex.crypto_body_pending_attacker.<[session]>:<[attacker]>
    - if <[owner].flag[lapex.crypto_body_pending_flush]||null> == <[session]>:
        - stop
    - flag <[owner]> lapex.crypto_body_pending_flush:<[session]>
    - run lapex_crypto_body_flush def.owner:<[owner]> def.session:<[session]> def.proxy:<[proxy]>

lapex_crypto_body_flush:
    type: task
    debug: false
    definitions: owner|session|proxy
    script:
    - wait 1t
    - define damage <[owner].flag[lapex.crypto_body_pending_damage.<[session]>]||0>
    - define attacker <[owner].flag[lapex.crypto_body_pending_attacker.<[session]>]||null>
    - define cause <[owner].flag[lapex.crypto_body_pending_cause.<[session]>]||CUSTOM>
    - flag <[owner]> lapex.crypto_body_pending_damage.<[session]>:!
    - flag <[owner]> lapex.crypto_body_pending_attacker.<[session]>:!
    - flag <[owner]> lapex.crypto_body_pending_cause.<[session]>:!
    - flag <[owner]> lapex.crypto_body_pending_flush:!
    - if !<[owner].is_online||false> || <[damage]> <= 0:
        - stop
    - if <[owner].flag[lapex.crypto_active]||null> != <[session]> || <[owner].flag[lapex.crypto_body_entity]||null> != <[proxy]>:
        - stop
    - ~run lapex_crypto_exit def.owner:<[owner]> def.reason:body_hit
    - if <[attacker]> != null && <[attacker].is_spawned||false>:
        - hurt <[damage]> <[owner]> cause:<[cause]> source:<[attacker]>
    - else:
        - hurt <[damage]> <[owner]> cause:<[cause]>

lapex_crypto_drone_hit:
    type: task
    debug: false
    definitions: owner|damage|attacker|session|proxy
    script:
    - if !<[owner].is_online||false> || <[owner].flag[lapex.crypto_active]||null> != <[session]> || <[owner].flag[lapex.crypto_drone_entity]||null> != <[proxy]> || <[owner].has_flag[lapex.crypto_destroyed]>:
        - stop
    - define drone <[owner].flag[lapex.crypto_drone_entity]||null>
    - define health <[owner].flag[lapex.crypto_drone_health]||10>
    - define health <[health].sub[<[damage].max[0.5]>].max[0]>
    - flag <[owner]> lapex.crypto_drone_health:<[health]>
    - if <[drone]> != null && <[drone].is_spawned||false>:
        - adjust <[drone]> "custom_name:<aqua>DRONE <white><[health].mul[5].round>"
        - playeffect effect:electric_spark at:<[drone].location> offset:0.35 quantity:10
        - playsound <[drone]> sound:block.copper_bulb.break pitch:1.5 volume:0.7
    - actionbar "<red>DRONE DAMAGED <white><[health].mul[5].round>/50" targets:<[owner]>
    - if <[health]> <= 0:
        - flag <[owner]> lapex.crypto_destroyed expire:2s
        - wait 1t
        - run lapex_crypto_exit def.owner:<[owner]> def.reason:destroyed

lapex_crypto_exit:
    type: task
    debug: false
    definitions: owner|reason
    script:
    - if <[owner]> == null:
        - stop
    - define body <[owner].flag[lapex.crypto_body_entity]||null>
    - define drone <[owner].flag[lapex.crypto_drone_entity]||null>
    - define origin <[owner].flag[lapex.crypto_origin]||null>
    - define return_location <[origin]>
    - define body_chunk <[owner].flag[lapex.crypto_body_chunk]||null>
    - define old_gamemode <[owner].flag[lapex.crypto_gamemode]||SURVIVAL>
    # Paper may save the spectator-camera position during disconnect. Keep a
    # one-shot fallback so reconnect always returns to the guarded body spot.
    - if <[body]> != null && <[body].is_spawned||false>:
        - define return_location <[body].location>
    - if <[reason]> == quit && <[return_location]> != null:
        - flag <[owner]> lapex.crypto_reconnect_location:<[return_location]>
    - if <[body_chunk]> != null:
        - chunkload <[body_chunk]>
    - if <[drone]> != null && <[drone].is_spawned||false>:
        - if <[reason]> == destroyed:
            - playeffect effect:explosion at:<[drone].location> offset:0.25 quantity:3
            - playsound <[drone]> sound:entity.generic.explode pitch:1.8 volume:0.8
        - remove <[drone]>
    - if <[body]> != null && <[body].is_spawned||false>:
        - remove <[body]>
    - if <[owner].is_online||false>:
        - adjust <[owner]> gamemode:<[old_gamemode]>
        # An empty value clears Paper's packet-level override. Setting this to
        # 1 would leave an override registered and can strand the camera FOV.
        - adjust <[owner]> fov_multiplier
        - if <[return_location]> != null && <[reason]> != death:
            - teleport <[owner]> <[return_location]>
        - if <[reason]> == destroyed:
            - actionbar "<red>DRONE DESTROYED" targets:<[owner]>
        - else if <[reason]> == body_hit:
            - actionbar "<red>BODY UNDER ATTACK" targets:<[owner]>
        - else if <[reason]> == timeout:
            - actionbar "<gray>DRONE SIGNAL ENDED" targets:<[owner]>
        - else:
            - actionbar "<gray>DRONE RECALLED" targets:<[owner]>
    - flag <[owner]> lapex.crypto_active:!
    - flag <[owner]> lapex.crypto_origin:!
    - flag <[owner]> lapex.crypto_gamemode:!
    - flag <[owner]> lapex.crypto_body_entity:!
    - flag <[owner]> lapex.crypto_drone_entity:!
    - flag <[owner]> lapex.crypto_drone:!
    - flag <[owner]> lapex.crypto_drone_health:!
    - flag <[owner]> lapex.crypto_destroyed:!
    - flag <[owner]> lapex.crypto_body_chunk:!
    - flag <[owner]> lapex.crypto_body_pending_damage:!
    - flag <[owner]> lapex.crypto_body_pending_attacker:!
    - flag <[owner]> lapex.crypto_body_pending_cause:!
    - flag <[owner]> lapex.crypto_body_pending_flush:!
    # Destruction uses the official recovery window. A normal recall only gets
    # a short input lock so it cannot be spammed in the same client tick.
    - if <[reason]> == destroyed:
        - flag <[owner]> lapex.cooldown.tactical expire:30s
    - else if <list[manual|body_hit].contains[<[reason]>]>:
        - flag <[owner]> lapex.cooldown.tactical expire:2s
    - if <[body_chunk]> != null:
        # Denizen chunk tickets are plugin-wide. Do not remove the shared ticket
        # while another active Crypto body still owns this chunk.
        - define keep_chunk false
        - foreach <server.online_players> as:other:
            - if <[other]> != <[owner]> && <[other].has_flag[lapex.crypto_active]> && <[other].flag[lapex.crypto_body_chunk]||null> == <[body_chunk]>:
                - define keep_chunk true
        - if !<[keep_chunk]>:
            - chunkload remove <[body_chunk]>

lapex_tactical_fuse:
    type: task
    script:
    - define eye <player.eye_location>
    - define impact <[eye].ray_trace[range=48;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playeffect effect:small_flame at:<[eye].forward[0.8].points_between[<[impact]>].distance[2]> offset:0.05 quantity:2
    - playsound <player> sound:entity.firework_rocket.launch pitch:1.2 volume:0.8
    - wait 10t
    - repeat 4:
        - playeffect effect:explosion at:<[impact]> offset:1.2 quantity:3
        - playsound <[impact]> sound:entity.generic.explode pitch:1.35 volume:0.9
        - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:4 def.damage:12 def.effect:burn def.pylon_blockable:true
        - wait 8t

lapex_tactical_gibraltar:
    type: task
    debug: false
    script:
    - define desired <player.location.forward[2]>
    - define center <proc[lapex_legend_safe_destination].context[<[desired]>|null]||null>
    - if <[center]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NO SAFE DOME LOCATION"
        - stop
    - define spawn_tag lapex_dome_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[center]> def.tag:<[spawn_tag]> def.arms:false def.small:true def.marker:true
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>DOME DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> collidable:false
    - equip <[device]> head:<item[lapex_model_gibraltar_dome]>
    - flag <[device]> lapex.deployable_invulnerable
    - flag <[device]> lapex.deployable_state:active
    - flag <[device]> lapex.gibraltar_dome_active expire:12s
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:gibraltar_dome def.health:1 def.max_count:1 "def.label:<aqua>DOME"
    - playsound <[center]> sound:block.beacon.activate pitch:0.8 volume:1

lapex_tactical_horizon:
    type: task
    script:
    - define lift <player.eye_location.ray_trace[range=20;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - playsound <[lift]> sound:block.beacon.power_select pitch:1.9 volume:0.75
    - repeat 24:
        - if !<player.is_online>:
            - stop
        - playeffect effect:portal at:<[lift]> offset:2 quantity:14
        - foreach <[lift].find_entities[living].within[3.5]> as:target:
            - cast levitation duration:8t amplifier:2 <[target]>
            - cast slow_falling duration:2s amplifier:0 <[target]>
        - wait 5t

lapex_tactical_lifeline:
    type: task
    debug: false
    script:
    - define desired <player.location.forward[2]>
    - define location <proc[lapex_legend_safe_destination].context[<[desired]>|null]||null>
    - if <[location]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>NO SAFE D.O.C. LOCATION"
        - stop
    - define spawn_tag lapex_doc_<util.random_uuid>
    - define doc_start <player.location.with_pitch[0].backward[1.2].right[0.8].above[0.5]>
    - ~run lapex_native_spawn_armor_stand def.location:<[doc_start]> def.tag:<[spawn_tag]> def.arms:false def.small:true def.marker:true
    - define device <server.flag[lapex.native_spawn_result.<[spawn_tag]>]||null>
    - flag server lapex.native_spawn_result.<[spawn_tag]>:!
    - if <[device]> == null:
        - flag player lapex.cooldown.tactical:!
        - actionbar "<red>D.O.C. DEPLOY FAILED"
        - stop
    - adjust <[device]> gravity:false
    - adjust <[device]> silent:true
    - adjust <[device]> visible:false
    - adjust <[device]> base_plate:false
    - adjust <[device]> collidable:false
    - equip <[device]> head:<item[lapex_model_lifeline_doc]>
    - flag <[device]> lapex.deployable_invulnerable
    - flag <[device]> lapex.deployable_state:active
    - flag <[device]> lapex.lifeline_doc_target:<player>
    - flag <[device]> lapex.lifeline_doc_active expire:20s
    - run lapex_deployable_register def.owner:<player> def.entity:<[device]> def.kind:lifeline_doc def.health:1 def.max_count:1 "def.label:<green>D.O.C."
    - playsound <[device]> sound:block.beacon.activate pitch:1.6 volume:0.7

lapex_tactical_loba:
    type: task
    script:
    - define eye <player.eye_location>
    - define raw_destination <[eye].ray_trace[range=45;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - define destination <proc[lapex_legend_safe_destination].context[<[raw_destination]>|<player.location>]>
    - playeffect effect:end_rod at:<[eye].forward[0.8].points_between[<[destination]>].distance[2]> offset:0.06 quantity:2
    - playsound <player> sound:entity.firework_rocket.launch pitch:1.8 volume:0.55
    - wait 10t
    - teleport <player> <[destination].with_yaw[<[eye].yaw>].with_pitch[<[eye].pitch>]>
    - playeffect effect:witch at:<player.location.above[1]> offset:0.45 quantity:24

lapex_tactical_mad_maggie:
    type: task
    script:
    - define eye <player.eye_location>
    - define impact <[eye].ray_trace[range=45;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playeffect effect:flame at:<[eye].forward[0.8].points_between[<[impact]>].distance[2]> offset:0.05 quantity:2
    - playsound <player> sound:item.firecharge.use pitch:1.3 volume:0.8
    - repeat 10:
        - playeffect effect:flame at:<[impact]> offset:1.6 quantity:20
        - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:2.7 def.damage:8 def.effect:burn def.pylon_blockable:true
        - wait 10t

lapex_tactical_mirage:
    type: task
    script:
    - define origin <player.location>
    - playsound <player> sound:entity.illusioner.mirror_move pitch:1.4 volume:0.7
    - repeat 24 as:step:
        - if !<player.is_online>:
            - stop
        - define left <[origin].with_yaw[<[origin].yaw.add[25]>].forward[<[step].mul[0.6]>].above[1]>
        - define center <[origin].forward[<[step].mul[0.65]>].above[1]>
        - define right <[origin].with_yaw[<[origin].yaw.sub[25]>].forward[<[step].mul[0.6]>].above[1]>
        - playeffect effect:dust at:<list[<[left]>|<[center]>|<[right]>]> offset:0.25 quantity:4 special_data:[size=0.9;color=70,170,255]
        - wait 2t

lapex_tactical_newcastle:
    type: task
    script:
    - define shield <player.location.forward[5].above[1]>
    - playsound <[shield]> sound:block.beacon.activate pitch:1.2 volume:0.8
    - repeat 15:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[shield]> offset:2 quantity:24 special_data:[size=1.1;color=65,130,255]
        - foreach <proc[lapex_legend_allies_near].context[<[shield]>|4|<player>]> as:target:
            - flag <[target]> lapex.legend_protected expire:1.3s
        - wait 1s

lapex_tactical_octane:
    type: task
    script:
    - if <player.has_flag[lapex.stim_active]> && !<player.has_flag[lapex.stim_surge_cooldown]>:
        - flag player lapex.stim_active expire:6s
        - flag player lapex.stim_surge expire:6s
        - flag player lapex.stim_surge_cooldown expire:20s
        - cast speed duration:6s amplifier:2 <player>
        - playeffect effect:electric_spark at:<player.location.above[1]> offset:0.35 quantity:12
        - playsound <player> sound:block.conduit.activate pitch:1.8 volume:0.7
        - actionbar "<green>STIM SURGE <white>6s <dark_gray>| <gray>SWIFT MEND ACTIVE"
        - stop
    # EA does not publish the current exact health cost. Twenty Apex HP remains
    # an explicit Lapex tuning value for normal Stim uses.
    - define cost <element[20].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
    # Stim cannot kill its user, but it must still spend every available point
    # above the minimum health floor. At the floor, reject the use instead of
    # granting a free speed boost.
    - define payable <[cost].min[<player.health.sub[0.5]>]>
    - if <[payable]> <= 0:
        - actionbar "<red>TOO LITTLE HEALTH TO STIM"
        - playsound <player> sound:block.dispenser.fail pitch:1.2 volume:0.55
        - flag player lapex.cooldown.tactical:!
        - stop
    - hurt <[payable]> <player> cause:CUSTOM source:<player>
    - flag player lapex.stim_active expire:6s
    - cast speed duration:6s amplifier:2 <player>
    - playeffect effect:happy_villager at:<player.location.above[1]> offset:0.35 quantity:10
    - playsound <player> sound:block.brewing_stand.brew pitch:1.8 volume:0.7

lapex_tactical_pathfinder:
    type: task
    script:
    - define origin <player.location>
    - define destination <player.eye_location.ray_trace[range=35;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - playeffect effect:crit at:<[origin].above[1].points_between[<[destination]>].distance[1.5]> offset:0.04 quantity:2
    - playsound <player> sound:block.chain.place pitch:1.5 volume:0.8
    - push <player> origin:<[origin]> destination:<[destination]> speed:2 duration:2s no_damage

lapex_tactical_rampart:
    type: task
    script:
    - define cover <player.location.forward[4].above[1]>
    - playsound <[cover]> sound:block.iron_door.close pitch:0.8 volume:0.8
    - repeat 20:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[cover]> offset:2 quantity:22 special_data:[size=1.1;color=255,145,50]
        - foreach <proc[lapex_legend_allies_near].context[<[cover]>|4|<player>]> as:target:
            - flag <[target]> lapex.legend_protected expire:1.3s
            - flag <[target]> lapex.amped_cover expire:1.3s
        - wait 1s

lapex_tactical_revenant:
    type: task
    script:
    - define origin <player.location>
    - define destination <player.eye_location.ray_trace[range=28;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - playsound <player> sound:entity.ender_dragon.flap pitch:0.7 volume:0.7
    - playeffect effect:smoke at:<player.location.above[1]> offset:0.5 quantity:18
    - push <player> origin:<[origin]> destination:<[destination]> speed:2.2 duration:18t no_damage
    - cast resistance duration:2s amplifier:1 <player>

lapex_tactical_seer:
    type: task
    script:
    - define impact <player.eye_location.ray_trace[range=38;entities=living;ignore=<player>;raysize=1.2;default=air]>
    - playeffect effect:dust at:<player.eye_location.forward[0.8].points_between[<[impact]>].distance[1.5]> offset:0.3 quantity:4 special_data:[size=0.8;color=80,210,255]
    - playsound <player> sound:block.sculk_sensor.clicking pitch:1.6 volume:0.8
    - foreach <[impact].find_entities[living].within[8]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> != null && !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[combat_player].has_flag[lapex.legend_protected]> && !<[combat_player].has_flag[lapex.phased]>:
            - flag <[combat_player]> lapex.legend_silenced expire:8s
    - run lapex_legend_scan def.location:<[impact]> def.radius:10 def.duration:8s

lapex_tactical_sparrow:
    type: task
    script:
    - define dart <player.eye_location.ray_trace[range=55;entities=living;ignore=<player>;raysize=0.3;default=air]>
    - playeffect effect:end_rod at:<player.eye_location.forward[0.8].points_between[<[dart]>].distance[2]> offset:0.04 quantity:2
    - playsound <player> sound:entity.arrow.shoot pitch:1.7 volume:0.75
    - repeat 14:
        - if !<player.is_online>:
            - stop
        - playeffect effect:electric_spark at:<[dart]> offset:0.5 quantity:6
        - run lapex_legend_scan def.location:<[dart]> def.radius:14 def.duration:1.5s
        - wait 1.5s

lapex_tactical_valkyrie:
    type: task
    script:
    - define impact <player.eye_location.ray_trace[range=55;entities=living;ignore=<player>;raysize=0.4;default=air]>
    - playsound <player> sound:entity.firework_rocket.launch pitch:1.3 volume:0.8
    - repeat 6:
        - playeffect effect:small_flame at:<player.eye_location.forward[1].points_between[<[impact]>].distance[3]> offset:0.15 quantity:3
        - wait 3t
        - playeffect effect:explosion at:<[impact]> offset:3 quantity:3
        - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:5 def.damage:8 def.effect:slow def.pylon_blockable:true

lapex_tactical_vantage:
    type: task
    script:
    - define origin <player.location>
    - define destination <player.eye_location.ray_trace[range=36;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - playeffect effect:end_rod at:<[origin].above[1].points_between[<[destination]>].distance[2]> offset:0.08 quantity:2
    - playsound <player> sound:entity.bat.takeoff pitch:1.5 volume:0.75
    - push <player> origin:<[origin]> destination:<[destination]> speed:1.8 duration:2s no_damage
    - cast slow_falling duration:4s amplifier:0 <player>

lapex_tactical_wattson:
    type: task
    script:
    - define origin <player.location.above[1]>
    - define end <player.eye_location.ray_trace[range=24;entities=living;ignore=<player>;raysize=0.2;default=air]>
    - define fence <[origin].points_between[<[end]>].distance[1.5]>
    - playsound <player> sound:block.beacon.activate pitch:1.9 volume:0.7
    - repeat 20:
        - if !<player.is_online>:
            - stop
        - playeffect effect:electric_spark at:<[fence]> offset:0.05 quantity:2
        - foreach <[fence]> as:node:
            - run lapex_legend_damage_sphere def.location:<[node]> def.radius:1.2 def.damage:3 def.effect:slow
        - wait 1s

lapex_tactical_wraith:
    type: task
    script:
    - flag player lapex.phased expire:4s
    - cast invisibility duration:4s amplifier:0 <player> no_ambient hide_particles
    - cast resistance duration:4s amplifier:4 <player> no_ambient hide_particles
    - cast speed duration:4s amplifier:1 <player> no_ambient hide_particles
    - playeffect effect:portal at:<player.location.above[1]> offset:0.5 quantity:30
    - playsound <player> sound:entity.enderman.teleport pitch:1.4 volume:0.8
