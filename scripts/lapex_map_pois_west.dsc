# Launch-era Kings Canyon landmarks across the western, northern, and central
# half of the island. Coordinates assume a 640-block map centered on 0,0.

lapex_map_poi_slum_lakes:
    type: task
    debug: false
    definitions: world
    script:
    # A flooded shack basin divided by the original twin-pipe trench.
    - ~run lapex_map_pool def.world:<[world]> def.x:-205 def.y:58 def.z:-160 def.rx:47 def.rz:28
    - ~run lapex_map_pool def.world:<[world]> def.x:-164 def.y:59 def.z:-151 def.rx:19 def.rz:14
    - ~run lapex_map_box def.world:<[world]> def.x1:-248 def.y1:59 def.z1:-164 def.x2:-154 def.y2:61 def.z2:-151 def.material:mud
    - ~run lapex_map_box def.world:<[world]> def.x1:-244 def.y1:62 def.z1:-162 def.x2:-158 def.y2:64 def.z2:-160 def.material:polished_deepslate
    - ~run lapex_map_box def.world:<[world]> def.x1:-244 def.y1:62 def.z1:-155 def.x2:-158 def.y2:64 def.z2:-153 def.material:polished_deepslate
    - ~run lapex_map_road def.world:<[world]> def.x1:-229 def.y1:65 def.z1:-179 def.x2:-229 def.y2:65 def.z2:-137 def.width:3 def.material:spruce_planks
    - ~run lapex_map_road def.world:<[world]> def.x1:-187 def.y1:65 def.z1:-179 def.x2:-187 def.y2:65 def.z2:-136 def.width:3 def.material:spruce_planks
    - ~run lapex_map_box def.world:<[world]> def.x1:-230 def.y1:58 def.z1:-177 def.x2:-228 def.y2:64 def.z2:-175 def.material:dark_oak_log
    - ~run lapex_map_box def.world:<[world]> def.x1:-230 def.y1:58 def.z1:-160 def.x2:-228 def.y2:64 def.z2:-158 def.material:dark_oak_log
    - ~run lapex_map_box def.world:<[world]> def.x1:-230 def.y1:58 def.z1:-142 def.x2:-228 def.y2:64 def.z2:-140 def.material:dark_oak_log
    - ~run lapex_map_box def.world:<[world]> def.x1:-188 def.y1:58 def.z1:-177 def.x2:-186 def.y2:64 def.z2:-175 def.material:dark_oak_log
    - ~run lapex_map_box def.world:<[world]> def.x1:-188 def.y1:58 def.z1:-160 def.x2:-186 def.y2:64 def.z2:-158 def.material:dark_oak_log
    - ~run lapex_map_box def.world:<[world]> def.x1:-188 def.y1:58 def.z1:-142 def.x2:-186 def.y2:64 def.z2:-140 def.material:dark_oak_log
    - ~run lapex_map_stilts def.world:<[world]> def.x:-235 def.y:64 def.z:-181 def.width:10 def.depth:8 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-235 def.y:64 def.z:-181 def.width:10 def.height:7 def.depth:8 def.wall:dark_oak_planks def.roof:deepslate_tiles
    - ~run lapex_map_stilts def.world:<[world]> def.x:-215 def.y:64 def.z:-184 def.width:9 def.depth:8 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-215 def.y:64 def.z:-184 def.width:9 def.height:6 def.depth:8 def.wall:spruce_planks def.roof:dark_oak_slab
    - ~run lapex_map_stilts def.world:<[world]> def.x:-192 def.y:64 def.z:-181 def.width:11 def.depth:9 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-192 def.y:64 def.z:-181 def.width:11 def.height:7 def.depth:9 def.wall:dark_oak_planks def.roof:deepslate_tiles
    - ~run lapex_map_stilts def.world:<[world]> def.x:-169 def.y:64 def.z:-176 def.width:9 def.depth:8 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-169 def.y:64 def.z:-176 def.width:9 def.height:6 def.depth:8 def.wall:spruce_planks def.roof:dark_oak_slab
    - ~run lapex_map_stilts def.world:<[world]> def.x:-239 def.y:64 def.z:-137 def.width:10 def.depth:9 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-239 def.y:64 def.z:-137 def.width:10 def.height:7 def.depth:9 def.wall:spruce_planks def.roof:deepslate_tiles
    - ~run lapex_map_stilts def.world:<[world]> def.x:-215 def.y:64 def.z:-135 def.width:8 def.depth:8 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-215 def.y:64 def.z:-135 def.width:8 def.height:6 def.depth:8 def.wall:dark_oak_planks def.roof:dark_oak_slab
    - ~run lapex_map_stilts def.world:<[world]> def.x:-193 def.y:64 def.z:-137 def.width:10 def.depth:9 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-193 def.y:64 def.z:-137 def.width:10 def.height:7 def.depth:9 def.wall:spruce_planks def.roof:deepslate_tiles
    - ~run lapex_map_stilts def.world:<[world]> def.x:-166 def.y:64 def.z:-132 def.width:11 def.depth:8 def.base_y:58 def.material:dark_oak_log
    - ~run lapex_map_hut def.world:<[world]> def.x:-166 def.y:64 def.z:-132 def.width:11 def.height:7 def.depth:8 def.wall:dark_oak_planks def.roof:dark_oak_slab
    - ~run lapex_map_tower def.world:<[world]> def.x:-151 def.y:64 def.z:-172 def.height:18 def.accent:orange_concrete

