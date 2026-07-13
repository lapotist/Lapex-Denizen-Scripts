# Dense, deterministic geometry for Arena Foundry. Every public geometry task
# is one resumable build unit; helper tasks are intentionally stateless.

# Solid combat cover with a readable accent stripe. Width/depth are centered
# on the registry coordinate and all cover begins on the Y=64 combat surface.
lapex_arena_cover:
    type: task
    debug: false
    definitions: world|x|z|width|depth|height|material|accent
    script:
    - define half_width <[width].div[2].round_down>
    - define half_depth <[depth].div[2].round_down>
    - define x1 <[x].sub[<[half_width]>]>
    - define x2 <[x1].add[<[width]>].sub[1]>
    - define z1 <[z].sub[<[half_depth]>]>
    - define z2 <[z1].add[<[depth]>].sub[1]>
    - define y2 <element[64].add[<[height]>].sub[1]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:64 def.z1:<[z1]> def.x2:<[x2]> def.y2:<[y2]> def.z2:<[z2]> def.material:<[material]>
    - if <[height]> >= 2:
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:65 def.z1:<[z1]> def.x2:<[x2]> def.y2:65 def.z2:<[z1]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:<[y2]> def.z1:<[z2]> def.x2:<[x2]> def.y2:<[y2]> def.z2:<[z2]> def.material:polished_andesite

# Loot controllers spawn interactive containers in the air above these pads.
# Keeping the pad separate makes rebuilds safe while a match is not running.
lapex_arena_supply_pad:
    type: task
    debug: false
    definitions: world|x|z|accent
    script:
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:63 def.z1:<[z].sub[1]> def.x2:<[x].add[2]> def.y2:63 def.z2:<[z].add[1]> def.material:polished_andesite
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:63 def.z1:<[z].sub[1]> def.x2:<[x].sub[2]> def.y2:63 def.z2:<[z].add[1]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].add[2]> def.y1:63 def.z1:<[z].sub[1]> def.x2:<[x].add[2]> def.y2:63 def.z2:<[z].add[1]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x]> def.y1:63 def.z1:<[z]> def.x2:<[x]> def.y2:63 def.z2:<[z]> def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[1]> def.y1:64 def.z1:<[z].sub[1]> def.x2:<[x].add[1]> def.y2:66 def.z2:<[z].add[1]> def.material:air

