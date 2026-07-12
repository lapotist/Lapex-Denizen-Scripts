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
        # A launch-pad landing owns this token. Keep it a few ticks beyond the
        # server's ground check so Paper's fall event cannot race the air loop.
        - if <context.cause> == FALL && <[victim].has_flag[lapex.octane_fall_safe]>:
            - adjust <[victim]> fall_distance:0
            - flag <[victim]> lapex.octane_fall_safe:!
            - determine cancelled
        - if <[damager]> != null && <[damager]> != <[victim]> && <[victim].has_flag[lapex.legend_protected]>:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - define projectile <context.projectile||null>
        - if <[victim].has_flag[lapex.pylon_protected]> && <[projectile]> != null:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - if <[victim].has_flag[lapex.pylon_protected]> && <list[BLOCK_EXPLOSION|ENTITY_EXPLOSION].contains[<context.cause>]||false>:
            - playeffect effect:electric_spark at:<[victim].location.above[1]> offset:0.3 quantity:8
            - determine cancelled
        - if <[victim].has_flag[lapex.phased]>:
            - determine cancelled

        # Gun Shield absorbs one incoming hit while Gibraltar is braced, then
        # spends its current nine-second recharge.
        - if <[damager]> != null && <[victim].flag[lapex.legend]||bangalore> == gibraltar && <[victim].has_flag[lapex.ads]> && !<[victim].has_flag[lapex.gun_shield_cooldown]>:
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
            - case fuse:
                - if <list[BLOCK_EXPLOSION|ENTITY_EXPLOSION|FIRE|FIRE_TICK].contains[<context.cause>]||false>:
                    - determine <context.damage.mul[0.5]>
            - case revenant:
                - if <[victim].has_flag[lapex.forged_shadows]>:
                    - determine <context.damage.mul[0.65]>

        # These combat flags are also populated by the hitscan engine. This
        # path covers melee, projectiles, and legend ability damage.
        on entity damaged:
        - define damager <context.damager||null>
        - define source null
        - if <[damager]> != null:
            - define source <[damager].shooter||<[damager]>>
        - if <[source]> == null || !<[source].is_player||false> || <[source]> == <context.entity>:
            - stop
        # Phase transit blocks outgoing vanilla melee and projectiles too. Gun
        # and ability entry points already reject the same shared flag.
        - if <[source].has_flag[lapex.phased]>:
            - determine cancelled
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
        - if <player.has_flag[lapex.legend_grounded]>:
            - stop
        - if <player.flag[lapex.legend]||bangalore> == horizon:
            - cast slow_falling duration:2.5s amplifier:0 <player> no_ambient hide_particles
            - cast speed duration:2s amplifier:0 <player> no_ambient hide_particles

        # Sneak in midair is the keyboard-safe second movement input used for
        # abilities that normally require an extra jump or jet button.
        on player starts sneaking:
        - if <player.has_flag[lapex.legend_grounded]>:
            - stop
        # One physical key press may satisfy several movement abilities. The
        # active ride state owns it before the selected legend passive does.
        - if <player.has_flag[lapex.octane_double_ready]>:
            - run lapex_octane_double_jump def.target:<player>
            - stop
        - if <player.has_flag[lapex.nitro_token]>:
            - run lapex_slide_stop def.target:<player> def.reason:input
            - stop
        - choose <player.flag[lapex.legend]||bangalore>:
            - case ash:
                - if !<player.is_on_ground> && !<player.has_flag[lapex.predator_dash_cooldown]>:
                    - flag player lapex.predator_dash_cooldown expire:10s
                    - define eye <player.eye_location>
                    - define impulse <[eye].forward[1.25].sub[<[eye]>]>
                    - adjust <player> velocity:<[impulse]>
                    - playeffect effect:portal at:<player.location.above[1]> offset:0.35 quantity:14
            - case axle:
                - if <player.is_on_ground> && <player.is_sprinting> && !<player.has_flag[lapex.drift_cooldown]>:
                    - flag player lapex.drift_cooldown expire:2s
                    - run lapex_slide_start def.target:<player> def.steps:20 def.speed:1.1 def.steering:0.45 def.source:drift
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

        # Beacons stand in for survey/ring consoles. A reinforced door owns
        # exactly its two matching block halves; trapdoors and neighboring floor
        # blocks must never inherit barricade state.
        on player right clicks block:
        - define location <context.location||null>
        - if <[location]> == null:
            - stop
        - define material <[location].material.name>
        - define door_parts <list>
        - define existing_owner null
        - if <[material].ends_with[_door]> && !<[material].ends_with[_trapdoor]>:
            - if <[location].below.material.name> == <[material]>:
                - define door_lower <[location].below>
            - else if <[location].above.material.name> == <[material]>:
                - define door_lower <[location]>
            - else:
                - define door_lower null
            - if <[door_lower]> != null:
                - define door_parts <list[<[door_lower]>|<[door_lower].above>]>
                - define existing_owner <[door_lower].flag[lapex.catalyst_owner]||<[door_lower].above.flag[lapex.catalyst_owner]||null>>
        # Reinforcement is ownership-aware for every legend. Enemies must break
        # the door rather than opening it or replacing its owner with Catalyst.
        - if <[existing_owner]> != null && !<proc[lapex_legend_is_ally].context[<[existing_owner]>|<player>]>:
            - determine passively cancelled
            - playsound <[location]> sound:item.shield.block pitch:0.65 volume:0.55
            - actionbar "<light_purple>ENEMY REINFORCED DOOR <gray>- break through" targets:<player>
            - stop
        - choose <player.flag[lapex.legend]||bangalore>:
            - case catalyst:
                - if !<[door_parts].is_empty> && <[existing_owner]> == null && <player.is_sneaking> && !<player.has_flag[lapex.barricade_cooldown]>:
                    - determine passively cancelled
                    - flag player lapex.barricade_cooldown expire:12s
                    - foreach <[door_parts]> as:door_part:
                        - flag <[door_part]> lapex.catalyst_owner:<player> expire:30s
                        - flag <[door_part]> lapex.catalyst_health:3 expire:30s
                    - switch <[door_parts].first> state:off
                    - playeffect effect:portal at:<[door_parts].first.above[1]> offset:0.5 quantity:18
                    - actionbar "<light_purple>BARRICADE REINFORCED <white>3 HITS" targets:<player>
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

        on player breaks block:
        - define location <context.location>
        - define material <[location].material.name>
        # Clear a legacy flag that may have been written to a neighboring block
        # by an older script version, but never intercept that block's break.
        - if !<[material].ends_with[_door]> || <[material].ends_with[_trapdoor]>:
            - if <[location].has_flag[lapex.catalyst_owner]>:
                - flag <[location]> lapex.catalyst_owner:!
                - flag <[location]> lapex.catalyst_health:!
            - stop
        - if <[location].below.material.name> == <[material]>:
            - define door_lower <[location].below>
        - else if <[location].above.material.name> == <[material]>:
            - define door_lower <[location]>
        - else:
            - flag <[location]> lapex.catalyst_owner:!
            - flag <[location]> lapex.catalyst_health:!
            - stop
        - define door_parts <list[<[door_lower]>|<[door_lower].above>]>
        - define owner <[location].flag[lapex.catalyst_owner]||<[door_lower].flag[lapex.catalyst_owner]||<[door_lower].above.flag[lapex.catalyst_owner]||null>>>
        - if <[owner]> == null:
            - stop
        - if <proc[lapex_legend_is_ally].context[<[owner]>|<player>]>:
            - foreach <[door_parts]> as:door_part:
                - flag <[door_part]> lapex.catalyst_owner:!
                - flag <[door_part]> lapex.catalyst_health:!
            - stop
        - define health <[location].flag[lapex.catalyst_health]||<[door_lower].flag[lapex.catalyst_health]||<[door_lower].above.flag[lapex.catalyst_health]||1>>>
        - if <[health]> <= 1:
            - foreach <[door_parts]> as:door_part:
                - flag <[door_part]> lapex.catalyst_owner:!
                - flag <[door_part]> lapex.catalyst_health:!
            - playsound <[location]> sound:block.iron_door.break pitch:0.75 volume:0.8
            - stop
        - determine passively cancelled
        - define health <[health].sub[1]>
        - foreach <[door_parts]> as:door_part:
            - flag <[door_part]> lapex.catalyst_owner:<[owner]> expire:30s
            - flag <[door_part]> lapex.catalyst_health:<[health]> expire:30s
        - playeffect effect:portal at:<[location].center> offset:0.35 quantity:12
        - playsound <[location]> sound:item.shield.block pitch:0.7 volume:0.6
        - actionbar "<light_purple>REINFORCED DOOR <white><[health]> HITS" targets:<player>

