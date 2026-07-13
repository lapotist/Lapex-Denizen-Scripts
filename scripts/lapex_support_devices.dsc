# Physical support devices and Dome boundary interception. All repeated tasks
# use shared deployable sessions so stale queues cannot affect replacement items.

lapex_support_device_events:
    type: world
    debug: false
    events:
        on projectile launched:
        - if <server.flag[lapex.deployable_index.gibraltar_dome].is_empty||true>:
            - stop
        - run lapex_dome_projectile_loop def.projectile:<context.projectile>

        # The one-tick projectile loop is authoritative. This fallback covers a
        # projectile plugin that moves and damages in the same server tick.
        # Run before the normal damage routers. Cancelling here makes their
        # default-priority paths skip proxy health forwarding and deployable HP.
        on entity damaged priority:-100:
        - define projectile <context.projectile||null>
        - if <[projectile]> == null:
            - stop
        - define damaged <context.entity>
        - define trace_start <[projectile].flag[lapex.dome_previous]||null>
        - if <[trace_start]> == null:
            - define shooter <[projectile].shooter||null>
            - if <[shooter]> == null || !<[shooter].is_spawned||false>:
                - stop
            - define trace_start <[shooter].eye_location>
        - define damaged_height <[damaged].height||1>
        - define target_center <[damaged].location.above[<[damaged_height].div[2]>]>
        - define block_point <proc[lapex_dome_trace_intersection].context[<[trace_start]>|<[target_center]>]||null>
        - if <[block_point]> != null:
            - playeffect effect:electric_spark at:<[block_point]> offset:0.22 quantity:10
            - playsound <[block_point]> sound:item.shield.block pitch:1.45 volume:0.7
            - if <[projectile].is_spawned||false>:
                - remove <[projectile]>
            - determine cancelled

lapex_dome_projectile_loop:
    type: task
    debug: false
    definitions: projectile
    script:
    - if <[projectile]||null> == null || !<[projectile].is_spawned||false>:
        - stop
    - define previous <[projectile].location>
    - flag <[projectile]> lapex.dome_previous:<[previous]> expire:5s
    - while <[projectile].is_spawned||false> && !<server.flag[lapex.deployable_index.gibraltar_dome].is_empty||true>:
        - wait 1t
        - if !<[projectile].is_spawned||false>:
            - stop
        - define current <[projectile].location>
        - define block_point <proc[lapex_dome_trace_intersection].context[<[previous]>|<[current]>]||null>
        - if <[block_point]> != null:
            - playeffect effect:electric_spark at:<[block_point]> offset:0.22 quantity:10
            - playsound <[block_point]> sound:item.shield.block pitch:1.45 volume:0.7
            - remove <[projectile]>
            - stop
        - define previous <[current]>
        - flag <[projectile]> lapex.dome_previous:<[previous]> expire:5s

# Pure geometry helper kept separate so the boundary rules can be smoke-tested
# without an online player or a live deployable session.
lapex_sphere_trace_intersection:
    type: procedure
    debug: false
    definitions: start|end|center|radius|upper_only
    script:
    - if <[start]||null> == null || <[end]||null> == null || <[center]||null> == null || <[start].world> != <[end].world> || <[start].world> != <[center].world>:
        - determine null
    - if <[start].distance[<[center]>]> < <[radius]> && <[end].distance[<[center]>]> < <[radius]>:
        - determine null
    - define dx <[end].x.sub[<[start].x>]>
    - define dy <[end].y.sub[<[start].y>]>
    - define dz <[end].z.sub[<[start].z>]>
    - define a <[dx].mul[<[dx]>].add[<[dy].mul[<[dy]>]>].add[<[dz].mul[<[dz]>]>]>
    - if <[a]> <= 0:
        - determine null
    - define fx <[start].x.sub[<[center].x>]>
    - define fy <[start].y.sub[<[center].y>]>
    - define fz <[start].z.sub[<[center].z>]>
    - define b <element[2].mul[<[fx].mul[<[dx]>].add[<[fy].mul[<[dy]>]>].add[<[fz].mul[<[dz]>]>]>]>
    - define c <[fx].mul[<[fx]>].add[<[fy].mul[<[fy]>]>].add[<[fz].mul[<[fz]>]>].sub[<[radius].mul[<[radius]>]>]>
    - define discriminant <[b].mul[<[b]>].sub[<element[4].mul[<[a]>].mul[<[c]>]>]>
    - if <[discriminant]> < 0:
        - determine null
    - define root <[discriminant].sqrt>
    - define denominator <[a].mul[2]>
    - define first <[b].mul[-1].sub[<[root]>].div[<[denominator]>]>
    - define second <[b].mul[-1].add[<[root]>].div[<[denominator]>]>
    - define hit_location null
    # Test both roots in travel order. For a Dome, the first root can be on the
    # invisible lower half while the second root still strikes the visible cap.
    - foreach <list[<[first]>|<[second]>]> as:candidate:
        - if <[candidate]> < 0 || <[candidate]> > 1:
            - foreach next
        - define candidate_location <[start].add[<[dx].mul[<[candidate]>]>,<[dy].mul[<[candidate]>]>,<[dz].mul[<[candidate]>]>]>
        # Use a fixed world-space epsilon instead of a fraction of the trace;
        # long traces must not ignore the first blocks of the shell.
        - if <[start].distance[<[candidate_location]>]> <= 0.02:
            - foreach next
        - if <[upper_only]||false> && <[candidate_location].y> < <[center].y>:
            - foreach next
        - define hit_location <[candidate_location]>
        - foreach stop
    - determine <[hit_location]>

