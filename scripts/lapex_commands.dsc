lapex_command:
    type: command
    name: lapex
    description: Manages Lapex Apex weapons and legends.
    usage: /lapex <&lt>list|give|giveall|refill|legends|legend|setteam|tactical|ultimate|resetcooldowns|validate<&gt> [id]
    permission: lapex.admin
    permission message: <red>You do not have permission to manage Lapex weapons.
    tab completions:
        1: list|give|giveall|refill|legends|legend|setteam|tactical|ultimate|resetcooldowns|validate
        2: <script[lapex_weapon_data].data_key[all_ids].include[<script[lapex_legend_data].data_key[all_ids]>]>
    script:
    - define action <context.args.get[1]||help>
    - define registry <script[lapex_weapon_data].data_key[weapons]>
    - choose <[action]>:
        - case list:
            - narrate "<gold><bold>Lapex Arsenal <gray>- 29 standard + 3 legend guns"
            - narrate "<yellow>AR <dark_gray>| <white>havoc, flatline, hemlok_breach, r301, nemesis"
            - narrate "<yellow>SMG <dark_gray>| <white>alternator, prowler, r99, volt, car"
            - narrate "<yellow>LMG <dark_gray>| <white>devotion, lstar, spitfire, rampage"
            - narrate "<yellow>Marksman <dark_gray>| <white>g7_scout, triple_take, repeater_3030, bocek"
            - narrate "<yellow>Sniper <dark_gray>| <white>charge_rifle, longbow, kraber, sentinel"
            - narrate "<yellow>Shotgun <dark_gray>| <white>eva8, mastiff, mozambique, peacekeeper"
            - narrate "<yellow>Pistol <dark_gray>| <white>re45_burst, p2020, wingman"
            - narrate "<red>Legend <dark_gray>| <white>sheila, a13_sentry, whistler"
        - case give:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - define id <context.args.get[2]||null>
            - if <[id]> == null || !<[registry].keys.contains[<[id]>]>:
                - narrate "<red>Unknown weapon. Use <white>/lapex list<red>."
                - stop
            - define item_name apex_<[id]>
            - give <item[<[item_name]>]>
            - narrate "<green>Given <gold><[registry].get[<[id]>].get[name]><green>."
        - case giveall:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - foreach <script[lapex_weapon_data].data_key[all_ids]> as:id:
                - define item_name apex_<[id]>
                - give <item[<[item_name]>]>
            - narrate "<green>Given all 32 Lapex guns."
        - case refill:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - define id <player.item_in_hand.flag[lapex.id]||null>
            - if <[id]> == null || !<[registry].keys.contains[<[id]>]>:
                - narrate "<red>Hold a Lapex gun first."
                - stop
            - inventory flag slot:hand lapex.ammo:<[registry].get[<[id]>].get[mag]>
            - narrate "<green>Refilled <gold><[registry].get[<[id]>].get[name]><green>."
        - case legends:
            - narrate "<gold><bold>Lapex Legends <gray>- 28 playable kits"
            - narrate "<red>Assault <dark_gray>| <white>ballistic, bangalore, fuse, mad_maggie, revenant"
            - narrate "<aqua>Skirmisher <dark_gray>| <white>alter, ash, axle, horizon, octane, pathfinder, wraith"
            - narrate "<green>Recon <dark_gray>| <white>bloodhound, crypto, seer, sparrow, valkyrie, vantage"
            - narrate "<yellow>Controller <dark_gray>| <white>catalyst, caustic, rampart, wattson"
            - narrate "<blue>Support <dark_gray>| <white>conduit, gibraltar, lifeline, loba, mirage, newcastle"
        - case legend:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - define id <context.args.get[2]||null>
            - if <[id]> == null || !<script[lapex_legend_data].data_key[all_ids].contains[<[id]>]>:
                - narrate "<red>Unknown legend. Use <white>/lapex legends<red>."
                - stop
            - run lapex_legend_select def.id:<[id]>
        - case setteam:
            - define target <server.match_player[<context.args.get[2]||null>]||null>
            - define team <context.args.get[3]||null>
            - if <[target]> == null || <[team]> == null:
                - narrate "<red>Usage: <white>/lapex setteam <player> <name|clear>"
                - stop
            - if <[team]> == clear:
                - flag <[target]> lapex.team:!
                - narrate "<green>Cleared <white><[target].name><green>'s legend team."
            - else:
                - flag <[target]> lapex.team:<[team].to_lowercase>
                - narrate "<green>Set <white><[target].name><green>'s legend team to <white><[team].to_lowercase><green>."
        - case tactical:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - run lapex_legend_activate def.slot:tactical
        - case ultimate:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - run lapex_legend_activate def.slot:ultimate
        - case resetcooldowns:
            - if <context.source_type> != player:
                - narrate "<red>This action requires a player command source."
                - stop
            - flag player lapex.cooldown:!
            - narrate "<green>Legend cooldowns reset."
        - case validate:
            - run lapex_validate
        - default:
            - narrate "<gold>/lapex list"
            - narrate "<gold>/lapex give <white><weapon>"
            - narrate "<gold>/lapex giveall"
            - narrate "<gold>/lapex refill"
            - narrate "<gold>/lapex legends <dark_gray>| <gold>/lapex legend <white><legend>"
            - narrate "<gold>/lapex setteam <white><player> <team|clear>"
            - narrate "<gold>/lapex tactical <dark_gray>| <gold>/lapex ultimate"

