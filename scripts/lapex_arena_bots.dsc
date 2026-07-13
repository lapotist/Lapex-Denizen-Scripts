# Native Arena playtest opponents. Husks supply Minecraft pathfinding and hit
# boxes; Denizen owns target choice and firearms. Citizens is not required.

lapex_arena_bot_events:
    type: world
    debug: false
    events:
        on entity dies:
        - if !<context.entity.has_flag[lapex.arena_bot]>:
            - stop
        - determine passively NO_DROPS
        - determine passively NO_XP
        - define session <context.entity.flag[lapex.arena_bot_session]||null>
        - define team <context.entity.flag[lapex.arena_bot_team]||null>
        - if <[session]> == null || !<list[red|blue].contains[<[team]>]>:
            - stop
        - if <server.flag[lapex.arena.session]||null> == <[session]>:
            - define roster <server.flag[lapex.arena.bots.<[team]>]||<list>>
            - flag server lapex.arena.bots.<[team]>:<[roster].exclude[<context.entity>]>
            - if <server.flag[lapex.arena.bot_smoke_session]||null> != <[session]>:
                - run lapex_arena_check_round def.session:<[session]> delay:1t

        # A husk's built-in target selector would otherwise race the scripted
        # gun AI and make it sprint toward any nearby player. Only targets
        # deliberately selected by the Arena controller may drive native
        # pursuit. The controller still cancels pursuit at firing distance.
        on entity targets entity:
        - define bot <context.entity>
        - if !<[bot].has_flag[lapex.arena_bot]>:
            - stop
        - define controlled_target <[bot].flag[lapex.arena_bot_controlled_target]||null>
        - define requested_target <context.target||null>
        # Bukkit also fires this event when a target is cleared. Never cancel
        # that transition or an old chase can survive after the controller
        # deliberately calls `attack cancel`.
        - if <[requested_target]> == null:
            - stop
        - if <[controlled_target]> == null || <[requested_target]> != <[controlled_target]>:
            - determine cancelled

        # Native punches and arrows do not pass through the Lapex hitscan ally
        # gate. Protect allied bots here while leaving environmental Ring and
        # fall damage intact.
        on entity damaged:
        - define victim <context.entity>
        - if !<[victim].has_flag[lapex.arena_bot]>:
            - stop
        - define session <[victim].flag[lapex.arena_bot_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
            - determine cancelled
        - if <[victim].has_flag[lapex.phased]>:
            - determine cancelled
        - define damager <context.damager||null>
        - if <[damager]> == null:
            - stop
        - define source <[damager].shooter||<[damager]>>
        - if <[victim].has_flag[lapex.legend_protected]>:
            - determine cancelled
        - if <[victim].has_flag[lapex.pylon_protected]> && <list[PROJECTILE|BLOCK_EXPLOSION|ENTITY_EXPLOSION].contains[<context.cause>]>:
            - determine cancelled
        - if <[source].has_flag[lapex.phased]> || <proc[lapex_legend_is_ally].context[<[source]>|<[victim]>]>:
            - determine cancelled

        # Native melee is only a close-range fallback. It must obey the same
        # match, ally, phase, and protection gates as a scripted bullet.
        on entity damages entity:
        - define source <context.damager||null>
        - if <[source]> == null || !<[source].has_flag[lapex.arena_bot]> || <context.cause> != ENTITY_ATTACK:
            - stop
        - define session <[source].flag[lapex.arena_bot_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
            - determine cancelled
        - define state_target <proc[lapex_legend_combat_player].context[<context.entity>]||null>
        - if <[state_target]> == null || <proc[lapex_legend_is_ally].context[<[source]>|<context.entity>]>:
            - determine cancelled
        - if <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - determine cancelled

        on pre script reload:
        - define session <server.flag[lapex.arena.session]||null>
        - if <[session]> != null:
            - run lapex_arena_bots_cleanup def.session:<[session]>

        # Persistent mobs in unloaded chunks are invisible to ordinary cleanup.
        # Reconcile them whenever their chunk returns and once after startup.
        on chunk loads entities:
        - foreach <context.entities> as:entity:
            - if <[entity].has_flag[lapex.arena_bot]>:
                - run lapex_arena_bot_reconcile def.bot:<[entity]>

        on scripts loaded:
        - foreach <server.worlds> as:loaded_world:
            - foreach <[loaded_world].entities> as:entity:
                - if <[entity].has_flag[lapex.arena_bot]>:
                    - run lapex_arena_bot_reconcile def.bot:<[entity]>

lapex_arena_bot_reconcile:
    type: task
    debug: false
    definitions: bot
    script:
    - if <[bot]||null> == null || !<[bot].is_spawned||false> || !<[bot].has_flag[lapex.arena_bot]>:
        - stop
    - define session <[bot].flag[lapex.arena_bot_session]||null>
    - define current <server.flag[lapex.arena.session]||null>
    - define team <[bot].flag[lapex.arena_bot_team]||null>
    - define valid false
    - if <[session]> != null && <[session]> == <[current]> && <server.flag[lapex.arena.state]||none> == live && <list[red|blue].contains[<[team]>]>:
        - define roster <server.flag[lapex.arena.bots.<[team]>]||<list>>
        - if <[roster].contains[<[bot]>]>:
            - define valid true
    - if !<[valid]>:
        - attack <[bot]> cancel
        - walk <[bot]> stop
        - remove <[bot]>

# Paper 26's generic Denizen spawn adapter can return an EntityTag whose Bukkit
# entity is null. Native summon plus a unique scoreboard tag gives us the same
# stable binding pattern used by Crypto and physical legend devices.
lapex_arena_native_spawn_husk:
    type: task
    debug: false
    definitions: location|tag
    script:
    - define dimension minecraft:<[location].world.name>
    - if <[location].world.name> == world:
        - define dimension minecraft:overworld
    - else if <[location].world.name> == world_nether:
        - define dimension minecraft:the_nether
    - else if <[location].world.name> == world_the_end:
        - define dimension minecraft:the_end
    - execute as_server "execute in <[dimension]> run summon minecraft:husk <[location].x> <[location].y> <[location].z> {Tags:['<[tag]>'],PersistenceRequired:1b,Silent:1b,CanPickUpLoot:0b}" silent
    - wait 2t
    - foreach <[location].find_entities[husk].within[0.75]> as:candidate:
        - if <[candidate].scoreboard_tags.contains[<[tag]>]>:
            - flag server lapex.arena.native_spawn_result.<[tag]>:<[candidate]> expire:1m
            - foreach stop

# Prune the current lists, count valid humans, then fill each combined roster to
# exactly five. The controller calls this only after the round enters live.
lapex_arena_bots_fill:
    type: task
    debug: false
    definitions: session
    script:
    - if <[session]||null> == null || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - if <world[<[world_name]>]||null> == null:
        - stop
    # Native entities do not keep an otherwise empty dimension loaded. Lease
    # every chunk in the compact authored footprint so a graph edge never
    # crosses an unticked gap during an all-bot playtest.
    - define leased_chunks <list>
    - define min_chunk_x <script[lapex_arena_data].data_key[bounds.min_x].div[16].round_down>
    - define max_chunk_x <script[lapex_arena_data].data_key[bounds.max_x].div[16].round_down>
    - define min_chunk_z <script[lapex_arena_data].data_key[bounds.min_z].div[16].round_down>
    - define max_chunk_z <script[lapex_arena_data].data_key[bounds.max_z].div[16].round_down>
    - repeat <[max_chunk_x].sub[<[min_chunk_x]>].add[1]> as:x_offset:
        - define chunk_x <[min_chunk_x].add[<[x_offset]>].sub[1]>
        - repeat <[max_chunk_z].sub[<[min_chunk_z]>].add[1]> as:z_offset:
            - define chunk_z <[min_chunk_z].add[<[z_offset]>].sub[1]>
            - define chunk_location <location[<[chunk_x].mul[16]>,64,<[chunk_z].mul[16]>,<[world_name]>]>
            - define leased_chunks <[leased_chunks].include[<[chunk_location].chunk>]>
    - foreach <[leased_chunks]> as:leased_chunk:
        - chunkload <[leased_chunk]> duration:4m
    - flag server lapex.arena.bot_chunks_session:<[session]>
    - flag server lapex.arena.bot_chunks:<[leased_chunks]>
    - wait 1t
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - foreach <list[red|blue]> as:team:
        - define valid_bots <list>
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:old_bot:
            - if <[old_bot].is_spawned||false> && <[old_bot].flag[lapex.arena_bot_session]||null> == <[session]> && <[old_bot].flag[lapex.arena_bot_team]||null> == <[team]>:
                - define valid_bots <[valid_bots].include[<[old_bot]>]>
            - else if <[old_bot].is_spawned||false>:
                - remove <[old_bot]>
        - flag server lapex.arena.bots.<[team]>:<[valid_bots]>
        - define humans <list>
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:human:
            - if <[human].is_online||false> && <[human].flag[lapex.arena_session]||null> == <[session]> && !<[human].has_flag[lapex.arena_eliminated]>:
                - define humans <[humans].include[<[human]>]>
        - define occupied <[humans].size.add[<[valid_bots].size>]>
        - define needed <element[5].sub[<[occupied]>]>
        - if <[needed]> <= 0:
            - foreach next
        - define spawns <script[lapex_arena_data].data_key[team_spawns.<[team]>]||<list>>
        - repeat <[needed]> as:bot_number:
            - define slot <[occupied].add[<[bot_number]>]>
            - define coordinates <[spawns].get[<[slot]>]||<[spawns].last||0,65,0>>
            - define spawn_at <location[<[coordinates]>,<[world_name]>]>
            - define weapon <list[r301|flatline|volt|spitfire].random>
            - define spawn_tag lapex_arena_bot_<util.random_uuid>
            - ~run lapex_arena_native_spawn_husk def.location:<[spawn_at]> def.tag:<[spawn_tag]>
            - define bot <server.flag[lapex.arena.native_spawn_result.<[spawn_tag]>]||null>
            - flag server lapex.arena.native_spawn_result.<[spawn_tag]>:!
            - if <[bot]> == null:
                - repeat next
            - flag <[bot]> lapex.arena_bot:true
            - flag <[bot]> lapex.arena_session:<[session]>
            - flag <[bot]> lapex.arena_team:<[team]>
            - flag <[bot]> lapex.team:arena_<[session]>_<[team]>
            - flag <[bot]> lapex.arena_bot_session:<[session]>
            - flag <[bot]> lapex.arena_bot_team:<[team]>
            - flag <[bot]> lapex.arena_bot_weapon:<[weapon]>
            - flag <[bot]> lapex.arena_bot_ammo:<script[lapex_weapon_data].data_key[weapons.<[weapon]>.mag]>
            - flag <[bot]> lapex.arena_bot_slot:<[slot]>
            - define aim_scale_min <script[lapex_arena_data].data_key[bot_tuning.aim_error_scale_min]||0.9>
            - define aim_scale_max <script[lapex_arena_data].data_key[bot_tuning.aim_error_scale_max]||1.15>
            - define aim_scale <util.random_decimal.mul[<[aim_scale_max].sub[<[aim_scale_min]>]>].add[<[aim_scale_min]>]>
            - flag <[bot]> lapex.arena_bot_aim_error_scale:<[aim_scale]>
            - adjust <[bot]> can_pickup_items:false
            - adjust <[bot]> silent:true
            - adjust <[bot]> health:20
            - if <[team]> == red:
                - adjust <[bot]> "custom_name:<red>RED BOT <gray>#<[slot]> <dark_gray>[<[weapon].to_uppercase>]"
                - equip <[bot]> head:red_concrete hand:<item[apex_<[weapon]>]>
            - else:
                - adjust <[bot]> "custom_name:<blue>BLUE BOT <gray>#<[slot]> <dark_gray>[<[weapon].to_uppercase>]"
                - equip <[bot]> head:blue_concrete hand:<item[apex_<[weapon]>]>
            - adjust <[bot]> custom_name_visible:true
            - define valid_bots <[valid_bots].include[<[bot]>]>
            - flag server lapex.arena.bots.<[team]>:<[valid_bots]>
            - playeffect effect:electric_spark at:<[spawn_at].above[1]> offset:0.2 quantity:4 visibility:96
            - run lapex_arena_bot_opening_watchdog def.bot:<[bot]> def.session:<[session]> def.team:<[team]> def.slot:<[slot]>
    # Never let a transient native-spawn failure turn into a free round. A
    # complete live roster is five valid actors per team or the session ends.
    - define fill_failed false
    - foreach <list[red|blue]> as:team:
        - define actor_count 0
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:human:
            - if <[human].is_online||false> && <[human].flag[lapex.arena_session]||null> == <[session]> && !<[human].has_flag[lapex.arena_eliminated]>:
                - define actor_count <[actor_count].add[1]>
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_session]||null> == <[session]> && <[bot].health||0> > 0:
                - define actor_count <[actor_count].add[1]>
        - if <[actor_count]> != 5:
            - narrate "<red>[Arena Bots] <[team]> roster fill failed: <[actor_count]>/5 valid actors."
            - define fill_failed true
    - if <[fill_failed]>:
        - run lapex_arena_announce def.session:<[session]> "def.message:<red>Arena stopped because a playtest bot could not spawn."
        - run lapex_arena_cleanup def.session:<[session]> def.reason:bot_fill_failed
        - stop
    - define token <util.random_uuid>
    - flag server lapex.arena.bot_loop_token:<[token]>
    - run lapex_arena_bots_loop def.session:<[session]> def.token:<[token]>

# Idempotent and session-scoped. Besides authoritative lists, scan the compact
# Arena world so a list write interrupted by a reload cannot orphan a husk.
lapex_arena_bots_cleanup:
    type: task
    debug: false
    definitions: session
    script:
    - if <[session]||null> == null:
        - stop
    - flag server lapex.arena.bot_loop_token:<util.random_uuid>
    - define remove_list <list>
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_session]||null> == <[session]>:
                - define remove_list <[remove_list].include[<[bot]>]>
        - if <server.flag[lapex.arena.session]||null> == <[session]>:
            - flag server lapex.arena.bots.<[team]>:<list>
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> != null:
        - foreach <[map_world].entities> as:entity:
            - if <[entity].has_flag[lapex.arena_bot]> && <[entity].flag[lapex.arena_bot_session]||null> == <[session]>:
                - define remove_list <[remove_list].include[<[entity]>]>
    - foreach <[remove_list].deduplicate> as:bot:
        - if <[bot].is_spawned||false>:
            - attack <[bot]> cancel
            - walk <[bot]> stop
            - remove <[bot]>
    # Release tickets only after every session entity has been found and
    # removed. Reversing this order can unload persistent husks mid-cleanup.
    - if <server.flag[lapex.arena.bot_chunks_session]||null> == <[session]>:
        - foreach <server.flag[lapex.arena.bot_chunks]||<list>> as:leased_chunk:
            - chunkload remove <[leased_chunk]>
        - flag server lapex.arena.bot_chunks_session:!
        - flag server lapex.arena.bot_chunks:!

