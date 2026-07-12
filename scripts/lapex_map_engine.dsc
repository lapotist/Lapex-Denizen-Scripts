# Kings Canyon world bootstrap, admin controls, build orchestration, and shared
# construction primitives. Macro terrain and POIs live in separate files.

lapex_map_events:
    type: world
    debug: false
    events:
        on server prestart:
        - createworld <script[lapex_map_data].data_key[world]> generator:denizen:void environment:NORMAL generate_structures:false

        on server start:
        - wait 1t
        - run lapex_map_setup

        on player breaks block:
        - if <context.location.world.name> == <script[lapex_map_data].data_key[world]> && !<player.has_permission[lapex.map.edit]>:
            - determine cancelled

        on player places block:
        - if <context.location.world.name> == <script[lapex_map_data].data_key[world]> && !<player.has_permission[lapex.map.edit]>:
            - determine cancelled

lapex_map_command:
    type: command
    debug: false
    name: lapexmap
    description: Creates and manages the Lapex Kings Canyon arena.
    usage: /lapexmap <&lt>create|build|status|list|tp|validate|rebuild<&gt> [option]
    permission: lapex.admin
    permission message: <red>You do not have permission to manage the Lapex map.
    tab completions:
        1: create|build|status|list|tp|validate|rebuild
        2: <script[lapex_map_data].data_key[all_ids].include[staging|resume|force|confirm]>
    script:
    - define action <context.args.get[1]||status>
    - define world_name <script[lapex_map_data].data_key[world]>
    - choose <[action]>:
        - case create:
            - if <world[<[world_name]>]||null> == null:
                - narrate "<yellow>Creating the Kings Canyon void world..."
                - ~createworld <[world_name]> generator:denizen:void environment:NORMAL generate_structures:false
            - run lapex_map_setup
            - narrate "<green>Kings Canyon world is loaded. Use <white>/lapexmap build<green>."
        - case build:
            - if <world[<[world_name]>]||null> == null:
                - narrate "<red>Create the world first with <white>/lapexmap create<red>."
                - stop
            - if !<script[lapex_map_build].queues.is_empty>:
                - narrate "<red>A Kings Canyon build is already running."
                - stop
            - define force <context.args.get[2].equals_case_sensitive[force]||false>
            - run lapex_map_build def.force:<[force]> id:lapex_map_build
            - narrate "<green>Kings Canyon build started. Progress is checkpointed per terrain unit and POI."
        - case rebuild:
            - if <context.args.get[2]||null> != confirm:
                - narrate "<red>This repairs all generated geometry. Confirm with <white>/lapexmap rebuild confirm<red>."
                - stop
            - if !<script[lapex_map_build].queues.is_empty>:
                - narrate "<red>A Kings Canyon build is already running."
                - stop
            - run lapex_map_build def.force:true id:lapex_map_build
            - narrate "<yellow>Full Kings Canyon repair started."
        - case status:
            - define finished 0
            - foreach <script[lapex_map_data].data_key[all_ids]> as:id:
                - if <server.has_flag[lapex.map.v1.units.poi_<[id]>]>:
                    - define finished <[finished].add[1]>
            - narrate "<gold>Kings Canyon <gray>- POIs <white><[finished]>/17<gray>, complete <white><server.has_flag[lapex.map.v1.complete]><gray>, builder active <white><script[lapex_map_build].queues.is_empty.not>."
        - case list:
            - narrate "<gold><bold>Launch Kings Canyon <gray>- 17 named POIs"
            - foreach <script[lapex_map_data].data_key[all_ids]> as:id:
                - define poi <script[lapex_map_data].data_key[pois.<[id]>]>
                - narrate "<yellow><[poi].get[name]> <dark_gray>| <gray><[poi].get[region]> <dark_gray>- <white><[poi].get[signature]>"
        - case tp:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - define id <context.args.get[2]||staging>
            - if <[id]> == staging:
                - define coordinates <script[lapex_map_data].data_key[staging]>
            - else:
                - define poi <script[lapex_map_data].data_key[pois.<[id]>]||null>
                - if <[poi]> == null:
                    - narrate "<red>Unknown POI. Use <white>/lapexmap list<red>."
                    - stop
                - define coordinates <[poi].get[spawn]>
            - teleport <player> <location[<[coordinates]>,<[world_name]>]>
            - cast resistance duration:3s amplifier:4 <player> no_ambient hide_particles
        - case validate:
            - run lapex_map_validate
        - default:
            - narrate "<gold>/lapexmap create <dark_gray>| <gold>/lapexmap build <white>[force]"
            - narrate "<gold>/lapexmap status <dark_gray>| <gold>/lapexmap list <dark_gray>| <gold>/lapexmap tp <white><poi>"
            - narrate "<gold>/lapexmap validate <dark_gray>| <gold>/lapexmap rebuild <white>confirm"

