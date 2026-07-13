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
    - hurt <[damage]> <[bot]> cause:WORLD_BORDER
    - adjust <[bot]> no_damage_duration:0s
    - playeffect effect:damage_indicator at:<[bot].location.above[1]> offset:0.25 quantity:3 visibility:96

lapex_arena_bot_decide:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]>:
        - stop
    - define target <proc[lapex_arena_bot_choose_target].context[<[bot]>|<[session]>]||null>
    - if <[target]> == null:
        - if <[bot].has_flag[lapex.arena_bot_melee]>:
            - attack <[bot]> cancel
            - flag <[bot]> lapex.arena_bot_melee:!
        - flag <[bot]> lapex.arena_bot_target:!
        - run lapex_arena_bot_navigate def.bot:<[bot]> def.session:<[session]>
        - stop
    - flag <[bot]> lapex.arena_bot_target:<[target]> expire:2s
    - define target_height <[target].height||1.8>
    - define target_center <[target].location.above[<[target_height].mul[0.65]>]>
    - look <[bot]> <[target_center]> duration:5t
    - define distance <[bot].location.distance[<[target].location>]>
    - if <[distance]> <= 2.6:
        - if !<[bot].has_flag[lapex.arena_bot_melee]>:
            - flag <[bot]> lapex.arena_bot_melee
            - attack <[bot]> target:<[target]>
        - stop
    - if <[bot].has_flag[lapex.arena_bot_melee]>:
        - attack <[bot]> cancel
        - flag <[bot]> lapex.arena_bot_melee:!
    # Pathing is an aid, not a firing dependency. If navigation stalls the bot
    # remains a stationary visible shooter instead of teleporting or freezing
    # its combat queue.
    - if <[distance]> > 14 && !<[bot].has_flag[lapex.arena_bot_stationary]>:
        - walk <[bot]> <[target].location> speed:1.05 lookat:<[target_center]>
        - flag <[bot]> lapex.arena_bot_moving expire:2s
        - run lapex_arena_bot_track_movement def.bot:<[bot]> def.session:<[session]>
    - else if <[distance]> < 7:
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_moving:!
    - if !<[bot].has_flag[lapex.arena_bot_firing]>:
        - run lapex_arena_bot_fire_loop def.bot:<[bot]> def.session:<[session]>

lapex_arena_bot_track_movement:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if <[bot].has_flag[lapex.arena_bot_movement_check]>:
        - stop
    - flag <[bot]> lapex.arena_bot_movement_check expire:24t
    - define origin <[bot].location>
    - wait 20t
    - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || !<[bot].has_flag[lapex.arena_bot_moving]>:
        - stop
    - if <[bot].location.distance[<[origin]>]> < 0.45:
        - walk <[bot]> stop
        - flag <[bot]> lapex.arena_bot_stationary expire:2s
        - flag <[bot]> lapex.arena_bot_moving:!