# One five-Hz decision queue serves all ten bots. Weapon fire has independent
# cadence queues so a 600-RPM registry entry still fires faster than decisions.
lapex_arena_bots_loop:
    type: task
    debug: false
    definitions: session|token
    script:
    - while <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.bot_loop_token]||null> == <[token]>:
        - if <server.flag[lapex.arena.state]||none> == live:
            - foreach <list[red|blue]> as:team:
                - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
                    - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_session]||null> == <[session]> && <[bot].health||0> > 0:
                        - run lapex_arena_bot_enforce_ring def.bot:<[bot]> def.session:<[session]>
                        - run lapex_arena_bot_decide def.bot:<[bot]> def.session:<[session]>
        - wait 4t

# World borders only damage players. Mirror the current, continuously shrinking
# square for native bots or an all-bot round could survive outside forever.
lapex_arena_bot_enforce_ring:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define arena_world <world[<[world_name]>]||null>
    - if <[arena_world]> == null:
        - stop
    - if <[bot].world> != <[arena_world]>:
        - hurt 100 <[bot]> cause:VOID
        - stop
    - define center <[arena_world].border_center>
    - define half <[arena_world].border_size.div[2]>
    - define outside false
    - if <[bot].location.x.sub[<[center].x>].abs> > <[half]> || <[bot].location.z.sub[<[center].z>].abs> > <[half]>:
        - define outside true
    - if !<[outside]>:
        - stop
    - define damage <[arena_world].border_damage.div[5].max[0.5]>
    # Capture the effect position before damage. The hit can kill and despawn
    # the bot, after which reading its live location is invalid in Denizen.
    - define effect_location <[bot].location.above[1]>
    - hurt <[damage]> <[bot]> cause:WORLD_BORDER
    - if <[bot].is_spawned||false>:
        - adjust <[bot]> no_damage_duration:0s
    - playeffect effect:damage_indicator at:<[effect_location]> offset:0.25 quantity:3 visibility:96