lapex_arena_geometry_foundation:
    type: task
    debug: false
    definitions: world
    script:
    # A six-block slab prevents explosive holes from opening into the void.
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:58 def.z1:-72 def.x2:96 def.y2:62 def.z2:72 def.material:deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:63 def.z1:-72 def.x2:96 def.y2:63 def.z2:72 def.material:smooth_stone

    # Three floor palettes make lane calls readable without adding obstacles.
    - ~run lapex_map_box def.world:<[world]> def.x1:-92 def.y1:63 def.z1:-68 def.x2:-34 def.y2:63 def.z2:68 def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:-32 def.y1:63 def.z1:-68 def.x2:32 def.y2:63 def.z2:68 def.material:smooth_stone
    - ~run lapex_map_box def.world:<[world]> def.x1:34 def.y1:63 def.z1:-68 def.x2:92 def.y2:63 def.z2:68 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-34 def.y1:63 def.z1:-68 def.x2:-33 def.y2:63 def.z2:68 def.material:yellow_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:33 def.y1:63 def.z1:-68 def.x2:34 def.y2:63 def.z2:68 def.material:yellow_concrete

    # Thick foundry walls and corner buttresses bound the playable footprint.
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:63 def.z1:-72 def.x2:-93 def.y2:70 def.z2:72 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:93 def.y1:63 def.z1:-72 def.x2:96 def.y2:70 def.z2:72 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:63 def.z1:-72 def.x2:96 def.y2:70 def.z2:-69 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:63 def.z1:69 def.x2:96 def.y2:70 def.z2:72 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:-88 def.y1:68 def.z1:-72 def.x2:88 def.y2:68 def.z2:-69 def.material:red_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-88 def.y1:68 def.z1:69 def.x2:88 def.y2:68 def.z2:72 def.material:blue_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-96 def.y1:71 def.z1:-72 def.x2:-93 def.y2:71 def.z2:72 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:93 def.y1:71 def.z1:-72 def.x2:96 def.y2:71 def.z2:72 def.material:iron_bars

    # Recessed light rows divide rotations into short, countable segments.
    - foreach <list[-54|-36|-18|0|18|36|54]> as:z:
        - ~run lapex_map_box def.world:<[world]> def.x1:-30 def.y1:63 def.z1:<[z]> def.x2:-27 def.y2:63 def.z2:<[z]> def.material:sea_lantern
        - ~run lapex_map_box def.world:<[world]> def.x1:27 def.y1:63 def.z1:<[z]> def.x2:30 def.y2:63 def.z2:<[z]> def.material:sea_lantern
        - ~run lapex_map_box def.world:<[world]> def.x1:-92 def.y1:67 def.z1:<[z]> def.x2:-92 def.y2:68 def.z2:<[z].add[2]> def.material:cyan_stained_glass
        - ~run lapex_map_box def.world:<[world]> def.x1:92 def.y1:67 def.z1:<[z]> def.x2:92 def.y2:68 def.z2:<[z].add[2]> def.material:yellow_stained_glass

    # Four beacons give the small map a visible industrial skyline.
    - ~run lapex_map_tower def.world:<[world]> def.x:-86 def.y:64 def.z:-60 def.height:10 def.accent:red_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:86 def.y:64 def.z:-60 def.height:10 def.accent:red_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:-86 def.y:64 def.z:60 def.height:10 def.accent:blue_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:86 def.y:64 def.z:60 def.height:10 def.accent:blue_concrete

lapex_arena_geometry_spawn_north:
    type: task
    debug: false
    definitions: world
    script:
    - ~run lapex_arena_geometry_spawn_room def.world:<[world]> def.side:north def.accent:red_concrete

lapex_arena_geometry_spawn_south:
    type: task
    debug: false
    definitions: world
    script:
    - ~run lapex_arena_geometry_spawn_room def.world:<[world]> def.side:south def.accent:blue_concrete

lapex_arena_geometry_spawn_room:
    type: task
    debug: false
    definitions: world|side|accent
    script:
    - choose <[side]>:
        - case north:
            - define z1 -70
            - define z2 -51
            - define front -51
            - define pad_z -62
            - define blocker_z1 -48
            - define blocker_z2 -42
            - define wing_z1 -50
            - define wing_z2 -43
        - case south:
            - define z1 51
            - define z2 70
            - define front 51
            - define pad_z 62
            - define blocker_z1 42
            - define blocker_z2 48
            - define wing_z1 43
            - define wing_z2 50
        - default:
            - stop
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-45 def.y1:63 def.z1:<[z1]> def.x2:45 def.y2:71 def.z2:<[z2]> def.wall:polished_blackstone_bricks def.floor:polished_deepslate def.roof:black_concrete

    # Three exits split the opening push while the central machine denies a
    # direct spawn-to-spawn sightline.
    - ~run lapex_map_box def.world:<[world]> def.x1:-39 def.y1:64 def.z1:<[front]> def.x2:-29 def.y2:68 def.z2:<[front]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-5 def.y1:64 def.z1:<[front]> def.x2:5 def.y2:68 def.z2:<[front]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:29 def.y1:64 def.z1:<[front]> def.x2:39 def.y2:68 def.z2:<[front]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-13 def.y1:64 def.z1:<[blocker_z1]> def.x2:13 def.y2:70 def.z2:<[blocker_z2]> def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:-11 def.y1:66 def.z1:<[blocker_z1]> def.x2:11 def.y2:67 def.z2:<[blocker_z2]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:-25 def.y1:64 def.z1:<[wing_z1]> def.x2:-17 def.y2:67 def.z2:<[wing_z2]> def.material:stone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:17 def.y1:64 def.z1:<[wing_z1]> def.x2:25 def.y2:67 def.z2:<[wing_z2]> def.material:stone_bricks

    # Five pads are raised one block and have guaranteed two-block headroom.
    - foreach <list[-32|-16|0|16|32]> as:x:
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:64 def.z1:<[pad_z].sub[2]> def.x2:<[x].add[2]> def.y2:64 def.z2:<[pad_z].add[2]> def.material:<[accent]>
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[1]> def.y1:65 def.z1:<[pad_z].sub[1]> def.x2:<[x].add[1]> def.y2:67 def.z2:<[pad_z].add[1]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-43 def.y1:68 def.z1:<[z1]> def.x2:43 def.y2:68 def.z2:<[z1]> def.material:<[accent]>
    - ~run lapex_map_box def.world:<[world]> def.x1:-24 def.y1:71 def.z1:<[pad_z].sub[2]> def.x2:24 def.y2:71 def.z2:<[pad_z].add[2]> def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-43 def.y1:66 def.z1:<[pad_z].sub[3]> def.x2:-43 def.y2:68 def.z2:<[pad_z].add[3]> def.material:tinted_glass
    - ~run lapex_map_box def.world:<[world]> def.x1:43 def.y1:66 def.z1:<[pad_z].sub[3]> def.x2:43 def.y2:68 def.z2:<[pad_z].add[3]> def.material:tinted_glass

