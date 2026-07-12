# Shared lifecycle for physical legend devices. The visible armor stand is also
# a living hitbox so the existing Lapex hitscan engine and vanilla attacks can
# damage it. Virtual health is stored in Apex HP and never delegated to mob HP.

lapex_deployable_events:
    type: world
    debug: false
    events:
        on entity damaged:
        - define proxy <context.entity>
        - define kind <[proxy].flag[lapex.deployable_kind]||null>
        - if <[kind]> == null:
            - if <[proxy].has_flag[lapex.deployable_extra_session]>:
                - determine passively cancelled
                - run lapex_deployable_reconcile_extra def.entity:<[proxy]>
            - stop
        - determine passively cancelled
        - if <[proxy].has_flag[lapex.deployable_invulnerable]>:
            - stop
        # A direct left-click also emits vanilla melee after the Lapex hitscan.
        # Ignore that second path when the attacker is holding a Lapex gun.
        - if <context.cause> == ENTITY_ATTACK && <context.damager.is_player||false> && <context.damager.item_in_hand.flag[lapex.id]||null> != null:
            - stop
        - define owner <[proxy].flag[lapex.deployable_owner]||null>
        - define session <[proxy].flag[lapex.deployable_session]||null>
        - if <[owner]> == null || <[session]> == null:
            - remove <[proxy]>
            - stop
        - define expected <[owner].flag[lapex.deployable.<[session]>]||null>
        - if <[expected]> != <[proxy]>:
            - remove <[proxy]>
            - stop
        - define damager <context.damager||null>
        - define source null
        - if <[damager]> != null:
            - define source <[damager].shooter||<[damager]>>
        - if <[source]> != null && <[source].is_player||false> && <[source].has_flag[lapex.phased]>:
            - stop
        - if <[source]> != null && <[source].is_player||false> && <proc[lapex_legend_is_ally].context[<[owner]>|<[source]>]>:
            - if <[kind]> == caustic_trap:
                - run lapex_caustic_trigger def.entity:<[proxy]> def.session:<[session]>
            - stop
        - run lapex_deployable_damage def.entity:<[proxy]> def.session:<[session]> def.incoming:<context.final_damage||<context.damage>> def.source:<[source]>

        # Timed queues stop when an entity chunk unloads. Rehydrate a valid
        # session when Paper loads its entities again, or remove stale proxies.
        on chunk loads entities:
        - foreach <context.entities> as:proxy:
            - if <[proxy].has_flag[lapex.deployable_kind]>:
                - run lapex_deployable_rehydrate def.entity:<[proxy]>
            - else if <[proxy].has_flag[lapex.deployable_extra_session]>:
                - run lapex_deployable_reconcile_extra def.entity:<[proxy]>

        # Chunks near spawn can load before Denizen registers world events.
        # Sweep already-loaded entities once scripts are ready as well.
        on scripts loaded:
        - flag server lapex.deployable_index:!
        - foreach <server.worlds> as:world:
            - foreach <[world].entities> as:proxy:
                - if <[proxy].has_flag[lapex.deployable_kind]>:
                    - run lapex_deployable_rehydrate def.entity:<[proxy]>
                - else if <[proxy].has_flag[lapex.deployable_extra_session]>:
                    - run lapex_deployable_reconcile_extra def.entity:<[proxy]>

        # Equipment is the visible model. Do not let a right-click remove it
        # from the armor-stand hitbox while the device session is active.
        on player changes armor stand item:
        - if <context.armor_stand.has_flag[lapex.deployable_kind]> || <context.armor_stand.has_flag[lapex.deployable_extra_session]> || <context.armor_stand.has_flag[lapex.crypto_body_owner]>:
            - determine cancelled

        on player quits:
        - run lapex_deployable_cleanup_owner def.owner:<player>

        # A hard server stop can skip the quit event. Player flags persist, so
        # reconcile them on the next login and let chunk-load cleanup remove
        # any unloaded proxy when its chunk appears.
        on player joins:
        - run lapex_deployable_cleanup_owner def.owner:<player>

        on player dies:
        - run lapex_deployable_cleanup_owner def.owner:<player>

        on player changes world:
        - run lapex_deployable_cleanup_owner def.owner:<player>

        on pre script reload:
        - foreach <server.online_players> as:owner:
            - run lapex_deployable_cleanup_owner def.owner:<[owner]>