lapex_map_poi_runoff:
    type: task
    debug: false
    definitions: world
    script:
    # Three bridged treatment blocks and exposed settling tanks.
    - ~run lapex_map_box def.world:<[world]> def.x1:-278 def.y1:62 def.z1:-86 def.x2:-181 def.y2:64 def.z2:-17 def.material:polished_andesite
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-271 def.y1:64 def.z1:-76 def.x2:-251 def.y2:79 def.z2:-30 def.wall:gray_concrete def.floor:smooth_stone def.roof:light_gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-239 def.y1:64 def.z1:-76 def.x2:-218 def.y2:79 def.z2:-30 def.wall:gray_concrete def.floor:smooth_stone def.roof:light_gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-206 def.y1:64 def.z1:-67 def.x2:-187 def.y2:78 def.z2:-30 def.wall:gray_concrete def.floor:smooth_stone def.roof:light_gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-272 def.y1:66 def.z1:-57 def.x2:-268 def.y2:71 def.z2:-49 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-240 def.y1:66 def.z1:-57 def.x2:-236 def.y2:71 def.z2:-49 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-207 def.y1:66 def.z1:-54 def.x2:-203 def.y2:71 def.z2:-46 def.material:air
    - ~run lapex_map_road def.world:<[world]> def.x1:-251 def.y1:73 def.z1:-53 def.x2:-239 def.y2:73 def.z2:-53 def.width:4 def.material:iron_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-218 def.y1:73 def.z1:-50 def.x2:-206 def.y2:73 def.z2:-50 def.width:4 def.material:iron_block
    - ~run lapex_map_disc def.world:<[world]> def.x:-260 def.y:66 def.z:-20 def.rx:13 def.ry:3 def.rz:13 def.material:light_gray_concrete
    - ~run lapex_map_disc def.world:<[world]> def.x:-260 def.y:69 def.z:-20 def.rx:9 def.ry:1 def.rz:9 def.material:water
    - ~run lapex_map_disc def.world:<[world]> def.x:-226 def.y:66 def.z:-20 def.rx:13 def.ry:3 def.rz:13 def.material:light_gray_concrete
    - ~run lapex_map_disc def.world:<[world]> def.x:-226 def.y:69 def.z:-20 def.rx:9 def.ry:1 def.rz:9 def.material:water
    - ~run lapex_map_tower def.world:<[world]> def.x:-188 def.y:64 def.z:-78 def.height:22 def.accent:yellow_concrete

