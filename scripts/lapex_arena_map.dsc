# Arena Foundry world lifecycle, admin command, resumable build, and validator.
# Geometry is isolated in lapex_arena_geometry.dsc; shared low-lag primitives
# remain in lapex_map_engine.dsc.

lapex_arena_map_events:
    type: world
    debug: false
    events:
        on server prestart:
        - createworld <script[lapex_arena_data].data_key[world]> generator:denizen:void environment:NORMAL generate_structures:false

        on server start:
        - wait 1t
        - run lapex_arena_setup

        on player breaks block:
        - if <context.location.world.name> == <script[lapex_arena_data].data_key[world]> && !<player.has_permission[lapex.arena.edit]>:
            - determine cancelled

        on player places block:
        - if <context.location.world.name> == <script[lapex_arena_data].data_key[world]> && !<player.has_permission[lapex.arena.edit]>:
            - determine cancelled

lapex_arena_map_command:
    type: command
    debug: false
    name: lapexarena
    description: Creates and manages the compact Lapex Arena Foundry map.
    usage: /lapexarena <&lt>create|build|status|tp|validate|rebuild<&gt> [option]
    permission: lapex.admin
    permission message: <red>You do not have permission to manage the Lapex arena.
    tab completions:
        1: create|build|status|tp|validate|rebuild
        2: staging|red|blue|center|west|east|force|confirm
    script:
    - define action <context.args.get[1]||status>
    - define world_name <script[lapex_arena_data].data_key[world]>
    - choose <[action]>:
        - case create:
            - if <world[<[world_name]>]||null> == null:
                - narrate "<yellow>Creating the Arena Foundry void world..."
                - ~createworld <[world_name]> generator:denizen:void environment:NORMAL generate_structures:false
            - run lapex_arena_setup
            - narrate "<green>Arena Foundry is loaded. Use <white>/lapexarena build<green>."
        - case build:
            - if <world[<[world_name]>]||null> == null:
                - narrate "<red>Create the world first with <white>/lapexarena create<red>."
                - stop
            - if !<script[lapex_arena_build].queues.is_empty>:
                - narrate "<red>An Arena Foundry build is already running."
                - stop
            - define force <context.args.get[2].equals_case_sensitive[force]||false>
            - run lapex_arena_build def.force:<[force]> id:lapex_arena_build
            - narrate "<green>Arena Foundry build started. Finished units will be resumed after interruptions."
        - case rebuild:
            - if <context.args.get[2]||null> != confirm:
                - narrate "<red>This repairs all authored arena geometry. Confirm with <white>/lapexarena rebuild confirm<red>."
                - stop
            - if !<script[lapex_arena_build].queues.is_empty>:
                - narrate "<red>An Arena Foundry build is already running."
                - stop
            - run lapex_arena_build def.force:true id:lapex_arena_build
            - narrate "<yellow>Full Arena Foundry repair started."
        - case status:
            - define finished 0
            - foreach <script[lapex_arena_data].data_key[build_units]> as:unit:
                - if <server.has_flag[lapex.arena_map.v1.units.<[unit]>]>:
                    - define finished <[finished].add[1]>
            - define total <script[lapex_arena_data].data_key[build_units].size>
            - narrate "<gold>Arena Foundry <gray>- units <white><[finished]>/<[total]><gray>, complete <white><server.has_flag[lapex.arena_map.v1.complete]><gray>, builder active <white><script[lapex_arena_build].queues.is_empty.not>."
        - case tp:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - if <world[<[world_name]>]||null> == null:
                - narrate "<red>Create the world first with <white>/lapexarena create<red>."
                - stop
            - define id <context.args.get[2]||staging>
            - define points <script[lapex_arena_data].data_key[teleport_points]>
            - if !<[points].keys.contains[<[id]>]>:
                - narrate "<red>Unknown destination. Use staging, red, blue, center, west, or east."
                - stop
            - teleport <player> <location[<[points].get[<[id]>]>,<[world_name]>]>
            - cast resistance duration:3s amplifier:4 <player> no_ambient hide_particles
        - case validate:
            - run lapex_arena_validate
        - default:
            - narrate "<gold>/lapexarena create <dark_gray>| <gold>/lapexarena build <white>[force]"
            - narrate "<gold>/lapexarena status <dark_gray>| <gold>/lapexarena tp <white><destination>"
            - narrate "<gold>/lapexarena validate <dark_gray>| <gold>/lapexarena rebuild <white>confirm"

