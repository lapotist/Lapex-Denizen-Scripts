# Shared movement and portal behavior. Short velocity updates preserve camera
# control and normal steering; long Push queues are intentionally avoided here.

lapex_mobility_events:
    type: world
    debug: false
    events:
        on player joins:
        - run lapex_mobility_cleanup_player def.target:<player> def.reason:join

        on player quits:
        - run lapex_mobility_cleanup_player def.target:<player> def.reason:quit

        on player dies:
        - run lapex_mobility_cleanup_player def.target:<player> def.reason:death

        on player changes world:
        - run lapex_mobility_cleanup_player def.target:<player> def.reason:world_change

        on pre script reload:
        - foreach <server.online_players> as:target:
            - run lapex_mobility_cleanup_player def.target:<[target]> def.reason:reload

lapex_mobility_cleanup_player:
    type: task
    debug: false
    definitions: target|reason
    script:
    - if <[target]||null> == null:
        - stop
    - flag <[target]> lapex.octane_double_ready:!
    - flag <[target]> lapex.octane_launch_token:!
    - flag <[target]> lapex.octane_launch_grace:!
    - flag <[target]> lapex.octane_pad_contact:!
    - if <[target].has_flag[lapex.octane_fall_safe]> && <[target].is_online||false>:
        - adjust <[target]> fall_distance:0
    - flag <[target]> lapex.octane_fall_safe:!
    - flag <[target]> lapex.nitro_token:!
    - flag <[target]> lapex.nitro_contact:!
    - flag <[target]> lapex.slide_source:!
    - flag <[target]> lapex.ash_transit:!
    - flag <[target]> lapex.ash_transit_pending:!
    - if <[target].has_flag[lapex.ash_invisibility]>:
        # Offline potion timers can resume on reconnect. Keep this ownership
        # marker until a join cleanup can remove the transit's effect.
        - if <[target].is_online||false>:
            - cast invisibility remove <[target]>
            - flag <[target]> lapex.ash_invisibility:!
    - if <[target].has_flag[lapex.ash_transit_active]>:
        - flag <[target]> lapex.phased:!
    - flag <[target]> lapex.ash_transit_active:!

# Phase Breach is one-way. Only the entrance scans for willing travelers.
lapex_ash_portal_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - define destination <[entity].flag[lapex.ash_destination]||null>
    - if <[destination]> == null:
        - run lapex_deployable_cleanup def.entity:<[entity]> def.session:<[session]> def.reason:invalid
        - stop
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.ash_portal_active]>:
        - playeffect effect:portal at:<list[<[entity].location.above[1]>|<[destination].above[1]>]> offset:0.55 quantity:10
        - foreach <[entity].location.find_entities[player].within[1.6]> as:traveler:
            - if <[traveler].gamemode> != SPECTATOR && !<[traveler].has_flag[lapex.crypto_active]> && !<[traveler].has_flag[lapex.phased]> && !<[traveler].has_flag[lapex.ash_transit.<[session]>]>:
                - flag <[traveler]> lapex.ash_transit.<[session]> expire:16s
                - run lapex_ash_transit def.target:<[traveler]> def.destination:<[destination]> def.session:<[session]>
        - wait 2t
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:ash_portal def.session:<[session]> def.reason:expired

lapex_ash_transit:
    type: task
    debug: false
    definitions: target|destination|session
    script:
    - if <[target]||null> == null || !<[target].is_online||false> || <[target].world> != <[destination].world>:
        - stop
    # Registration resumes the entrance loop before Ash's ultimate queue returns.
    # This session latch makes either caller authoritative without starting twice.
    - if <[target].has_flag[lapex.ash_transit_pending.<[session]>]> || <[target].has_flag[lapex.ash_transit_active]>:
        - stop
    - define transit_token <util.random_uuid>
    - flag <[target]> lapex.ash_transit_pending.<[session]>:<[transit_token]> expire:3s
    - define distance <[target].location.distance[<[destination]>]>
    - define travel_ticks <element[10].add[<[distance].div[100].mul[40]>].round>
    - if <[travel_ticks]> < 10:
        - define travel_ticks 10
    - else if <[travel_ticks]> > 50:
        - define travel_ticks 50
    - define anchor <[target].location>
    - define view <[anchor]>
    - flag <[target]> lapex.ash_transit_active:<[transit_token]>
    - flag <[target]> lapex.phased expire:<[travel_ticks].add[2]>t
    - flag <[target]> lapex.ash_invisibility:<[transit_token]>
    - cast invisibility duration:<[travel_ticks]>t amplifier:0 <[target]> no_ambient hide_particles
    - define stopped <[target].velocity.with_x[0].with_y[0].with_z[0]>
    - adjust <[target]> velocity:<[stopped]>
    - playsound <[target]> sound:entity.enderman.teleport pitch:0.55 volume:0.8
    - define transit_valid true
    # Snap only XYZ back to the entry anchor. Reading yaw/pitch before each snap
    # leaves the camera under player control throughout the phase animation.
    - repeat <[travel_ticks]>:
        - wait 1t
        - if !<[target].is_online||false> || <[target].flag[lapex.ash_transit_active]||null> != <[transit_token]> || <[target].world> != <[anchor].world>:
            - define transit_valid false
            - repeat stop
        - define view <[target].location>
        - teleport <[target]> <[anchor].with_yaw[<[view].yaw>].with_pitch[<[view].pitch>]>
        - adjust <[target]> velocity:<[stopped]>
    - if !<[transit_valid]>:
        - if <[target].is_online||false> && <[target].flag[lapex.ash_transit_active]||null> == <[transit_token]>:
            - cast invisibility remove <[target]>
            - flag <[target]> lapex.ash_invisibility:!
            - flag <[target]> lapex.ash_transit_active:!
            - flag <[target]> lapex.phased:!
        - if <[target].flag[lapex.ash_transit_pending.<[session]>]||null> == <[transit_token]>:
            - flag <[target]> lapex.ash_transit_pending.<[session]>:!
        - stop
    - if <[target].world> == <[destination].world>:
        - teleport <[target]> <[destination].with_yaw[<[view].yaw>].with_pitch[<[view].pitch>]>
        - adjust <[target]> velocity:<[stopped]>
        - cast resistance duration:1s amplifier:4 <[target]> no_ambient hide_particles
        - playeffect effect:reverse_portal at:<[destination].above[1]> offset:0.55 quantity:28
    - cast invisibility remove <[target]>
    - flag <[target]> lapex.ash_invisibility:!
    - flag <[target]> lapex.ash_transit_active:!
    - flag <[target]> lapex.phased:!
    - if <[target].flag[lapex.ash_transit_pending.<[session]>]||null> == <[transit_token]>:
        - flag <[target]> lapex.ash_transit_pending.<[session]>:!