lapex_arena_geometry_center_foundry:
    type: task
    debug: false
    definitions: world
    script:
    # Four furnaces divide the lower level into short peeks while leaving a
    # complete north/south and east/west route beneath the upper deck.
    - ~run lapex_map_box def.world:<[world]> def.x1:-24 def.y1:64 def.z1:-17 def.x2:-16 def.y2:69 def.z2:-9 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:16 def.y1:64 def.z1:-17 def.x2:24 def.y2:69 def.z2:-9 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:-24 def.y1:64 def.z1:9 def.x2:-16 def.y2:69 def.z2:17 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:16 def.y1:64 def.z1:9 def.x2:24 def.y2:69 def.z2:17 def.material:polished_blackstone_bricks
    - foreach <list[-20|20]> as:x:
        - foreach <list[-13|13]> as:z:
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:65 def.z1:<[z].sub[2]> def.x2:<[x].add[2]> def.y2:66 def.z2:<[z].add[2]> def.material:orange_concrete
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[1]> def.y1:70 def.z1:<[z].sub[1]> def.x2:<[x].add[1]> def.y2:78 def.z2:<[z].add[1]> def.material:cut_copper
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x].sub[2]> def.y1:79 def.z1:<[z].sub[2]> def.x2:<[x].add[2]> def.y2:80 def.z2:<[z].add[2]> def.material:polished_andesite

    # The upper objective deck has four independent stair approaches.
    - ~run lapex_map_box def.world:<[world]> def.x1:-14 def.y1:70 def.z1:-10 def.x2:14 def.y2:70 def.z2:10 def.material:cut_copper
    - ~run lapex_map_box def.world:<[world]> def.x1:-14 def.y1:71 def.z1:-10 def.x2:14 def.y2:71 def.z2:-10 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-14 def.y1:71 def.z1:10 def.x2:14 def.y2:71 def.z2:10 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-14 def.y1:71 def.z1:-9 def.x2:-14 def.y2:71 def.z2:9 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:14 def.y1:71 def.z1:-9 def.x2:14 def.y2:71 def.z2:9 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-2 def.y1:71 def.z1:-10 def.x2:2 def.y2:72 def.z2:-10 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-2 def.y1:71 def.z1:10 def.x2:2 def.y2:72 def.z2:10 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-14 def.y1:71 def.z1:-2 def.x2:-14 def.y2:72 def.z2:2 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:14 def.y1:71 def.z1:-2 def.x2:14 def.y2:72 def.z2:2 def.material:air
    - ~run lapex_map_stair def.world:<[world]> def.x:0 def.y:64 def.z:-23 def.rise:6 def.direction:south def.width:5 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:0 def.y:64 def.z:23 def.rise:6 def.direction:north def.width:5 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:-27 def.y:64 def.z:0 def.rise:6 def.direction:east def.width:5 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:27 def.y:64 def.z:0 def.rise:6 def.direction:west def.width:5 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-1 def.y1:70 def.z1:-1 def.x2:1 def.y2:70 def.z2:1 def.material:copper_block

