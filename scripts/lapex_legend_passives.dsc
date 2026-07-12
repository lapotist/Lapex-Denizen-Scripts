# Passive and shared-state runtime for all 28 legends. The secondly event is
# reload-safe: it resumes for every online player whenever scripts are loaded.

lapex_legend_passive_events:
    type: world
    debug: false
    events:
        on delta time secondly:
        - foreach <server.online_players> as:target:
            - run lapex_legend_passive_tick def.target:<[target]>

        # Protection zones set short flags every pulse. Only externally sourced
        # damage is blocked, so fall damage and ability health costs still work.
        on player damaged:
        - define victim <context.entity>
        - define damager <context.damager||null>
        - if <[damager]> != null && <[victim].has_flag[lapex.legend_protected]>:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - define projectile <context.projectile||null>
        - if <[victim].has_flag[lapex.pylon_protected]> && <[projectile]> != null:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - if <[victim].has_flag[lapex.pylon_protected]> && <list[BLOCK_EXPLOSION|ENTITY_EXPLOSION].contains[<context.cause>]||false>:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - if <[damager]> != null && <[victim].has_flag[lapex.phased]>:
            - determine cancelled

        # Gun Shield absorbs one incoming hit while Gibraltar is braced, then
        # spends its current nine-second recharge.
        - if <[damager]> != null && <[victim].flag[lapex.legend]||bangalore> == gibraltar && <[victim].is_sneaking> && !<[victim].has_flag[lapex.gun_shield_cooldown]>:
            - flag <[victim]> lapex.gun_shield_cooldown expire:9s
            - playeffect effect:electric_spark at:<[victim].eye_location.forward[0.5]> offset:0.25 quantity:12
            - playsound <[victim]> sound:item.shield.block pitch:1.25 volume:0.75
            - determine cancelled

        - flag <[victim]> lapex.recent_damage:<[victim].location> expire:6s
        - define projected_health <[victim].health.sub[<context.final_damage||<context.damage>>]>
        - if <[projected_health].div[<[victim].health_max>]> <= 0.4:
            - flag <[victim]> lapex.low_health expire:6s

        - choose <[victim].flag[lapex.legend]||bangalore>:
            - case bangalore:
                - if <[victim].is_sprinting> && !<[victim].has_flag[lapex.double_time_cooldown]>:
                    - flag <[victim]> lapex.double_time_cooldown expire:5s
                    - cast speed duration:3s amplifier:1 <[victim]>
                    - playsound <[victim]> sound:entity.horse.gallop pitch:1.5 volume:0.45
            - case catalyst:
                - if <[victim].has_flag[lapex.barricaded]>:
                    - determine <context.damage.mul[0.5]>
            - case fuse:
                - if <list[BLOCK_EXPLOSION|ENTITY_EXPLOSION|FIRE|FIRE_TICK].contains[<context.cause>]||false>:
                    - determine <context.damage.mul[0.5]>
            - case revenant:
                - if <[victim].has_flag[lapex.forged_shadows]>:
                    - determine <context.damage.mul[0.65]>

        # These combat flags are also populated by the hitscan engine. This
        # path covers melee, projectiles, and legend ability damage.
        on entity damaged:
        - define source <context.damager||null>
        - if <[source]> == null || !<[source].is_player||false> || <[source]> == <context.entity>:
            - stop
        - if <context.entity.has_flag[lapex.legend_protected]> || <context.entity.has_flag[lapex.phased]>:
            - stop
        - if <context.entity.has_flag[lapex.pylon_protected]> && <context.projectile||null> != null:
            - stop
        - flag <context.entity> lapex.last_attacker:<[source]> expire:10s
        - flag <context.entity> lapex.last_damage_location:<context.entity.location> expire:10s
        - flag <context.entity> lapex.threatened_by:<[source]> expire:4s
        - flag <[source]> lapex.last_target:<context.entity> expire:10s
        - define projected_health <context.entity.health.sub[<context.final_damage||<context.damage>>]>
        - if <[projected_health].div[<context.entity.health_max||20>]> <= 0.4:
            - flag <context.entity> lapex.low_health expire:6s
        - if <[source].flag[lapex.legend]||bangalore> == caustic && <context.cause> == MAGIC:
            - flag <[source]> lapex.field_research:+:1 expire:30s
            - if <[source].flag[lapex.field_research]> >= 3:
                - flag <[source]> lapex.field_research:!
                - cast absorption duration:8s amplifier:0 <[source]>
                - playsound <[source]> sound:block.brewing_stand.brew pitch:0.7 volume:0.6

        on player jumps:
        - if <player.flag[lapex.legend]||bangalore> == horizon:
            - cast slow_falling duration:2.5s amplifier:0 <player> no_ambient hide_particles
            - cast speed duration:2s amplifier:0 <player> no_ambient hide_particles

        # Sneak in midair is the keyboard-safe second movement input used for
        # abilities that normally require an extra jump or jet button.
        on player starts sneaking:
        - choose <player.flag[lapex.legend]||bangalore>:
            - case ash:
                - if !<player.is_on_ground> && !<player.has_flag[lapex.predator_dash_cooldown]>:
                    - flag player lapex.predator_dash_cooldown expire:10s
                    - push <player> origin:<player.location> destination:<player.eye_location.forward[8]> speed:1.6 duration:8t no_damage
                    - playeffect effect:portal at:<player.location.above[1]> offset:0.35 quantity:14
            - case axle:
                - if <player.is_on_ground> && !<player.has_flag[lapex.drift_cooldown]>:
                    - flag player lapex.drift_cooldown expire:1.5s
                    - push <player> origin:<player.location> destination:<player.location.forward[8]> speed:1.35 duration:7t no_damage
                    - cast speed duration:1.5s amplifier:1 <player>
            - case lifeline:
                - if !<player.is_on_ground> && !<player.has_flag[lapex.combat_glide_cooldown]>:
                    - flag player lapex.combat_glide_cooldown expire:7s
                    - cast slow_falling duration:4s amplifier:0 <player> no_ambient hide_particles
                    - playeffect effect:end_rod at:<player.location.above[1]> offset:0.25 quantity:8
            - case sparrow:
                - if !<player.is_on_ground> && !<player.has_flag[lapex.double_jump_cooldown]>:
                    - flag player lapex.double_jump_cooldown expire:2s
                    - push <player> origin:<player.location> destination:<player.location.forward[4].above[5]> speed:1.25 duration:8t no_damage
                    - playsound <player> sound:entity.ender_dragon.flap pitch:1.8 volume:0.45
            - case valkyrie:
                - if !<player.is_on_ground> && !<player.has_flag[lapex.vtol_cooldown]>:
                    - flag player lapex.vtol_cooldown expire:6s
                    - cast levitation duration:1.5s amplifier:1 <player> no_ambient hide_particles
                    - cast slow_falling duration:4s amplifier:0 <player> no_ambient hide_particles
                    - playeffect effect:small_flame at:<player.location.below[0.2]> offset:0.25 quantity:10

        # Sling is approximated as an especially quick draw when Ballistic
        # rotates onto any Lapex weapon.
        on player holds item:
        - wait 1t
        - if <player.flag[lapex.legend]||bangalore> == ballistic && <player.item_in_hand.flag[lapex.id]||null> != null && !<player.has_flag[lapex.sling_draw_cooldown]>:
            - flag player lapex.sling_draw_cooldown expire:2s
            - cast speed duration:1.5s amplifier:0 <player> no_ambient hide_particles
            - playsound <player> sound:item.armor.equip_chain pitch:1.7 volume:0.4

        # Beacons stand in for survey/ring consoles. Doors provide a short
        # defensive state because Minecraft has no ownership-aware door health.
        on player right clicks block:
        - define location <context.location||null>
        - if <[location]> == null:
            - stop
        - define material <[location].material.name>
        - choose <player.flag[lapex.legend]||bangalore>:
            - case catalyst:
                - if <[material].ends_with[_door]> && <player.is_sneaking> && !<player.has_flag[lapex.barricade_cooldown]>:
                    - determine passively cancelled
                    - flag player lapex.barricade_cooldown expire:12s
                    - flag player lapex.barricaded expire:8s
                    - switch <[location]> state:off
                    - playeffect effect:portal at:<[location].above[1]> offset:0.5 quantity:18
                    - actionbar "<light_purple>BARRICADE REINFORCED" targets:<player>
            - case pathfinder:
                - if <[material]> == beacon && !<player.has_flag[lapex.insider_scan_cooldown]>:
                    - flag player lapex.insider_scan_cooldown expire:30s
                    - define expiry <player.flag_expiration[lapex.cooldown.ultimate]||null>
                    - if <[expiry]> != null:
                        - define reduced_expiry <[expiry].sub[30s]>
                        - if <[reduced_expiry].is_after[<util.time_now>]>:
                            - flag player lapex.cooldown.ultimate expire:<[reduced_expiry]>
                        - else:
                            - flag player lapex.cooldown.ultimate:!
                    - playeffect effect:happy_villager at:<[location].above[1]> offset:0.5 quantity:18
                    - actionbar "<green>INSIDER KNOWLEDGE: ZIPLINE CHARGED" targets:<player>

