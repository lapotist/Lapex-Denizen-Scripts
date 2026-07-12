# Launch-era Kings Canyon registry. Coordinates use +X east and +Z south.

lapex_map_data:
    type: data

    world: lapex_kings_canyon
    border_size: 640
    build_budget_ms: 45
    ocean_level: 52
    staging: 8,160,0

    all_ids:
    - artillery
    - relay
    - slum_lakes
    - pit
    - cascades
    - wetlands
    - runoff
    - bunker
    - swamps
    - airbase
    - bridges
    - hydro_dam
    - market
    - repulsor
    - skull_town
    - thunderdome
    - water_treatment

    required_tasks:
    - lapex_map_build
    - lapex_map_build_terrain
    - lapex_map_terrain_ellipsoid
    - lapex_map_staging
    - lapex_map_safe_spawn
    - lapex_map_box
    - lapex_map_disc
    - lapex_map_hollow
    - lapex_map_hut
    - lapex_map_tower
    - lapex_map_pool
    - lapex_map_road
    - lapex_map_stair
    - lapex_map_stilts

    # Stable block signatures used by the post-build validator. These avoid
    # decorative edges and sample one defining structure in each landmark.
    signature_checks:
        artillery:
            location: -12,94,-250
            material: iron_block
        relay:
            location: 239,116,-239
            material: red_concrete
        slum_lakes:
            location: -200,63,-162
            material: polished_deepslate
        pit:
            location: -147,64,-110
            material: packed_mud
        cascades:
            location: -24,69,-112
            material: water
        wetlands:
            location: 225,65,-120
            material: mangrove_planks
        runoff:
            location: -230,63,-80
            material: polished_andesite
        bunker:
            location: -80,68,-27
            material: iron_block
        swamps:
            location: 235,59,140
            material: mangrove_planks
        airbase:
            location: -280,59,20
            material: white_concrete
        bridges:
            location: 35,73,15
            material: polished_andesite
        hydro_dam:
            location: 173,85,0
            material: polished_andesite
        market:
            location: -50,77,125
            material: red_concrete
        repulsor:
            location: 205,123,210
            material: iron_block
        skull_town:
            location: -102,86,112
            material: bone_block
        thunderdome:
            location: -186,81,210
            material: iron_block
        water_treatment:
            location: 35,67,250
            material: polished_andesite

    pois:
        artillery:
            name: Artillery
            spawn: 32,91,-211
            region: Northern Rim
            signature: Walled IMC plateau with barracks, gun emplacements, and tunnel gates.
        relay:
            name: Relay
            spawn: 225,89,-225
            region: Northeast Coast
            signature: Coastal antenna station with a relay mast, inlet, and offshore platform.
        slum_lakes:
            name: Slum Lakes
            spawn: -187,66,-160
            region: Northwest Basin
            signature: Dense shack basin split by a drainage trench and paired industrial pipes.
        pit:
            name: The Pit
            spawn: -147,65,-103
            region: Northwest Canyon
            signature: Circular sunken combat bowl with four narrow approaches.
        cascades:
            name: Cascades
            spawn: -24,71,-98
            region: North River
            signature: River village descending through waterfalls and improvised crossings.
        wetlands:
            name: Wetlands
            spawn: 225,66,-105
            region: Northeast Ridges
            signature: Scattered compounds enclosed by long finger-like stone ridges.
        runoff:
            name: Runoff
            spawn: -230,65,-51
            region: West Industrial
            signature: Sewage plant with treatment blocks, tanks, channels, and catwalks.
        bunker:
            name: Bunker
            spawn: -90,69,-27
            region: High Desert
            signature: Fortified tunnel linking the western plateau to River Center.
        swamps:
            name: Swamps
            spawn: 235,60,135
            region: East Marsh
            signature: Stilt settlement, flooded pipes, mangroves, and raised walkways.
        airbase:
            name: Airbase
            spawn: -260,60,20
            region: West Coast
            signature: Twin landing strips over the sea with hangars and a fortified seawall.
        bridges:
            name: Bridges
            spawn: 35,74,15
            region: River Center
            signature: Compact settlement controlling the map's primary multi-level crossing.
        hydro_dam:
            name: Hydro Dam
            spawn: 198,70,0
            region: East River
            signature: Massive concrete dam, turbine halls, spillways, and an industrial yard.
        market:
            name: Market
            spawn: -30,67,120
            region: South Center
            signature: Enclosed warehouse with roof entries, stalls, and close-quarters lanes.
        repulsor:
            name: Repulsor
            spawn: 205,80,250
            region: Southeast Plateau
            signature: IMC compound with covered pits, barracks, and a landmark repulsor tower.
        skull_town:
            name: Skull Town
            spawn: -102,65,147
            region: Southwest Basin
            signature: Dense cross-grid settlement beneath a colossal skull and rib skeleton.
        thunderdome:
            name: Thunderdome
            spawn: -186,64,211
            region: Southwest Coast
            signature: Coastal arena bowl with cage towers, gantries, and aerial routes.
        water_treatment:
            name: Water Treatment
            spawn: 35,65,220
            region: South Coast
            signature: Southern plant with a main hall and four large circular settling basins.