lapex_map_poi_airbase:
    type: task
    debug: false
    definitions: world
    script:
    # Twin sea runways terminate at an enclosed hangar apron.
    - ~run lapex_map_road def.world:<[world]> def.x1:-306 def.y1:58 def.z1:20 def.x2:-218 def.y2:58 def.z2:20 def.width:13 def.material:light_gray_concrete
    - ~run lapex_map_road def.world:<[world]> def.x1:-306 def.y1:58 def.z1:57 def.x2:-218 def.y2:58 def.z2:57 def.width:13 def.material:light_gray_concrete
    - ~run lapex_map_road def.world:<[world]> def.x1:-218 def.y1:59 def.z1:4 def.x2:-218 def.y2:59 def.z2:74 def.width:7 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-306 def.y1:59 def.z1:19 def.x2:-292 def.y2:59 def.z2:21 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-280 def.y1:59 def.z1:19 def.x2:-266 def.y2:59 def.z2:21 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-254 def.y1:59 def.z1:19 def.x2:-240 def.y2:59 def.z2:21 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-306 def.y1:59 def.z1:56 def.x2:-292 def.y2:59 def.z2:58 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-280 def.y1:59 def.z1:56 def.x2:-266 def.y2:59 def.z2:58 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-254 def.y1:59 def.z1:56 def.x2:-240 def.y2:59 def.z2:58 def.material:white_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-302 def.y1:53 def.z1:18 def.x2:-298 def.y2:57 def.z2:22 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-277 def.y1:53 def.z1:18 def.x2:-273 def.y2:57 def.z2:22 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-252 def.y1:53 def.z1:18 def.x2:-248 def.y2:57 def.z2:22 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-227 def.y1:53 def.z1:18 def.x2:-223 def.y2:57 def.z2:22 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-302 def.y1:53 def.z1:55 def.x2:-298 def.y2:57 def.z2:59 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-277 def.y1:53 def.z1:55 def.x2:-273 def.y2:57 def.z2:59 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-252 def.y1:53 def.z1:55 def.x2:-248 def.y2:57 def.z2:59 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-227 def.y1:53 def.z1:55 def.x2:-223 def.y2:57 def.z2:59 def.material:gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-216 def.y1:59 def.z1:7 def.x2:-186 def.y2:75 def.z2:31 def.wall:gray_concrete def.floor:smooth_stone def.roof:light_gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-216 def.y1:59 def.z1:46 def.x2:-186 def.y2:75 def.z2:70 def.wall:gray_concrete def.floor:smooth_stone def.roof:light_gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-217 def.y1:61 def.z1:13 def.x2:-211 def.y2:70 def.z2:25 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-217 def.y1:61 def.z1:52 def.x2:-211 def.y2:70 def.z2:64 def.material:air
    - ~run lapex_map_tower def.world:<[world]> def.x:-203 def.y:59 def.z:38 def.height:24 def.accent:red_concrete
    - ~run lapex_map_road def.world:<[world]> def.x1:-232 def.y1:68 def.z1:20 def.x2:-232 def.y2:68 def.z2:57 def.width:3 def.material:iron_block

lapex_map_poi_pit:
    type: task
    debug: false
    definitions: world
    script:
    # A circular canyon bowl with only four narrow, readable entrances.
    - ~run lapex_map_disc def.world:<[world]> def.x:-147 def.y:72 def.z:-103 def.rx:43 def.ry:11 def.rz:43 def.material:orange_terracotta
    - ~run lapex_map_disc def.world:<[world]> def.x:-147 def.y:78 def.z:-103 def.rx:32 def.ry:15 def.rz:32 def.material:air
    - ~run lapex_map_disc def.world:<[world]> def.x:-147 def.y:63 def.z:-103 def.rx:31 def.ry:1 def.rz:31 def.material:coarse_dirt
    - ~run lapex_map_box def.world:<[world]> def.x1:-151 def.y1:63 def.z1:-151 def.x2:-143 def.y2:74 def.z2:-128 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-151 def.y1:63 def.z1:-78 def.x2:-143 def.y2:74 def.z2:-55 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-195 def.y1:63 def.z1:-107 def.x2:-172 def.y2:74 def.z2:-99 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-122 def.y1:63 def.z1:-107 def.x2:-99 def.y2:74 def.z2:-99 def.material:air
    - ~run lapex_map_road def.world:<[world]> def.x1:-178 def.y1:64 def.z1:-103 def.x2:-116 def.y2:64 def.z2:-103 def.width:4 def.material:packed_mud
    - ~run lapex_map_road def.world:<[world]> def.x1:-147 def.y1:64 def.z1:-134 def.x2:-147 def.y2:64 def.z2:-72 def.width:4 def.material:packed_mud
    - ~run lapex_map_box def.world:<[world]> def.x1:-160 def.y1:64 def.z1:-113 def.x2:-154 def.y2:68 def.z2:-107 def.material:orange_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-140 def.y1:64 def.z1:-97 def.x2:-134 def.y2:68 def.z2:-91 def.material:yellow_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-154 def.y1:64 def.z1:-91 def.x2:-149 def.y2:67 def.z2:-86 def.material:gray_concrete

