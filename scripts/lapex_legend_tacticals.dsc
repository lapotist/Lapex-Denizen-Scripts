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
    script:
    - define gate <player.location.forward[4]>
    - define destination <player.location.forward[16]>
    - playsound <[gate]> sound:block.beacon.activate pitch:1.7 volume:0.8
    - repeat 30:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[gate]> offset:1.1 quantity:14 special_data:[size=1;color=75,225,255]
        - foreach <[gate].find_entities[living].within[2.2]> as:rider:
            - if !<[rider].has_flag[lapex.nitro_boost]>:
                - flag <[rider]> lapex.nitro_boost expire:2s
                - push <[rider]> origin:<[gate]> destination:<[destination]> speed:1.8 duration:10t no_damage
                - cast speed duration:2s amplifier:2 <[rider]>
        - wait 10t

lapex_tactical_ballistic:
    type: task
    script:
    - if <player.item_in_hand.flag[lapex.id]||null> == whistler:
        - inventory flag slot:hand lapex.ammo:<script[lapex_weapon_data].data_key[weapons.whistler.mag]>
        - actionbar "<gold>Whistler reloaded"
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
    script:
    - define trap <player.eye_location.ray_trace[range=18;entities=living;ignore=<player>;raysize=0.25;default=air]>
    - playeffect effect:cloud at:<[trap]> offset:0.3 quantity:12
    - playsound <[trap]> sound:block.iron_trapdoor.close pitch:0.7 volume:0.8
    - define triggered false
    - repeat 40:
        - playeffect effect:dust at:<[trap]> offset:0.35 quantity:3 special_data:[size=0.65;color=180,230,35]
        - foreach <[trap].find_entities[player].within[3]> as:target:
            - if !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[target].has_flag[lapex.legend_protected]> && !<[target].has_flag[lapex.phased]>:
                - define triggered true
                - repeat stop
        - if <[triggered]>:
            - repeat stop
        - wait 10t
    - if !<[triggered]>:
        - stop
    - playsound <[trap]> sound:block.fire.extinguish pitch:0.55 volume:1
    - repeat 12:
        - playeffect effect:cloud at:<[trap]> offset:3 quantity:40
        - run lapex_legend_damage_sphere def.location:<[trap]> def.radius:5 def.damage:5 def.effect:slow def.pylon_blockable:true
        - wait 1s

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
    - execute as_server "execute in <[dimension]> run summon minecraft:mannequin <[origin].x> <[origin].y> <[origin].z> {profile:{name:'<[owner].name>'},immovable:true}" silent
    - define body <[origin].find_entities[mannequin].within[0.75].first||null>
    - if <[body]> == null:
        - spawn armor_stand <[origin]> persistent save:crypto_body_fallback
        - define body <entry[crypto_body_fallback].spawned_entity||null>
        - if <[body]> != null:
            - adjust <[body]> arms:true
            - adjust <[body]> base_plate:false
    - if <[body]> == null:
        - flag <[owner]> lapex.cooldown.tactical:!
        - actionbar "<red>DRONE DEPLOY FAILED" targets:<[owner]>
        - stop
    - adjust <[body]> gravity:false
    - adjust <[body]> silent:true
    - adjust <[body]> custom_name:<gold><[owner].name>
    - adjust <[body]> custom_name_visible:true
    - flag <[body]> lapex.crypto_body_owner:<[owner]>
    - flag <[body]> lapex.crypto_session:<[session]>
    - define gear <[owner].equipment_map>
    - equip <[body]> hand:<[owner].item_in_hand> head:<[owner].skull_item> chest:<[gear].get[chestplate]||air> legs:<[gear].get[leggings]||air> boots:<[gear].get[boots]||air>

    - spawn allay <[origin].above[1.35]> persistent save:crypto_drone_spawn
    - define drone <entry[crypto_drone_spawn].spawned_entity||null>
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
    definitions: owner|damage|attacker|session|proxy
    script:
    # Let the firing queue finish its target bookkeeping before removing the
    # proxy, then restore the owner so normal hurt/death behavior can run.
    - wait 1t
    - if !<[owner].is_online||false>:
        - stop
    - if <[owner].flag[lapex.crypto_active]||null> != <[session]> || <[owner].flag[lapex.crypto_body_entity]||null> != <[proxy]>:
        - stop
    - if <[owner].has_flag[lapex.crypto_active]>:
        - run lapex_crypto_exit def.owner:<[owner]> def.reason:body_hit
    - if <[damage]> <= 0:
        - stop
    - if <[attacker]> != null && <[attacker].is_spawned||false>:
        - hurt <[damage]> <[owner]> cause:PROJECTILE source:<[attacker]>
    - else:
        - hurt <[damage]> <[owner]> cause:CUSTOM

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
    - define body_chunk <[owner].flag[lapex.crypto_body_chunk]||null>
    - define old_gamemode <[owner].flag[lapex.crypto_gamemode]||SURVIVAL>
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
        - adjust <[owner]> fov_multiplier:1
        - if <[origin]> != null && <[reason]> != quit && <[reason]> != death:
            - teleport <[owner]> <[origin]>
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
    script:
    - define center <player.location>
    - playsound <[center]> sound:block.beacon.activate pitch:0.8 volume:1
    - repeat 15:
        - if !<player.is_online>:
            - stop
        - playeffect effect:dust at:<[center].above[2]> offset:5 quantity:32 special_data:[size=1.25;color=80,170,255]
        - foreach <proc[lapex_legend_allies_near].context[<[center]>|6|<player>]> as:target:
            - flag <[target]> lapex.legend_protected expire:1.3s
        - wait 1s

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
    script:
    - define drone <player.location.forward[2].above[1]>
    - playsound <[drone]> sound:block.beacon.activate pitch:1.6 volume:0.7
    - repeat 20:
        - if !<player.is_online>:
            - stop
        - playeffect effect:heart at:<[drone]> offset:0.45 quantity:5
        - define allies <proc[lapex_legend_allies_near].context[<[drone]>|7|<player>]>
        - if !<[allies].is_empty>:
            - heal 1 <[allies]>
        - wait 1s

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
    - define cost <element[20].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
    - if <player.health> > <[cost].add[0.5]>:
        - hurt <[cost]> <player> cause:CUSTOM source:<player>
    - cast speed duration:6s amplifier:2 <player>
    - cast jump_boost duration:6s amplifier:1 <player>
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
    - run lapex_legend_damage_sphere def.location:<[impact]> def.radius:8 def.damage:10 def.effect:silence
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
