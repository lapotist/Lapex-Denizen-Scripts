# Resumable macro terrain for the 640x640 launch-era Kings Canyon arena.
# Each logical unit is idempotent and is checkpointed only after its waited
# block edits finish. Large fills stay split into local chunk neighborhoods.

lapex_map_build_terrain:
    type: task
    debug: false
    definitions: world|force
    script:
    - define force <[force]||false>
    - if <[world]||null> == null:
        - narrate "<red>[Lapex Map] Terrain build requires a loaded world."
        - stop

    # The void world gets an 8x8 grid of 80-block ocean sectors. Each sector
    # loads only 25 horizontal chunks at a time and can resume independently.
    - narrate "<yellow>[Lapex Map] Preparing sectorized ocean floor..."
    - repeat 8 as:sector_x:
        - define x1 <[sector_x].sub[1].mul[80].sub[320]>
        - define x2 <[x1].add[79]>
        - repeat 8 as:sector_z:
            - define z1 <[sector_z].sub[1].mul[80].sub[320]>
            - define z2 <[z1].add[79]>
            - define unit ocean_<[sector_x]>_<[sector_z]>
            - if !<[force]> && <server.has_flag[lapex.map.v1.units.<[unit]>]>:
                - repeat next
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:47 def.z1:<[z1]> def.x2:<[x2]> def.y2:48 def.z2:<[z2]> def.material:stone
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:49 def.z1:<[z1]> def.x2:<[x2]> def.y2:49 def.z2:<[z2]> def.material:sand
            - ~run lapex_map_box def.world:<[world]> def.x1:<[x1]> def.y1:50 def.z1:<[z1]> def.x2:<[x2]> def.y2:52 def.z2:<[z2]> def.material:water
            - flag server lapex.map.v1.units.<[unit]>

    # Western Kings Canyon is a chain of red sandstone shelves and orange
    # mesas. Overlap keeps the coastline organic while leaving ocean inlets.
    - narrate "<yellow>[Lapex Map] Raising the western desert shelves..."
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_slum_base def.x:-200 def.y:48 def.z:-157 def.rx:75 def.ry:8 def.rz:60 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_slum_mid def.x:-200 def.y:52 def.z:-157 def.rx:68 def.ry:4 def.rz:54 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_slum_cap def.x:-200 def.y:56 def.z:-157 def.rx:61 def.ry:1 def.rz:48 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_pit_base def.x:-147 def.y:52 def.z:-103 def.rx:65 def.ry:10 def.rz:60 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_pit_mid def.x:-147 def.y:57 def.z:-103 def.rx:58 def.ry:5 def.rz:54 def.material:terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_pit_cap def.x:-147 def.y:61 def.z:-103 def.rx:51 def.ry:2 def.rz:47 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_runoff_base def.x:-230 def.y:52 def.z:-51 def.rx:65 def.ry:8 def.rz:58 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_runoff_mid def.x:-230 def.y:56 def.z:-51 def.rx:58 def.ry:4 def.rz:52 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_runoff_cap def.x:-230 def.y:60 def.z:-51 def.rx:51 def.ry:1 def.rz:46 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_airbase_base def.x:-190 def.y:52 def.z:38 def.rx:38 def.ry:5 def.rz:70 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_airbase_mid def.x:-190 def.y:54 def.z:38 def.rx:34 def.ry:3 def.rz:63 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_airbase_cap def.x:-190 def.y:56 def.z:38 def.rx:30 def.ry:1 def.rz:56 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_bunker_base def.x:-90 def.y:58 def.z:-27 def.rx:72 def.ry:10 def.rz:60 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_bunker_mid def.x:-90 def.y:63 def.z:-27 def.rx:64 def.ry:5 def.rz:54 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_bunker_cap def.x:-90 def.y:66 def.z:-27 def.rx:56 def.ry:1 def.rz:48 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_center_base def.x:-135 def.y:52 def.z:55 def.rx:75 def.ry:8 def.rz:78 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_center_mid def.x:-135 def.y:57 def.z:55 def.rx:68 def.ry:6 def.rz:70 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_center_cap def.x:-135 def.y:61 def.z:55 def.rx:60 def.ry:3 def.rz:62 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_skull_base def.x:-102 def.y:52 def.z:147 def.rx:78 def.ry:10 def.rz:72 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_skull_mid def.x:-102 def.y:57 def.z:147 def.rx:70 def.ry:5 def.rz:65 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_skull_cap def.x:-102 def.y:61 def.z:147 def.rx:62 def.ry:2 def.rz:58 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_thunder_base def.x:-186 def.y:52 def.z:211 def.rx:60 def.ry:5 def.rz:60 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_thunder_mid def.x:-186 def.y:54 def.z:211 def.rx:53 def.ry:3 def.rz:53 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_thunder_cap def.x:-186 def.y:57 def.z:211 def.rx:46 def.ry:1 def.rz:46 def.material:red_sand

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_market_base def.x:-30 def.y:52 def.z:120 def.rx:64 def.ry:8 def.rz:60 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_market_mid def.x:-30 def.y:57 def.z:120 def.rx:58 def.ry:4 def.rz:54 def.material:orange_terracotta
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:west_market_cap def.x:-30 def.y:61 def.z:120 def.rx:52 def.ry:1 def.rz:48 def.material:red_sand

    # The northeast rises into greener high ground around Artillery, Relay,
    # Cascades, and the central river villages.
    - narrate "<yellow>[Lapex Map] Raising the northern green highlands..."
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_artillery_base def.x:32 def.y:66 def.z:-211 def.rx:78 def.ry:14 def.rz:62 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_artillery_mid def.x:32 def.y:77 def.z:-211 def.rx:70 def.ry:7 def.rz:56 def.material:coarse_dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_artillery_cap def.x:32 def.y:83 def.z:-211 def.rx:62 def.ry:2 def.rz:50 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_relay_base def.x:225 def.y:62 def.z:-225 def.rx:68 def.ry:14 def.rz:68 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_relay_mid def.x:225 def.y:76 def.z:-225 def.rx:60 def.ry:8 def.rz:60 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_relay_cap def.x:225 def.y:84 def.z:-225 def.rx:53 def.ry:1 def.rz:52 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_base def.x:-24 def.y:52 def.z:-103 def.rx:68 def.ry:8 def.rz:70 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_mid def.x:-24 def.y:56 def.z:-103 def.rx:61 def.ry:5 def.rz:63 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_cap def.x:-24 def.y:62 def.z:-103 def.rx:54 def.ry:1 def.rz:56 def.material:grass_block
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_middle_bank def.x:-24 def.y:63 def.z:-105 def.rx:62 def.ry:5 def.rz:22 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_middle_cap def.x:-24 def.y:67 def.z:-105 def.rx:55 def.ry:1 def.rz:18 def.material:grass_block
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_upper_base def.x:-24 def.y:70 def.z:-128 def.rx:62 def.ry:6 def.rz:24 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_cascades_upper_cap def.x:-24 def.y:75 def.z:-128 def.rx:55 def.ry:1 def.rz:20 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_wetlands_base def.x:225 def.y:52 def.z:-105 def.rx:72 def.ry:8 def.rz:78 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_wetlands_mid def.x:225 def.y:57 def.z:-105 def.rx:65 def.ry:5 def.rz:70 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_wetlands_cap def.x:225 def.y:61 def.z:-105 def.rx:58 def.ry:2 def.rz:62 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_center_base def.x:65 def.y:52 def.z:-25 def.rx:80 def.ry:8 def.rz:85 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_center_mid def.x:65 def.y:57 def.z:-25 def.rx:72 def.ry:6 def.rz:77 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_center_cap def.x:65 def.y:61 def.z:-25 def.rx:64 def.ry:2 def.rz:69 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_south_base def.x:65 def.y:52 def.z:170 def.rx:80 def.ry:7 def.rz:72 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_south_mid def.x:65 def.y:57 def.z:170 def.rx:72 def.ry:6 def.rz:64 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_south_cap def.x:65 def.y:61 def.z:170 def.rx:64 def.ry:2 def.rz:56 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_repulsor_base def.x:205 def.y:61 def.z:225 def.rx:78 def.ry:13 def.rz:68 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_repulsor_mid def.x:205 def.y:70 def.z:225 def.rx:70 def.ry:7 def.rz:60 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_repulsor_cap def.x:205 def.y:76 def.z:225 def.rx:62 def.ry:2 def.rz:52 def.material:grass_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_treatment_base def.x:35 def.y:52 def.z:250 def.rx:78 def.ry:8 def.rz:52 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_treatment_mid def.x:35 def.y:58 def.z:250 def.rx:70 def.ry:5 def.rz:46 def.material:dirt
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:green_treatment_cap def.x:35 def.y:62 def.z:250 def.rx:62 def.ry:2 def.rz:40 def.material:grass_block

    # Low eastern lobes use clay, mud, and moss to distinguish Hydro's basin,
    # Wetlands, and the broad Swamps from the northern grass shelves.
    - narrate "<yellow>[Lapex Map] Forming the eastern marsh basin..."
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_hydro_base def.x:190 def.y:54 def.z:25 def.rx:78 def.ry:8 def.rz:78 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_hydro_mid def.x:190 def.y:59 def.z:25 def.rx:70 def.ry:5 def.rz:70 def.material:mud
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_hydro_cap def.x:190 def.y:64 def.z:25 def.rx:62 def.ry:1 def.rz:62 def.material:moss_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_coast_base def.x:250 def.y:48 def.z:5 def.rx:55 def.ry:3 def.rz:80 def.material:clay
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_coast_mid def.x:250 def.y:52 def.z:5 def.rx:49 def.ry:3 def.rz:72 def.material:mud
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_coast_cap def.x:250 def.y:53 def.z:5 def.rx:43 def.ry:2 def.rz:64 def.material:moss_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_north_base def.x:235 def.y:48 def.z:95 def.rx:65 def.ry:5 def.rz:60 def.material:clay
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_north_mid def.x:235 def.y:52 def.z:95 def.rx:58 def.ry:4 def.rz:54 def.material:mud
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_north_cap def.x:235 def.y:55 def.z:95 def.rx:50 def.ry:2 def.rz:46 def.material:moss_block

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_south_base def.x:235 def.y:48 def.z:165 def.rx:65 def.ry:5 def.rz:60 def.material:clay
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_south_mid def.x:235 def.y:52 def.z:165 def.rx:58 def.ry:4 def.rz:54 def.material:mud
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:swamp_south_cap def.x:235 def.y:55 def.z:165 def.rx:50 def.ry:2 def.rz:46 def.material:moss_block

    # Flatten only the landmark mesas that need readable silhouettes. The
    # underlying ellipsoids still provide slopes, beaches, and natural cover.
    - narrate "<yellow>[Lapex Map] Cutting landmark mesas and ridge chokes..."
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_artillery]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:32 def.y:78 def.z:-211 def.rx:68 def.ry:6 def.rz:54 def.material:stone
        - ~run lapex_map_disc def.world:<[world]> def.x:32 def.y:84 def.z:-211 def.rx:61 def.ry:1 def.rz:48 def.material:grass_block
        - flag server lapex.map.v1.units.mesa_artillery
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_relay]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:225 def.y:82 def.z:-225 def.rx:58 def.ry:6 def.rz:54 def.material:stone
        - ~run lapex_map_disc def.world:<[world]> def.x:225 def.y:87 def.z:-225 def.rx:52 def.ry:1 def.rz:48 def.material:grass_block
        - flag server lapex.map.v1.units.mesa_relay
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_airbase]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:-195 def.y:53 def.z:38 def.rx:32 def.ry:3 def.rz:48 def.material:red_sandstone
        - ~run lapex_map_disc def.world:<[world]> def.x:-195 def.y:56 def.z:38 def.rx:28 def.ry:1 def.rz:43 def.material:red_sand
        - flag server lapex.map.v1.units.mesa_airbase
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_pit]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:-147 def.y:56 def.z:-103 def.rx:50 def.ry:5 def.rz:47 def.material:red_sandstone
        - ~run lapex_map_disc def.world:<[world]> def.x:-147 def.y:61 def.z:-103 def.rx:44 def.ry:1 def.rz:41 def.material:red_sand
        - flag server lapex.map.v1.units.mesa_pit
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_thunderdome]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:-186 def.y:54 def.z:211 def.rx:52 def.ry:3 def.rz:48 def.material:red_sandstone
        - ~run lapex_map_disc def.world:<[world]> def.x:-186 def.y:57 def.z:211 def.rx:46 def.ry:1 def.rz:42 def.material:red_sand
        - flag server lapex.map.v1.units.mesa_thunderdome
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.mesa_repulsor]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:205 def.y:70 def.z:225 def.rx:63 def.ry:6 def.rz:52 def.material:stone
        - ~run lapex_map_disc def.world:<[world]> def.x:205 def.y:76 def.z:225 def.rx:57 def.ry:1 def.rz:46 def.material:grass_block
        - flag server lapex.map.v1.units.mesa_repulsor

    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:ridge_bunker_north def.x:-90 def.y:66 def.z:-65 def.rx:62 def.ry:12 def.rz:14 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:ridge_bunker_south def.x:-90 def.y:64 def.z:10 def.rx:62 def.ry:12 def.rz:14 def.material:red_sandstone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:ridge_wetlands_west def.x:185 def.y:63 def.z:-135 def.rx:55 def.ry:10 def.rz:12 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:ridge_wetlands_east def.x:245 def.y:64 def.z:-70 def.rx:45 def.ry:10 def.rz:12 def.material:stone
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:ridge_wetlands_north def.x:205 def.y:62 def.z:-165 def.rx:18 def.ry:9 def.rz:45 def.material:stone

    # Air cuts expose the ocean-level river and reproduce the central canyon,
    # Bunker choke, and Hydro approach without creating one map-wide area.
    - narrate "<yellow>[Lapex Map] Carving the central canyon and river..."
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_north def.x:-24 def.y:73 def.z:-175 def.rx:22 def.ry:20 def.rz:58 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_cascades def.x:-24 def.y:67 def.z:-103 def.rx:24 def.ry:14 def.rz:50 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_center def.x:8 def.y:65 def.z:-45 def.rx:28 def.ry:12 def.rz:48 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_bridges def.x:35 def.y:63 def.z:15 def.rx:25 def.ry:10 def.rz:48 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_market def.x:12 def.y:62 def.z:120 def.rx:22 def.ry:9 def.rz:48 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_river_south def.x:15 def.y:61 def.z:205 def.rx:22 def.ry:8 def.rz:58 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_bunker_choke def.x:-90 def.y:70 def.z:-27 def.rx:55 def.ry:18 def.rz:13 def.material:air
    - ~run lapex_map_terrain_ellipsoid def.world:<[world]> def.force:<[force]> def.id:cut_hydro_choke def.x:108 def.y:68 def.z:15 def.rx:58 def.ry:16 def.rz:20 def.material:air

    - if <[force]> || !<server.has_flag[lapex.map.v1.units.river_main]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:-24 def.y1:52 def.z1:-310 def.x2:-24 def.y2:52 def.z2:-103 def.width:9 def.material:water
        - ~run lapex_map_road def.world:<[world]> def.x1:-24 def.y1:52 def.z1:-103 def.x2:8 def.y2:52 def.z2:-45 def.width:9 def.material:water
        - ~run lapex_map_road def.world:<[world]> def.x1:8 def.y1:52 def.z1:-45 def.x2:35 def.y2:52 def.z2:15 def.width:9 def.material:water
        - ~run lapex_map_road def.world:<[world]> def.x1:35 def.y1:52 def.z1:15 def.x2:15 def.y2:52 def.z2:105 def.width:9 def.material:water
        - ~run lapex_map_road def.world:<[world]> def.x1:15 def.y1:52 def.z1:105 def.x2:15 def.y2:52 def.z2:285 def.width:9 def.material:water
        - flag server lapex.map.v1.units.river_main
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.river_hydro_branch]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:35 def.y1:52 def.z1:15 def.x2:178 def.y2:52 def.z2:15 def.width:8 def.material:water
        - flag server lapex.map.v1.units.river_hydro_branch

    # A small rock island preserves the low route beneath the later Bridges
    # superstructure while the river remains open on both sides.
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.bridge_island]>:
        - ~run lapex_map_disc def.world:<[world]> def.x:35 def.y:60 def.z:15 def.rx:12 def.ry:7 def.rz:11 def.material:stone
        - ~run lapex_map_disc def.world:<[world]> def.x:35 def.y:66 def.z:15 def.rx:9 def.ry:1 def.rz:8 def.material:gravel
        - flag server lapex.map.v1.units.bridge_island

    # Primary routes follow the launch map's coastal, high-desert, river, and
    # eastern military rotations. Roads are narrow enough to remain combat
    # lanes rather than erasing the terrain beneath them.
    - narrate "<yellow>[Lapex Map] Laying the primary rotation routes..."
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.route_west_coast]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:-187 def.y1:65 def.z1:-136 def.x2:-230 def.y2:64 def.z2:-86 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:-230 def.y1:64 def.z1:-17 def.x2:-218 def.y2:58 def.z2:4 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:-218 def.y1:58 def.z1:57 def.x2:-186 def.y2:63 def.z2:163 def.width:3 def.material:gravel
        - flag server lapex.map.v1.units.route_west_coast
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.route_high_desert]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:-99 def.y1:64 def.z1:-103 def.x2:-149 def.y2:68 def.z2:-27 def.width:3 def.material:coarse_dirt
        - ~run lapex_map_road def.world:<[world]> def.x1:-31 def.y1:68 def.z1:-27 def.x2:-102 def.y2:64 def.z2:91 def.width:3 def.material:coarse_dirt
        - ~run lapex_map_road def.world:<[world]> def.x1:-102 def.y1:64 def.z1:204 def.x2:-186 def.y2:63 def.z2:163 def.width:3 def.material:coarse_dirt
        - flag server lapex.map.v1.units.route_high_desert
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.route_north_east]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:88 def.y1:90 def.z1:-212 def.x2:225 def.y2:88 def.z2:-268 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:225 def.y1:88 def.z1:-190 def.x2:225 def.y2:64 def.z2:-150 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:225 def.y1:64 def.z1:-82 def.x2:182 def.y2:69 def.z2:0 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:216 def.y1:69 def.z1:0 def.x2:235 def.y2:58 def.z2:91 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:235 def.y1:58 def.z1:166 def.x2:172 def.y2:79 def.z2:246 def.width:3 def.material:gravel
        - flag server lapex.map.v1.units.route_north_east
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.route_river_center]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:32 def.y1:90 def.z1:-170 def.x2:-24 def.y2:78 def.z2:-119 def.width:3 def.material:coarse_dirt
        - ~run lapex_map_road def.world:<[world]> def.x1:-24 def.y1:65 def.z1:-77 def.x2:-18 def.y2:71 def.z2:15 def.width:3 def.material:coarse_dirt
        - ~run lapex_map_road def.world:<[world]> def.x1:35 def.y1:61 def.z1:29 def.x2:-30 def.y2:64 def.z2:82 def.width:3 def.material:coarse_dirt
        - ~run lapex_map_road def.world:<[world]> def.x1:-30 def.y1:64 def.z1:159 def.x2:35 def.y2:64 def.z2:207 def.width:3 def.material:coarse_dirt
        - flag server lapex.map.v1.units.route_river_center
    - if <[force]> || !<server.has_flag[lapex.map.v1.units.route_south_crossing]>:
        - ~run lapex_map_road def.world:<[world]> def.x1:-40 def.y1:64 def.z1:147 def.x2:-69 def.y2:64 def.z2:120 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:-30 def.y1:64 def.z1:159 def.x2:35 def.y2:64 def.z2:207 def.width:3 def.material:gravel
        - ~run lapex_map_road def.world:<[world]> def.x1:82 def.y1:64 def.z1:250 def.x2:172 def.y2:79 def.z2:246 def.width:3 def.material:gravel
        - flag server lapex.map.v1.units.route_south_crossing

    - narrate "<green>[Lapex Map] Terrain units complete. POI construction can begin."


# Direct ellipsoid primitive for medium terrain units. Unlike the shared disc
# helper, this owns its checkpoint so a stopped build never repeats prior lobes.
lapex_map_terrain_ellipsoid:
    type: task
    debug: false
    definitions: world|force|id|x|y|z|rx|ry|rz|material
    script:
    - if !<[force]> && <server.has_flag[lapex.map.v1.units.<[id]>]>:
        - stop
    - define shape <location[<[x]>,<[y]>,<[z]>,<[world]>].to_ellipsoid[<[rx]>,<[ry]>,<[rz]>]>
    - define chunks <[shape].bounding_box.partial_chunks>
    - chunkload <[chunks]> duration:10m
    - ~modifyblock <[shape]> <[material]> no_physics delayed max_delay_ms:<script[lapex_map_data].data_key[build_budget_ms]>
    - chunkload remove <[chunks]>
    - flag server lapex.map.v1.units.<[id]>