lapex_map_poi_artillery:
    type: task
    debug: false
    definitions: world
    script:
    # The northern high-ground fortress: walled yard, barracks, and gun line.
    - ~run lapex_map_box def.world:<[world]> def.x1:-22 def.y1:86 def.z1:-248 def.x2:87 def.y2:89 def.z2:-174 def.material:polished_andesite
    - ~run lapex_map_box def.world:<[world]> def.x1:-22 def.y1:90 def.z1:-248 def.x2:87 def.y2:96 def.z2:-244 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-22 def.y1:90 def.z1:-178 def.x2:22 def.y2:96 def.z2:-174 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:42 def.y1:90 def.z1:-178 def.x2:87 def.y2:96 def.z2:-174 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-22 def.y1:90 def.z1:-244 def.x2:-18 def.y2:96 def.z2:-178 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:83 def.y1:90 def.z1:-244 def.x2:87 def.y2:96 def.z2:-220 def.material:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:83 def.y1:90 def.z1:-204 def.x2:87 def.y2:96 def.z2:-178 def.material:gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-10 def.y1:89 def.z1:-237 def.x2:26 def.y2:105 def.z2:-218 def.wall:light_gray_concrete def.floor:smooth_stone def.roof:gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:39 def.y1:89 def.z1:-238 def.x2:70 def.y2:102 def.z2:-222 def.wall:light_gray_concrete def.floor:smooth_stone def.roof:gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:37 def.y1:89 def.z1:-205 def.x2:72 def.y2:102 def.z2:-188 def.wall:light_gray_concrete def.floor:smooth_stone def.roof:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-11 def.y1:91 def.z1:-230 def.x2:-7 def.y2:99 def.z2:-224 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:38 def.y1:91 def.z1:-233 def.x2:42 def.y2:98 def.z2:-227 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:36 def.y1:91 def.z1:-200 def.x2:40 def.y2:98 def.z2:-194 def.material:air
    - ~run lapex_map_road def.world:<[world]> def.x1:6 def.y1:90 def.z1:-211 def.x2:76 def.y2:90 def.z2:-211 def.width:8 def.material:smooth_stone
    - ~run lapex_map_disc def.world:<[world]> def.x:-10 def.y:91 def.z:-242 def.rx:5 def.ry:2 def.rz:5 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-12 def.y1:94 def.z1:-258 def.x2:-8 def.y2:97 def.z2:-241 def.material:iron_block
    - ~run lapex_map_disc def.world:<[world]> def.x:16 def.y:91 def.z:-242 def.rx:5 def.ry:2 def.rz:5 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:14 def.y1:94 def.z1:-258 def.x2:18 def.y2:97 def.z2:-241 def.material:iron_block
    - ~run lapex_map_tower def.world:<[world]> def.x:-15 def.y:90 def.z:-182 def.height:20 def.accent:red_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:80 def.y:90 def.z:-181 def.height:20 def.accent:red_concrete