lapex_map_setup:
    type: task
    debug: false
    script:
    - define world_name <script[lapex_map_data].data_key[world]>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> == null:
        - stop
    - define center <location[0,64,0,<[world_name]>]>
    - define staging <location[<script[lapex_map_data].data_key[staging]>,<[world_name]>]>
    - worldborder <[map_world]> center:<[center]> size:<script[lapex_map_data].data_key[border_size]> warningdistance:16 damage:4 damagebuffer:0
    - adjust <[map_world]> spawn_location:<[staging]>
    - gamerule <[map_world]> mob_griefing false
    - weather sunny <[world_name]>
    - time 6000t <[world_name]>
    # The top light in the staging beacon is written only after every POI.
    # It lets a copied, prebuilt world restore its lightweight server flags.
    - define completion_marker <location[0,176,0,<[world_name]>]>
    - chunkload <[completion_marker].chunk> duration:1m
    - wait 1t
    - if !<server.has_flag[lapex.map.v1.complete]> && <[completion_marker].material.name> == sea_lantern:
        - flag server lapex.map.v1.complete
        - foreach <script[lapex_map_data].data_key[all_ids]> as:id:
            - flag server lapex.map.v1.units.poi_<[id]>
    - chunkload remove <[completion_marker].chunk>

lapex_map_build:
    type: task
    debug: false
    definitions: force
    script:
    - define force <[force]||false>
    - define world_name <script[lapex_map_data].data_key[world]>
    - if <world[<[world_name]>]||null> == null:
        - narrate "<red>[Lapex Map] World is not loaded."
        - stop
    - if !<[force]> && <server.has_flag[lapex.map.v1.complete]>:
        - narrate "<green>[Lapex Map] This world is already complete. Use <white>/lapexmap rebuild confirm<green> to repair generated geometry."
        - stop
    - if <[force]>:
        - flag server lapex.map.v1.units:!
        - flag server lapex.map.v1.complete:!
        - modifyblock <location[0,176,0,<[world_name]>]> air no_physics
    - run lapex_map_setup
    - narrate "<yellow>[Lapex Map] Building terrain and river routes..."
    - ~run lapex_map_build_terrain def.world:<[world_name]> def.force:<[force]>
    - foreach <script[lapex_map_data].data_key[all_ids]> as:id:
        - if !<[force]> && <server.has_flag[lapex.map.v1.units.poi_<[id]>]>:
            - foreach next
        - narrate "<yellow>[Lapex Map] Building <white><script[lapex_map_data].data_key[pois.<[id]>.name]><yellow>..."
        - ~run lapex_map_poi_<[id]> def.world:<[world_name]>
        - ~run lapex_map_safe_spawn def.world:<[world_name]> def.coordinates:<script[lapex_map_data].data_key[pois.<[id]>.spawn]>
        - adjust <world[<[world_name]>]> save
        - flag server lapex.map.v1.units.poi_<[id]>
    - ~run lapex_map_staging def.world:<[world_name]>
    - ~run lapex_map_safe_spawn def.world:<[world_name]> def.coordinates:<script[lapex_map_data].data_key[staging]>
    - adjust <world[<[world_name]>]> save
    - flag server lapex.map.v1.complete
    - narrate "<green>[Lapex Map] Kings Canyon build complete: 17 POIs across a 640x640 combat island."

lapex_map_staging:
    type: task
    debug: false
    definitions: world
    script:
    - ~run lapex_map_disc def.world:<[world]> def.x:0 def.y:156 def.z:0 def.rx:18 def.ry:2 def.rz:18 def.material:polished_deepslate
    - ~run lapex_map_disc def.world:<[world]> def.x:0 def.y:158 def.z:0 def.rx:16 def.ry:1 def.rz:16 def.material:tinted_glass
    - ~run lapex_map_box def.world:<[world]> def.x1:-2 def.y1:159 def.z1:-2 def.x2:2 def.y2:159 def.z2:2 def.material:sea_lantern
    - ~run lapex_map_tower def.world:<[world]> def.x:0 def.y:159 def.z:0 def.height:15 def.accent:orange_concrete