# Console-safe runtime smoke test. This deliberately instantiates every item;
# Denizen otherwise defers some item/material/mechanism errors until first use.
lapex_validate:
    type: task
    debug: false
    script:
    - define registry <script[lapex_weapon_data].data_key[weapons]>
    - define ids <script[lapex_weapon_data].data_key[all_ids]>
    - define failures 0
    - narrate "<yellow>Lapex validation started for <[ids].size> guns..."
    - foreach <[ids]> as:id:
        - if !<[registry].keys.contains[<[id]>]>:
            - narrate "<red>[Lapex] Missing registry entry: <[id]>"
            - define failures <[failures].add[1]>
            - foreach next
        - define weapon <[registry].get[<[id]>]>
        - define item_name apex_<[id]>
        - define built_item <item[<[item_name]>]||null>
        - if <[built_item]> == null:
            - narrate "<red>[Lapex] Missing item script: <[item_name]>"
            - define failures <[failures].add[1]>
            - foreach next
        - if <[built_item].material.name> != carrot_on_a_stick:
            - narrate "<red>[Lapex] Right-click input material mismatch: <[item_name]>"
            - define failures <[failures].add[1]>
        - if <[built_item].flag[lapex.id]||null> != <[id]>:
            - narrate "<red>[Lapex] Item ID mismatch: <[item_name]>"
            - define failures <[failures].add[1]>
        - if <[built_item].flag[lapex.ammo]||0> != <[weapon].get[mag]>:
            - narrate "<red>[Lapex] Initial magazine mismatch: <[id]>"
            - define failures <[failures].add[1]>
        # Force required values through the object conversions used by runtime.
        - define checked_damage <[weapon].get[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
        - define checked_rpm <element[1200].div[<[weapon].get[rpm]>]>
        - define checked_range <[weapon].get[range].round>
        - define checked_mag <[weapon].get[mag].round>
        - define checked_reload <duration[<[weapon].get[reload]>].in_ticks>
        - define checked_empty_reload <duration[<[weapon].get[empty_reload]>].in_ticks>
        - define checked_recoil <[weapon].get[recoil_pitch].add[<[weapon].get[recoil_yaw]>]>
        - define checked_spread <[weapon].get[hip_spread].add[<[weapon].get[ads_spread]>]>
    - if <[registry].size> != <[ids].size>:
        - narrate "<red>[Lapex] Registry/list size mismatch: <[registry].size>/<[ids].size>"
        - define failures <[failures].add[1]>
    - define legend_registry <script[lapex_legend_data].data_key[legends]>
    - define legend_ids <script[lapex_legend_data].data_key[all_ids]>
    - narrate "<yellow>Lapex validation continuing for <[legend_ids].size> legends..."
    - foreach <[legend_ids]> as:id:
        - if !<[legend_registry].keys.contains[<[id]>]>:
            - narrate "<red>[Lapex] Missing legend registry entry: <[id]>"
            - define failures <[failures].add[1]>
            - foreach next
        - define kit <[legend_registry].get[<[id]>]>
        - define tactical_script <script[lapex_tactical_<[id]>]||null>
        - define ultimate_script <script[lapex_ultimate_<[id]>]||null>
        - if <[tactical_script]> == null || <[ultimate_script]> == null:
            - narrate "<red>[Lapex] Missing active ability task for <[id]>"
            - define failures <[failures].add[1]>
        - foreach <list[name|class|passive|tactical|ultimate|passive_note|tactical_note|ultimate_note|tactical_cooldown|ultimate_cooldown]> as:key:
            - if !<[kit].contains[<[key]>]>:
                - narrate "<red>[Lapex] <[id]> is missing <[key]>"
                - define failures <[failures].add[1]>
        - if !<[kit].contains[tactical_cooldown]> || !<[kit].contains[ultimate_cooldown]>:
            - foreach next
        - define checked_tactical <duration[<[kit].get[tactical_cooldown]>].in_ticks>
        - define checked_ultimate <duration[<[kit].get[ultimate_cooldown]>].in_ticks>
        - if <[checked_tactical]> <= 0 || <[checked_ultimate]> <= 0:
            - narrate "<red>[Lapex] Invalid cooldown on <[id]>"
            - define failures <[failures].add[1]>
    - if <[legend_registry].size> != 28 || <[legend_ids].size> != 28:
        - narrate "<red>[Lapex] Legend registry/list size mismatch: <[legend_registry].size>/<[legend_ids].size>"
        - define failures <[failures].add[1]>
    - if <[failures]> == 0:
        - narrate "<green>Lapex validation passed: <[ids].size> guns and <[legend_ids].size> legends resolved."
    - else:
        - narrate "<red>Lapex validation failed with <[failures]> problem(s)."