lapex_map_poi_cascades:
    type: task
    debug: false
    definitions: world
    script:
    # Stepped river pools, waterfalls, and a village on both banks.
    - ~run lapex_map_pool def.world:<[world]> def.x:-24 def.y:76 def.z:-126 def.rx:16 def.rz:11
    - ~run lapex_map_box def.world:<[world]> def.x1:-29 def.y1:69 def.z1:-116 def.x2:-19 def.y2:76 def.z2:-110 def.material:water
    - ~run lapex_map_pool def.world:<[world]> def.x:-24 def.y:68 def.z:-104 def.rx:18 def.rz:13
    - ~run lapex_map_box def.world:<[world]> def.x1:-30 def.y1:64 def.z1:-93 def.x2:-18 def.y2:68 def.z2:-88 def.material:water
    - ~run lapex_map_pool def.world:<[world]> def.x:-24 def.y:63 def.z:-79 def.rx:20 def.rz:14
    - ~run lapex_map_road def.world:<[world]> def.x1:-48 def.y1:78 def.z1:-119 def.x2:1 def.y2:78 def.z2:-119 def.width:3 def.material:spruce_planks
    - ~run lapex_map_road def.world:<[world]> def.x1:-49 def.y1:70 def.z1:-98 def.x2:2 def.y2:70 def.z2:-98 def.width:3 def.material:spruce_planks
    - ~run lapex_map_road def.world:<[world]> def.x1:-50 def.y1:65 def.z1:-77 def.x2:4 def.y2:65 def.z2:-77 def.width:3 def.material:spruce_planks
    - ~run lapex_map_hut def.world:<[world]> def.x:-48 def.y:77 def.z:-129 def.width:11 def.height:7 def.depth:9 def.wall:spruce_planks def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-4 def.y:77 def.z:-130 def.width:10 def.height:7 def.depth:9 def.wall:dark_oak_planks def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-50 def.y:69 def.z:-106 def.width:9 def.height:7 def.depth:8 def.wall:dark_oak_planks def.roof:dark_oak_slab
    - ~run lapex_map_hut def.world:<[world]> def.x:3 def.y:69 def.z:-106 def.width:10 def.height:7 def.depth:8 def.wall:spruce_planks def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-51 def.y:64 def.z:-83 def.width:11 def.height:7 def.depth:9 def.wall:spruce_planks def.roof:dark_oak_slab
    - ~run lapex_map_hut def.world:<[world]> def.x:4 def.y:64 def.z:-82 def.width:10 def.height:7 def.depth:9 def.wall:dark_oak_planks def.roof:deepslate_tiles
    - ~run lapex_map_tower def.world:<[world]> def.x:9 def.y:75 def.z:-119 def.height:18 def.accent:yellow_concrete

lapex_map_poi_bunker:
    type: task
    debug: false
    definitions: world
    script:
    # A long fortified tunnel bored through a broad central mesa.
    - ~run lapex_map_disc def.world:<[world]> def.x:-90 def.y:80 def.z:-27 def.rx:54 def.ry:18 def.rz:34 def.material:tuff
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-145 def.y1:68 def.z1:-35 def.x2:-35 def.y2:81 def.z2:-19 def.wall:deepslate_bricks def.floor:iron_block def.roof:deepslate_tiles
    - ~run lapex_map_box def.world:<[world]> def.x1:-146 def.y1:70 def.z1:-31 def.x2:-140 def.y2:78 def.z2:-23 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-40 def.y1:70 def.z1:-31 def.x2:-34 def.y2:78 def.z2:-23 def.material:air
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-116 def.y1:68 def.z1:-52 def.x2:-84 def.y2:79 def.z2:-35 def.wall:deepslate_bricks def.floor:smooth_stone def.roof:deepslate_tiles
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-78 def.y1:68 def.z1:-19 def.x2:-48 def.y2:79 def.z2:-2 def.wall:deepslate_bricks def.floor:smooth_stone def.roof:deepslate_tiles
    - ~run lapex_map_box def.world:<[world]> def.x1:-103 def.y1:70 def.z1:-36 def.x2:-96 def.y2:77 def.z2:-31 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-67 def.y1:70 def.z1:-23 def.x2:-60 def.y2:77 def.z2:-18 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-133 def.y1:79 def.z1:-29 def.x2:-125 def.y2:79 def.z2:-25 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-108 def.y1:79 def.z1:-29 def.x2:-100 def.y2:79 def.z2:-25 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-83 def.y1:79 def.z1:-29 def.x2:-75 def.y2:79 def.z2:-25 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-58 def.y1:79 def.z1:-29 def.x2:-50 def.y2:79 def.z2:-25 def.material:sea_lantern
    - ~run lapex_map_box def.world:<[world]> def.x1:-149 def.y1:67 def.z1:-38 def.x2:-143 def.y2:83 def.z2:-16 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-147 def.y1:70 def.z1:-31 def.x2:-142 def.y2:78 def.z2:-23 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-37 def.y1:67 def.z1:-38 def.x2:-31 def.y2:83 def.z2:-16 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-38 def.y1:70 def.z1:-31 def.x2:-33 def.y2:78 def.z2:-23 def.material:air