# Every registry destination gets a small solid floor and two blocks of
# headroom after its landmark has been built.
lapex_map_safe_spawn:
    type: task
    debug: false
    definitions: world|coordinates
    script:
    - define spawn <location[<[coordinates]>,<[world]>]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[spawn].x.sub[1]> def.y1:<[spawn].y.sub[1]> def.z1:<[spawn].z.sub[1]> def.x2:<[spawn].x.add[1]> def.y2:<[spawn].y.sub[1]> def.z2:<[spawn].z.add[1]> def.material:polished_andesite
    - ~run lapex_map_box def.world:<[world]> def.x1:<[spawn].x.sub[1]> def.y1:<[spawn].y> def.z1:<[spawn].z.sub[1]> def.x2:<[spawn].x.add[1]> def.y2:<[spawn].y.add[1]> def.z2:<[spawn].z.add[1]> def.material:air

# A low-lag cuboid fill used by every deterministic structure primitive.
lapex_map_box:
    type: task
    debug: false
    definitions: world|x1|y1|z1|x2|y2|z2|material
    script:
    - define start <location[<[x1]>,<[y1]>,<[z1]>,<[world]>]>
    - define area <[start].to_cuboid[<location[<[x2]>,<[y2]>,<[z2]>,<[world]>]>]>
    - define chunks <[area].partial_chunks>
    - chunkload <[chunks]> duration:10m
    - ~modifyblock <[area]> <[material]> no_physics delayed max_delay_ms:<script[lapex_map_data].data_key[build_budget_ms]>
    - chunkload remove <[chunks]>

lapex_map_disc:
    type: task
    debug: false
    definitions: world|x|y|z|rx|ry|rz|material
    script:
    - define shape <location[<[x]>,<[y]>,<[z]>,<[world]>].to_ellipsoid[<[rx]>,<[ry]>,<[rz]>]>
    - define chunks <[shape].bounding_box.partial_chunks>
    - chunkload <[chunks]> duration:10m
    - ~modifyblock <[shape]> <[material]> no_physics delayed max_delay_ms:<script[lapex_map_data].data_key[build_budget_ms]>
    - chunkload remove <[chunks]>

lapex_map_hollow:
    type: task
    debug: false
    definitions: world|x1|y1|z1|x2|y2|z2|wall|floor|roof
    script:
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[y1]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[y2]> def.z2:<[z2]> def.material:<[wall]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1].add[1]> def.y1:<[y1].add[1]> def.z1:<[z1].add[1]> def.x2:<[x2].sub[1]> def.y2:<[y2].sub[1]> def.z2:<[z2].sub[1]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[y1]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[y1]> def.z2:<[z2]> def.material:<[floor]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[y2]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[y2]> def.z2:<[z2]> def.material:<[roof]>

lapex_map_hut:
    type: task
    debug: false
    definitions: world|x|y|z|width|height|depth|wall|roof
    script:
    - define half_w <[width].div[2].round_down>
    - define half_d <[depth].div[2].round_down>
    - define x1 <[x].sub[<[half_w]>]>
    - define x2 <[x1].add[<[width]>].sub[1]>
    - define z1 <[z].sub[<[half_d]>]>
    - define z2 <[z1].add[<[depth]>].sub[1]>
    - define y2 <[y].add[<[height]>].sub[1]>
    - ~run lapex_map_hollow def.world:<[world]> def.x1:<[x1]> def.y1:<[y]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[y2]> def.z2:<[z2]> def.wall:<[wall]> def.floor:spruce_planks def.roof:<[roof]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x]> def.y1:<[y].add[1]> def.z1:<[z1]> def.x2:<[x]> def.y2:<[y].add[3]> def.z2:<[z1]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[y].add[2]> def.z1:<[z]> def.x2:<[x1]> def.y2:<[y].add[3]> def.z2:<[z].add[1]> def.material:glass
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x2]> def.y1:<[y].add[2]> def.z1:<[z]> def.x2:<[x2]> def.y2:<[y].add[3]> def.z2:<[z].add[1]> def.material:glass
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1].sub[1]> def.y1:<[y2].add[1]> def.z1:<[z1].sub[1]> def.x2:<[x2].add[1]> def.y2:<[y2].add[1]> def.z2:<[z2].add[1]> def.material:<[roof]>