lapex_arena_geometry_west_tunnel:
    type: task
    debug: false
    definitions: world
    script:
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-92 def.y1:63 def.z1:-46 def.x2:-60 def.y2:70 def.z2:46 def.wall:stone_bricks def.floor:polished_deepslate def.roof:deepslate_tiles
    - ~run lapex_map_box def.world:<[world]> def.x1:-86 def.y1:64 def.z1:-46 def.x2:-66 def.y2:68 def.z2:-46 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-86 def.y1:64 def.z1:46 def.x2:-66 def.y2:68 def.z2:46 def.material:air
    - foreach <list[-32|0|32]> as:z:
        - ~run lapex_map_box def.world:<[world]> def.x1:-60 def.y1:64 def.z1:<[z].sub[5]> def.x2:-60 def.y2:68 def.z2:<[z].add[5]> def.material:air
        - ~run lapex_map_box def.world:<[world]> def.x1:-91 def.y1:69 def.z1:<[z].sub[4]> def.x2:-61 def.y2:69 def.z2:<[z].add[4]> def.material:iron_block
    # Parallel utility pipes identify the tunnel even from its open doors.
    - ~run lapex_map_box def.world:<[world]> def.x1:-89 def.y1:67 def.z1:-44 def.x2:-87 def.y2:68 def.z2:44 def.material:cut_copper
    - ~run lapex_map_box def.world:<[world]> def.x1:-65 def.y1:68 def.z1:-44 def.x2:-63 def.y2:69 def.z2:44 def.material:cyan_concrete
    - foreach <list[-40|-28|-16|-4|8|20|32|44]> as:z:
        - ~run lapex_map_box def.world:<[world]> def.x1:-86 def.y1:69 def.z1:<[z]> def.x2:-67 def.y2:69 def.z2:<[z].add[1]> def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-90 def.y1:68 def.z1:-1 def.x2:-90 def.y2:68 def.z2:1 def.material:cyan_concrete

lapex_arena_geometry_east_cargo:
    type: task
    debug: false
    definitions: world
    script:
    # The east lane stays mostly open at ground level; a boundary warehouse and
    # elevated gantry supply a second route without mirroring the tunnel theme.
    - ~run lapex_map_hollow def.world:<[world]> def.x1:84 def.y1:63 def.z1:-46 def.x2:92 def.y2:70 def.z2:46 def.wall:gray_concrete def.floor:smooth_stone def.roof:yellow_concrete
    - foreach <list[-34|-10|14|38]> as:z:
        - ~run lapex_map_box def.world:<[world]> def.x1:84 def.y1:64 def.z1:<[z].sub[4]> def.x2:84 def.y2:68 def.z2:<[z].add[4]> def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:79 def.y1:70 def.z1:-44 def.x2:90 def.y2:70 def.z2:44 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:79 def.y1:71 def.z1:-44 def.x2:79 def.y2:72 def.z2:44 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:90 def.y1:71 def.z1:-44 def.x2:90 def.y2:72 def.z2:44 def.material:iron_bars
    - foreach <list[-42|-24|-6|12|30|42]> as:z:
        - ~run lapex_map_box def.world:<[world]> def.x1:80 def.y1:64 def.z1:<[z]> def.x2:82 def.y2:69 def.z2:<[z].add[2]> def.material:yellow_concrete
    - ~run lapex_map_stair def.world:<[world]> def.x:82 def.y:64 def.z:-44 def.rise:6 def.direction:south def.width:3 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:82 def.y:64 def.z:44 def.rise:6 def.direction:north def.width:3 def.material:iron_block

    # Overhead crane, counterweight, and work lights frame the cargo lane.
    - ~run lapex_map_box def.world:<[world]> def.x1:44 def.y1:76 def.z1:-2 def.x2:90 def.y2:78 def.z2:2 def.material:yellow_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:46 def.y1:64 def.z1:-1 def.x2:48 def.y2:75 def.z2:1 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:64 def.y1:74 def.z1:-1 def.x2:70 def.y2:75 def.z2:1 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:88 def.y1:74 def.z1:-4 def.x2:91 def.y2:78 def.z2:4 def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:90 def.y1:68 def.z1:-1 def.x2:90 def.y2:68 def.z2:1 def.material:yellow_concrete