# Return [crossing location, Dome entity, session] for the nearest current Dome.
# Keeping the identity beside the geometry makes overlap destruction exact.
lapex_dome_trace_hit:
    type: procedure
    debug: false
    definitions: start|end
    script:
    - if <[start]||null> == null || <[end]||null> == null || <[start].world> != <[end].world>:
        - determine null
    - define best_location null
    - define best_dome null
    - define best_session null
    - define best_distance 1000000
    - foreach <server.flag[lapex.deployable_index.gibraltar_dome]||<list>> as:dome:
        - define session <[dome].flag[lapex.deployable_session]||null>
        - if !<proc[lapex_deployable_is_current].context[<[dome]>|<[session]>]> || !<[dome].has_flag[lapex.gibraltar_dome_active]> || <[dome].world> != <[start].world>:
            - foreach next
        - define hit <proc[lapex_sphere_trace_intersection].context[<[start]>|<[end]>|<[dome].location.above[0.25]>|6|true]>
        - if <[hit]> == null:
            - foreach next
        - define hit_distance <[start].distance[<[hit]>]>
        - if <[hit_distance]> < <[best_distance]>:
            - define best_location <[hit]>
            - define best_dome <[dome]>
            - define best_session <[session]>
            - define best_distance <[hit_distance]>
    - if <[best_location]> == null:
        - determine null
    - determine <list[<[best_location]>|<[best_dome]>|<[best_session]>]>

# Public compatibility wrapper: existing callers only need the crossing point.
lapex_dome_trace_intersection:
    type: procedure
    debug: false
    definitions: start|end
    script:
    - define dome_hit <proc[lapex_dome_trace_hit].context[<[start]>|<[end]>]||null>
    - if <[dome_hit]> == null:
        - determine null
    - determine <[dome_hit].get[1]>

lapex_dome_geometry_smoke:
    type: task
    debug: false
    definitions: center
    script:
    - if <[center]||null> == null:
        - narrate "<red>[Lapex] Dome geometry smoke needs a center."
        - stop
    - define outside_left <[center].add[-10,1,0]>
    - define outside_right <[center].add[10,1,0]>
    - define inside_left <[center].add[-2,1,0]>
    - define inside_right <[center].add[2,1,0]>
    - define below_left <[center].add[-10,-1,0]>
    - define below_right <[center].add[10,-1,0]>
    - define diagonal_lower <[center].add[-10,-4,0]>
    - define diagonal_upper <[center].add[10,4,0]>
    - define through <proc[lapex_sphere_trace_intersection].context[<[outside_left]>|<[outside_right]>|<[center]>|6|true]>
    - define inward <proc[lapex_sphere_trace_intersection].context[<[outside_left]>|<[inside_right]>|<[center]>|6|true]>
    - define outward <proc[lapex_sphere_trace_intersection].context[<[inside_left]>|<[outside_right]>|<[center]>|6|true]>
    - define internal <proc[lapex_sphere_trace_intersection].context[<[inside_left]>|<[inside_right]>|<[center]>|6|true]>
    - define lower_rejected <proc[lapex_sphere_trace_intersection].context[<[below_left]>|<[below_right]>|<[center]>|6|true]>
    - define lower_then_upper <proc[lapex_sphere_trace_intersection].context[<[diagonal_lower]>|<[diagonal_upper]>|<[center]>|6|true]>
    - define upper_root_valid true
    - if <[lower_then_upper]> == null:
        - define upper_root_valid false
    - else if <[lower_then_upper].y> < <[center].y>:
        - define upper_root_valid false
    - define ring_size <[center].points_around_y[radius=6;points=32].size>
    - if <[through]> == null || <[inward]> == null || <[outward]> == null || <[internal]> != null || <[lower_rejected]> != null || !<[upper_root_valid]> || <[ring_size]> != 32:
        - narrate "<red>Lapex Dome geometry smoke failed. <gray>through=<[through]> inward=<[inward]> outward=<[outward]> internal=<[internal]> lower=<[lower_rejected]> diagonal=<[lower_then_upper]> ring=<[ring_size]>"
        - stop
    - narrate "<green>Lapex Dome geometry smoke passed: upper shell, both directions, internal shot, and lower-half rejection."