lapex_arena_bot_decide:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]>:
        - stop
    - if <[bot].has_flag[lapex.arena_bot_smoke_slide_test]>:
        - stop
    - if <[bot].has_flag[lapex.arena_bot_opening_escort]>:
        - stop
    - define target <proc[lapex_arena_bot_choose_target].context[<[bot]>|<[session]>]||null>
    - if <[target]> == null:
        - if <[bot].has_flag[lapex.arena_bot_controlled_target]>:
            - attack <[bot]> cancel
            - flag <[bot]> lapex.arena_bot_moving:!
        - flag <[bot]> lapex.arena_bot_controlled_target:!
        - flag <[bot]> lapex.arena_bot_melee:!
        - flag <[bot]> lapex.arena_bot_target:!
        - define patrol_goal <[bot].flag[lapex.arena_bot_nav_goal]||null>
        - if <[patrol_goal]> != null:
            - run lapex_arena_bot_try_slide def.bot:<[bot]> def.session:<[session]> def.goal:<[patrol_goal]>
        - run lapex_arena_bot_navigate def.bot:<[bot]> def.session:<[session]>
        - stop
    # A newly visible enemy supersedes a patrol destination. Stop the one active
    # walk before selecting chase/hold behavior so its speed-restoration
    # callback cannot overlap another path.
    - if <[bot].has_flag[lapex.arena_bot_nav_goal]>:
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_nav_goal:!
        - flag <[bot]> lapex.arena_bot_nav_lock:!
        - flag <[bot]> lapex.arena_bot_moving:!
        - flag <[bot]> lapex.arena_bot_movement_check:!
    - define previous_target <[bot].flag[lapex.arena_bot_target]||null>
    - if <[previous_target]> != <[target]>:
        # A short per-acquisition delay makes the turn toward an opponent a
        # readable warning instead of an instant first-shot hit.
        - define reaction_min <script[lapex_arena_data].data_key[bot_tuning.reaction_min_ticks]||7>
        - define reaction_max <script[lapex_arena_data].data_key[bot_tuning.reaction_max_ticks]||15>
        - define reaction_ticks <util.random.int[<[reaction_min]>].to[<[reaction_max]>]>
        - flag <[bot]> lapex.arena_bot_reaction expire:<[reaction_ticks]>t
    - flag <[bot]> lapex.arena_bot_target:<[target]> expire:2s
    - define target_height <[target].height||1.8>
    - define aim_height <script[lapex_arena_data].data_key[bot_tuning.aim_height]||0.52>
    - define target_center <[target].location.above[<[target_height].mul[<[aim_height]>]>]>
    - look <[bot]> <[target_center]> duration:5t
    - define distance <[bot].location.distance[<[target].location>]>
    - if <[distance]> <= 2.6:
        - if <[bot].flag[lapex.arena_bot_controlled_target]||null> != <[target]> || !<[bot].has_flag[lapex.arena_bot_melee]>:
            - flag <[bot]> lapex.arena_bot_controlled_target:<[target]>
            - flag <[bot]> lapex.arena_bot_melee
            - attack <[bot]> target:<[target]>
        - stop
    - if <[bot].has_flag[lapex.arena_bot_melee]>:
        - attack <[bot]> cancel
        - flag <[bot]> lapex.arena_bot_melee:!
        - flag <[bot]> lapex.arena_bot_controlled_target:!
    # Native pursuit tracks a moving actor without issuing a fresh path command
    # five times per second. Two different thresholds form a stable ranged
    # combat band: chase outside 18 blocks, then hold and shoot inside 12.
    - define chase_start <script[lapex_arena_data].data_key[bot_tuning.chase_start_distance]||18>
    - define chase_stop <script[lapex_arena_data].data_key[bot_tuning.chase_stop_distance]||12>
    - define controlled_target <[bot].flag[lapex.arena_bot_controlled_target]||null>
    - if <[controlled_target]> != null && <[controlled_target]> != <[target]>:
        - attack <[bot]> cancel
        - flag <[bot]> lapex.arena_bot_controlled_target:!
        - flag <[bot]> lapex.arena_bot_moving:!
    - define should_chase false
    - if <[distance]> > <[chase_start]>:
        - define should_chase true
    - else if <[distance]> >= <[chase_stop]> && <[bot].flag[lapex.arena_bot_controlled_target]||null> == <[target]>:
        - define should_chase true
    - if <[should_chase]> && !<[bot].has_flag[lapex.arena_bot_stationary]>:
        # A native goal may clear its target after a failed path. Compare both
        # controller intent and the mob's real target so pursuit self-recovers.
        - if <[bot].flag[lapex.arena_bot_controlled_target]||null> != <[target]> || <[bot].target||null> != <[target]>:
            - walk <[bot]> stop
            - flag <[bot]> lapex.arena_bot_controlled_target:<[target]>
            - attack <[bot]> target:<[target]>
            - flag <[bot]> lapex.arena_bot_moving
        - run lapex_arena_bot_try_slide def.bot:<[bot]> def.session:<[session]> def.goal:<[target].location>
    - else if <[distance]> < <[chase_stop]>:
        - if <[bot].has_flag[lapex.arena_bot_controlled_target]>:
            - attack <[bot]> cancel
            - flag <[bot]> lapex.arena_bot_controlled_target:!
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_moving:!
    - if !<[bot].has_flag[lapex.arena_bot_firing]> && !<[bot].has_flag[lapex.arena_bot_reaction]> && !<[bot].has_flag[lapex.arena_bot_slide_token]>:
        - run lapex_arena_bot_fire_loop def.bot:<[bot]> def.session:<[session]>

lapex_arena_bot_track_movement:
    type: task
    debug: false
    definitions: bot|session|goal|token
    script:
    - define previous <[bot].location>
    - repeat <script[lapex_arena_data].data_key[bot_tuning.navigation_checks]||12>:
        - wait 20t
        - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <[bot].flag[lapex.arena_bot_movement_check]||null> != <[token]>:
            - stop
        - if <[bot].flag[lapex.arena_bot_nav_goal]||null> != <[goal]> || <[bot].has_flag[lapex.arena_bot_controlled_target]>:
            - flag <[bot]> lapex.arena_bot_movement_check:!
            - stop
        - define progress <[bot].location.distance[<[previous]>]>
        - if <[progress]> < 0.35:
            - walk <[bot]> stop
            - flag <[bot]> lapex.arena_bot_stationary expire:1s
            - flag <[bot]> lapex.arena_bot_moving:!
            - flag <[bot]> lapex.arena_bot_nav_goal:!
            - flag <[bot]> lapex.arena_bot_nav_lock:!
            - flag <[bot]> lapex.arena_bot_movement_check:!
            - stop
        - define previous <[bot].location>
    - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_movement_check]||null> == <[token]>:
        - flag <[bot]> lapex.arena_bot_movement_check:!

# Native husks can finish a partial path or let an idle goal replace it while
# still drifting inside a spawn room. Guide only the opening leg along its clear,
# slot-aligned line at ordinary running speed. If collision or another plugin
# defeats that guide for twelve seconds, recover to the verified block directly
# beyond the same door. The rest of the match remains native graph navigation.
lapex_arena_bot_opening_watchdog:
    type: task
    debug: false
    definitions: bot|session|team|slot
    script:
    - define nodes <script[lapex_arena_data].data_key[navigation_nodes]||<map>>
    - define opening_id <script[lapex_arena_data].data_key[bot_opening_nodes.<[team]>].get[<[slot]>]||null>
    - define coordinates <[nodes].get[<[opening_id]>]||null>
    - if <[coordinates]> == null:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define doorway <location[<[coordinates]>,<[world_name]>]>
    - if <[team]> == red:
        - define recovery <[doorway].with_z[<[doorway].z.add[1]>]>
    - else:
        - define recovery <[doorway].with_z[<[doorway].z.sub[1]>]>
    - if !<[recovery].below.material.is_solid> || <[recovery].material.is_solid> || <[recovery].above.material.is_solid>:
        - stop
    - define guide_ticks <duration[<script[lapex_arena_data].data_key[bot_tuning.opening_watchdog]||12s>].in_ticks>
    - define guide_speed <script[lapex_arena_data].data_key[bot_tuning.opening_escort_speed]||0.12>
    - attack <[bot]> cancel
    - walk <[bot]> stop
    - flag <[bot]> lapex.arena_bot_opening_escort expire:<[guide_ticks].add[10]>t
    - foreach <list[controlled_target|melee|nav_goal|nav_lock|nav_refresh|moving|movement_check|stationary]> as:state:
        - flag <[bot]> lapex.arena_bot_<[state]>:!
    - repeat <[guide_ticks]>:
        - wait 1t
        - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
            - stop
        - define escaped false
        - if <[team]> == red && <[bot].location.z> >= -50:
            - define escaped true
        - else if <[team]> == blue && <[bot].location.z> <= 50:
            - define escaped true
        - if <[escaped]>:
            - flag <[bot]> lapex.arena_bot_opening_complete
            - flag <[bot]> lapex.arena_bot_opening_escort:!
            - adjust <[bot]> velocity:<[bot].velocity.with_x[0].with_z[0]>
            - stop
        - define origin <[bot].location>
        - define level_goal <[recovery].with_y[<[origin].y>]>
        - define impulse <[origin].face[<[level_goal]>].forward[<[guide_speed]>].sub[<[origin]>].with_y[-0.08]>
        - adjust <[bot]> velocity:<[impulse]>
    - flag <[bot]> lapex.arena_bot_opening_escort:!
    - if <[team]> == red && <[bot].location.z> >= -50:
        - flag <[bot]> lapex.arena_bot_opening_complete
        - stop
    - if <[team]> == blue && <[bot].location.z> <= 50:
        - flag <[bot]> lapex.arena_bot_opening_complete
        - stop
    - teleport <[bot]> <[recovery]>
    - flag <[bot]> lapex.arena_bot_opening_complete
    - flag <[bot]> lapex.arena_bot_opening_recovered
    - flag <[bot]> lapex.arena_bot_opening_recovery_slot:<[team]>#<[slot]>
    - foreach <list[controlled_target|melee|nav_goal|nav_lock|nav_refresh|moving|movement_check|stationary]> as:state:
        - flag <[bot]> lapex.arena_bot_<[state]>:!
    - playeffect effect:cloud at:<[recovery].above[0.5]> offset:0.1 quantity:3 visibility:64