lapex_map_poi_skull_town:
    type: task
    debug: false
    definitions: world
    script:
    # Four dense lanes beneath a giant south-facing leviathan skull and ribs.
    - ~run lapex_map_road def.world:<[world]> def.x1:-166 def.y1:64 def.z1:147 def.x2:-40 def.y2:64 def.z2:147 def.width:9 def.material:packed_mud
    - ~run lapex_map_road def.world:<[world]> def.x1:-102 def.y1:64 def.z1:91 def.x2:-102 def.y2:64 def.z2:204 def.width:9 def.material:packed_mud
    - ~run lapex_map_hut def.world:<[world]> def.x:-151 def.y:64 def.z:126 def.width:14 def.height:8 def.depth:12 def.wall:orange_terracotta def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-128 def.y:64 def.z:122 def.width:12 def.height:9 def.depth:13 def.wall:gray_concrete def.roof:light_gray_concrete
    - ~run lapex_map_hut def.world:<[world]> def.x:-74 def.y:64 def.z:124 def.width:14 def.height:8 def.depth:12 def.wall:orange_terracotta def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-49 def.y:64 def.z:130 def.width:12 def.height:9 def.depth:12 def.wall:gray_concrete def.roof:light_gray_concrete
    - ~run lapex_map_hut def.world:<[world]> def.x:-151 def.y:64 def.z:169 def.width:13 def.height:9 def.depth:12 def.wall:gray_concrete def.roof:light_gray_concrete
    - ~run lapex_map_hut def.world:<[world]> def.x:-127 def.y:64 def.z:177 def.width:15 def.height:8 def.depth:13 def.wall:orange_terracotta def.roof:deepslate_tiles
    - ~run lapex_map_hut def.world:<[world]> def.x:-77 def.y:64 def.z:174 def.width:14 def.height:9 def.depth:12 def.wall:gray_concrete def.roof:light_gray_concrete
    - ~run lapex_map_hut def.world:<[world]> def.x:-52 def.y:64 def.z:168 def.width:12 def.height:8 def.depth:13 def.wall:orange_terracotta def.roof:deepslate_tiles
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-137 def.y1:64 def.z1:153 def.x2:-116 def.y2:82 def.z2:168 def.wall:light_gray_concrete def.floor:smooth_stone def.roof:gray_concrete
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-88 def.y1:64 def.z1:101 def.x2:-67 def.y2:81 def.z2:116 def.wall:light_gray_concrete def.floor:smooth_stone def.roof:gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-128 def.y1:66 def.z1:152 def.x2:-123 def.y2:73 def.z2:156 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-81 def.y1:66 def.z1:112 def.x2:-75 def.y2:73 def.z2:117 def.material:air
    - ~run lapex_map_road def.world:<[world]> def.x1:-153 def.y1:75 def.z1:147 def.x2:-51 def.y2:75 def.z2:147 def.width:2 def.material:iron_block
    - ~run lapex_map_disc def.world:<[world]> def.x:-102 def.y:86 def.z:112 def.rx:21 def.ry:14 def.rz:17 def.material:bone_block
    - ~run lapex_map_disc def.world:<[world]> def.x:-111 def.y:89 def.z:126 def.rx:5 def.ry:5 def.rz:5 def.material:air
    - ~run lapex_map_disc def.world:<[world]> def.x:-93 def.y:89 def.z:126 def.rx:5 def.ry:5 def.rz:5 def.material:air
    - ~run lapex_map_disc def.world:<[world]> def.x:-102 def.y:83 def.z:129 def.rx:3 def.ry:5 def.rz:4 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-115 def.y1:75 def.z1:126 def.x2:-89 def.y2:80 def.z2:139 def.material:bone_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-111 def.y1:78 def.z1:132 def.x2:-106 def.y2:84 def.z2:140 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-98 def.y1:78 def.z1:132 def.x2:-93 def.y2:84 def.z2:140 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-154 def.y1:65 def.z1:111 def.x2:-150 def.y2:92 def.z2:115 def.material:bone_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-136 def.y1:65 def.z1:103 def.x2:-132 def.y2:96 def.z2:107 def.material:bone_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-72 def.y1:65 def.z1:103 def.x2:-68 def.y2:96 def.z2:107 def.material:bone_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-54 def.y1:65 def.z1:111 def.x2:-50 def.y2:92 def.z2:115 def.material:bone_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-152 def.y1:92 def.z1:113 def.x2:-134 def.y2:96 def.z2:105 def.width:3 def.material:bone_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-70 def.y1:96 def.z1:105 def.x2:-52 def.y2:92 def.z2:113 def.width:3 def.material:bone_block