lapex_destroy_indexed_deployables:
    type: task
    debug: false
    definitions: location|radius|kinds|source|enemies_only
    script:
    - foreach <[kinds]> as:kind:
        - foreach <server.flag[lapex.deployable_index.<[kind]>]||<list>> as:device:
            - define session <[device].flag[lapex.deployable_session]||null>
            - if <proc[lapex_deployable_is_current].context[<[device]>|<[session]>]> && <[device].world> == <[location].world> && <[device].location.distance[<[location]>]> <= <[radius]>:
                - if <[enemies_only]||false> && <[source]||null> != null && <proc[lapex_legend_is_ally].context[<[source]>|<[device]>]>:
                    - foreach next
                - run lapex_deployable_cleanup def.entity:<[device]> def.session:<[session]> def.reason:destroyed

lapex_destroy_dome_crossed:
    type: task
    debug: false
    definitions: start|end
    script:
    - define dome_hit <proc[lapex_dome_trace_hit].context[<[start]>|<[end]>]||null>
    - if <[dome_hit]> == null:
        - stop
    - define dome <[dome_hit].get[2]>
    - define session <[dome_hit].get[3]>
    - if <proc[lapex_deployable_is_current].context[<[dome]>|<[session]>]> && <[dome].has_flag[lapex.gibraltar_dome_active]>:
        - run lapex_deployable_cleanup def.entity:<[dome]> def.session:<[session]> def.reason:destroyed

lapex_gibraltar_dome_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.gibraltar_dome_active]>:
        - define center <[entity].location.above[0.25]>
        - define shell <[center].above[0.25].points_around_y[radius=6;points=32]>
        - define shell <[shell].include[<[center].above[2].points_around_y[radius=5.65;points=28]>]>
        - define shell <[shell].include[<[center].above[4].points_around_y[radius=4.45;points=22]>]>
        - define shell <[shell].include[<[center].above[5.5].points_around_y[radius=2.4;points=14]>]>
        - playeffect effect:dust at:<[shell]> offset:0 quantity:1 visibility:128 special_data:[size=0.75;color=70,165,255]
        - playeffect effect:electric_spark at:<[center].above[6.1]> offset:0.18 quantity:4 visibility:128
        - wait 5t
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:gibraltar_dome def.session:<[session]> def.reason:expired

lapex_lifeline_doc_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - define pulse 0
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.lifeline_doc_active]>:
        - define pulse <[pulse].add[1]>
        - define owner <[entity].flag[lapex.deployable_owner]>
        - define follow <[entity].flag[lapex.lifeline_doc_target]||null>
        - define follow_available false
        - if <[follow]> != null:
            - if <[follow].is_player||false> && <[follow].is_online||false>:
                - define follow_available true
            - else if !<[follow].is_player||false> && <[follow].is_spawned||false>:
                - define follow_available true
        - if <[follow_available]> && <[follow].world> == <[entity].world>:
            - if <[follow].has_flag[lapex.crypto_active]>:
                - define body <[follow].flag[lapex.crypto_body_entity]||null>
                - if <[body]> != null && <[body].is_spawned||false>:
                    - teleport <[entity]> <[body].location.with_pitch[0].backward[1.2].right[0.8].above[0.5]>
            - else:
                - teleport <[entity]> <[follow].location.with_pitch[0].backward[1.2].right[0.8].above[0.5]>
        - else if <[follow]> != null:
            - flag <[entity]> lapex.lifeline_doc_target:!
        - if <[entity].has_flag[lapex.lifeline_doc_malfunction]>:
            - playeffect effect:large_smoke at:<[entity].location.above[0.5]> offset:0.35 quantity:5
        - else:
            - playeffect effect:heart at:<[entity].location.above[0.5]> offset:0.45 quantity:3
            - if <[pulse].mod[4]> == 0:
                - define allies <proc[lapex_legend_allies_near].context[<[entity].location>|6|<[owner]>]>
                - if !<[allies].is_empty>:
                    - heal 1.6 <[allies]>
        - wait 5t
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:lifeline_doc def.session:<[session]> def.reason:expired