# With no visible enemy, follow one edge of the authored navigation graph. This
# keeps goals local and avoids expensive all-map paths for native mobs.
lapex_arena_bot_navigate:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if <[bot].has_flag[lapex.arena_bot_stationary]> || <[bot].has_flag[lapex.arena_bot_opening_escort]> || <[bot].has_flag[lapex.arena_bot_slide_token]>:
        - stop
    - define team <[bot].flag[lapex.arena_bot_team]||null>
    # Reaching the outside face of the spawn wall is the one-way opening
    # contract. Before then, a slot-specific gate overrides random traversal.
    - if !<[bot].has_flag[lapex.arena_bot_opening_complete]>:
        - define exited_spawn false
        - if <[team]> == red && <[bot].location.z> >= -51.5:
            - define exited_spawn true
        - else if <[team]> == blue && <[bot].location.z> <= 51.5:
            - define exited_spawn true
        - if <[exited_spawn]>:
            - flag <[bot]> lapex.arena_bot_opening_complete
    # One native path may remain active for up to the longest authored graph
    # edge. Reaching its saved goal clears the lock immediately; otherwise the
    # progress monitor owns recovery instead of restarting it every decision.
    - if <[bot].has_flag[lapex.arena_bot_nav_lock]>:
        - define active_goal <[bot].flag[lapex.arena_bot_nav_goal]||null>
        - if <[active_goal]> == null:
            - stop
        - define arrival_radius 2
        - if !<[bot].has_flag[lapex.arena_bot_opening_complete]>:
            # A two-block radius can declare the center gate complete while the
            # mob is still inside the spawn wall. Opening routes must cross it.
            - define arrival_radius 0.9
        - if <[bot].location.distance[<[active_goal]>]> > <[arrival_radius]>:
            # Generic mobs retain vanilla idle goals, which can replace a
            # one-shot navigation path. Renew the same authored path at a
            # modest rate until the waypoint is actually reached.
            - if !<[bot].has_flag[lapex.arena_bot_nav_refresh]>:
                - flag <[bot]> lapex.arena_bot_nav_refresh expire:12t
                - run lapex_arena_bot_walk_safe def.bot:<[bot]> def.goal:<[active_goal]> def.session:<[session]> delay:1t
            - stop
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_nav_lock:!
        - flag <[bot]> lapex.arena_bot_nav_goal:!
        - flag <[bot]> lapex.arena_bot_moving:!
        - flag <[bot]> lapex.arena_bot_movement_check:!
        - flag <[bot]> lapex.arena_bot_nav_refresh:!
    - define nodes <script[lapex_arena_data].data_key[navigation_nodes]||<map>>
    - if <[nodes].is_empty>:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define nearest null
    - define nearest_distance 9999
    - foreach <[nodes].keys> as:key:
        - define node <location[<[nodes].get[<[key]>]>,<[world_name]>]>
        - define distance <[bot].location.distance[<[node]>]>
        - if <[distance]> < <[nearest_distance]>:
            - define nearest <[key]>
            - define nearest_distance <[distance]>
    - if <[nearest]> == null:
        - stop
    - define next null
    - if !<[bot].has_flag[lapex.arena_bot_opening_complete]>:
        - define slot <[bot].flag[lapex.arena_bot_slot]||3>
        - define opening_nodes <script[lapex_arena_data].data_key[bot_opening_nodes.<[team]>]||<list>>
        - define next <[opening_nodes].get[<[slot]>]||null>
    - if <[next]> == null:
        - define choices <list>
        - foreach <script[lapex_arena_data].data_key[navigation_links]||<list>> as:link:
            - define ends <[link].split[|]>
            - if <[ends].first> == <[nearest]>:
                - define choices <[choices].include[<[ends].last>]>
            - else if <[ends].last> == <[nearest]>:
                - define choices <[choices].include[<[ends].first>]>
        - define previous <[bot].flag[lapex.arena_bot_nav_previous]||null>
        - if <[choices].size> > 1 && <[previous]> != null:
            - define choices <[choices].exclude[<[previous]>]>
        # Prefer an edge which reduces distance to the nearest live opponent,
        # even while cover blocks line of sight. This only guides movement;
        # the firing selector still requires direct visibility. Near a spawn,
        # forward progress remains mandatory so an opponent cannot pull a bot
        # back into its own room.
        - define forward_choices <list>
        - define pursuit_choices <list>
        - define pursuit_distance 9999
        - define pursuit <proc[lapex_arena_bot_choose_pursuit].context[<[bot]>|<[session]>]||null>
        - define nearest_location <location[<[nodes].get[<[nearest]>]>,<[world_name]>]>
        - foreach <[choices]> as:choice:
            - define choice_location <location[<[nodes].get[<[choice]>]>,<[world_name]>]>
            - if <[team]> == red && <[choice_location].z> > <[nearest_location].z>:
                - define forward_choices <[forward_choices].include[<[choice]>]>
            - else if <[team]> == blue && <[choice_location].z> < <[nearest_location].z>:
                - define forward_choices <[forward_choices].include[<[choice]>]>
            - if <[pursuit]> != null:
                - define option_distance <[choice_location].distance[<[pursuit].location>]>
                - if <[option_distance]> < <[pursuit_distance]>:
                    - define pursuit_distance <[option_distance]>
                    - define pursuit_choices <list[<[choice]>]>
                - else if <[option_distance]> == <[pursuit_distance]>:
                    - define pursuit_choices <[pursuit_choices].include[<[choice]>]>
        - if <[bot].location.z.abs> > 40 && !<[forward_choices].is_empty>:
            - define choices <[forward_choices]>
        - else if !<[pursuit_choices].is_empty> && <util.random_decimal> <= <script[lapex_arena_data].data_key[bot_tuning.pursuit_bias]||0.9>:
            - define choices <[pursuit_choices]>
        - else if !<[forward_choices].is_empty> && <util.random_decimal> <= <script[lapex_arena_data].data_key[bot_tuning.forward_bias]||0.8>:
            - define choices <[forward_choices]>
        - if <[choices].is_empty>:
            - define next <[nearest]>
        - else:
            - define next <[choices].random>
    - if <[nodes].get[<[next]>]||null> == null:
        - stop
    - define goal <location[<[nodes].get[<[next]>]>,<[world_name]>]>
    - flag <[bot]> lapex.arena_bot_nav_previous:<[nearest]>
    - flag <[bot]> lapex.arena_bot_nav_goal:<[goal]> expire:<script[lapex_arena_data].data_key[bot_tuning.navigation_lock]||12s>
    - flag <[bot]> lapex.arena_bot_nav_lock expire:<script[lapex_arena_data].data_key[bot_tuning.navigation_lock]||12s>
    - flag <[bot]> lapex.arena_bot_nav_refresh expire:12t
    # Stop any path whose timeout just elapsed, then give its per-tick adapter
    # one tick to restore the original movement attribute before a new path
    # captures it. This prevents old/new speed callbacks from racing.
    - walk <[bot]> stop
    - run lapex_arena_bot_walk_safe def.bot:<[bot]> def.goal:<[goal]> def.session:<[session]> delay:1t

# Denizen's native walk adapter teleports a mob when Minecraft cannot create a
# path. Detect that synchronous fallback and restore the origin before clients
# receive a sustained position change. This keeps blocked graph edges from
# becoming accidental teleports while retaining native obstacle pathfinding.
lapex_arena_bot_walk_safe:
    type: task
    debug: false
    definitions: bot|goal|session
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]>:
        - stop
    - if <[bot].flag[lapex.arena_bot_nav_goal]||null> != <[goal]> || <[bot].has_flag[lapex.arena_bot_controlled_target]>:
        - stop
    - define origin <[bot].location>
    - define speed <script[lapex_arena_data].data_key[bot_tuning.patrol_speed]||0.21>
    - walk <[bot]> <[goal]> speed:<[speed]>
    - define fallback_distance <script[lapex_arena_data].data_key[bot_tuning.fallback_teleport_distance]||1.0>
    - if <[bot].location.distance[<[origin]>]> > <[fallback_distance]>:
        - teleport <[bot]> <[origin]>
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_stationary expire:1s
        - flag <[bot]> lapex.arena_bot_moving:!
        - flag <[bot]> lapex.arena_bot_nav_goal:!
        - flag <[bot]> lapex.arena_bot_nav_lock:!
        - flag <[bot]> lapex.arena_bot_movement_check:!
        - stop
    - flag <[bot]> lapex.arena_bot_moving expire:<script[lapex_arena_data].data_key[bot_tuning.movement_flag_duration]||13s>
    # Keep one progress monitor across path refreshes. Replacing this token on
    # every refresh prevents its one-second stall check from ever running.
    - if !<[bot].has_flag[lapex.arena_bot_movement_check]>:
        - define movement_token <util.random_uuid>
        - flag <[bot]> lapex.arena_bot_movement_check:<[movement_token]> expire:<script[lapex_arena_data].data_key[bot_tuning.movement_flag_duration]||13s>
        - run lapex_arena_bot_track_movement def.bot:<[bot]> def.session:<[session]> def.goal:<[goal]> def.token:<[movement_token]>

# A slide is allowed only across known flat, empty floor. Sampling halfway and
# at the configured look-ahead catches thin cover without using teleportation
# or relying on the native path adapter's fallback behavior.
lapex_arena_bot_slide_path_clear:
    type: procedure
    debug: false
    definitions: origin|goal
    script:
    - if <[origin]||null> == null || <[goal]||null> == null || <[origin].world> != <[goal].world>:
        - determine false
    - define probe_distance <script[lapex_arena_data].data_key[bot_tuning.slide_probe_distance]||1.15>
    - define margin <script[lapex_arena_data].data_key[bot_tuning.slide_bounds_margin]||5>
    - define min_x <script[lapex_arena_data].data_key[bounds.min_x].add[<[margin]>]>
    - define max_x <script[lapex_arena_data].data_key[bounds.max_x].sub[<[margin]>]>
    - define min_z <script[lapex_arena_data].data_key[bounds.min_z].add[<[margin]>]>
    - define max_z <script[lapex_arena_data].data_key[bounds.max_z].sub[<[margin]>]>
    - define level_goal <[goal].with_y[<[origin].y>]>
    - if <[origin].distance[<[level_goal]>]> < 0.5:
        - determine false
    - define facing <[origin].with_pitch[0].face[<[level_goal]>]>
    - define halfway <[facing].forward[<[probe_distance].div[2]>]>
    - define endpoint <[facing].forward[<[probe_distance]>]>
    - foreach <list[<[halfway]>|<[endpoint]>]> as:sample:
        - define feet <[sample].with_y[<[origin].y>]>
        - if <[feet].x> < <[min_x]> || <[feet].x> > <[max_x]> || <[feet].z> < <[min_z]> || <[feet].z> > <[max_z]>:
            - determine false
        - if <[feet].material.is_solid> || <[feet].above[1].material.is_solid> || !<[feet].below[1].material.is_solid>:
            - determine false
    - if !<[endpoint].find_entities[living].within[0.55].is_empty>:
        - determine false
    - determine true