lapex_legend_passive_tick:
    type: task
    debug: false
    definitions: target
    script:
    - if !<[target].is_online||false>:
        - stop
    - choose <[target].flag[lapex.legend]||bangalore>:
        - case alter:
            - if <[target].is_sneaking> && !<[target].has_flag[lapex.rift_pull_cooldown]>:
                - define drop <[target].location.find_entities[item].within[8].first||null>
                - if <[drop]> != null:
                    - flag <[target]> lapex.rift_pull_cooldown expire:10s
                    - teleport <[drop]> <[target].location>
                    - playeffect effect:reverse_portal at:<[drop].location> offset:0.25 quantity:10
        - case bloodhound:
            - foreach <[target].location.find_entities[player].within[32].exclude[<[target]>]> as:tracked:
                - if <[tracked].has_flag[lapex.last_damage_location]> || <[tracked].has_flag[lapex.last_shot_location]>:
                    - define track <[tracked].flag[lapex.last_damage_location]||<[tracked].flag[lapex.last_shot_location]>>
                    - playeffect effect:dust at:<[track]> offset:0.15 quantity:5 special_data:[size=0.65;color=255,70,45]
        - case conduit:
            - foreach <[target].location.find_entities[player].within[64].exclude[<[target]>]> as:ally:
                - if <proc[lapex_legend_is_ally].context[<[target]>|<[ally]>]> && <[target].location.distance[<[ally].location>]> > 20:
                    - cast speed duration:1.3s amplifier:0 <[target]> no_ambient hide_particles
                    - foreach stop
        - case crypto:
            - if <[target].has_flag[lapex.crypto_drone]>:
                - run lapex_passive_crypto_neurolink def.source:<[target]> def.location:<[target].flag[lapex.crypto_drone]>
        - case gibraltar:
            - if <[target].is_sprinting> && <[target].item_in_hand.material.name> == air:
                - flag <[target]> lapex.momentum_ticks:+:1 expire:3s
                - if <[target].flag[lapex.momentum_ticks]> >= 3:
                    - cast speed duration:1.3s amplifier:1 <[target]> no_ambient hide_particles
            - else:
                - flag <[target]> lapex.momentum_ticks:!
        - case lifeline:
            - define ally <proc[lapex_legend_low_ally].context[<[target]>|4]>
            - if <[ally]> != null && !<[target].has_flag[lapex.combat_medic_cooldown]>:
                - flag <[target]> lapex.combat_medic_cooldown expire:8s
                - cast regeneration duration:4s amplifier:0 <[ally]>
                - playeffect effect:heart at:<[ally].location.above[1]> offset:0.3 quantity:6
        - case loba:
            - foreach <[target].location.find_entities[item].within[16]> as:loot:
                - playeffect effect:end_rod at:<[loot].location.above[0.25]> offset:0.08 quantity:2
        - case mad_maggie:
            - define weapon_id <[target].item_in_hand.flag[lapex.id]||null>
            - if <[weapon_id]> != null && <script[lapex_weapon_data].data_key[weapons.<[weapon_id]>.class]||none> == Shotgun:
                - cast speed duration:1.3s amplifier:0 <[target]> no_ambient hide_particles
        - case mirage:
            - if <[target].is_sneaking> && !<[target].has_flag[lapex.mirage_cloak_cooldown]>:
                - define ally <proc[lapex_legend_low_ally].context[<[target]>|3]>
                - if <[ally]> != null:
                    - flag <[target]> lapex.mirage_cloak_cooldown expire:5s
                    - cast invisibility duration:3s amplifier:0 <[target]>|<[ally]> no_ambient hide_particles
                    - cast resistance duration:3s amplifier:0 <[ally]> no_ambient hide_particles
        - case newcastle:
            - if <[target].is_sneaking>:
                - define ally <proc[lapex_legend_low_ally].context[<[target]>|3]>
                - if <[ally]> != null:
                    - cast resistance duration:1.3s amplifier:1 <[target]>|<[ally]> no_ambient hide_particles
                    - cast regeneration duration:1.3s amplifier:0 <[ally]> no_ambient hide_particles
                    - cast slowness duration:1.3s amplifier:0 <[target]> no_ambient hide_particles
        - case octane:
            - if !<[target].has_flag[lapex.recent_damage]> && <[target].health> < <[target].health_max>:
                - heal 0.5 <[target]>
            - if <[target].has_effect[speed]> && <[target].health.div[<[target].health_max>]> <= 0.4 && !<[target].has_flag[lapex.stim_surge_cooldown]>:
                - flag <[target]> lapex.stim_surge_cooldown expire:26s
                - cast regeneration duration:6s amplifier:1 <[target]>
                - playsound <[target]> sound:block.brewing_stand.brew pitch:1.8 volume:0.55
        - case revenant:
            - define low_targets <list>
            - foreach <[target].location.find_entities[player].within[24].exclude[<[target]>]> as:possible:
                - if !<proc[lapex_legend_is_ally].context[<[target]>|<[possible]>]>:
                    - if <[possible].has_flag[lapex.phased]>:
                        - foreach next
                    - if <[possible].has_flag[lapex.low_health]> || <[possible].health.div[<[possible].health_max||20>]> <= 0.4:
                        - define low_targets <[low_targets].include[<[possible]>]>
            - if !<[low_targets].is_empty>:
                - run lapex_legend_private_outline def.viewer:<[target]> def.targets:<[low_targets]> def.duration:1.2s
        - case seer:
            - if <[target].is_sneaking> && !<[target].has_flag[lapex.trigger]> && !<[target].has_flag[lapex.reloading]>:
                - foreach <[target].location.find_entities[player].within[50].exclude[<[target]>]> as:possible:
                    - if !<proc[lapex_legend_is_ally].context[<[target]>|<[possible]>]>:
                        - define distance <[target].location.distance[<[possible].location].round>
                        - actionbar "<aqua>HEARTBEAT <white><[distance]>m" targets:<[target]>
                        - playsound <[target]> sound:block.note_block.basedrum pitch:0.6 volume:0.25
                        - foreach stop
        - case vantage:
            - if <[target].is_sneaking> && !<[target].has_flag[lapex.trigger]>:
                - define spotted <[target].eye_location.ray_trace_target[range=80;entities=player;ignore=<[target]>;raysize=0.3]||null>
                - if <[spotted]> != null && !<proc[lapex_legend_is_ally].context[<[target]>|<[spotted]>]> && !<[spotted].has_flag[lapex.phased]>:
                    - define distance <[target].location.distance[<[spotted].location].round>
                    - actionbar "<red>SPOTTER <white><[spotted].health.round>/<[spotted].health_max.round> HP <gray>- <[distance]>m" targets:<[target]>
                    - run lapex_legend_private_outline def.viewer:<[target]> def.targets:<list[<[spotted]>]> def.duration:1.2s
                    - if !<[target].has_flag[lapex.spotter_team_cooldown]>:
                        - flag <[target]> lapex.spotter_team_cooldown expire:10s
                        - flag <[spotted]> lapex.vantage_spotted:<[target]> expire:10s
        - case wattson:
            - if !<[target].has_flag[lapex.recent_damage]> && !<[target].has_flag[lapex.spark_regen_cooldown]>:
                - flag <[target]> lapex.spark_regen_cooldown expire:4s
                - cast absorption duration:5s amplifier:0 <[target]> no_ambient hide_particles
        - case wraith:
            - if <[target].has_flag[lapex.threatened_by]> && !<[target].has_flag[lapex.void_voice_cooldown]>:
                - flag <[target]> lapex.void_voice_cooldown expire:3s
                - actionbar "<light_purple>VOICE: DANGER CLOSE" targets:<[target]>
                - playsound <[target]> sound:block.amethyst_block.chime pitch:0.7 volume:0.65