lapex_arena_setup:
    type: task
    debug: false
    script:
    - define world_name <script[lapex_arena_data].data_key[world]>
    - define arena_world <world[<[world_name]>]||null>
    - if <[arena_world]> == null:
        - stop
    - define center <location[0,64,0,<[world_name]>]>
    - define staging <location[<script[lapex_arena_data].data_key[staging]>,<[world_name]>]>
    - worldborder <[arena_world]> center:<[center]> size:<script[lapex_arena_data].data_key[border_size]> warningdistance:8 damage:8 damagebuffer:0
    - adjust <[arena_world]> spawn_location:<[staging]>
    - gamerule <[arena_world]> mob_griefing false
    - gamerule <[arena_world]> spawn_mobs false
    - gamerule <[arena_world]> advance_weather false
    - gamerule <[arena_world]> advance_time false
    - weather sunny <[world_name]>
    - time 6000t <[world_name]>
    # A copied prebuilt world restores lightweight checkpoint flags from one
    # marker that is written only after every waited geometry unit succeeds.
    - define marker <location[<script[lapex_arena_data].data_key[completion_marker]>,<[world_name]>]>
    - chunkload <[marker].chunk> duration:1m
    - wait 1t
    - if !<server.has_flag[lapex.arena_map.v1.complete]> && <[marker].material.name> == sea_lantern:
        - flag server lapex.arena_map.v1.complete
        - foreach <script[lapex_arena_data].data_key[build_units]> as:unit:
            - flag server lapex.arena_map.v1.units.<[unit]>
    - chunkload remove <[marker].chunk>

lapex_arena_build:
    type: task
    debug: false
    definitions: force
    script:
    - define force <[force]||false>
    - define world_name <script[lapex_arena_data].data_key[world]>
    - if <world[<[world_name]>]||null> == null:
        - narrate "<red>[Lapex Arena] World is not loaded."
        - stop
    - if !<[force]> && <server.has_flag[lapex.arena_map.v1.complete]>:
        - narrate "<green>[Lapex Arena] Arena Foundry is already complete. Use <white>/lapexarena rebuild confirm<green> to repair it."
        - stop
    - if <[force]>:
        - flag server lapex.arena_map.v1.units:!
        - flag server lapex.arena_map.v1.complete:!
        - modifyblock <location[<script[lapex_arena_data].data_key[completion_marker]>,<[world_name]>]> air no_physics
    - run lapex_arena_setup
    - foreach <script[lapex_arena_data].data_key[build_units]> as:unit:
        - if !<[force]> && <server.has_flag[lapex.arena_map.v1.units.<[unit]>]>:
            - foreach next
        - narrate "<yellow>[Lapex Arena] Building <white><[unit].replace[_].with[ ]><yellow>..."
        - ~run lapex_arena_geometry_<[unit]> def.world:<[world_name]>
        - adjust <world[<[world_name]>]> save
        - flag server lapex.arena_map.v1.units.<[unit]>
    - ~modifyblock <location[<script[lapex_arena_data].data_key[completion_marker]>,<[world_name]>]> sea_lantern no_physics
    - adjust <world[<[world_name]>]> save
    - flag server lapex.arena_map.v1.complete
    - narrate "<green>[Lapex Arena] Arena Foundry build complete: three dense lanes, two elevations, ten spawns, and six mirrored loot points."