# Moderately faster traversal without the old permanent speed boost. The
# destination is captured from the current path/target, speed decays every tick,
# and any floor, headroom, arena-bound, or combat-state failure stops the burst.
lapex_arena_bot_try_slide:
    type: task
    debug: false
    definitions: bot|session|goal|force
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - if <[goal]||null> == null || <[goal].world> != <[bot].world> || !<[bot].has_flag[lapex.arena_bot_opening_complete]>:
        - stop
    - if !<[bot].has_flag[lapex.arena_bot_moving]> || <[bot].has_flag[lapex.arena_bot_opening_escort]> || <[bot].has_flag[lapex.arena_bot_stationary]> || <[bot].has_flag[lapex.arena_bot_slide_token]> || <[bot].has_flag[lapex.arena_bot_slide_cooldown]>:
        - stop
    - if <[bot].has_flag[lapex.arena_bot_firing]> || <[bot].has_flag[lapex.arena_bot_reloading]> || <[bot].has_flag[lapex.arena_bot_reaction]> || <[bot].has_flag[lapex.arena_bot_melee]>:
        - stop
    - define spawn_clearance <script[lapex_arena_data].data_key[bot_tuning.slide_spawn_clearance_z]||48>
    - if <[bot].location.z.abs> > <[spawn_clearance]>:
        - stop
    - define minimum_distance <script[lapex_arena_data].data_key[bot_tuning.slide_min_goal_distance]||8>
    - define level_goal <[goal].with_y[<[bot].location.y>]>
    - if <[bot].location.distance[<[level_goal]>]> < <[minimum_distance]>:
        - stop
    - define chance <script[lapex_arena_data].data_key[bot_tuning.slide_chance]||0.18>
    - if !<[force]||false> && <util.random_decimal> > <[chance]>:
        - stop
    - if !<proc[lapex_arena_bot_slide_path_clear].context[<[bot].location>|<[goal]>]>:
        - stop
    - define cooldown_min <script[lapex_arena_data].data_key[bot_tuning.slide_cooldown_min_ticks]||100>
    - define cooldown_max <script[lapex_arena_data].data_key[bot_tuning.slide_cooldown_max_ticks]||160>
    - define cooldown <util.random.int[<[cooldown_min]>].to[<[cooldown_max]>]>
    - define duration <script[lapex_arena_data].data_key[bot_tuning.slide_duration_ticks]||8>
    - define start_speed <script[lapex_arena_data].data_key[bot_tuning.slide_start_speed]||0.32>
    - define end_speed <script[lapex_arena_data].data_key[bot_tuning.slide_end_speed]||0.18>
    - define decay <[start_speed].sub[<[end_speed]>].div[<[duration].sub[1].max[1]>]>
    - define token <util.random_uuid>
    - flag <[bot]> lapex.arena_bot_slide_cooldown expire:<[cooldown]>t
    - flag <[bot]> lapex.arena_bot_slide_token:<[token]> expire:<[duration].add[4]>t
    - playsound <[bot].location> sound:entity.horse.gallop pitch:1.7 volume:0.25
    - define speed <[start_speed]>
    - repeat <[duration]>:
        - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <[bot].flag[lapex.arena_bot_slide_token]||null> != <[token]>:
            - repeat stop
        - if !<[bot].has_flag[lapex.arena_bot_moving]> || <[bot].has_flag[lapex.arena_bot_firing]> || <[bot].has_flag[lapex.arena_bot_reloading]> || <[bot].has_flag[lapex.arena_bot_reaction]> || <[bot].has_flag[lapex.arena_bot_melee]> || <[bot].has_flag[lapex.arena_bot_opening_escort]>:
            - define stopped <[bot].velocity.with_x[<[bot].velocity.x.mul[0.25]>].with_z[<[bot].velocity.z.mul[0.25]>]>
            - adjust <[bot]> velocity:<[stopped]>
            - repeat stop
        - define origin <[bot].location>
        - define level_goal <[goal].with_y[<[origin].y>]>
        - if <[origin].distance[<[level_goal]>]> < <[minimum_distance]>:
            - define stopped <[bot].velocity.with_x[<[bot].velocity.x.mul[0.25]>].with_z[<[bot].velocity.z.mul[0.25]>]>
            - adjust <[bot]> velocity:<[stopped]>
            - repeat stop
        - if !<proc[lapex_arena_bot_slide_path_clear].context[<[origin]>|<[goal]>]>:
            - define stopped <[bot].velocity.with_x[<[bot].velocity.x.mul[0.25]>].with_z[<[bot].velocity.z.mul[0.25]>]>
            - adjust <[bot]> velocity:<[stopped]>
            - repeat stop
        - define facing <[origin].with_pitch[0].face[<[level_goal]>]>
        - define impulse <[facing].forward[<[speed]>].sub[<[facing]>].with_y[-0.08]>
        - adjust <[bot]> velocity:<[impulse]>
        - if <[value].mod[2]> == 0:
            - playeffect effect:cloud at:<[origin].above[0.15]> offset:0.08 quantity:2 visibility:64
        - define speed <[speed].sub[<[decay]>].max[<[end_speed]>]>
        - wait 1t
    - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_slide_token]||null> == <[token]>:
        - flag <[bot]> lapex.arena_bot_slide_token:!

lapex_arena_bot_available:
    type: procedure
    debug: false
    definitions: actor|session
    script:
    - if <[actor]||null> == null:
        - determine false
    - if <[actor].is_player||false>:
        - if !<[actor].is_online||false> || <[actor].flag[lapex.arena_session]||null> != <[session]> || <[actor].has_flag[lapex.arena_eliminated]> || <[actor].health||0> <= 0:
            - determine false
        - if <[actor].gamemode> == SPECTATOR && !<[actor].has_flag[lapex.crypto_active]>:
            - determine false
        - determine true
    - if !<[actor].is_spawned||false> || !<[actor].has_flag[lapex.arena_bot]> || <[actor].flag[lapex.arena_bot_session]||null> != <[session]> || <[actor].health||0> <= 0:
        - determine false
    - determine true

# Strategic pursuit may use an enemy's position behind cover to choose the next
# authored graph edge. It never grants a firing target; the separate combat
# selector below still requires a clear eye-to-torso line of sight.
lapex_arena_bot_choose_pursuit:
    type: procedure
    debug: false
    definitions: bot|session
    script:
    - define team <[bot].flag[lapex.arena_bot_team]||null>
    - if <[team]> == red:
        - define enemy blue
    - else:
        - define enemy red
    - define candidates <server.flag[lapex.arena.players.<[enemy]>]||<list>>
    - define candidates <[candidates].include[<server.flag[lapex.arena.bots.<[enemy]>]||<list>>].deduplicate>
    - define chosen null
    - define chosen_distance 9999
    - foreach <[candidates]> as:candidate:
        - if !<proc[lapex_arena_bot_available].context[<[candidate]>|<[session]>]>:
            - foreach next
        - define physical <[candidate]>
        - if <[candidate].is_player||false> && <[candidate].has_flag[lapex.crypto_active]>:
            - define body <[candidate].flag[lapex.crypto_body_entity]||null>
            - if <[body]> == null || !<[body].is_spawned||false>:
                - foreach next
            - define physical <[body]>
        - if <[physical].world> != <[bot].world> || <proc[lapex_legend_is_ally].context[<[bot]>|<[physical]>]>:
            - foreach next
        - define distance <[bot].location.distance[<[physical].location>]>
        - if <[distance]> < <[chosen_distance]>:
            - define chosen <[physical]>
            - define chosen_distance <[distance]>
    - determine <[chosen]>

# Only actors visible from the bot's eye are candidates. A Crypto pilot maps to
# the live mannequin body, leaving the spectator camera untargetable.
lapex_arena_bot_choose_target:
    type: procedure
    debug: false
    definitions: bot|session
    script:
    - define team <[bot].flag[lapex.arena_bot_team]||null>
    - if <[team]> == red:
        - define enemy blue
    - else:
        - define enemy red
    - define candidates <server.flag[lapex.arena.players.<[enemy]>]||<list>>
    - define candidates <[candidates].include[<server.flag[lapex.arena.bots.<[enemy]>]||<list>>].deduplicate>
    - define weapon_id <[bot].flag[lapex.arena_bot_weapon]||r301>
    - define range <script[lapex_weapon_data].data_key[weapons.<[weapon_id]>.range]||100>
    - define chosen null
    - define chosen_distance 9999
    - foreach <[candidates]> as:candidate:
        - if !<proc[lapex_arena_bot_available].context[<[candidate]>|<[session]>]>:
            - foreach next
        - define physical <[candidate]>
        - if <[candidate].is_player||false> && <[candidate].has_flag[lapex.crypto_active]>:
            - define body <[candidate].flag[lapex.crypto_body_entity]||null>
            - if <[body]> == null || !<[body].is_spawned||false>:
                - foreach next
            - define physical <[body]>
        - define state_target <proc[lapex_legend_combat_player].context[<[physical]>]||null>
        - if <[state_target]> == null || <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - foreach next
        - if <proc[lapex_legend_is_ally].context[<[bot]>|<[physical]>]> || <[physical].world> != <[bot].world>:
            - foreach next
        - define physical_height <[physical].height||1.8>
        - define aim_height <script[lapex_arena_data].data_key[bot_tuning.aim_height]||0.52>
        - define center <[physical].location.above[<[physical_height].mul[<[aim_height]>]>]>
        - define distance <[bot].eye_location.distance[<[center]>]>
        - if <[distance]> > <[range]> || !<[bot].eye_location.line_of_sight[<[center]>]>:
            - foreach next
        - if <[distance]> < <[chosen_distance]>:
            - define chosen <[physical]>
            - define chosen_distance <[distance]>
    - determine <[chosen]>