# With no visible enemy, follow one edge of the authored navigation graph. This
# keeps goals local and avoids expensive all-map paths for native mobs.
lapex_arena_bot_navigate:
    type: task
    debug: false
    definitions: bot|session
    script:
    - if <[bot].has_flag[lapex.arena_bot_nav_lock]> || <[bot].has_flag[lapex.arena_bot_stationary]>:
        - stop
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
    - if <[choices].is_empty>:
        - define next <[nearest]>
    - else:
        - define next <[choices].random>
    - define goal <location[<[nodes].get[<[next]>]>,<[world_name]>]>
    - flag <[bot]> lapex.arena_bot_nav_previous:<[nearest]>
    - flag <[bot]> lapex.arena_bot_nav_lock expire:2s
    - flag <[bot]> lapex.arena_bot_moving expire:2s
    - walk <[bot]> <[goal]> speed:1.1
    - run lapex_arena_bot_track_movement def.bot:<[bot]> def.session:<[session]>

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
        - define center <[physical].location.above[<[physical_height].mul[0.65]>]>
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
    - flag <[bot]> lapex.arena_bot_firing:<[token]>
    - repeat 120:
        - if !<proc[lapex_arena_bot_available].context[<[bot]>|<[session]>]> || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <[bot].flag[lapex.arena_bot_firing]||null> != <[token]> || <[bot].has_flag[lapex.arena_bot_melee]>:
            - repeat stop
        - define target <[bot].flag[lapex.arena_bot_target]||null>
        - if <[target]> == null:
            - repeat stop
        - define state_target <proc[lapex_legend_combat_player].context[<[target]>]||null>
        - if <[state_target]> == null || !<proc[lapex_arena_bot_available].context[<[state_target]>|<[session]>]> || <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - repeat stop
        - define target_height <[target].height||1.8>
        - define target_center <[target].location.above[<[target_height].mul[0.65]>]>
        - if <[target].world> != <[bot].world> || !<[bot].eye_location.line_of_sight[<[target_center]>]>:
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
        - define cadence <element[1200].div[<[weapon].get[rpm]>].round_up.max[1]>
        - wait <[cadence]>t
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
    - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]||null>
    - if <[weapon]> == null || <[bot].flag[lapex.arena_bot_ammo]||0> <= 0:
        - stop
    - flag <[bot]> lapex.arena_bot_ammo:-:1
    - define eye <[bot].eye_location>
    - define target_height <[target].height||1.8>
    - define target_center <[target].location.above[<[target_height].mul[0.65]>]>
    - define base_aim <[eye].face[<[target_center]>]>
    # A modest random cone lets bots pressure players without tracking like an
    # aimbot. Long shots naturally miss more often because the cone is angular.
    - define yaw_error <util.random_decimal.sub[0.5].mul[2.8]>
    - define pitch_error <util.random_decimal.sub[0.5].mul[2.2]>
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
    - define state_target <proc[lapex_legend_combat_player].context[<[hit]>]||null>
    - define is_deployable <[hit].has_flag[lapex.deployable_kind]>
    - if <[state_target]> == null && !<[is_deployable]>:
        - stop
    - if <proc[lapex_legend_is_ally].context[<[bot]>|<[hit]>]>:
        - stop
    - if <[state_target]> != null:
        - if <[state_target].has_flag[lapex.phased]> || <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.pylon_protected]>:
            - playeffect effect:electric_spark at:<[impact]> offset:0.12 quantity:5
            - stop
    - define damage <[weapon].get[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
    - if !<[is_deployable]>:
        - define height_fraction <[impact].y.sub[<[hit].location.y>].div[<[hit].height||1.8>]>
        - if <[height_fraction]> >= <script[lapex_weapon_data].data_key[head_zone]>:
            - define damage <[damage].mul[<[weapon].get[head_mult]>]>
        - else if <[height_fraction]> <= <script[lapex_weapon_data].data_key[leg_zone]>:
            - define damage <[damage].mul[<[weapon].get[leg_mult]>]>
    - define old_velocity <[hit].velocity>
    - hurt <[damage]> <[hit]> cause:PROJECTILE source:<[bot]>
    - adjust <[hit]> no_damage_duration:0s
    - adjust <[hit]> velocity:<[old_velocity]>
    - playeffect effect:crit at:<[impact]> offset:0.07 quantity:3

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
    - define nodes <script[lapex_arena_data].data_key[navigation_nodes]||<map>>
    - if <[nodes].size> < 20 || <script[lapex_arena_data].data_key[navigation_links].size||0> < 20:
        - narrate "<red>[Arena Bots] Navigation graph is too small."
        - define failures <[failures].add[1]>
    - foreach <list[r301|flatline|volt|spitfire]> as:id:
        - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]||null>
        - if <[weapon]> == null || <[weapon].get[damage]||0> <= 0 || <[weapon].get[range]||0> <= 0 || <[weapon].get[rpm]||0> <= 0 || <[weapon].get[mag]||0> <= 0 || <[weapon].get[reload]||null> == null || <[weapon].get[tracer]||null> == null:
            - narrate "<red>[Arena Bots] Incomplete bot weapon registry entry: <[id]>"
            - define failures <[failures].add[1]>
    - foreach <list[lapex_arena_bot_reconcile|lapex_arena_native_spawn_husk|lapex_arena_bots_fill|lapex_arena_bots_cleanup|lapex_arena_bots_loop|lapex_arena_bot_enforce_ring|lapex_arena_bot_decide|lapex_arena_bot_choose_target|lapex_arena_bot_fire_loop|lapex_arena_bot_fire_once]> as:script_id:
        - if <script[<[script_id]>]||null> == null:
            - narrate "<red>[Arena Bots] Missing script: <[script_id]>"
            - define failures <[failures].add[1]>
    - if <[failures]> == 0:
        - narrate "<green>Arena bot smoke passed: 5v5 spawns, navigation graph, and four registry-backed loadouts."
    - else:
        - narrate "<red>Arena bot smoke failed with <[failures]> problem(s)."

# Opt-in integration smoke for a built local Foundry. It refuses to touch an
# existing match, runs ten bots at center briefly, and owns complete rollback.
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
            - define z <[loop_index].mul[2].sub[6]>
            - if <[team]> == red:
                - define x -8
            - else:
                - define x 8
            - teleport <[bot]> <location[<[x]>,64,<[z]>,<[world_name]>]>
    - wait 1s
    - define fired 0
    - define damaged 0
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if <[bot].is_spawned||false>:
                - define id <[bot].flag[lapex.arena_bot_weapon]||r301>
                - define full_mag <script[lapex_weapon_data].data_key[weapons.<[id]>.mag]>
                - if <[bot].flag[lapex.arena_bot_ammo]||<[full_mag]>> < <[full_mag]>:
                    - define fired <[fired].add[1]>
                - if <[bot].health||20> < 20:
                    - define damaged <[damaged].add[1]>
    - if <[fired]> == 0:
        - narrate "<red>[Arena Bots] Runtime smoke saw no registry-backed weapon fire."
        - define failures <[failures].add[1]>
    - run lapex_arena_bots_cleanup def.session:<[session]>
    - flag server lapex.arena.session:!
    - flag server lapex.arena.state:!
    - flag server lapex.arena.round:!
    - flag server lapex.arena.players:!
    - flag server lapex.arena.bots:!
    - flag server lapex.arena.bot_smoke_session:!
    - if <[failures]> == 0:
        - narrate "<gray>[Arena Bots] Activity: <white><[fired]> fired<gray>, <white><[damaged]> took damage<gray>."
        - narrate "<green>Arena bot runtime smoke passed: ten native bots spawned, acquired targets, and fired."
    - else:
        - narrate "<red>Arena bot runtime smoke failed with <[failures]> problem(s); rollback completed."