lapex_legend_passive_tick:
    type: task
    debug: false
    definitions: target
    script:
    - if !<[target].is_online||false>:
        - stop
    - run lapex_legend_charge_tick def.target:<[target]>
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
            - if <[target].has_flag[lapex.stim_surge]> && <[target].health> < <[target].health_max>:
                - define missing <element[1].sub[<[target].health.div[<[target].health_max>]>]>
                - define apex_heal <element[3].add[<[missing].mul[6]>]>
                - heal <[apex_heal].mul[<script[lapex_weapon_data].data_key[damage_scale]>]> <[target]>
            - else if !<[target].has_flag[lapex.recent_damage]> && <[target].health> < <[target].health_max>:
                - heal 0.6 <[target]>
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
            - if <[target].has_flag[lapex.ads]> && !<[target].has_flag[lapex.trigger]> && !<[target].has_flag[lapex.reloading]>:
                - foreach <[target].location.find_entities[living].within[50]> as:possible:
                    - define combat_player <proc[lapex_legend_combat_player].context[<[possible]>]>
                    - if <[combat_player]> != null && !<proc[lapex_legend_is_ally].context[<[target]>|<[possible]>]>:
                        - define distance <[target].location.distance[<[possible].location].round>
                        - actionbar "<aqua>HEARTBEAT <white><[distance]>m" targets:<[target]>
                        - playsound <[target]> sound:block.note_block.basedrum pitch:0.6 volume:0.25
                        - foreach stop
        - case vantage:
            # Ultimate rounds charge in the background even while A-13 is in a
            # backpack slot. The due time is player state; ammo stays on the
            # individual gun item.
            - define a13_found false
            - define a13_slot null
            - define a13_ammo 0
            - define a13_max <script[lapex_weapon_data].data_key[weapons.a13_sentry.mag]>
            - foreach <[target].inventory.list_contents> key:slot as:item:
                - if <[item].flag[lapex.id]||null> == a13_sentry:
                    - define a13_found true
                    - define a13_slot <[slot]>
                    - define ammo <[item].flag[lapex.ammo]||0>
                    - if <[ammo]> > <[a13_max]>:
                        - define ammo <[a13_max]>
                        - inventory flag destination:<[target].inventory> slot:<[slot]> lapex.ammo:<[ammo]>
                    - define a13_ammo <[ammo]>
                    - if <[ammo]> >= <[a13_max]>:
                        - flag <[target]> lapex.a13_regen_due:!
                        - flag <[target]> lapex.a13_tracking_progress:!
                    - else:
                        - define due <[target].flag[lapex.a13_regen_due]||null>
                        - if <[due]> == null:
                            - flag <[target]> lapex.a13_regen_due:<util.time_now.add[40s]>
                        - else if <[due].is_before[<util.time_now>]||false>:
                            - define a13_ammo <[ammo].add[1].min[<[a13_max]>]>
                            - inventory flag destination:<[target].inventory> slot:<[slot]> lapex.ammo:<[a13_ammo]>
                            - if <[a13_ammo]> < <[a13_max]>:
                                - flag <[target]> lapex.a13_regen_due:<util.time_now.add[40s]>
                            - else:
                                - flag <[target]> lapex.a13_regen_due:!
                                - flag <[target]> lapex.a13_tracking_progress:!
                            - actionbar "<red>A-13 ROUND READY <white><[a13_ammo]>/<[a13_max]>" targets:<[target]>
                    - foreach stop
            - if !<[a13_found]>:
                - flag <[target]> lapex.a13_regen_due:!
                - flag <[target]> lapex.a13_tracking_progress:!
            - if <[target].has_flag[lapex.ads]> && !<[target].has_flag[lapex.trigger]>:
                - define spotted <[target].eye_location.ray_trace_target[range=80;entities=living;ignore=<[target]>;raysize=0.3]||null>
                - define combat_spotted <proc[lapex_legend_combat_player].context[<[spotted]>]>
                - if <[combat_spotted]> != null && !<proc[lapex_legend_is_ally].context[<[target]>|<[spotted]>]> && !<[combat_spotted].has_flag[lapex.phased]>:
                    - define distance <[target].location.distance[<[spotted].location].round>
                    - actionbar "<red>SPOTTER <white><[combat_spotted].health.round>/<[combat_spotted].health_max.round> HP <gray>- <[distance]>m" targets:<[target]>
                    - run lapex_legend_private_outline def.viewer:<[target]> def.targets:<list[<[spotted]>]> def.duration:1.2s
                    - define tracked_team <[combat_spotted].flag[lapex.team]||<[combat_spotted].uuid>>
                    - if !<[target].has_flag[lapex.spotter_team_cooldown.<[tracked_team]>]>:
                        - flag <[target]> lapex.spotter_team_cooldown.<[tracked_team]> expire:10s
                        # Fractional tracking charge exists only while the carried
                        # A-13 magazine has room. Full or absent guns cannot bank
                        # an unbounded reserve for later shots.
                        - if <[a13_slot]> != null && <[a13_ammo]> < <[a13_max]>:
                            - define tracking <[target].flag[lapex.a13_tracking_progress]||0>
                            - define tracking <[tracking].max[0].min[0.999999].add[0.7]>
                            - if <[tracking]> >= 1:
                                - define a13_ammo <[a13_ammo].add[1].min[<[a13_max]>]>
                                - inventory flag destination:<[target].inventory> slot:<[a13_slot]> lapex.ammo:<[a13_ammo]>
                                - define tracking <[tracking].sub[1]>
                                - actionbar "<red>TEAM TRACKED <gray>- <white>A-13 ROUND RESTORED" targets:<[target]>
                            - if <[a13_ammo]> >= <[a13_max]>:
                                - flag <[target]> lapex.a13_tracking_progress:!
                                - flag <[target]> lapex.a13_regen_due:!
                            - else:
                                - flag <[target]> lapex.a13_tracking_progress:<[tracking]>
        - case wattson:
            - if !<[target].has_flag[lapex.recent_damage]> && !<[target].has_flag[lapex.spark_regen_cooldown]>:
                - flag <[target]> lapex.spark_regen_cooldown expire:4s
                - cast absorption duration:5s amplifier:0 <[target]> no_ambient hide_particles
        - case wraith:
            - if <[target].has_flag[lapex.threatened_by]> && !<[target].has_flag[lapex.void_voice_cooldown]>:
                - flag <[target]> lapex.void_voice_cooldown expire:3s
                - actionbar "<light_purple>VOICE: DANGER CLOSE" targets:<[target]>
                - playsound <[target]> sound:block.amethyst_block.chime pitch:0.7 volume:0.65