lapex_arena_bot_fire_loop:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if <[bot].has_flag[lapex.arena_bot_firing]>:
        - stop
    - define token <util.random_uuid>
    - define phase <[bot].flag[lapex.arena_bot_fire_phase]||0.5>
    - define burst_min <script[lapex_arena_data].data_key[bot_tuning.burst_min_shots]||4>
    - define burst_max <script[lapex_arena_data].data_key[bot_tuning.burst_max_shots]||8>
    - define burst_remaining <util.random.int[<[burst_min]>].to[<[burst_max]>]>
    - flag <[bot]> lapex.arena_bot_firing:<[token]>
    - repeat 120:
        - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <[bot].flag[lapex.arena_bot_firing]||null> != <[token]> || <[bot].has_flag[lapex.arena_bot_melee]> || <[bot].has_flag[lapex.arena_bot_reaction]> || <[bot].has_flag[lapex.arena_bot_slide_token]>:
            - repeat stop
        - define target <[bot].flag[lapex.arena_bot_target]||null>
        - if <[target]> == null:
            - repeat stop
        - if !<[target].is_spawned||false>:
            - repeat stop
        - if <[target].health||0> <= 0:
            - repeat stop
        - define state_target <proc[lapex_legend_combat_player].context[<[target]>]||null>
        - if <[state_target]> == null || !<proc[lapex_arena_bot_available].context[<[state_target]>|<[session]>]> || <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - repeat stop
        - define target_location <[target].location>
        - define target_height <[target].height||1.8>
        - define aim_height <script[lapex_arena_data].data_key[bot_tuning.aim_height]||0.52>
        - define target_center <[target_location].above[<[target_height].mul[<[aim_height]>]>]>
        - if <[target_location].world> != <[bot].world> || !<[bot].eye_location.line_of_sight[<[target_center]>]>:
            - repeat stop
        - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
        - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]||null>
        - if <[weapon]> == null:
            - repeat stop
        - define ammo <[bot].flag[lapex.arena_bot_ammo]||0>
        - if <[ammo]> <= 0:
            - flag <[bot]> lapex.arena_bot_reloading
            - playsound <[bot].location> sound:item.armor.equip_iron pitch:1.35 volume:0.45
            - wait <[weapon].get[reload]||3s>
            - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.state]||none> != live || <[bot].flag[lapex.arena_bot_firing]||null> != <[token]>:
                - repeat stop
            - flag <[bot]> lapex.arena_bot_ammo:<[weapon].get[mag]>
            - flag <[bot]> lapex.arena_bot_reloading:!
            - repeat next
        - run lapex_arena_bot_fire_once def.bot:<[bot]> def.target:<[target]> def.session:<[session]>
        - define cadence <proc[lapex_weapon_cadence_step].context[<[weapon].get[rpm]>|<[phase]>]>
        - define phase <[cadence].get[phase]>
        - flag <[bot]> lapex.arena_bot_fire_phase:<[phase]> expire:30s
        - wait <[cadence].get[delay]>t
        - define burst_remaining <[burst_remaining].sub[1]>
        - if <[burst_remaining]> <= 0:
            - define pause_min <script[lapex_arena_data].data_key[bot_tuning.burst_pause_min_ticks]||6>
            - define pause_max <script[lapex_arena_data].data_key[bot_tuning.burst_pause_max_ticks]||13>
            - wait <util.random.int[<[pause_min]>].to[<[pause_max]>]>t
            - define burst_remaining <util.random.int[<[burst_min]>].to[<[burst_max]>]>
    - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_firing]||null> == <[token]>:
        - flag <[bot]> lapex.arena_bot_firing:!
        - flag <[bot]> lapex.arena_bot_reloading:!