lapex_map_poi_thunderdome:
    type: task
    debug: false
    definitions: world
    script:
    # A circular arena of grounded cages, suspended bridges, and a high cage.
    - ~run lapex_map_disc def.world:<[world]> def.x:-186 def.y:59 def.z:211 def.rx:52 def.ry:3 def.rz:48 def.material:polished_blackstone
    - ~run lapex_map_disc def.world:<[world]> def.x:-186 def.y:62 def.z:211 def.rx:43 def.ry:1 def.rz:39 def.material:orange_terracotta
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-221 def.y1:62 def.z1:198 def.x2:-200 def.y2:76 def.z2:220 def.wall:iron_bars def.floor:polished_deepslate def.roof:iron_bars
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-172 def.y1:62 def.z1:199 def.x2:-151 def.y2:76 def.z2:221 def.wall:iron_bars def.floor:polished_deepslate def.roof:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-202 def.y1:64 def.z1:205 def.x2:-199 def.y2:71 def.z2:212 def.material:air
    - ~run lapex_map_box def.world:<[world]> def.x1:-173 def.y1:64 def.z1:206 def.x2:-170 def.y2:71 def.z2:213 def.material:air
    - ~run lapex_map_hollow def.world:<[world]> def.x1:-198 def.y1:81 def.z1:199 def.x2:-177 def.y2:93 def.z2:218 def.wall:iron_bars def.floor:iron_block def.roof:iron_bars
    - ~run lapex_map_box def.world:<[world]> def.x1:-189 def.y1:82 def.z1:198 def.x2:-184 def.y2:89 def.z2:201 def.material:air
    - ~run lapex_map_tower def.world:<[world]> def.x:-186 def.y:62 def.z:246 def.height:35 def.accent:yellow_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:-229 def.y:62 def.z:211 def.height:22 def.accent:orange_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:-143 def.y:62 def.z:211 def.height:22 def.accent:orange_concrete
    - ~run lapex_map_tower def.world:<[world]> def.x:-186 def.y:62 def.z:174 def.height:22 def.accent:orange_concrete
    - ~run lapex_map_road def.world:<[world]> def.x1:-226 def.y1:82 def.z1:211 def.x2:-198 def.y2:82 def.z2:209 def.width:3 def.material:iron_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-177 def.y1:82 def.z1:209 def.x2:-146 def.y2:82 def.z2:211 def.width:3 def.material:iron_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-187 def.y1:82 def.z1:199 def.x2:-186 def.y2:82 def.z2:177 def.width:3 def.material:iron_block
    - ~run lapex_map_road def.world:<[world]> def.x1:-187 def.y1:82 def.z1:218 def.x2:-186 def.y2:82 def.z2:246 def.width:3 def.material:iron_block
    - ~run lapex_map_stair def.world:<[world]> def.x:-238 def.y:62 def.z:217 def.rise:19 def.direction:east def.width:3 def.material:iron_block
    - ~run lapex_map_box def.world:<[world]> def.x1:-198 def.y1:82 def.z1:215 def.x2:-197 def.y2:84 def.z2:219 def.material:air
    - ~run lapex_map_disc def.world:<[world]> def.x:-186 def.y:63 def.z:229 def.rx:8 def.ry:2 def.rz:8 def.material:light_gray_concrete
    - ~run lapex_map_box def.world:<[world]> def.x1:-190 def.y1:64 def.z1:225 def.x2:-182 def.y2:68 def.z2:233 def.material:gray_concrete