lapex_arena_geometry_crosslinks:
    type: task
    debug: false
    definitions: world
    script:
    # Two marked ground cross-routes prevent the three lanes from becoming
    # isolated corridors and keep rotations visible to both teams.
    - ~run lapex_map_box def.world:<[world]> def.x1:-59 def.y1:63 def.z1:-34 def.x2:78 def.y2:63 def.z2:-30 def.material:light_gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-59 def.y1:63 def.z1:30 def.x2:78 def.y2:63 def.z2:34 def.material:light_gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-59 def.y1:63 def.z1:-32 def.x2:78 def.y2:63 def.z2:-32 def.material:red_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-59 def.y1:63 def.z1:32 def.x2:78 def.y2:63 def.z2:32 def.material:blue_concrete

    # A continuous upper route joins the tunnel roof, objective deck, and east
    # gantry. Rail gaps every twelve blocks preserve climb and firing options.
    - ~run lapex_map_box def.world:<[world]> def.x1:-61 def.y1:70 def.z1:-2 def.x2:-15 def.y2:70 def.z2:2 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:15 def.y1:70 def.z1:-2 def.x2:82 def.y2:70 def.z2:2 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-13 def.y1:70 def.z1:-2 def.x2:13 def.y2:70 def.z2:-2 def.material:iron_block
    - foreach <list[-58|-46|-34|-22|22|34|46|58|70]> as:x:
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x]> def.y1:71 def.z1:-3 def.x2:<[x].add[5]> def.y2:71 def.z2:-3 def.material:iron_bars
        - ~run lapex_map_box def.world:<[world]> def.x1:<[x]> def.y1:71 def.z1:3 def.x2:<[x].add[5]> def.y2:71 def.z2:3 def.material:iron_bars
    - ~run lapex_map_stair def.world:<[world]> def.x:-58 def.y:64 def.z:-16 def.rise:6 def.direction:south def.width:3 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:58 def.y:64 def.z:16 def.rise:6 def.direction:north def.width:3 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-61 def.y1:64 def.z1:-5 def.x2:-60 def.y2:68 def.z2:5 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:0 def.y1:70 def.z1:-2 def.x2:0 def.y2:70 def.z2:-2 def.material:iron_block