lapex_deployable_register:
    type: task
    debug: false
    definitions: owner|entity|kind|health|max_count|label
    script:
    - if <[owner]> == null || <[entity]> == null || !<[entity].is_spawned||false>:
        - stop
    - define sessions <[owner].flag[lapex.deployable_sessions.<[kind]>]||<list>>
    - define limit <[max_count]||1>
    - if <[sessions].size> >= <[limit]>:
        - define old_session <[sessions].first>
        - define old_entity <[owner].flag[lapex.deployable.<[old_session]>]||null>
        - ~run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[old_entity]> def.kind:<[kind]> def.session:<[old_session]> def.reason:replaced
        - define sessions <[sessions].exclude[<[old_session]>]>
    - define session <util.random_uuid>
    - flag <[entity]> lapex.deployable_kind:<[kind]>
    - flag <[entity]> lapex.deployable_owner:<[owner]>
    - flag <[entity]> lapex.deployable_session:<[session]>
    - flag <[entity]> lapex.deployable_health:<[health]>
    - flag <[entity]> lapex.deployable_health_max:<[health]>
    - flag <[entity]> lapex.deployable_label:<[label]>
    - flag <[owner]> lapex.deployable.<[session]>:<[entity]>
    - flag <[owner]> lapex.deployable_sessions.<[kind]>:<[sessions].include[<[session]>].deduplicate>
    - define kinds <[owner].flag[lapex.deployable_kinds]||<list>>
    - flag <[owner]> lapex.deployable_kinds:<[kinds].include[<[kind]>].deduplicate>
    - define indexed <server.flag[lapex.deployable_index.<[kind]>]||<list>>
    - flag server lapex.deployable_index.<[kind]>:<[indexed].include[<[entity]>].deduplicate>
    - if <[entity].has_flag[lapex.deployable_invulnerable]>:
        - adjust <[entity]> "custom_name:<[label]>"
    - else:
        - adjust <[entity]> "custom_name:<[label]> <white><[health].round>"
    - adjust <[entity]> custom_name_visible:true
    - run lapex_deployable_resume def.entity:<[entity]> def.session:<[session]>

# A portal has two visible entities but one authoritative session. Extra
# entities never receive damage independently and always follow primary cleanup.
lapex_deployable_attach_extra:
    type: task
    debug: false
    definitions: owner|primary|extra
    script:
    - if <[owner]||null> == null || <[primary]||null> == null || <[extra]||null> == null || !<[extra].is_spawned||false>:
        - stop
    - define session <[primary].flag[lapex.deployable_session]||null>
    - if <[session]> == null || <[owner].flag[lapex.deployable.<[session]>]||null> != <[primary]>:
        - remove <[extra]>
        - stop
    - flag <[extra]> lapex.deployable_extra_owner:<[owner]>
    - flag <[extra]> lapex.deployable_extra_session:<[session]>
    - flag <[extra]> lapex.deployable_extra_primary:<[primary]>
    - define extras <[owner].flag[lapex.deployable_extras.<[session]>]||<list>>
    - define extras <[extras].include[<[extra]>].deduplicate>
    - flag <[owner]> lapex.deployable_extras.<[session]>:<[extras]>
    - flag <[primary]> lapex.deployable_extras:<[extras]>

lapex_deployable_reconcile_extra:
    type: task
    debug: false
    definitions: entity
    script:
    - define owner <[entity].flag[lapex.deployable_extra_owner]||null>
    - define session <[entity].flag[lapex.deployable_extra_session]||null>
    - define primary <[entity].flag[lapex.deployable_extra_primary]||null>
    - if <[owner]> == null || <[session]> == null || <[primary]> == null || !<[owner].is_online||false>:
        - remove <[entity]>
        - stop
    - define extras <[owner].flag[lapex.deployable_extras.<[session]>]||<list>>
    - if <[owner].flag[lapex.deployable.<[session]>]||null> != <[primary]> || !<[extras].contains[<[entity]>]>:
        - remove <[entity]>