lapex_octane_pad_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].flag[lapex.deployable_state]||null> == active:
        - playeffect effect:happy_villager at:<[entity].location.above[0.25]> offset:0.65 quantity:5
        - foreach <[entity].location.find_entities[player].within[1.4]> as:rider:
            - if <[rider].gamemode> != SPECTATOR && !<[rider].has_flag[lapex.crypto_active]> && !<[rider].has_flag[lapex.octane_pad_contact.<[session]>]>:
                - flag <[rider]> lapex.octane_pad_contact.<[session]> expire:1s
                - run lapex_octane_launch def.target:<[rider]> def.session:<[session]>
        - wait 2t

lapex_octane_launch:
    type: task
    debug: false
    definitions: target|session
    script:
    - if !<[target].is_online||false>:
        - stop
    - define base <[target].location.with_pitch[0]>
    - define vertical <[target].velocity.y.max[0.9]>
    - define impulse <[base].forward[1.15].sub[<[base]>].with_y[<[vertical]>]>
    - define token <util.random_uuid>
    - adjust <[target]> velocity:<[impulse]>
    - adjust <[target]> fall_distance:0
    - flag <[target]> lapex.octane_launch_token:<[token]> expire:6s
    - flag <[target]> lapex.octane_launch_grace:<[token]> expire:6t
    - flag <[target]> lapex.octane_double_ready:<[token]> expire:6s
    - flag <[target]> lapex.octane_fall_safe:<[token]> expire:15s
    - playsound <[target]> sound:block.piston.extend pitch:1.6 volume:0.75
    - actionbar "<green>LAUNCHED <dark_gray>| <white>SNEAK ONCE TO DOUBLE JUMP" targets:<[target]>
    - run lapex_octane_air_loop def.target:<[target]> def.token:<[token]>

lapex_octane_double_jump:
    type: task
    debug: false
    definitions: target
    script:
    - define token <[target].flag[lapex.octane_double_ready]||null>
    - if <[token]> == null:
        - stop
    - if <[target].is_on_ground> && <[target].flag[lapex.octane_launch_grace]||null> != <[token]>:
        - flag <[target]> lapex.octane_double_ready:!
        - stop
    - define base <[target].location.with_pitch[0]>
    - define vertical <[target].velocity.y.max[0.65]>
    - define impulse <[base].forward[1.05].sub[<[base]>].with_y[<[vertical]>]>
    - flag <[target]> lapex.octane_double_ready:!
    - flag <[target]> lapex.octane_launch_grace:!
    - flag <[target]> lapex.octane_fall_safe:<[token]> expire:15s
    - adjust <[target]> fall_distance:0
    - adjust <[target]> velocity:<[impulse]>
    - playsound <[target]> sound:entity.ender_dragon.flap pitch:1.9 volume:0.5
    - playeffect effect:cloud at:<[target].location.below[0.2]> offset:0.25 quantity:10

lapex_octane_air_loop:
    type: task
    debug: false
    definitions: target|token
    script:
    - wait 6t
    - if <[target].flag[lapex.octane_launch_grace]||null> == <[token]>:
        - flag <[target]> lapex.octane_launch_grace:!
    - while <[target].is_online||false> && <[target].flag[lapex.octane_launch_token]||null> == <[token]> && !<[target].is_on_ground>:
        - wait 2t
    - if <[target].flag[lapex.octane_launch_token]||null> == <[token]>:
        - adjust <[target]> fall_distance:0
        - flag <[target]> lapex.octane_launch_token:!
        - flag <[target]> lapex.octane_double_ready:!
        - if <[target].flag[lapex.octane_fall_safe]||null> == <[token]>:
            # Paper may calculate FALL just after is_on_ground becomes true.
            # Leave a short landing window for the damage event to consume.
            - flag <[target]> lapex.octane_fall_safe:<[token]> expire:4t