lapex_legend_charge_tick:
    type: task
    debug: false
    definitions: target
    script:
    - define groups <[target].flag[lapex.charge_groups]||<list>>
    - define active_groups <[groups]>
    - foreach <[groups]> as:group:
        - define parts <[group].split[.]>
        - define id <[parts].get[1]||null>
        - define slot <[parts].get[2]||null>
        - define kit <script[lapex_legend_data].data_key[legends.<[id]>]||null>
        - if <[kit]> == null || !<list[tactical|ultimate].contains[<[slot]>]>:
            - define active_groups <[active_groups].exclude[<[group]>]>
            - flag <[target]> lapex.charge_due.<[group]>:!
            - foreach next
        - define due_list <[target].flag[lapex.charge_due.<[group]>]||<list>>
        - define remaining <list>
        - define restored 0
        - foreach <[due_list]> as:due:
            - if <[due].is_before[<util.time_now>]||false>:
                - define restored <[restored].add[1]>
            - else:
                - define remaining <[remaining].include[<[due]>]>
        - if <[restored]> > 0:
            - define max_charges <[kit].get[<[slot]>_charges]||1>
            - define charges <[target].flag[lapex.charges.<[group]>]||0>
            - define charges <[charges].add[<[restored]>].min[<[max_charges]>]>
            - flag <[target]> lapex.charges.<[group]>:<[charges]>
            - if <[target].flag[lapex.legend]||bangalore> == <[id]>:
                - actionbar "<green><[kit].get[<[slot]>]> CHARGE READY <white><[charges]>/<[max_charges]>" targets:<[target]>
        - if <[remaining].is_empty>:
            - flag <[target]> lapex.charge_due.<[group]>:!
            - define active_groups <[active_groups].exclude[<[group]>]>
        - else:
            - flag <[target]> lapex.charge_due.<[group]>:<[remaining]>
    - if <[active_groups].is_empty>:
        - flag <[target]> lapex.charge_groups:!
    - else:
        - flag <[target]> lapex.charge_groups:<[active_groups]>