# The actual ray may miss or strike an unintended actor. Damage and ally gates
# therefore apply to the ray result, not merely the bot's selected opponent.
lapex_arena_bot_fire_once:
    type: task
    debug: false
    definitions: bot|target|session
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - if <[target]||null> == null || !<[target].is_spawned||false>:
        - stop
    - if <[target].health||0> <= 0:
        - stop
    - define requested_target_location <[target].location>
    - define requested_target_height <[target].height||1.8>
    - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]||null>
    - if <[weapon]> == null || <[bot].flag[lapex.arena_bot_ammo]||0> <= 0:
        - stop
    - flag <[bot]> lapex.arena_bot_ammo:-:1
    - define eye <[bot].eye_location>
    - define aim_height <script[lapex_arena_data].data_key[bot_tuning.aim_height]||0.52>
    - define target_center <[requested_target_location].above[<[requested_target_height].mul[<[aim_height]>]>]>
    - define base_aim <[eye].face[<[target_center]>]>
    # A data-driven angular cone and per-bot error scale make close pressure
    # credible while long-range tracers visibly bracket rather than lock on.
    - define error_scale <[bot].flag[lapex.arena_bot_aim_error_scale]||1>
    - define yaw_limit <script[lapex_arena_data].data_key[bot_tuning.aim_yaw_error]||5.0>
    - define pitch_limit <script[lapex_arena_data].data_key[bot_tuning.aim_pitch_error]||3.6>
    - define yaw_error <util.random_decimal.sub[0.5].mul[2].mul[<[yaw_limit]>].mul[<[error_scale]>]>
    - define pitch_error <util.random_decimal.sub[0.5].mul[2].mul[<[pitch_limit]>].mul[<[error_scale]>]>
    - define aim <[base_aim].with_yaw[<[base_aim].yaw.add[<[yaw_error]>]>].with_pitch[<[base_aim].pitch.add[<[pitch_error]>]>]>
    - define range <[weapon].get[range]>
    - define raysize <[weapon].get[homing_raysize]||0.18>
    - define muzzle <[eye].forward[0.65]>
    - define hit <[aim].ray_trace_target[range=<[range]>;entities=living;ignore=<[bot]>;raysize=<[raysize]>]||null>
    - define impact <[aim].ray_trace[range=<[range]>;entities=living;ignore=<[bot]>;raysize=<[raysize]>;default=air]>
    - define dome_block <proc[lapex_dome_trace_intersection].context[<[eye]>|<[impact]>]||null>
    - if <[dome_block]> != null:
        - run lapex_weapon_render_tracer def.start:<[muzzle]> def.end:<[dome_block]> def.color:<[weapon].get[tracer]> def.style:standard
        - playeffect effect:electric_spark at:<[dome_block]> offset:0.15 quantity:6
        - playsound <[dome_block]> sound:item.shield.block pitch:1.4 volume:0.45
        - stop
    - run lapex_weapon_render_tracer def.start:<[muzzle]> def.end:<[impact]> def.color:<[weapon].get[tracer]> def.style:standard
    - playeffect effect:small_flame at:<[muzzle]> offset:0.025 quantity:2
    - playsound <[eye]> sound:item.crossbow.shoot pitch:<[weapon].get[sound_pitch]||1> volume:0.55
    - if <[hit]> == null:
        - stop
    # The selected actor can die to another queue between the ray command and
    # damage processing. Stop before any spawned-only property access.
    - if !<[hit].is_spawned||false>:
        - stop
    - if <[hit].health||0> <= 0:
        - stop
    - define hit_location <[hit].location>
    - define hit_height <[hit].height||1.8>
    - define state_target <proc[lapex_legend_combat_player].context[<[hit]>]||null>
    - define is_deployable <[hit].has_flag[lapex.deployable_kind]>
    - if <[state_target]> == null && !<[is_deployable]>:
        - stop
    # The intended target was session-checked during selection, but another
    # actor can cross the authoritative ray. Validate what was actually hit so
    # an outsider or outsider-owned device cannot take Arena bot damage.
    - if <[state_target]> != null:
        - if !<proc[lapex_arena_bot_available].context[<[state_target]>|<[session]>]>:
            - stop
    - else:
        - define deployable_owner <[hit].flag[lapex.deployable_owner]||null>
        - if <[deployable_owner]> == null || !<proc[lapex_arena_bot_available].context[<[deployable_owner]>|<[session]>]>:
            - stop
    - if <proc[lapex_legend_is_ally].context[<[bot]>|<[hit]>]>:
        - stop
    - if <[state_target]> != null:
        - if <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - playeffect effect:electric_spark at:<[impact]> offset:0.12 quantity:5
            - stop
    - define damage <[weapon].get[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
    - if !<[is_deployable]>:
        - define height_fraction <[impact].y.sub[<[hit_location].y>].div[<[hit_height]>]>
        - if <[height_fraction]> >= <script[lapex_weapon_data].data_key[head_zone]>:
            - define damage <[damage].mul[<[weapon].get[head_mult]>]>
        - else if <[height_fraction]> <= <script[lapex_weapon_data].data_key[leg_zone]>:
            - define damage <[damage].mul[<[weapon].get[leg_mult]>]>
    - define before_health <[state_target].health||0>
    - define before_absorption <[state_target].absorption_health||0>
    - define was_eliminated <[state_target].has_flag[lapex.arena_eliminated]||false>
    - if !<[hit].is_spawned||false>:
        - stop
    - if <[hit].health||0> <= 0:
        - stop
    - define old_velocity <[hit].velocity>
    - define old_no_damage <[hit].no_damage_duration||0s>
    - adjust <[hit]> no_damage_duration:0s
    - flag <[bot]> lapex.damage_transaction expire:2t
    - hurt <[damage]> <[hit]> cause:PROJECTILE source:<[bot]>
    - flag <[bot]> lapex.damage_transaction:!
    - if <[hit].is_spawned||false>:
        - adjust <[hit]> no_damage_duration:0s
        - adjust <[hit]> velocity:<[old_velocity]>
    # Crypto body damage is confirmed by its one-tick owner flush. Ordinary
    # combat actors can be measured synchronously here.
    - if <[state_target]> != null && !<[hit].has_flag[lapex.crypto_body_owner]>:
        - define after_health <[state_target].health||0>
        - define after_absorption <[state_target].absorption_health||0>
        - define accepted <proc[lapex_weapon_resolve_damage].context[<[before_health]>|<[before_absorption]>|<[after_health]>|<[after_absorption]>|<[was_eliminated]>|<[state_target].has_flag[lapex.arena_eliminated]>]>
        - define accepted_damage <[accepted].get[total]>
        - define remaining <[accepted].get[remaining]>
        - if <[accepted_damage]> > 0:
            - flag <[state_target]> lapex.last_attacker:<[bot]> expire:10s
            - flag <[state_target]> lapex.last_damage_location:<[impact]> expire:10s
            - flag <[state_target]> lapex.threatened_by:<[bot]> expire:4s
            - flag <[bot]> lapex.last_target:<[state_target]> expire:10s
            - define max_apex_health <[state_target].health_max.div[<script[lapex_weapon_data].data_key[damage_scale]||0.2>]||100>
            - if <[remaining].div[<[max_apex_health]>]> <= 0.4:
                - flag <[state_target]> lapex.low_health expire:6s
            - playeffect effect:crit at:<[impact]> offset:0.07 quantity:3
        - else if <[hit].is_spawned||false>:
            - adjust <[hit]> no_damage_duration:<[old_no_damage]>

# Static smoke: data and registry only, with no entity spawn or server flags.
lapex_arena_bots_smoke:
    type: task
    debug: false
    script:
    - define failures 0
    - foreach <list[red|blue]> as:team:
        - define spawns <script[lapex_arena_data].data_key[team_spawns.<[team]>]||<list>>
        - if <[spawns].size> != 5 || <[spawns].deduplicate.size> != 5:
            - narrate "<red>[Arena Bots] <[team]> needs five unique spawns."
            - define failures <[failures].add[1]>
        - define openings <script[lapex_arena_data].data_key[bot_opening_nodes.<[team]>]||<list>>
        - if <[openings].size> != 5:
            - narrate "<red>[Arena Bots] <[team]> needs one opening node for every spawn slot."
            - define failures <[failures].add[1]>
    - define nodes <script[lapex_arena_data].data_key[navigation_nodes]||<map>>
    - if <[nodes].size> < 20 || <script[lapex_arena_data].data_key[navigation_links].size||0> < 20:
        - narrate "<red>[Arena Bots] Navigation graph is too small."
        - define failures <[failures].add[1]>
    - define patrol_speed <script[lapex_arena_data].data_key[bot_tuning.patrol_speed]||0>
    - define chase_start <script[lapex_arena_data].data_key[bot_tuning.chase_start_distance]||0>
    - define chase_stop <script[lapex_arena_data].data_key[bot_tuning.chase_stop_distance]||0>
    - define forward_bias <script[lapex_arena_data].data_key[bot_tuning.forward_bias]||0>
    - define pursuit_bias <script[lapex_arena_data].data_key[bot_tuning.pursuit_bias]||0>
    - define aim_height <script[lapex_arena_data].data_key[bot_tuning.aim_height]||0>
    - define aim_yaw <script[lapex_arena_data].data_key[bot_tuning.aim_yaw_error]||0>
    - define aim_pitch <script[lapex_arena_data].data_key[bot_tuning.aim_pitch_error]||0>
    - define aim_scale_min <script[lapex_arena_data].data_key[bot_tuning.aim_error_scale_min]||0>
    - define aim_scale_max <script[lapex_arena_data].data_key[bot_tuning.aim_error_scale_max]||0>
    - define reaction_min <script[lapex_arena_data].data_key[bot_tuning.reaction_min_ticks]||0>
    - define reaction_max <script[lapex_arena_data].data_key[bot_tuning.reaction_max_ticks]||0>
    - define burst_min <script[lapex_arena_data].data_key[bot_tuning.burst_min_shots]||0>
    - define burst_max <script[lapex_arena_data].data_key[bot_tuning.burst_max_shots]||0>
    - define pause_min <script[lapex_arena_data].data_key[bot_tuning.burst_pause_min_ticks]||0>
    - define pause_max <script[lapex_arena_data].data_key[bot_tuning.burst_pause_max_ticks]||0>
    - define slide_chance <script[lapex_arena_data].data_key[bot_tuning.slide_chance]||0>
    - define slide_cooldown_min <script[lapex_arena_data].data_key[bot_tuning.slide_cooldown_min_ticks]||0>
    - define slide_cooldown_max <script[lapex_arena_data].data_key[bot_tuning.slide_cooldown_max_ticks]||0>
    - define slide_duration <script[lapex_arena_data].data_key[bot_tuning.slide_duration_ticks]||0>
    - define slide_start <script[lapex_arena_data].data_key[bot_tuning.slide_start_speed]||0>
    - define slide_end <script[lapex_arena_data].data_key[bot_tuning.slide_end_speed]||0>
    - define slide_probe <script[lapex_arena_data].data_key[bot_tuning.slide_probe_distance]||0>
    - define slide_goal <script[lapex_arena_data].data_key[bot_tuning.slide_min_goal_distance]||0>
    - define slide_spawn_clearance <script[lapex_arena_data].data_key[bot_tuning.slide_spawn_clearance_z]||0>
    - define slide_margin <script[lapex_arena_data].data_key[bot_tuning.slide_bounds_margin]||0>
    - if <[patrol_speed]> < 0.2 || <[patrol_speed]> > 0.22:
        - narrate "<red>[Arena Bots] Patrol speed must remain moderately below vanilla husk speed (0.20-0.22)."
        - define failures <[failures].add[1]>
    - if <[chase_stop]> < 4 || <[chase_start]> <= <[chase_stop]>:
        - narrate "<red>[Arena Bots] Chase distances need a valid stop/start hysteresis band."
        - define failures <[failures].add[1]>
    - if <[forward_bias]> < 0.5 || <[forward_bias]> > 1 || <[pursuit_bias]> < 0.5 || <[pursuit_bias]> > 1:
        - narrate "<red>[Arena Bots] Forward and pursuit navigation biases must stay between 0.5 and 1."
        - define failures <[failures].add[1]>
    - if <[aim_height]> < 0.4 || <[aim_height]> > 0.65 || <[aim_yaw]> < 3 || <[aim_pitch]> < 2 || <[aim_scale_min]> <= 0 || <[aim_scale_max]> < <[aim_scale_min]>:
        - narrate "<red>[Arena Bots] Aim height, error cone, or per-bot scale is outside its readable range."
        - define failures <[failures].add[1]>
    - if <[reaction_min]> <= 0 || <[reaction_max]> < <[reaction_min]> || <[burst_min]> <= 0 || <[burst_max]> < <[burst_min]> || <[pause_min]> <= 0 || <[pause_max]> < <[pause_min]>:
        - narrate "<red>[Arena Bots] Reaction and burst-pause ranges must be positive and ordered."
        - define failures <[failures].add[1]>
    - if <[slide_chance]> < 0.08 || <[slide_chance]> > 0.25 || <[slide_cooldown_min]> < 80 || <[slide_cooldown_max]> < <[slide_cooldown_min]> || <[slide_cooldown_max]> > 200:
        - narrate "<red>[Arena Bots] Slide chance or cooldown would make traversal absent or excessive."
        - define failures <[failures].add[1]>
    - if <[slide_duration]> < 4 || <[slide_duration]> > 10 || <[slide_start]> <= <[patrol_speed]> || <[slide_start]> > 0.38 || <[slide_end]> < 0.12 || <[slide_end]> > <[patrol_speed]>:
        - narrate "<red>[Arena Bots] Slide duration and decay must stay inside the short moderate-speed envelope."
        - define failures <[failures].add[1]>
    - if <[slide_probe]> < 0.75 || <[slide_probe]> > 2 || <[slide_goal]> < 6 || <[slide_spawn_clearance]> < 40 || <[slide_spawn_clearance]> > 48 || <[slide_margin]> < 4 || <[slide_margin]> > 12:
        - narrate "<red>[Arena Bots] Slide collision probe or minimum goal distance is unsafe."
        - define failures <[failures].add[1]>
    - foreach <list[red|blue]> as:team:
        - foreach <script[lapex_arena_data].data_key[bot_opening_nodes.<[team]>]||<list>> as:opening:
            - if !<[nodes].keys.contains[<[opening]>]>:
                - narrate "<red>[Arena Bots] Opening node is missing from the navigation graph: <[opening]>"
                - define failures <[failures].add[1]>
    - foreach <list[r301|flatline|volt|spitfire]> as:id:
        - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]||null>
        - if <[weapon]> == null || <[weapon].get[damage]||0> <= 0 || <[weapon].get[range]||0> <= 0 || <[weapon].get[rpm]||0> <= 0 || <[weapon].get[mag]||0> <= 0 || <[weapon].get[reload]||null> == null || <[weapon].get[tracer]||null> == null:
            - narrate "<red>[Arena Bots] Incomplete bot weapon registry entry: <[id]>"
            - define failures <[failures].add[1]>
    - foreach <list[lapex_arena_bot_reconcile|lapex_arena_native_spawn_husk|lapex_arena_bots_fill|lapex_arena_bots_cleanup|lapex_arena_bots_loop|lapex_arena_bot_enforce_ring|lapex_arena_bot_decide|lapex_arena_bot_track_movement|lapex_arena_bot_opening_watchdog|lapex_arena_bot_walk_safe|lapex_arena_bot_slide_path_clear|lapex_arena_bot_try_slide|lapex_arena_bot_choose_pursuit|lapex_arena_bot_choose_target|lapex_arena_bot_fire_loop|lapex_arena_bot_fire_once|lapex_weapon_cadence_step]> as:script_id:
        - if <script[<[script_id]>]||null> == null:
            - narrate "<red>[Arena Bots] Missing script: <[script_id]>"
            - define failures <[failures].add[1]>
    - if <[failures]> == 0:
        - narrate "<green>Arena bot smoke passed: 5v5 spawns, navigation graph, moderate movement, guarded slides, and four registry-backed loadouts."
    - else:
        - narrate "<red>Arena bot smoke failed with <[failures]> problem(s)."