lapex_map_stilts:
    type: task
    debug: false
    definitions: world|x|y|z|width|depth|base_y|material
    script:
    - define half_w <[width].div[2].round_down>
    - define half_d <[depth].div[2].round_down>
    - define x1 <[x].sub[<[half_w]>]>
    - define x2 <[x1].add[<[width]>].sub[1]>
    - define z1 <[z].sub[<[half_d]>]>
    - define z2 <[z1].add[<[depth]>].sub[1]>
    - define support_top <[y].sub[1]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[base_y]> def.z1:<[z1]> def.x2:<[x1].add[1]> def.y2:<[support_top]> def.z2:<[z1].add[1]> def.material:<[material]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x2].sub[1]> def.y1:<[base_y]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[support_top]> def.z2:<[z1].add[1]> def.material:<[material]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[base_y]> def.z1:<[z2].sub[1]> def.x2:<[x1].add[1]> def.y2:<[support_top]> def.z2:<[z2]> def.material:<[material]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x2].sub[1]> def.y1:<[base_y]> def.z1:<[z2].sub[1]> def.x2:<[x2]> def.y2:<[support_top]> def.z2:<[z2]> def.material:<[material]>

lapex_map_tower:
    type: task
    debug: false
    definitions: world|x|y|z|height|accent
    script:
    - define top <[y].add[<[height]>]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[3]> def.y1:<[y]> def.z1:<[z].sub[3]> def.x2:<[x].add[3]> def.y2:<[y].add[1]> def.z2:<[z].add[3]> def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[1]> def.y1:<[y].add[2]> def.z1:<[z].sub[1]> def.x2:<[x].add[1]> def.y2:<[top]> def.z2:<[z].add[1]> def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[4]> def.y1:<[top]> def.z1:<[z].sub[4]> def.x2:<[x].add[4]> def.y2:<[top].add[1]> def.z2:<[z].add[4]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:<[top].add[2]> def.z1:<[z].sub[2]> def.x2:<[x].add[2]> def.y2:<[top].add[4]> def.z2:<[z].add[2]> def.material:sea_lantern

lapex_map_pool:
    type: task
    debug: false
    definitions: world|x|y|z|rx|rz
    script:
    - ~run lapex_map_disc def.world:<[world]> def.x:<[x]> def.y:<[y]> def.z:<[z]> def.rx:<[rx]> def.ry:2 def.rz:<[rz]> def.material:smooth_stone
    - ~run lapex_map_disc def.world:<[world]> def.x:<[x]> def.y:<[y].add[1]> def.z:<[z]> def.rx:<[rx].sub[2]> def.ry:1 def.rz:<[rz].sub[2]> def.material:water

lapex_map_road:
    type: task
    debug: false
    definitions: world|x1|y1|z1|x2|y2|z2|width|material
    script:
    - define start <location[<[x1]>,<[y1]>,<[z1]>,<[world]>]>
    - define end <location[<[x2]>,<[y2]>,<[z2]>,<[world]>]>
    - define route <[start].points_between[<[end]>].distance[2]>
    # Width is a radius, so the finished path is up to (2 * width + 1)
    # blocks across. Expand the ticket cuboid to cover delayed edge edits.
    - define ticket_x1 <[x1].min[<[x2]>].sub[<[width]>]>
    - define ticket_x2 <[x1].max[<[x2]>].add[<[width]>]>
    - define ticket_y1 <[y1].min[<[y2]>].sub[1]>
    - define ticket_y2 <[y1].max[<[y2]>].add[1]>
    - define ticket_z1 <[z1].min[<[z2]>].sub[<[width]>]>
    - define ticket_z2 <[z1].max[<[z2]>].add[<[width]>]>
    - define ticket_start <location[<[ticket_x1]>,<[ticket_y1]>,<[ticket_z1]>,<[world]>]>
    - define ticket_end <location[<[ticket_x2]>,<[ticket_y2]>,<[ticket_z2]>,<[world]>]>
    - define chunks <[ticket_start].to_cuboid[<[ticket_end]>].partial_chunks>
    - chunkload <[chunks]> duration:10m
    - ~modifyblock <[route]> <[material]> radius:<[width]> height:0 depth:0 no_physics delayed max_delay_ms:<script[lapex_map_data].data_key[build_budget_ms]>
    - chunkload remove <[chunks]>