lapex_legend_low_ally:
    type: procedure
    definitions: source|radius
    script:
    - foreach <[source].location.find_entities[player].within[<[radius]>].exclude[<[source]>]> as:possible:
        - if <proc[lapex_legend_is_ally].context[<[source]>|<[possible]>]> && <[possible].health.div[<[possible].health_max>]> <= 0.4:
            - determine <[possible]>
    - determine null

lapex_legend_private_outline:
    type: task
    debug: false
    definitions: viewer|targets|duration
    script:
    - define visible_targets <list>
    - foreach <[targets]> as:target:
        - if <[target].is_spawned||false> && !<[target].has_flag[lapex.phased]>:
            - define visible_targets <[visible_targets].include[<[target]>]>
    - if <[visible_targets].is_empty>:
        - stop
    - define token <queue.id>
    - foreach <[visible_targets]> as:target:
        - flag <[target]> lapex.scan_token.<[viewer].uuid>:<[token]> expire:30s
    - glow <[visible_targets]> for:<[viewer]>
    - wait <[duration]>
    - foreach <[visible_targets]> as:target:
        - if <[target].flag[lapex.scan_token.<[viewer].uuid>]||null> == <[token]>:
            - glow <[target]> reset for:<[viewer]>
            - flag <[target]> lapex.scan_token.<[viewer].uuid>:!

lapex_passive_crypto_neurolink:
    type: task
    debug: false
    definitions: source|location
    script:
    - define hostiles <list>
    - foreach <[location].find_entities[player].within[30]> as:possible:
        - if !<proc[lapex_legend_is_ally].context[<[source]>|<[possible]>]> && !<[possible].has_flag[lapex.phased]>:
            - define hostiles <[hostiles].include[<[possible]>]>
    - if <[hostiles].is_empty>:
        - stop
    - foreach <[source].location.find_entities[player].within[64]> as:viewer:
        - if <proc[lapex_legend_is_ally].context[<[source]>|<[viewer]>]>:
            - run lapex_legend_private_outline def.viewer:<[viewer]> def.targets:<[hostiles]> def.duration:1.2s