lapex_arena_geometry_cover_and_loot:
    type: task
    debug: false
    definitions: world
    script:
    # West tunnel service lockers: alternating sides keep every peek short.
    - ~run lapex_arena_cover def:<[world]>|-82|-36|5|3|3|polished_deepslate|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-70|-24|5|3|3|stone_bricks|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-82|-12|5|3|3|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|-70|0|5|3|3|stone_bricks|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-82|12|5|3|3|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|-70|24|5|3|3|stone_bricks|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-82|36|5|3|3|polished_deepslate|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-52|-34|5|4|3|gray_concrete|red_concrete
    - ~run lapex_arena_cover def:<[world]>|-48|-18|4|5|3|polished_deepslate|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|-52|0|5|4|3|gray_concrete|cyan_concrete
    - ~run lapex_arena_cover def:<[world]>|-48|18|4|5|3|polished_deepslate|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|-52|34|5|4|3|gray_concrete|blue_concrete

    # Center cover is strictly mirrored across both axes for equal opening
    # timings. Taller pieces screen the stairs; low pieces support crouch peeks.
    - ~run lapex_arena_cover def:<[world]>|-20|-40|5|3|3|stone_bricks|red_concrete
    - ~run lapex_arena_cover def:<[world]>|20|-40|5|3|3|stone_bricks|red_concrete
    - ~run lapex_arena_cover def:<[world]>|-12|-26|4|4|2|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|12|-26|4|4|2|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|-22|-10|5|3|3|gray_concrete|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|22|-10|5|3|3|gray_concrete|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|-22|10|5|3|3|gray_concrete|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|22|10|5|3|3|gray_concrete|yellow_concrete
    - ~run lapex_arena_cover def:<[world]>|-12|26|4|4|2|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|12|26|4|4|2|polished_deepslate|orange_concrete
    - ~run lapex_arena_cover def:<[world]>|-20|40|5|3|3|stone_bricks|blue_concrete
    - ~run lapex_arena_cover def:<[world]>|20|40|5|3|3|stone_bricks|blue_concrete

    # East containers vary in footprint and color but retain mirrored combat
    # positions. They sit below the crane and alongside the gantry supports.
    - ~run lapex_arena_cover def:<[world]>|48|-38|7|4|4|red_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|62|-32|5|5|3|blue_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|78|-38|6|4|3|orange_concrete|black_concrete
    - ~run lapex_arena_cover def:<[world]>|52|-18|5|4|3|yellow_concrete|black_concrete
    - ~run lapex_arena_cover def:<[world]>|70|-12|7|3|3|cyan_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|84|0|5|4|3|orange_concrete|black_concrete
    - ~run lapex_arena_cover def:<[world]>|52|18|5|4|3|yellow_concrete|black_concrete
    - ~run lapex_arena_cover def:<[world]>|70|12|7|3|3|cyan_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|48|38|7|4|4|blue_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|62|32|5|5|3|red_concrete|white_concrete
    - ~run lapex_arena_cover def:<[world]>|78|38|6|4|3|orange_concrete|black_concrete

    # Six team-neutral pads are physically mirrored around Z=0.
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:-66 def.z:-26 def.accent:red_concrete
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:0 def.z:-32 def.accent:red_concrete
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:66 def.z:-26 def.accent:red_concrete
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:-66 def.z:26 def.accent:blue_concrete
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:0 def.z:32 def.accent:blue_concrete
    - ~run lapex_arena_supply_pad def.world:<[world]> def.x:66 def.z:26 def.accent:blue_concrete

lapex_arena_geometry_staging:
    type: task
    debug: false
    definitions: world
    script:
    # High glass floor gives spectators a readable whole-map view while an
    # enclosed lip prevents accidental drops during setup and team selection.
    - ~run lapex_map_box def.world:<[world]> def.x1:-18 def.y1:120 def.z1:-12 def.x2:18 def.y2:123 def.z2:12 def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:-17 def.y1:124 def.z1:-11 def.x2:17 def.y2:124 def.z2:11 def.material:tinted_glass
    - ~run lapex_map_box def.world:<[world]> def.x1:-18 def.y1:125 def.z1:-12 def.x2:18 def.y2:127 def.z2:-12 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-18 def.y1:125 def.z1:12 def.x2:18 def.y2:127 def.z2:12 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-18 def.y1:125 def.z1:-11 def.x2:-18 def.y2:127 def.z2:11 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:18 def.y1:125 def.z1:-11 def.x2:18 def.y2:127 def.z2:11 def.material:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-16 def.y1:124 def.z1:-10 def.x2:-2 def.y2:124 def.z2:-8 def.material:red_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:2 def.y1:124 def.z1:8 def.x2:16 def.y2:124 def.z2:10 def.material:blue_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-11 def.y1:125 def.z1:-1 def.x2:-9 def.y2:138 def.z2:1 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:9 def.y1:125 def.z1:-1 def.x2:11 def.y2:138 def.z2:1 def.material:polished_blackstone_bricks
    - ~run lapex_map_box def.world:<[world]> def.x1:-11 def.y1:137 def.z1:-1 def.x2:11 def.y2:138 def.z2:1 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-3 def.y1:137 def.z1:-1 def.x2:3 def.y2:138 def.z2:1 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-2 def.y1:125 def.z1:-2 def.x2:2 def.y2:128 def.z2:2 def.material:air