# Console-safe persistence check. It restores every touched flag so contributors
# can run it against an offline profile without changing that player's loadout.
lapex_charge_smoke:
    type: task
    debug: false
    definitions: target
    script:
    - if <[target]||null> == null:
        - narrate "<red>[Lapex] Charge smoke needs a player."
        - stop
    - define saved_charges <[target].flag[lapex.charges]||null>
    - define saved_due <[target].flag[lapex.charge_due]||null>
    - define saved_groups <[target].flag[lapex.charge_groups]||null>
    - define saved_legend <[target].flag[lapex.legend]||null>
    - flag <[target]> lapex.legend:bangalore
    - flag <[target]> lapex.charges:!
    - flag <[target]> lapex.charge_due:!
    - flag <[target]> lapex.charge_groups:!
    - define future_due <util.time_now.add[1h]>
    - flag <[target]> lapex.charges.pathfinder.tactical:0
    - flag <[target]> lapex.charge_due.pathfinder.tactical:<list[<util.time_now.sub[1s]>|<[future_due]>]>
    - flag <[target]> lapex.charge_groups:<list[pathfinder.tactical]>
    - ~run lapex_legend_charge_tick def.target:<[target]>
    - define passed false
    - define remaining <[target].flag[lapex.charge_due.pathfinder.tactical]||<list>>
    - if <[target].flag[lapex.charges.pathfinder.tactical]||0> == 1 && <[remaining].size> == 1 && <[remaining].contains[<[future_due]>]>:
        # Two overdue entries may mature together, but restoration must stop at
        # Pathfinder's two-charge maximum and retire the completed group.
        - flag <[target]> lapex.charges.pathfinder.tactical:1
        - flag <[target]> lapex.charge_due.pathfinder.tactical:<list[<util.time_now.sub[2s]>|<util.time_now.sub[1s]>]>
        - ~run lapex_legend_charge_tick def.target:<[target]>
        - if <[target].flag[lapex.charges.pathfinder.tactical]||0> == 2 && !<[target].has_flag[lapex.charge_due.pathfinder.tactical]> && !<[target].has_flag[lapex.charge_groups]>:
            - define passed true
    - if <[saved_charges]> == null:
        - flag <[target]> lapex.charges:!
    - else:
        - flag <[target]> lapex.charges:<[saved_charges]>
    - if <[saved_due]> == null:
        - flag <[target]> lapex.charge_due:!
    - else:
        - flag <[target]> lapex.charge_due:<[saved_due]>
    - if <[saved_groups]> == null:
        - flag <[target]> lapex.charge_groups:!
    - else:
        - flag <[target]> lapex.charge_groups:<[saved_groups]>
    - if <[saved_legend]> == null:
        - flag <[target]> lapex.legend:!
    - else:
        - flag <[target]> lapex.legend:<[saved_legend]>
    - if <[passed]>:
        - narrate "<green>Lapex charge smoke passed: due ordering, charge cap, and test-flag rollback."
    - else:
        - narrate "<red>Lapex charge smoke failed due ordering or cap restoration."