lapex_arena_validate:
    type: task
    debug: false
    script:
    - define failures 0
    - define world_name <script[lapex_arena_data].data_key[world]>
    - define arena_world <world[<[world_name]>]||null>
    - define units <script[lapex_arena_data].data_key[build_units]>
    - define red_spawns <script[lapex_arena_data].data_key[team_spawns.red]>
    - define blue_spawns <script[lapex_arena_data].data_key[team_spawns.blue]>
    - define loot <script[lapex_arena_data].data_key[supply_bin_anchors]>
    - if <[arena_world]> == null:
        - narrate "<red>[Lapex Arena] World is not loaded: <[world_name]>"
        - stop
    - if <[units].size> != 9:
        - narrate "<red>[Lapex Arena] Build unit registry size mismatch: <[units].size>/9"
        - define failures <[failures].add[1]>
    - if <[red_spawns].size> != 5 || <[blue_spawns].size> != 5:
        - narrate "<red>[Lapex Arena] Team spawn registry must contain exactly five locations per team."
        - define failures <[failures].add[1]>
    - define all_spawns <[red_spawns].include[<[blue_spawns]>]>
    - if <[all_spawns].deduplicate.size> != 10:
        - narrate "<red>[Lapex Arena] Team spawn locations are not unique."
        - define failures <[failures].add[1]>
    - if <[loot].size> != 6 || <[loot].deduplicate.size> != 6:
        - narrate "<red>[Lapex Arena] Supply-bin registry must contain six unique anchors."
        - define failures <[failures].add[1]>
    - foreach <script[lapex_arena_data].data_key[required_tasks]> as:task_id:
        - if <script[<[task_id]>]||null> == null:
            - narrate "<red>[Lapex Arena] Missing required task: <[task_id]>"
            - define failures <[failures].add[1]>
    - foreach <[all_spawns]> as:coordinates:
        - define spawn <location[<[coordinates]>,<[world_name]>]>
        - if <[spawn].x.abs> > 96 || <[spawn].z.abs> > 72:
            - narrate "<red>[Lapex Arena] Spawn outside authored bounds: <[coordinates]>"
            - define failures <[failures].add[1]>
        - if <server.has_flag[lapex.arena_map.v1.complete]>:
            - chunkload <[spawn].chunk> duration:1m
            - wait 1t
            - if !<[spawn].below[1].material.is_solid>:
                - narrate "<red>[Lapex Arena] Unsafe spawn floor: <[coordinates]>"
                - define failures <[failures].add[1]>
            - if <[spawn].material.is_solid> || <[spawn].above[1].material.is_solid>:
                - narrate "<red>[Lapex Arena] Obstructed spawn: <[coordinates]>"
                - define failures <[failures].add[1]>
            - chunkload remove <[spawn].chunk>
    - foreach <[loot]> as:coordinates:
        - define anchor <location[<[coordinates]>,<[world_name]>]>
        - if <[anchor].x.abs> > 96 || <[anchor].z.abs> > 72:
            - narrate "<red>[Lapex Arena] Loot anchor outside authored bounds: <[coordinates]>"
            - define failures <[failures].add[1]>
        - if <server.has_flag[lapex.arena_map.v1.complete]>:
            - chunkload <[anchor].chunk> duration:1m
            - wait 1t
            - if <[anchor].material.is_solid> || !<[anchor].below[1].material.is_solid>:
                - narrate "<red>[Lapex Arena] Blocked or unsupported loot anchor: <[coordinates]>"
                - define failures <[failures].add[1]>
            - chunkload remove <[anchor].chunk>
    - if <server.has_flag[lapex.arena_map.v1.complete]>:
        - foreach <[units]> as:unit:
            - define signature <script[lapex_arena_data].data_key[signature_checks.<[unit]>]>
            - define signature_location <location[<[signature].get[location]>,<[world_name]>]>
            - define expected <[signature].get[material]>
            - chunkload <[signature_location].chunk> duration:1m
            - wait 1t
            - if <[signature_location].material.name> != <[expected]>:
                - narrate "<red>[Lapex Arena] Missing unit signature: <[unit]> (expected <[expected]>, found <[signature_location].material.name>)"
                - define failures <[failures].add[1]>
            - chunkload remove <[signature_location].chunk>
        - define marker <location[<script[lapex_arena_data].data_key[completion_marker]>,<[world_name]>]>
        - chunkload <[marker].chunk> duration:1m
        - wait 1t
        - if <[marker].material.name> != sea_lantern:
            - narrate "<red>[Lapex Arena] Completion marker is missing."
            - define failures <[failures].add[1]>
        - chunkload remove <[marker].chunk>
    - if <[failures]> == 0 && <server.has_flag[lapex.arena_map.v1.complete]>:
        - narrate "<green>Lapex arena validation passed: 9 units, 10 unique spawns, 6 mirrored loot anchors, and all signatures present."
    - else if <[failures]> == 0:
        - narrate "<yellow>Lapex arena registry validation passed, but the geometry build is not complete."
    - else:
        - narrate "<red>Lapex arena validation failed with <[failures]> problem(s)."