lapex_lifeline_doc_assign:
    type: task
    debug: false
    definitions: owner|entity
    script:
    - if <[entity]||null> == null || !<[entity].is_spawned||false>:
        - stop
    - define aimed <[owner].eye_location.ray_trace_target[range=30;entities=living;ignore=<[owner]>|<[entity]>;raysize=0.45]||null>
    - if <[aimed]> == null:
        - define follow <[owner]>
    - else:
        - define follow <proc[lapex_legend_combat_player].context[<[aimed]>]>
        - if <[follow]> == null || !<proc[lapex_legend_is_ally].context[<[owner]>|<[aimed]>]>:
            - actionbar "<red>D.O.C. CAN ONLY FOLLOW AN ALLY" targets:<[owner]>
            - playsound <[owner]> sound:block.dispenser.fail pitch:1.2 volume:0.55
            - stop
    - flag <[entity]> lapex.lifeline_doc_target:<[follow]>
    - playsound <[entity]> sound:block.beacon.power_select pitch:1.8 volume:0.6
    - actionbar "<green>D.O.C. FOLLOWING <white><[follow].name>" targets:<[owner]>

lapex_lifeline_halo_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.lifeline_halo_active]>:
        - define owner <[entity].flag[lapex.deployable_owner]>
        - define center <[entity].location>
        - define ring <[center].above[0.3].points_around_y[radius=8;points=36]>
        - define ring <[ring].include[<[center].above[3].points_around_y[radius=8;points=36]>]>
        - define friends <list>
        - define enemies <list>
        - foreach <server.online_players> as:viewer:
            - if <[viewer].world> == <[center].world> && <[viewer].location.distance[<[center]>]> <= 64:
                - if <proc[lapex_legend_is_ally].context[<[owner]>|<[viewer]>]>:
                    - define friends <[friends].include[<[viewer]>]>
                - else:
                    - define enemies <[enemies].include[<[viewer]>]>
        - if !<[friends].is_empty>:
            - playeffect effect:dust at:<[ring]> offset:0 quantity:1 targets:<[friends]> special_data:[size=0.75;color=90,210,255]
        - if !<[enemies].is_empty>:
            - playeffect effect:dust at:<[ring]> offset:0 quantity:1 targets:<[enemies]> special_data:[size=0.75;color=255,95,55]
        - define members <list>
        # Membership is the rendered 8-block cylinder. A living entity counts
        # when its body overlaps the floor-to-top vertical span.
        - define field_bottom <[center].y.add[0.3]>
        - define field_top <[center].y.add[3]>
        - foreach <[center].find_entities[living].within[10]> as:possible:
            - define possible_bottom <[possible].location.y>
            - define possible_top <[possible_bottom].add[<[possible].height||1.8>]>
            - if <[possible_top]> < <[field_bottom]> || <[possible_bottom]> > <[field_top]>:
                - foreach next
            - define x_delta <[possible].location.x.sub[<[center].x>]>
            - define z_delta <[possible].location.z.sub[<[center].z>]>
            - define horizontal_squared <[x_delta].mul[<[x_delta]>].add[<[z_delta].mul[<[z_delta]>]>]>
            - if <[horizontal_squared]> > 64:
                - foreach next
            - define combat_player <proc[lapex_legend_combat_player].context[<[possible]>]>
            - if <[combat_player]> != null && !<[members].contains[<[combat_player]>]>:
                - define members <[members].include[<[combat_player]>]>
                - flag <[combat_player]> lapex.halo_active expire:1s
        - wait 10t
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:lifeline_halo def.session:<[session]> def.reason:expired