# Opt-in integration smoke for a built local Foundry. It refuses to touch an
# existing match, proves real spawn egress before a controlled center fight,
# and owns complete rollback.
lapex_arena_bots_runtime_smoke:
    type: task
    debug: false
    script:
    - if <server.has_flag[lapex.arena.session]>:
        - narrate "<red>[Arena Bots] Runtime smoke refused: a match is active."
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - if <world[<[world_name]>]||null> == null || !<server.has_flag[lapex.arena_map.v1.complete]>:
        - narrate "<red>[Arena Bots] Runtime smoke needs a loaded, built Foundry."
        - stop
    - define session arena_smoke_<util.random_uuid>
    - flag server lapex.arena.session:<[session]>
    - flag server lapex.arena.state:live
    - flag server lapex.arena.round:1
    - flag server lapex.arena.players.red:<list>
    - flag server lapex.arena.players.blue:<list>
    - flag server lapex.arena.bots.red:<list>
    - flag server lapex.arena.bots.blue:<list>
    - flag server lapex.arena.bot_smoke_session:<[session]>
    - ~run lapex_arena_bots_fill def.session:<[session]>
    - define failures 0
    - foreach <list[red|blue]> as:team:
        - define roster <server.flag[lapex.arena.bots.<[team]>]||<list>>
        - if <[roster].size> != 5:
            - narrate "<red>[Arena Bots] Runtime <[team]> spawn count was <[roster].size>/5."
            - define failures <[failures].add[1]>
        - foreach <[roster]> as:bot:
            - flag <[bot]> lapex.arena_bot_smoke_spawn_origin:<[bot].location> expire:30s
    # This phase intentionally starts from the authored +/-62 pads. The old
    # smoke teleported directly to center and could pass while spawn pathing was
    # completely broken.
    - wait 14s
    - define egressed 0
    - define displaced 0
    - define recovered 0
    - define recovery_slots <list>
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if !<[bot].is_spawned||false>:
                - narrate "<red>[Arena Bots] <[team]> bot disappeared during spawn egress."
                - define failures <[failures].add[1]>
                - foreach next
            - define spawn_origin <[bot].flag[lapex.arena_bot_smoke_spawn_origin]||null>
            - if <[spawn_origin]> != null && <[bot].location.distance[<[spawn_origin]>]> >= 6:
                - define displaced <[displaced].add[1]>
            - if <[bot].has_flag[lapex.arena_bot_opening_recovered]>:
                - define recovered <[recovered].add[1]>
                - define recovery_slots <[recovery_slots].include[<[bot].flag[lapex.arena_bot_opening_recovery_slot]||unknown>]>
            - define escaped false
            - if <[team]> == red && <[bot].location.z> >= -50:
                - define escaped true
            - else if <[team]> == blue && <[bot].location.z> <= 50:
                - define escaped true
            - if <[escaped]>:
                - define egressed <[egressed].add[1]>
            - else:
                - define active_goal <[bot].flag[lapex.arena_bot_nav_goal]||null>
                - narrate "<red>[Arena Bots] <[team]> bot remained in spawn at x=<[bot].location.x.round>, z=<[bot].location.z.round>; goal=<[active_goal].simple||none>, locked=<[bot].has_flag[lapex.arena_bot_nav_lock]>, stalled=<[bot].has_flag[lapex.arena_bot_stationary]>."
                - define failures <[failures].add[1]>
    - if <[displaced]> < 10 || <[egressed]> < 10:
        - narrate "<red>[Arena Bots] Spawn egress was <[egressed]>/10; meaningful displacement was <[displaced]>/10."
        - define failures <[failures].add[1]>
    # Prove the velocity burst itself on the authored center floor. This bypasses
    # only the random chance; all floor, entity, boundary, state, distance, and
    # cooldown guards still run. The decision loop yields this one actor until
    # the measured slide finishes.
    - define slide_distance 0
    - define slide_bot <server.flag[lapex.arena.bots.red].first||null>
    - if <[slide_bot]> == null || !<[slide_bot].is_spawned||false>:
        - narrate "<red>[Arena Bots] Runtime slide test had no live actor."
        - define failures <[failures].add[1]>
    - else:
        - attack <[slide_bot]> cancel
        - walk <[slide_bot]> stop
        - foreach <list[controlled_target|melee|target|reaction|firing|reloading|stationary|slide_token|slide_cooldown]> as:state:
            - flag <[slide_bot]> lapex.arena_bot_<[state]>:!
        - teleport <[slide_bot]> <location[-12,64,0,<[world_name]>]>
        - adjust <[slide_bot]> velocity:<[slide_bot].velocity.with_x[0].with_y[0].with_z[0]>
        - flag <[slide_bot]> lapex.arena_bot_opening_complete
        - flag <[slide_bot]> lapex.arena_bot_moving
        - flag <[slide_bot]> lapex.arena_bot_smoke_slide_test
        - define slide_origin <[slide_bot].location>
        - ~run lapex_arena_bot_try_slide def.bot:<[slide_bot]> def.session:<[session]> def.goal:<location[0,64,0,<[world_name]>]> def.force:true
        - define slide_distance <[slide_bot].location.distance[<[slide_origin]>]>
        - flag <[slide_bot]> lapex.arena_bot_smoke_slide_test:!
        - flag <[slide_bot]> lapex.arena_bot_moving:!
        - adjust <[slide_bot]> velocity:<[slide_bot].velocity.with_x[0].with_y[0].with_z[0]>
        - if <[slide_distance]> < 1 || <[slide_distance]> > 3:
            - narrate "<red>[Arena Bots] Guarded slide traveled <[slide_distance].round_to[2]> blocks; expected 1-3."
            - define failures <[failures].add[1]>
    # Reset active navigation before arranging a short, symmetric engagement.
    # Ammo is restored here so firing proves the center phase, not a lucky
    # long-range shot during the egress phase.
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if !<[bot].is_spawned||false>:
                - foreach next
            - attack <[bot]> cancel
            - walk <[bot]> stop
            - flag <[bot]> lapex.arena_bot_controlled_target:!
            - flag <[bot]> lapex.arena_bot_melee:!
            - flag <[bot]> lapex.arena_bot_target:!
            - flag <[bot]> lapex.arena_bot_reaction:!
            - flag <[bot]> lapex.arena_bot_firing:!
            - flag <[bot]> lapex.arena_bot_reloading:!
            - flag <[bot]> lapex.arena_bot_nav_goal:!
            - flag <[bot]> lapex.arena_bot_nav_lock:!
            - flag <[bot]> lapex.arena_bot_moving:!
            - flag <[bot]> lapex.arena_bot_movement_check:!
            - flag <[bot]> lapex.arena_bot_slide_token:!
            - flag <[bot]> lapex.arena_bot_slide_cooldown:!
            - flag <[bot]> lapex.arena_bot_opening_complete
            - define z <[loop_index].mul[2].sub[6]>
            - if <[team]> == red:
                - define x -8
            - else:
                - define x 8
            - teleport <[bot]> <location[<[x]>,64,<[z]>,<[world_name]>]>
            - adjust <[bot]> health:20
            - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
            - flag <[bot]> lapex.arena_bot_ammo:<script[lapex_weapon_data].data_key[weapons.<[id]>.mag]>
            - flag <[bot]> lapex.arena_bot_smoke_combat_origin:<[bot].location> expire:10s
    - wait 2s
    - define fired 0
    - define damaged 0
    - define cross_team_targets 0
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if <[bot].is_spawned||false>:
                - define combat_origin <[bot].flag[lapex.arena_bot_smoke_combat_origin]||null>
                - if <[combat_origin]> != null && <[bot].location.distance[<[combat_origin]>]> > 3:
                    - narrate "<red>[Arena Bots] <[team]> bot moved too far during its firing hold: <[bot].location.distance[<[combat_origin]>].round_to[1]> blocks."
                    - define failures <[failures].add[1]>
                - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
                - define full_mag <script[lapex_weapon_data].data_key[weapons.<[id]>.mag]>
                - if <[bot].flag[lapex.arena_bot_ammo]||<[full_mag]>> < <[full_mag]>:
                    - define fired <[fired].add[1]>
                - define selected <[bot].flag[lapex.arena_bot_target]||null>
                - if <[selected]> != null && <[selected].flag[lapex.arena_bot_team]||null> != <[team]>:
                    - define cross_team_targets <[cross_team_targets].add[1]>
                - if <[bot].health||20> < 20:
                    - define damaged <[damaged].add[1]>
    - if <[fired]> == 0:
        - narrate "<red>[Arena Bots] Runtime smoke saw no registry-backed weapon fire."
        - define failures <[failures].add[1]>
    - if <[cross_team_targets]> == 0:
        - narrate "<red>[Arena Bots] Runtime smoke saw no cross-team target acquisition."
        - define failures <[failures].add[1]>
    - run lapex_arena_bots_cleanup def.session:<[session]>
    - flag server lapex.arena.session:!
    - flag server lapex.arena.state:!
    - flag server lapex.arena.round:!
    - flag server lapex.arena.players:!
    - flag server lapex.arena.bots:!
    - flag server lapex.arena.bot_smoke_session:!
    - if <[failures]> == 0:
        - define recovery_slot_text none
        - if !<[recovery_slots].is_empty>:
            - define recovery_slot_text <[recovery_slots].comma_separated>
        - narrate "<gray>[Arena Bots] Activity - <white><[egressed]>/10 escaped spawn<gray>, slide <white><[slide_distance].round_to[2]> blocks<gray>, <white><[recovered]> needed doorway recovery <dark_gray>(slots <[recovery_slot_text]>)<gray>, <white><[cross_team_targets]> acquired enemies<gray>, <white><[fired]> fired<gray>, <white><[damaged]> took damage<gray>."
        - narrate "<green>Arena bot runtime smoke passed: ten native bots left spawn, completed a guarded slide, acquired cross-team targets, held combat distance, and fired."
    - else:
        - narrate "<red>Arena bot runtime smoke failed with <[failures]> problem(s); rollback completed."