lapex_legend_low_ally:
    type: procedure
    definitions: source|radius
    script:
    - foreach <[source].location.find_entities[living].within[<[radius]>]> as:possible:
        - define combat_player <proc[lapex_legend_combat_player].context[<[possible]>]>
        - if <[combat_player]> != null && <[combat_player]> != <[source]> && <proc[lapex_legend_is_ally].context[<[source]>|<[possible]>]> && <[combat_player].health.div[<[combat_player].health_max>]> <= 0.4:
            - determine <[combat_player]>
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
    - define seen_players <list>
    - foreach <[location].find_entities[living].within[30]> as:possible:
        - define combat_player <proc[lapex_legend_combat_player].context[<[possible]>]>
        - if <[combat_player]> != null && !<[seen_players].contains[<[combat_player].uuid>]> && !<proc[lapex_legend_is_ally].context[<[source]>|<[possible]>]> && !<[combat_player].has_flag[lapex.phased]>:
            - define hostiles <[hostiles].include[<[possible]>]>
            - define seen_players <[seen_players].include[<[combat_player].uuid>]>
    - if <[hostiles].is_empty>:
        - stop
    - foreach <[source].location.find_entities[player].within[64]> as:viewer:
        - if <proc[lapex_legend_is_ally].context[<[source]>|<[viewer]>]>:
            - run lapex_legend_private_outline def.viewer:<[viewer]> def.targets:<[hostiles]> def.duration:1.2s