lapex_axle_gate_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].flag[lapex.deployable_state]||null> == active:
        - playeffect effect:dust at:<[entity].location.above[1]> offset:0.75 quantity:8 special_data:[size=1;color=75,225,255]
        - foreach <[entity].location.find_entities[player].within[1.5]> as:rider:
            - if <[rider].gamemode> != SPECTATOR && !<[rider].has_flag[lapex.crypto_active]> && !<[rider].has_flag[lapex.nitro_contact.<[session]>]>:
                - flag <[rider]> lapex.nitro_contact.<[session]> expire:1s
                - if <[rider].flag[lapex.legend]||bangalore> == axle:
                    - run lapex_slide_start def.target:<[rider]> def.steps:50 def.speed:1.35 def.steering:0.45 def.source:nitro
                - else:
                    - run lapex_slide_start def.target:<[rider]> def.steps:50 def.speed:1.35 def.steering:0.25 def.source:nitro
        - wait 2t

lapex_slide_start:
    type: task
    debug: false
    definitions: target|steps|speed|steering|source
    script:
    - if !<[target].is_online||false>:
        - stop
    - define token <util.random_uuid>
    - define current <[target].velocity>
    - define base <[target].location.with_pitch[0]>
    - define desired <[base].forward[<[speed]>].sub[<[base]>]>
    - define keep <element[1].sub[<[steering]>]>
    - define blended_x <[current].x.mul[<[keep]>].add[<[desired].x.mul[<[steering]>]>]>
    - define blended_z <[current].z.mul[<[keep]>].add[<[desired].z.mul[<[steering]>]>]>
    - define blended <[current].with_x[<[blended_x]>].with_y[0].with_z[<[blended_z]>]>
    - define blend_length <[blended].vector_length>
    - if <[blend_length]> < 0.01:
        - define blended <[desired]>
        - define blend_length <[speed]>
    - define entry_speed <[current].with_y[0].vector_length.max[<[speed]>]>
    - define scale <[entry_speed].div[<[blend_length]>]>
    - define initial <[current].with_x[<[blended].x.mul[<[scale]>]>].with_z[<[blended].z.mul[<[scale]>]>]>
    - flag <[target]> lapex.nitro_token:<[token]> expire:<[steps].mul[2].add[4]>t
    - flag <[target]> lapex.slide_source:<[source]> expire:<[steps].mul[2].add[4]>t
    - adjust <[target]> velocity:<[initial]>
    - if <[source]> == nitro:
        - actionbar "<aqua>NITRO SLIDE <dark_gray>| <white>SNEAK TO CANCEL" targets:<[target]>
        - define decay 0.965
    - else:
        - define decay 0.94
    - run lapex_slide_loop def.target:<[target]> def.token:<[token]> def.steps:<[steps]> def.speed:<[speed]> def.steering:<[steering]> def.decay:<[decay]>

lapex_slide_loop:
    type: task
    debug: false
    definitions: target|token|steps|speed|steering|decay
    script:
    - repeat <[steps]>:
        - if !<[target].is_online||false> || <[target].flag[lapex.nitro_token]||null> != <[token]> || <[target].has_flag[lapex.legend_grounded]> || <[speed]> < 0.22:
            - repeat stop
        - define current <[target].velocity>
        - define base <[target].location.with_pitch[0]>
        - define desired <[base].forward[<[speed]>].sub[<[base]>]>
        - define keep <element[1].sub[<[steering]>]>
        - define new_x <[current].x.mul[<[keep]>].add[<[desired].x.mul[<[steering]>]>]>
        - define new_z <[current].z.mul[<[keep]>].add[<[desired].z.mul[<[steering]>]>]>
        - define impulse <[current].with_x[<[new_x]>].with_z[<[new_z]>]>
        - adjust <[target]> velocity:<[impulse]>
        - define speed <[speed].mul[<[decay]>]>
        - wait 2t
    - if <[target].flag[lapex.nitro_token]||null> == <[token]>:
        - flag <[target]> lapex.nitro_token:!
        - flag <[target]> lapex.slide_source:!

lapex_slide_stop:
    type: task
    debug: false
    definitions: target|reason
    script:
    - if !<[target].has_flag[lapex.nitro_token]>:
        - stop
    - define current <[target].velocity>
    - define reduced <[current].with_x[<[current].x.mul[0.35]>].with_z[<[current].z.mul[0.35]>]>
    - flag <[target]> lapex.nitro_token:!
    - flag <[target]> lapex.slide_source:!
    - adjust <[target]> velocity:<[reduced]>
    - playsound <[target]> sound:block.piston.contract pitch:1.8 volume:0.45