# Cardinal stair runs use two blocks of horizontal travel per one-block rise,
# with exact cuboids and headroom so every elevated POI route is walkable.
lapex_map_stair:
    type: task
    debug: false
    definitions: world|x|y|z|rise|direction|width|material
    script:
    - define half_width <[width].div[2].round_down>
    - repeat <[rise].add[1]> as:step_number:
        - define step <[step_number].sub[1]>
        - define offset <[step].mul[2]>
        - define step_y <[y].add[<[step]>]>
        - choose <[direction]>:
            - case east:
                - define x1 <[x].add[<[offset]>]>
                - define x2 <[x1].add[1]>
                - define z1 <[z].sub[<[half_width]>]>
                - define z2 <[z1].add[<[width]>].sub[1]>
            - case west:
                - define x2 <[x].sub[<[offset]>]>
                - define x1 <[x2].sub[1]>
                - define z1 <[z].sub[<[half_width]>]>
                - define z2 <[z1].add[<[width]>].sub[1]>
            - case south:
                - define z1 <[z].add[<[offset]>]>
                - define z2 <[z1].add[1]>
                - define x1 <[x].sub[<[half_width]>]>
                - define x2 <[x1].add[<[width]>].sub[1]>
            - case north:
                - define z2 <[z].sub[<[offset]>]>
                - define z1 <[z2].sub[1]>
                - define x1 <[x].sub[<[half_width]>]>
                - define x2 <[x1].add[<[width]>].sub[1]>
            - default:
                - stop
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[step_y].add[1]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[step_y].add[2]> def.z2:<[z2]> def.material:air
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[step_y]> def.z1:<[z1]> def.x2:<[x2]> def.y2:<[step_y]> def.z2:<[z2]> def.material:<[material]>

lapex_map_validate:
    type: task
    debug: false
    script:
    - define failures 0
    - define world_name <script[lapex_map_data].data_key[world]>
    - define ids <script[lapex_map_data].data_key[all_ids]>
    - define registry <script[lapex_map_data].data_key[pois]>
    - if <world[<[world_name]>]||null> == null:
        - narrate "<red>[Lapex Map] World is not loaded: <[world_name]>"
        - stop
    - if <[ids].size> != 17 || <[registry].size> != 17:
        - narrate "<red>[Lapex Map] POI registry size mismatch: <[ids].size>/<[registry].size>"
        - define failures <[failures].add[1]>
    - foreach <script[lapex_map_data].data_key[required_tasks]> as:task_id:
        - if <script[<[task_id]>]||null> == null:
            - narrate "<red>[Lapex Map] Missing required task: <[task_id]>"
            - define failures <[failures].add[1]>
    - foreach <[ids]> as:id:
        - define poi <[registry].get[<[id]>]||null>
        - if <[poi]> == null:
            - narrate "<red>[Lapex Map] Missing POI data: <[id]>"
            - define failures <[failures].add[1]>
            - foreach next
        - if <script[lapex_map_poi_<[id]>]||null> == null:
            - narrate "<red>[Lapex Map] Missing POI task: <[id]>"
            - define failures <[failures].add[1]>
        - define spawn <location[<[poi].get[spawn]>,<[world_name]>]>
        - if <[spawn].x.abs> > 310 || <[spawn].z.abs> > 310:
            - narrate "<red>[Lapex Map] POI outside border: <[id]>"
            - define failures <[failures].add[1]>
        - if <server.has_flag[lapex.map.v1.complete]>:
            - define signature <script[lapex_map_data].data_key[signature_checks.<[id]>]>
            - define signature_location <location[<[signature].get[location]>,<[world_name]>]>
            - define expected_material <[signature].get[material]>
            - chunkload <[spawn].chunk> duration:1m
            - chunkload <[signature_location].chunk> duration:1m
            - wait 1t
            - if !<[spawn].below[1].material.is_solid>:
                - narrate "<red>[Lapex Map] Unsafe POI spawn floor: <[id]>"
                - define failures <[failures].add[1]>
            - if <[spawn].material.is_solid> || <[spawn].above[1].material.is_solid>:
                - narrate "<red>[Lapex Map] Obstructed POI spawn: <[id]>"
                - define failures <[failures].add[1]>
            - if <[signature_location].material.name> != <[expected_material]>:
                - narrate "<red>[Lapex Map] Missing landmark signature: <[id]> (expected <[expected_material]>, found <[signature_location].material.name>)"
                - define failures <[failures].add[1]>
            - chunkload remove <[spawn].chunk>
            - chunkload remove <[signature_location].chunk>
    - if <[failures]> == 0:
        - narrate "<green>Lapex map validation passed: 17 POIs, 640x640 border, and all build tasks resolved."
    - else:
        - narrate "<red>Lapex map validation failed with <[failures]> problem(s)."
