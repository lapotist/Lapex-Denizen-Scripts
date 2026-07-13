# Arena containers are empty physical anchors backed by server flags. No item is
# ever placed in a block inventory, so hoppers and stale chunks cannot duplicate
# a round reward. Claims are written before a reward command runs.

lapex_arena_syringe:
    type: item
    material: honey_bottle
    display name: <aqua>Arena Syringe
    lore:
    - <gray>Drink to restore 25 health.
    flags:
        lapex:
            arena_heal: 5

lapex_arena_med_kit:
    type: item
    material: honey_bottle
    display name: <green>Arena Med Kit
    lore:
    - <gray>Drink to restore 50 health.
    flags:
        lapex:
            arena_heal: 10

lapex_arena_loot_events:
    type: world
    debug: false
    events:
        # The six barrels and center box contain nothing. This event owns the
        # entire interaction and identifies an anchor by exact block position.
        on player right clicks block using:hand:
        - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
        - if <context.location.world.name> != <[world_name]>:
            - stop
        - define box_index null
        - foreach <script[lapex_arena_data].data_key[loot_boxes]||<list>> as:raw:
            - define anchor <location[<[raw]>,<[world_name]>]>
            - if <proc[lapex_arena_same_block].context[<context.location>|<[anchor]>]>:
                - define box_index <[loop_index]>
                - foreach stop
        - if <[box_index]> != null:
            - determine passively cancelled
            - run lapex_arena_loot_claim def.kind:supply def.index:<[box_index]> def.location:<context.location>
            - stop
        - define care <location[<script[lapex_arena_data].data_key[care_box]||0,71,0>,<[world_name]>]>
        - if <proc[lapex_arena_same_block].context[<context.location>|<[care]>]>:
            - determine passively cancelled
            - run lapex_arena_loot_claim def.kind:care def.index:center def.location:<context.location>

        on player consumes item:
        - define heal <context.item.flag[lapex.arena_heal]||0>
        - if <[heal]> <= 0:
            - stop
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <player.has_flag[lapex.arena_eliminated]>:
            - stop
        - define before <player.health>
        - adjust <player> health:<[before].add[<[heal]>].min[<player.health_max>]>
        - playeffect effect:heart at:<player.location.above[1]> offset:0.25 quantity:5
        - playsound <player> sound:entity.experience_orb.pickup pitch:1.5 volume:0.55
        - actionbar "<green>Health <white><player.health.round>/<player.health_max.round>"

        # Round inventories are temporary. Keeping every drop player-owned also
        # prevents a weapon from one round becoming floor loot in the next.
        on player drops item:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> != null && <server.flag[lapex.arena.session]||null> == <[session]>:
            - determine cancelled

# Integer block comparison avoids yaw/pitch differences in event locations.
lapex_arena_same_block:
    type: procedure
    debug: false
    definitions: first|second
    script:
    - if <[first].world> != <[second].world>:
        - determine false
    - if <[first].x.round_down> != <[second].x.round_down> || <[first].y.round_down> != <[second].y.round_down> || <[first].z.round_down> != <[second].z.round_down>:
        - determine false
    - determine true

# Called once before every prep phase. Round zero is the controller's teardown
# signal and removes the otherwise-empty container blocks from the authored map.
lapex_arena_loot_reset:
    type: task
    debug: false
    definitions: session|round
    script:
    - if <[session]||null> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
        - stop
    - define round <[round]||<server.flag[lapex.arena.round]||0>>
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - flag server lapex.arena.loot.<[session]>:!
    - flag server lapex.arena.loot_session:<[session]>
    - flag server lapex.arena.loot_round:<[round]>
    - flag server lapex.arena.loot_token:<util.random_uuid>
    - if <[map_world]> == null:
        - stop
    - foreach <script[lapex_arena_data].data_key[loot_boxes]||<list>> as:raw:
        - define anchor <location[<[raw]>,<[world_name]>]>
        - chunkload <[anchor].chunk> duration:30s
        - if <[round]> > 0:
            - modifyblock <[anchor]> barrel no_physics
        - else:
            - modifyblock <[anchor]> air no_physics
    - define care <location[<script[lapex_arena_data].data_key[care_box]||0,71,0>,<[world_name]>]>
    - chunkload <[care].chunk> duration:30s
    - if <[round]> > 0:
        - modifyblock <[care]> yellow_shulker_box no_physics
        - playeffect effect:end_rod at:<[care].above[1]> offset:0.35 quantity:12 visibility:128
    - else:
        - modifyblock <[care]> air no_physics
        - flag server lapex.arena.loot_session:!
        - flag server lapex.arena.loot_round:!
        - flag server lapex.arena.loot_token:!