lapex_deployable_is_current:
    type: procedure
    debug: false
    definitions: entity|session|token
    script:
    - if <[entity]> == null || !<[entity].is_spawned||false> || <[entity].has_flag[lapex.deployable_cleaning]>:
        - determine false
    - if <[entity].flag[lapex.deployable_session]||null> != <[session]>:
        - determine false
    - if <[token]||null> != null && <[entity].flag[lapex.deployable_loop_token]||null> != <[token]>:
        - determine false
    - define owner <[entity].flag[lapex.deployable_owner]||null>
    - if <[owner]> == null || !<[owner].is_online||false>:
        - determine false
    - if <[owner].flag[lapex.deployable.<[session]>]||null> != <[entity]>:
        - determine false
    - determine true

lapex_current_deployable_for_owner:
    type: procedure
    debug: false
    definitions: owner|kind
    script:
    - foreach <[owner].flag[lapex.deployable_sessions.<[kind]>]||<list>> as:session:
        - define entity <[owner].flag[lapex.deployable.<[session]>]||null>
        - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>]>:
            - determine <[entity]>
    - determine null

lapex_deployable_damage:
    type: task
    debug: false
    definitions: entity|session|incoming|source
    script:
    - if !<proc[lapex_deployable_is_current].context[<[entity]>|<[session]>]>:
        - stop
    - if <[incoming]||0> <= 0:
        - stop
    - define scale <script[lapex_weapon_data].data_key[damage_scale]>
    - define apex_damage <[incoming].div[<[scale]>].max[1]>
    - define health <[entity].flag[lapex.deployable_health]||0>
    - define health <[health].sub[<[apex_damage]>].max[0]>
    - flag <[entity]> lapex.deployable_health:<[health]>
    - define label <[entity].flag[lapex.deployable_label]||<gray>DEVICE>
    - adjust <[entity]> "custom_name:<[label]> <white><[health].round>"
    - playeffect effect:electric_spark at:<[entity].location.above[1]> offset:0.3 quantity:10
    - playsound <[entity]> sound:block.copper_bulb.break pitch:1.4 volume:0.7
    - define owner <[entity].flag[lapex.deployable_owner]>
    - actionbar "<red>DEVICE DAMAGED <white><[health].round>" targets:<[owner]>
    - if <[health]> <= 0:
        # The gun queue still restores velocity and renders hit feedback after
        # this event. Keep the proxy alive for one tick so those mechanisms do
        # not run against an entity removed in the middle of the shot.
        - flag <[entity]> lapex.deployable_cleaning
        - run lapex_deployable_cleanup_after_hit def.owner:<[owner]> def.entity:<[entity]> def.kind:<[entity].flag[lapex.deployable_kind]> def.session:<[session]>
        - stop
    - if <[entity].flag[lapex.deployable_kind]||null> == caustic_trap && <[source]||null> != null && <[source].is_player||false>:
        - run lapex_caustic_trigger def.entity:<[entity]> def.session:<[session]>

lapex_deployable_cleanup_after_hit:
    type: task
    debug: false
    definitions: owner|entity|kind|session
    script:
    - wait 1t
    - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:destroyed

lapex_deployable_cleanup:
    type: task
    debug: false
    definitions: owner|entity|kind|session|reason
    script:
    - if <[owner]||null> == null && <[entity]||null> != null:
        - define owner <[entity].flag[lapex.deployable_owner]||null>
    - if <[kind]||null> == null && <[entity]||null> != null:
        - define kind <[entity].flag[lapex.deployable_kind]||null>
    - if <[session]||null> == null && <[entity]||null> != null:
        - define session <[entity].flag[lapex.deployable_session]||null>
    - if <[owner]||null> != null && <[session]||null> != null:
        - define expected <[owner].flag[lapex.deployable.<[session]>]||null>
        - if <[entity]||null> == null:
            - define entity <[expected]>
        - if <[expected]> == <[entity]>:
            - flag <[owner]> lapex.deployable.<[session]>:!
            - if <[kind]||null> != null:
                - define sessions <[owner].flag[lapex.deployable_sessions.<[kind]>]||<list>>
                - define sessions <[sessions].exclude[<[session]>]>
                - if <[sessions].is_empty>:
                    - flag <[owner]> lapex.deployable_sessions.<[kind]>:!
                    - define kinds <[owner].flag[lapex.deployable_kinds]||<list>>
                    - flag <[owner]> lapex.deployable_kinds:<[kinds].exclude[<[kind]>]>
                - else:
                    - flag <[owner]> lapex.deployable_sessions.<[kind]>:<[sessions]>
        - define extras <[owner].flag[lapex.deployable_extras.<[session]>]||<list>>
        - if <[extras].is_empty> && <[entity]||null> != null:
            - define extras <[entity].flag[lapex.deployable_extras]||<list>>
        - foreach <[extras]> as:extra:
            - if <[extra].is_spawned||false>:
                - remove <[extra]>
        - flag <[owner]> lapex.deployable_extras.<[session]>:!
    - if <[kind]||null> != null && <[entity]||null> != null:
        - define indexed <server.flag[lapex.deployable_index.<[kind]>]||<list>>
        - define indexed <[indexed].exclude[<[entity]>]>
        - if <[indexed].is_empty>:
            - flag server lapex.deployable_index.<[kind]>:!
        - else:
            - flag server lapex.deployable_index.<[kind]>:<[indexed]>
    - if <[entity]||null> != null && <[entity].is_spawned||false>:
        - flag <[entity]> lapex.deployable_cleaning
        - if <[reason]||cleanup> == destroyed:
            - playeffect effect:explosion at:<[entity].location.above[0.8]> offset:0.25 quantity:3
            - playsound <[entity]> sound:entity.generic.explode pitch:1.7 volume:0.75
        - else:
            - playeffect effect:large_smoke at:<[entity].location.above[0.8]> offset:0.2 quantity:5
        - remove <[entity]>

