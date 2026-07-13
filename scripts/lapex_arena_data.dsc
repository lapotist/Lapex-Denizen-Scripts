# Compact 5v5 arena registry. Coordinates use +X east and +Z south.
# Gameplay systems should read locations from here instead of copying them.

lapex_arena_data:
    type: data

    world: lapex_arena_foundry
    border_size: 224
    build_budget_ms: 45
    floor_y: 63
    staging: 0,125,0
    spectator_spawn: 0,125,0
    spectator: 0,125,0
    completion_marker: 0,139,0
    max_team_size: 5
    max_rounds: 9
    prep_seconds: 30
    round_seconds: 180
    ring:
        start_size: 208
        final_size: 44
        delay: 45s
        shrink: 90s

    # The authored floor is deliberately smaller than the world border. The
    # extra void prevents knockback at the wall from exposing another build.
    bounds:
        min_x: -96
        max_x: 96
        min_z: -72
        max_z: 72

    build_units:
    - foundation
    - spawn_north
    - spawn_south
    - center_foundry
    - west_tunnel
    - east_cargo
    - crosslinks
    - cover_and_loot
    - staging

    required_tasks:
    - lapex_arena_build
    - lapex_arena_setup
    - lapex_arena_validate
    - lapex_arena_geometry_foundation
    - lapex_arena_geometry_spawn_north
    - lapex_arena_geometry_spawn_south
    - lapex_arena_geometry_center_foundry
    - lapex_arena_geometry_west_tunnel
    - lapex_arena_geometry_east_cargo
    - lapex_arena_geometry_crosslinks
    - lapex_arena_geometry_cover_and_loot
    - lapex_arena_geometry_staging
    - lapex_arena_cover
    - lapex_arena_supply_pad
    - lapex_map_box
    - lapex_map_hollow
    - lapex_map_stair
    - lapex_map_tower

    # Five distinct north/south starts provide deterministic 5v5 slots.
    # Feet are at Y=65 and each pad is solid at Y=64.
    team_spawns:
        red:
        - -32,65,-62
        - -16,65,-62
        - 0,65,-62
        - 16,65,-62
        - 32,65,-62
        blue:
        - -32,65,62
        - -16,65,62
        - 0,65,62
        - 16,65,62
        - 32,65,62

    # Match-controller aliases. Keep these identical to team_spawns.
    spawns:
        red:
        - -32,65,-62
        - -16,65,-62
        - 0,65,-62
        - 16,65,-62
        - 32,65,-62
        blue:
        - -32,65,62
        - -16,65,62
        - 0,65,62
        - 16,65,62
        - 32,65,62

    # Three mirrored pairs keep round economy neutral. The mode may place its
    # own interactive bin entities at these clear feet locations.
    supply_bin_anchors:
    - -66,64,-26
    - 0,64,-32
    - 66,64,-26
    - -66,64,26
    - 0,64,32
    - 66,64,26
    care_package_anchor: 0,71,0

    # Compatibility names used by the Arena round/loot controller.
    loot_boxes:
    - -66,64,-26
    - 0,64,-32
    - 66,64,-26
    - -66,64,26
    - 0,64,32
    - 66,64,26
    care_box: 0,71,0

    teleport_points:
        red: 0,65,-62
        blue: 0,65,62
        center: 0,71,0
        west: -76,64,0
        east: 76,64,0
        staging: 0,125,0

    # Named nodes and explicit links form a small navigation graph for bots.
    # Upper nodes are walkable catwalks at Y=71; all others are ground routes.
    navigation_nodes:
        red_spawn: 0,65,-56
        red_west_gate: -34,65,-49
        red_center_gate: 0,65,-49
        red_east_gate: 34,65,-49
        north_west: -72,64,-34
        north_west_link: -48,64,-30
        north_center: 0,64,-34
        north_east_link: 48,64,-30
        north_east: 72,64,-34
        west_mid: -76,64,0
        west_upper: -58,71,0
        center_low: 0,64,0
        center_upper: 0,71,5
        east_upper: 58,71,0
        east_mid: 72,64,0
        south_west: -72,64,34
        south_west_link: -48,64,30
        south_center: 0,64,34
        south_east_link: 48,64,30
        south_east: 72,64,34
        blue_west_gate: -34,65,49
        blue_center_gate: 0,65,49
        blue_east_gate: 34,65,49
        blue_spawn: 0,65,56

    navigation_links:
    - red_spawn|red_west_gate
    - red_spawn|red_center_gate
    - red_spawn|red_east_gate
    - red_west_gate|north_west_link
    - red_center_gate|north_center
    - red_east_gate|north_east_link
    - north_west|north_west_link
    - north_west_link|north_center
    - north_center|north_east_link
    - north_east_link|north_east
    - north_west|west_mid
    - north_center|center_low
    - north_east|east_mid
    - west_mid|south_west
    - center_low|south_center
    - east_mid|south_east
    - south_west|south_west_link
    - south_west_link|south_center
    - south_center|south_east_link
    - south_east_link|south_east
    - south_west_link|blue_west_gate
    - south_center|blue_center_gate
    - south_east_link|blue_east_gate
    - blue_west_gate|blue_spawn
    - blue_center_gate|blue_spawn
    - blue_east_gate|blue_spawn
    - west_mid|west_upper
    - west_upper|center_upper
    - center_upper|east_upper
    - east_upper|east_mid
    - center_low|center_upper

    # Cover centers match physical blocks placed by cover_and_loot. AI can use
    # them as short movement goals without pathing into decorative walls.
    cover_nodes:
        west:
        - -82,64,-36
        - -70,64,-24
        - -82,64,-12
        - -70,64,0
        - -82,64,12
        - -70,64,24
        - -82,64,36
        - -52,64,-34
        - -48,64,-18
        - -52,64,0
        - -48,64,18
        - -52,64,34
        center:
        - -20,64,-40
        - 20,64,-40
        - -12,64,-26
        - 12,64,-26
        - -22,64,-10
        - 22,64,-10
        - -22,64,10
        - 22,64,10
        - -12,64,26
        - 12,64,26
        - -20,64,40
        - 20,64,40
        east:
        - 48,64,-38
        - 62,64,-32
        - 78,64,-38
        - 52,64,-18
        - 70,64,-12
        - 84,64,0
        - 52,64,18
        - 70,64,12
        - 48,64,38
        - 62,64,32
        - 78,64,38

    # Each checkpoint owns one stable, non-decorative block. Validation reads
    # these after a completed build to detect missing or partially copied units.
    signature_checks:
        foundation:
            location: -95,68,-71
            material: polished_blackstone_bricks
        spawn_north:
            location: -32,64,-62
            material: red_concrete
        spawn_south:
            location: -32,64,62
            material: blue_concrete
        center_foundry:
            location: 0,70,0
            material: copper_block
        west_tunnel:
            location: -90,68,0
            material: cyan_concrete
        east_cargo:
            location: 90,68,0
            material: yellow_concrete
        crosslinks:
            location: 0,70,-2
            material: iron_block
        cover_and_loot:
            location: -66,63,-26
            material: sea_lantern
        staging:
            location: 0,124,0
            material: tinted_glass