# No wait may be introduced before the claim flag write. Denizen queues execute
# serially until a wait, making the capacity check and list update one atomic
# section even when two players click during the same server tick.
lapex_arena_loot_claim:
    type: task
    debug: false
    definitions: kind|index|location
    script:
    - define session <server.flag[lapex.arena.session]||null>
    - define round <server.flag[lapex.arena.round]||0>
    - if <[session]> == null || <server.flag[lapex.arena.state]||none> != live:
        - actionbar "<red>Loot opens after the round starts."
        - stop
    - if <player.flag[lapex.arena_session]||null> != <[session]> || <player.has_flag[lapex.arena_eliminated]>:
        - stop
    - if <server.flag[lapex.arena.loot_session]||null> != <[session]> || <server.flag[lapex.arena.loot_round]||0> != <[round]>:
        - actionbar "<red>This container is not ready."
        - stop
    - if <[kind]> == care:
        # The original care package exposed three weapons. One atomic claim per
        # weapon keeps that contest meaningful on a larger 5v5 roster.
        - define capacity 3
        - define key care
    - else:
        - define capacity 2
        - define key supply_<[index]>
    - define claims <server.flag[lapex.arena.loot.<[session]>.<[round]>.<[key]>.claims]||<list>>
    - if <[claims].contains[<player.uuid>]>:
        - actionbar "<gray>You already searched this container."
        - stop
    - if <[claims].size> >= <[capacity]>:
        - actionbar "<red>This container is empty."
        - stop
    # Claim first, reward second. A reward error therefore fails closed instead
    # of reopening the same capacity slot for duplication.
    - define claims <[claims].include[<player.uuid>]>
    - flag server lapex.arena.loot.<[session]>.<[round]>.<[key]>.claims:<[claims]>
    - flag server lapex.arena.loot.<[session]>.<[round]>.<[key]>.capacity:<[capacity]>
    - if <[kind]> == care:
        - run lapex_arena_care_reward def.round:<[round]>
    - else:
        - run lapex_arena_supply_reward
    - playsound <[location]> sound:block.barrel.open pitch:1.1 volume:0.8
    - playeffect effect:happy_villager at:<[location].above[1]> offset:0.35 quantity:8 visibility:96
    - if <[claims].size> >= <[capacity]>:
        - modifyblock <[location]> gray_concrete no_physics
    - else:
        - actionbar "<yellow>Supply Bin <gray>- <white><[claims].size>/<[capacity]> claims"

lapex_arena_supply_reward:
    type: task
    debug: false
    script:
    - define gun_pool <list[alternator|flatline|r301|volt|g7_scout|eva8|wingman]>
    - define roll <util.random.int[1].to[100]>
    - if <[roll]> <= 65:
        - define id <[gun_pool].random>
        - give <item[apex_<[id]>]> to:<player.inventory>
        - actionbar "<green>Found <white><script[lapex_weapon_data].data_key[weapons.<[id]>.name]>"
    - else if <[roll]> <= 90:
        - give lapex_arena_syringe quantity:2 to:<player.inventory>
        - actionbar "<green>Found <white>2 Arena Syringes"
    - else:
        - give lapex_arena_med_kit to:<player.inventory>
        - actionbar "<green>Found <white>an Arena Med Kit"

# Later rounds pull from harder-hitting pools. Every entry remains a standard
# weapon, so care loot never leaks a legend-only gun into ordinary inventories.
lapex_arena_care_reward:
    type: task
    debug: false
    definitions: round
    script:
    - if <[round]> <= 2:
        - define pool <list[r301|flatline|volt|peacekeeper|wingman]>
        - define tier 1
    - else if <[round]> <= 4:
        - define pool <list[nemesis|spitfire|triple_take|mastiff|sentinel]>
        - define tier 2
    - else:
        - define pool <list[kraber|devotion|bocek|charge_rifle|peacekeeper]>
        - define tier 3
    - define id <[pool].random>
    - give <item[apex_<[id]>]> to:<player.inventory>
    - actionbar "<gold>Care Tier <[tier]> <gray>- <white><script[lapex_weapon_data].data_key[weapons.<[id]>.name]>"
    - playsound <player> sound:ui.toast.challenge_complete pitch:1.25 volume:0.7

# Console-safe static validation. It never creates claims, edits blocks, or
# requires the Arena world to be loaded.
lapex_arena_loot_smoke:
    type: task
    debug: false
    script:
    - define failures 0
    - define boxes <script[lapex_arena_data].data_key[loot_boxes]||<list>>
    - define care <script[lapex_arena_data].data_key[care_box]||null>
    - if <[boxes].size> != 6 || <[boxes].deduplicate.size> != <[boxes].size>:
        - narrate "<red>[Arena Loot] Expected six unique supply anchors."
        - define failures <[failures].add[1]>
    - if <[care]> == null || <[boxes].contains[<[care]>]>:
        - narrate "<red>[Arena Loot] Care anchor is missing or overlaps a supply anchor."
        - define failures <[failures].add[1]>
    - define ids <list[alternator|flatline|r301|volt|g7_scout|eva8|wingman|peacekeeper|nemesis|spitfire|triple_take|mastiff|sentinel|kraber|devotion|bocek|charge_rifle]>
    - foreach <[ids].deduplicate> as:id:
        - if !<script[lapex_weapon_data].data_key[standard_ids].contains[<[id]>]> || <item[apex_<[id]>]||null> == null:
            - narrate "<red>[Arena Loot] Invalid standard reward: <[id]>"
            - define failures <[failures].add[1]>
    - foreach <list[lapex_arena_syringe|lapex_arena_med_kit|lapex_arena_loot_reset|lapex_arena_loot_claim|lapex_arena_supply_reward|lapex_arena_care_reward]> as:script_id:
        - if <script[<[script_id]>]||null> == null:
            - narrate "<red>[Arena Loot] Missing script: <[script_id]>"
            - define failures <[failures].add[1]>
    - if <[failures]> == 0:
        - narrate "<green>Arena loot smoke passed: six atomic bins, one progressive care box, and standard rewards."
    - else:
        - narrate "<red>Arena loot smoke failed with <[failures]> problem(s)."