lapex_deployable_cleanup_owner:
    type: task
    debug: false
    definitions: owner
    script:
    - if <[owner]||null> == null:
        - stop
    - foreach <[owner].flag[lapex.deployable_kinds]||<list>> as:kind:
        - foreach <[owner].flag[lapex.deployable_sessions.<[kind]>]||<list>> as:session:
            - define entity <[owner].flag[lapex.deployable.<[session]>]||null>
            - ~run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:owner_cleanup
    - flag <[owner]> lapex.deployable:!
    - flag <[owner]> lapex.deployable_sessions:!
    - flag <[owner]> lapex.deployable_kinds:!
    - flag <[owner]> lapex.deployable_extras:!

lapex_deployable_rehydrate:
    type: task
    debug: false
    definitions: entity
    script:
    - define owner <[entity].flag[lapex.deployable_owner]||null>
    - define session <[entity].flag[lapex.deployable_session]||null>
    - define kind <[entity].flag[lapex.deployable_kind]||null>
    - if <[owner]> == null || <[session]> == null || <[kind]> == null:
        - remove <[entity]>
        - stop
    - if !<[owner].is_online||false> || <[owner].flag[lapex.deployable.<[session]>]||null> != <[entity]>:
        - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:stale
        - stop
    - define indexed <server.flag[lapex.deployable_index.<[kind]>]||<list>>
    - flag server lapex.deployable_index.<[kind]>:<[indexed].include[<[entity]>].deduplicate>
    - choose <[kind]>:
        - case caustic_trap:
            - if <[entity].has_flag[lapex.caustic_was_triggered]> && !<[entity].has_flag[lapex.caustic_gas_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - case horizon_newt:
            - if !<[entity].has_flag[lapex.horizon_newt_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - case ash_portal:
            - if !<[entity].has_flag[lapex.ash_portal_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - case octane_pad:
            - if <[entity].flag[lapex.deployable_state]||null> != active:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:invalid
                - stop
        - case axle_gate:
            - if <[entity].flag[lapex.deployable_state]||null> != active:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:invalid
                - stop
        - case gibraltar_dome:
            - if !<[entity].has_flag[lapex.gibraltar_dome_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - case lifeline_doc:
            - if !<[entity].has_flag[lapex.lifeline_doc_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - case lifeline_halo:
            - if !<[entity].has_flag[lapex.lifeline_halo_active]>:
                - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:expired
                - stop
        - default:
            - run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[entity]> def.kind:<[kind]> def.session:<[session]> def.reason:unknown
            - stop
    - run lapex_deployable_resume def.entity:<[entity]> def.session:<[session]>

lapex_deployable_resume:
    type: task
    debug: false
    definitions: entity|session
    script:
    - define token <util.random_uuid>
    - flag <[entity]> lapex.deployable_loop_token:<[token]>
    - choose <[entity].flag[lapex.deployable_kind]||null>:
        - case caustic_trap:
            - if <[entity].has_flag[lapex.caustic_gas_active]>:
                - run lapex_caustic_gas_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
            - else:
                - run lapex_caustic_trap_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case horizon_newt:
            - run lapex_horizon_newt_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case ash_portal:
            - run lapex_ash_portal_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case octane_pad:
            - run lapex_octane_pad_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case axle_gate:
            - run lapex_axle_gate_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case gibraltar_dome:
            - run lapex_gibraltar_dome_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case lifeline_doc:
            - run lapex_lifeline_doc_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>
        - case lifeline_halo:
            - run lapex_lifeline_halo_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>

lapex_caustic_trap_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - if <[entity].flag[lapex.deployable_state]||arming> == arming:
        - wait 16t
        - if !<proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
            - stop
        - flag <[entity]> lapex.deployable_state:active
        - playsound <[entity]> sound:block.iron_trapdoor.open pitch:1.5 volume:0.6
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].flag[lapex.deployable_state]||null> == active:
        - define target null
        - define owner <[entity].flag[lapex.deployable_owner]>
        - foreach <[entity].location.find_entities[living].within[3]> as:possible:
            - define combat_player <proc[lapex_legend_combat_player].context[<[possible]>]>
            - if <[combat_player]> != null && !<proc[lapex_legend_is_ally].context[<[owner]>|<[possible]>]> && !<[combat_player].has_flag[lapex.phased]>:
                - define target <[possible]>
                - foreach stop
        - if <[target]> != null:
            - run lapex_caustic_trigger def.entity:<[entity]> def.session:<[session]>
            - stop
        - wait 2t

# Proximity and gunshots share one guarded transition. A second hit cannot
# start a duplicate gas queue for the same trap session.
lapex_caustic_trigger:
    type: task
    debug: false
    definitions: entity|session
    script:
    - if !<proc[lapex_deployable_is_current].context[<[entity]>|<[session]>]> || <[entity].flag[lapex.deployable_state]||null> != active || <[entity].has_flag[lapex.caustic_was_triggered]>:
        - stop
    - flag <[entity]> lapex.deployable_state:triggered
    - flag <[entity]> lapex.caustic_was_triggered
    - flag <[entity]> lapex.caustic_gas_active expire:22s
    - flag <[entity]> lapex.caustic_gas_damage:10
    - playsound <[entity]> sound:block.fire.extinguish pitch:0.55 volume:1
    - define token <util.random_uuid>
    - flag <[entity]> lapex.deployable_loop_token:<[token]>
    - run lapex_caustic_gas_loop def.entity:<[entity]> def.session:<[session]> def.token:<[token]>

lapex_caustic_gas_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.caustic_gas_active]>:
        - define owner <[entity].flag[lapex.deployable_owner]>
        - define damage <[entity].flag[lapex.caustic_gas_damage]||10>
        - playeffect effect:cloud at:<[entity].location.above[1]> offset:3 quantity:45
        - run lapex_caustic_gas_pulse def.location:<[entity].location> def.radius:3 def.damage:<[damage]> def.owner:<[owner]>
        - flag <[entity]> lapex.caustic_gas_damage:<[damage].add[1].min[15]>
        - wait 1s
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:caustic_trap def.session:<[session]> def.reason:expired

# All Nox sources use the same owner-scoped damage lock. Overlapping traps can
# fill a larger area but cannot multiply the once-per-second damage tick.
lapex_caustic_gas_pulse:
    type: task
    debug: false
    definitions: location|radius|damage|owner
    script:
    - run lapex_legend_damage_sphere def.location:<[location]> def.radius:<[radius]> def.damage:<[damage]> def.effect:slow def.pylon_blockable:false def.source:<[owner]> def.lock_duration:18t
    - foreach <server.flag[lapex.deployable_index.lifeline_doc]||<list>> as:doc:
        - define doc_session <[doc].flag[lapex.deployable_session]||null>
        - if <proc[lapex_deployable_is_current].context[<[doc]>|<[doc_session]>]> && <[doc].world> == <[location].world> && <[doc].location.distance[<[location]>]> <= <[radius]> && !<proc[lapex_legend_is_ally].context[<[owner]>|<[doc]>]>:
            - flag <[doc]> lapex.lifeline_doc_malfunction expire:1.3s
    - foreach <[location].find_entities[living].within[<[radius]>]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> != null && !<proc[lapex_legend_is_ally].context[<[owner]>|<[target]>]> && !<[combat_player].has_flag[lapex.legend_protected]> && !<[combat_player].has_flag[lapex.phased]>:
            - flag <[combat_player]> lapex.legend_grounded expire:1.5s

lapex_horizon_newt_loop:
    type: task
    debug: false
    definitions: entity|session|token
    script:
    - while <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]> && <[entity].has_flag[lapex.horizon_newt_active]>:
        - define owner <[entity].flag[lapex.deployable_owner]>
        - playeffect effect:reverse_portal at:<[entity].location.above[1]> offset:2 quantity:24
        - define seen_players <list>
        - foreach <[entity].location.find_entities[living].within[10]> as:target:
            - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
            - if <[combat_player]> != null && !<[seen_players].contains[<[combat_player].uuid>]> && !<proc[lapex_legend_is_ally].context[<[owner]>|<[target]>]> && !<[combat_player].has_flag[lapex.phased]>:
                - define seen_players <[seen_players].include[<[combat_player].uuid>]>
                # Pull the mannequin hitbox for a piloting Crypto, but apply
                # the slow to the real player so it survives leaving the drone.
                - run lapex_horizon_newt_pull def.target:<[target]> def.combat_player:<[combat_player]> def.destination:<[entity].location>
        - wait 5t
    - if <proc[lapex_deployable_is_current].context[<[entity]>|<[session]>|<[token]>]>:
        - run lapex_deployable_cleanup def.owner:<[entity].flag[lapex.deployable_owner]> def.entity:<[entity]> def.kind:horizon_newt def.session:<[session]> def.reason:expired

# Push is a holdable command, so each target gets an independent queue. Running
# it inline would make a crowded black hole pull players one after another.
lapex_horizon_newt_pull:
    type: task
    debug: false
    definitions: target|combat_player|destination
    script:
    - cast slowness duration:8t amplifier:2 <[combat_player]>
    - push <[target]> origin:<[target].location> destination:<[destination]> speed:0.75 duration:5t no_damage no_rotate

# Console-safe lifecycle check for contributors. An offline owner is enough to
# verify entity mechanisms, dynamic registry flags, oldest replacement, and
# idempotent cleanup; combat behavior still requires the multiplayer checklist.
lapex_deployable_smoke:
    type: task
    debug: false
    definitions: owner|location
    script:
    - if <[owner]||null> == null || <[location]||null> == null:
        - narrate "<red>[Lapex] Deployable smoke needs an owner and location."
        - stop
    - define failures 0
    - chunkload <[location].chunk>
    # The smoke location is isolated. Clear a proxy left by an interrupted
    # earlier smoke run before asserting the new session.
    - foreach <[location].find_entities[armor_stand].within[3]> as:stale:
        - define stale_smoke false
        - foreach <[stale].scoreboard_tags> as:stale_tag:
            - if <[stale_tag].starts_with[lapex_smoke_]>:
                - define stale_smoke true
        - if <[stale_smoke]>:
            - remove <[stale]>
    - define first_tag lapex_smoke_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[location]> def.tag:<[first_tag]> def.arms:false
    - define first <server.flag[lapex.native_spawn_result.<[first_tag]>]||null>
    - flag server lapex.native_spawn_result.<[first_tag]>:!
    - if <[first]> == null:
        - narrate "<red>[Lapex] Deployable smoke could not spawn its first proxy."
        - chunkload remove <[location].chunk>
        - stop
    - adjust <[first]> gravity:false
    - adjust <[first]> visible:false
    - adjust <[first]> collidable:false
    - equip <[first]> head:<item[lapex_model_caustic_trap]>
    - flag <[first]> lapex.deployable_state:active
    - ~run lapex_deployable_register def.owner:<[owner]> def.entity:<[first]> def.kind:smoke_test def.health:100 def.max_count:1 "def.label:<green>SMOKE TEST"
    - define first_session <[first].flag[lapex.deployable_session]||null>
    - if <[first_session]> == null || <[owner].flag[lapex.deployable.<[first_session]>]||null> != <[first]>:
        - narrate "<red>[Lapex] Smoke first registration mismatch. <gray>spawned=<[first].is_spawned||false> session=<[first_session]> expected=<[owner].flag[lapex.deployable.<[first_session]>]||null>"
        - define failures <[failures].add[1]>
    - define second_tag lapex_smoke_<util.random_uuid>
    - ~run lapex_native_spawn_armor_stand def.location:<[location].add[1,0,0]> def.tag:<[second_tag]> def.arms:false
    - define second <server.flag[lapex.native_spawn_result.<[second_tag]>]||null>
    - flag server lapex.native_spawn_result.<[second_tag]>:!
    - if <[second]> == null:
        - define failures <[failures].add[1]>
    - else:
        - adjust <[second]> gravity:false
        - adjust <[second]> visible:false
        - adjust <[second]> collidable:false
        - equip <[second]> head:<item[lapex_model_horizon_newt]>
        - flag <[second]> lapex.deployable_state:active
        - ~run lapex_deployable_register def.owner:<[owner]> def.entity:<[second]> def.kind:smoke_test def.health:100 def.max_count:1 "def.label:<light_purple>SMOKE TEST"
        - define second_session <[second].flag[lapex.deployable_session]||null>
        - if <[first].is_spawned||false> || <[second_session]> == null || <[owner].flag[lapex.deployable.<[second_session]>]||null> != <[second]>:
            - narrate "<red>[Lapex] Smoke replacement mismatch. <gray>first_spawned=<[first].is_spawned||false> second_spawned=<[second].is_spawned||false> session=<[second_session]> expected=<[owner].flag[lapex.deployable.<[second_session]>]||null>"
            - define failures <[failures].add[1]>
        - define extra_tag lapex_smoke_extra_<util.random_uuid>
        - ~run lapex_native_spawn_armor_stand def.location:<[location].add[2,0,0]> def.tag:<[extra_tag]> def.arms:false def.small:true def.marker:true
        - define extra <server.flag[lapex.native_spawn_result.<[extra_tag]>]||null>
        - flag server lapex.native_spawn_result.<[extra_tag]>:!
        - if <[extra]> == null:
            - narrate "<red>[Lapex] Smoke small extra proxy did not spawn."
            - define failures <[failures].add[1]>
        - else:
            - adjust <[extra]> gravity:false
            - adjust <[extra]> visible:false
            - adjust <[extra]> collidable:false
            - equip <[extra]> head:<item[lapex_model_octane_pad]>
            - ~run lapex_deployable_attach_extra def.owner:<[owner]> def.primary:<[second]> def.extra:<[extra]>
            - if <[extra].flag[lapex.deployable_extra_session]||null> != <[second_session]> || !<[owner].flag[lapex.deployable_extras.<[second_session]>].contains[<[extra]>]||false>:
                - narrate "<red>[Lapex] Smoke extra registration mismatch."
                - define failures <[failures].add[1]>
        - ~run lapex_deployable_cleanup def.owner:<[owner]> def.entity:<[second]> def.kind:smoke_test def.session:<[second_session]> def.reason:smoke_test
        - if <[extra]||null> != null && <[extra].is_spawned||false>:
            - narrate "<red>[Lapex] Smoke cleanup left an extra proxy behind."
            - define failures <[failures].add[1]>
            - remove <[extra]>
    - if <[first].is_spawned||false>:
        - remove <[first]>
    - if <[second]||null> != null && <[second].is_spawned||false>:
        - remove <[second]>
    - define allay_tag lapex_smoke_allay_<util.random_uuid>
    - ~run lapex_native_spawn_allay def.location:<[location].above[1]> def.tag:<[allay_tag]>
    - define allay <server.flag[lapex.native_spawn_result.<[allay_tag]>]||null>
    - flag server lapex.native_spawn_result.<[allay_tag]>:!
    - if <[allay]> == null || !<[allay].is_spawned||false>:
        - narrate "<red>[Lapex] Smoke native allay binding mismatch."
        - define failures <[failures].add[1]>
    - else:
        - remove <[allay]>
    - flag <[owner]> lapex.deployable_sessions.smoke_test:!
    - chunkload remove <[location].chunk>
    - if <[failures]> == 0:
        - narrate "<green>Lapex deployable smoke passed: native proxies, extras, register, replace, and cleanup."
    - else:
        - narrate "<red>Lapex deployable smoke failed with <[failures]> problem(s)."
