# Arena Foundry 5v5 match authority.
#
# Runtime state intentionally lives under the flat lapex.arena namespace. Every
# delayed task also receives the session UUID and compares it before changing
# state, so an old round can never mutate a newer match.

lapex_arena_events:
    type: world
    debug: false
    events:
        on server start:
        - wait 1t
        - if <server.has_flag[lapex.arena.session]>:
            - run lapex_arena_cleanup def.session:<server.flag[lapex.arena.session]> def.reason:server_start

        on pre script reload:
        - if <server.has_flag[lapex.arena.session]>:
            - run lapex_arena_cleanup def.session:<server.flag[lapex.arena.session]> def.reason:scripts_reload

        on player joins:
        - wait 2t
        - if <player.has_flag[lapex.arena_restore_pending]>:
            - run lapex_arena_restore_player def.target:<player>
            - stop
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null:
            - stop
        - if <server.flag[lapex.arena.session]||null> != <[session]>:
            - run lapex_arena_restore_player def.target:<player>
            - stop
        - define state <server.flag[lapex.arena.state]||lobby>
        - if <[state]> == lobby:
            - run lapex_arena_send_to_staging def.target:<player> def.session:<[session]>
        - else:
            # Disconnecting forfeits the current slot. This path is defensive
            # for servers that stopped between quit processing and flag save.
            - flag player lapex.arena_eliminated
            - adjust player gamemode:spectator
            - run lapex_arena_send_to_spectator def.target:<player> def.session:<[session]>

        on player quits:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - run lapex_arena_disconnect def.target:<player> def.session:<[session]>

        on player changes world:
        - if <player.has_flag[lapex.arena_transfer]>:
            - stop
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - run lapex_arena_leave def.target:<player> def.session:<[session]> def.reason:world_change

        on player dies:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - if <server.flag[lapex.arena.state]||none> != live:
            - determine passively KEEP_INV
            - determine passively NO_DROPS
            - determine NO_XP
        - flag player lapex.arena_eliminated
        - determine passively KEEP_INV
        - determine passively NO_DROPS
        - determine passively NO_XP
        - run lapex_arena_check_round def.session:<[session]> delay:1t

        on player respawns:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - if !<player.has_flag[lapex.arena_eliminated]>:
            - stop
        - wait 1t
        - if <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - adjust player gamemode:spectator
        - run lapex_arena_send_to_spectator def.target:<player> def.session:<[session]>

        on player damaged:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> != null && <server.flag[lapex.arena.session]||null> == <[session]>:
            - if <server.flag[lapex.arena.state]||none> != live || <player.has_flag[lapex.arena_eliminated]>:
                - determine cancelled
            - define incoming <context.final_damage||<context.damage||0>>
            - if <player.health.sub[<[incoming]>]> <= 0:
                # Arena eliminations never open Minecraft's death screen. The
                # death event below remains a fallback for bypassing damage.
                - determine passively cancelled
                - adjust player health:1
                - flag player lapex.arena_eliminated
                - run lapex_arena_cancel_ability_queues def.target:<player>
                - adjust player gamemode:spectator
                - run lapex_arena_send_to_spectator def.target:<player> def.session:<[session]>
                - run lapex_arena_check_round def.session:<[session]> delay:1t

        on player damages player:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - if <context.entity.flag[lapex.arena_session]||null> == <[session]> && <context.entity.flag[lapex.arena_team]||null> == <player.flag[lapex.arena_team]||none>:
            - determine cancelled

        on player damages entity:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]>:
            - stop
        - if <context.entity.has_flag[lapex.arena_bot]> && <context.entity.flag[lapex.arena_session]||null> == <[session]> && <context.entity.flag[lapex.arena_team]||null> == <player.flag[lapex.arena_team]||none>:
            - determine cancelled

        # Round gear belongs to the match snapshot and must never leak into the
        # persistent world or another player's restored inventory.
        on player drops item:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> != null && <server.flag[lapex.arena.session]||null> == <[session]>:
            - determine cancelled

        # Prep pads are small cages rather than a global movement freeze. A
        # player may look and shuffle, but cannot leave the authored spawn pad.
        on player steps on *:
        - define session <player.flag[lapex.arena_session]||null>
        - if <[session]> == null || <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != prep:
            - stop
        - define anchor <player.flag[lapex.arena_prep_spawn]||null>
        - define destination <context.new_location>
        - if <[anchor]> != null && <[destination].world> == <[anchor].world>:
            - if <[destination].x> < <[anchor].x.sub[5]> || <[destination].x> > <[anchor].x.add[5]> || <[destination].z> < <[anchor].z.sub[5]> || <[destination].z> > <[anchor].z.add[5]>:
                - determine cancelled

lapex_arena_command:
    type: command
    debug: false
    name: arena
    description: Joins and controls Arena Foundry 5v5 matches.
    usage: /arena <&lt>join|leave|loadout|start|stop|status|validate<&gt> [team|weapon]
    tab completions:
        1: join|leave|loadout|start|stop|status|validate
        2: red|blue|<script[lapex_weapon_data].data_key[standard_ids]>
    script:
    - define action <context.args.get[1].to_lowercase||status>
    - define admin_actions <list[start|stop|validate]>
    - if <[admin_actions].contains[<[action]>]>:
        - if <context.source_type> == player && !<player.has_permission[lapex.admin]>:
            - narrate "<red>This Arena action requires <white>lapex.admin<red>."
            - stop
    - else if <[action]> != status:
        - if <context.source_type> != player:
            - narrate "<red>This Arena action requires a player command source."
            - stop
        - if !<player.has_permission[lapex.arena.play]>:
            - narrate "<red>Playing Arena requires <white>lapex.arena.play<red>."
            - stop
    - choose <[action]>:
        - case join:
            - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
            - if <world[<[world_name]>]||null> == null || !<server.has_flag[lapex.arena_map.v1.complete]>:
                - narrate "<red>Arena Foundry is not ready. An admin must run <white>/lapexarena create<red> and <white>/lapexarena build<red>."
                - stop
            - define session <server.flag[lapex.arena.session]||null>
            - if <[session]> == null:
                - run lapex_arena_open
                - define session <server.flag[lapex.arena.session]>
            - if <server.flag[lapex.arena.state]||none> != lobby:
                - narrate "<red>This match has already started. Wait for the next lobby."
                - stop
            - if <player.flag[lapex.arena_session]||null> == <[session]>:
                - narrate "<yellow>You are already on <white><player.flag[lapex.arena_team]><yellow>."
                - stop
            - if <player.has_flag[lapex.arena_session]> || <player.has_flag[lapex.arena_restore_pending]>:
                - run lapex_arena_restore_player def.target:<player>
            - define requested <context.args.get[2].to_lowercase||auto>
            - if !<list[auto|red|blue].contains[<[requested]>]>:
                - narrate "<red>Choose <white>red<red> or <white>blue<red>."
                - stop
            - define red <server.flag[lapex.arena.players.red]||<list>>
            - define blue <server.flag[lapex.arena.players.blue]||<list>>
            - if <[requested]> == auto:
                - if <[red].size> <= <[blue].size>:
                    - define requested red
                - else:
                    - define requested blue
            - define cap <script[lapex_arena_data].data_key[max_team_size]||5>
            - define roster <server.flag[lapex.arena.players.<[requested]>]||<list>>
            - if <[roster].size> >= <[cap]>:
                - narrate "<red>The <[requested]> team is full (<[cap]>/<[cap]>)."
                - stop
            - run lapex_arena_save_player def.target:<player>
            - run lapex_arena_clear_player_transients def.target:<player>
            - flag player lapex.arena_session:<[session]>
            - flag player lapex.arena_team:<[requested]>
            - flag player lapex.arena_eliminated:!
            - flag player lapex.team:arena_<[session]>_<[requested]>
            - flag server lapex.arena.players.<[requested]>:<[roster].include[<player>].deduplicate>
            - inventory clear destination:<player.inventory>
            - adjust player gamemode:adventure
            - run lapex_arena_send_to_staging def.target:<player> def.session:<[session]>
            - narrate "<green>Joined Arena Foundry on <white><[requested]><green>. Loadout: <white><player.flag[lapex.arena_loadout]||r301><green>."

        - case leave:
            - define session <player.flag[lapex.arena_session]||null>
            - if <[session]> == null:
                - narrate "<gray>You are not in an Arena match."
                - stop
            - run lapex_arena_leave def.target:<player> def.session:<[session]> def.reason:command

        - case loadout:
            - define id <context.args.get[2].to_lowercase||null>
            - if <[id]> == null || !<script[lapex_weapon_data].data_key[standard_ids].contains[<[id]>]>:
                - narrate "<red>Choose a standard Lapex weapon. Example: <white>/arena loadout r301"
                - stop
            - flag player lapex.arena_loadout:<[id]>
            - narrate "<green>Primary set to <white><script[lapex_weapon_data].data_key[weapons.<[id]>.name]><green>. Every round also includes a P2020."

        - case start:
            - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
            - if <world[<[world_name]>]||null> == null:
                - narrate "<red>Arena Foundry is not loaded. Use <white>/lapexarena create<red>."
                - stop
            - if !<server.has_flag[lapex.arena_map.v1.complete]>:
                - narrate "<red>Arena Foundry is not built. Use <white>/lapexarena build<red>."
                - stop
            - define session <server.flag[lapex.arena.session]||null>
            - if <[session]> == null:
                - run lapex_arena_open
                - define session <server.flag[lapex.arena.session]>
            - if <server.flag[lapex.arena.state]||none> != lobby:
                - narrate "<red>An Arena match is already <white><server.flag[lapex.arena.state]><red>."
                - stop
            - narrate "<green>Starting Arena session <white><[session]><green>. Empty slots will use playtest AI."
            - run lapex_arena_prepare_round def.session:<[session]>

        - case stop:
            - define session <server.flag[lapex.arena.session]||null>
            - if <[session]> == null:
                - narrate "<gray>No Arena session is active."
                - stop
            - run lapex_arena_cleanup def.session:<[session]> def.reason:admin_stop
            - narrate "<yellow>Arena session stopped and player state restored."

        - case status:
            - define session <server.flag[lapex.arena.session]||null>
            - if <[session]> == null:
                - narrate "<gray>Arena Foundry has no active session. Use <white>/arena join<gray>."
                - stop
            - narrate "<gold>Arena Foundry <dark_gray>| <gray>state <white><server.flag[lapex.arena.state]||none> <dark_gray>| <gray>round <white><server.flag[lapex.arena.round]||0>"
            - narrate "<red>RED <white><server.flag[lapex.arena.score.red]||0> <gray>(players <white><server.flag[lapex.arena.players.red].size||0><gray>, bots <white><server.flag[lapex.arena.bots.red].size||0><gray>) <dark_gray>| <blue>BLUE <white><server.flag[lapex.arena.score.blue]||0> <gray>(players <white><server.flag[lapex.arena.players.blue].size||0><gray>, bots <white><server.flag[lapex.arena.bots.blue].size||0><gray>)"

        - case validate:
            - run lapex_arena_match_validate

        - default:
            - narrate "<gold>/arena join <white>[red|blue] <dark_gray>| <gold>/arena leave"
            - narrate "<gold>/arena loadout <white><standard_weapon> <dark_gray>| <gold>/arena status"
            - narrate "<gold>/arena start <dark_gray>| <gold>/arena stop <dark_gray>| <gold>/arena validate"

lapex_arena_open:
    type: task
    debug: false
    script:
    - if <server.has_flag[lapex.arena.session]>:
        - stop
    - define session <util.random_uuid>
    - flag server lapex.arena.session:<[session]>
    - flag server lapex.arena.state:lobby
    - flag server lapex.arena.round:0
    - flag server lapex.arena.score.red:0
    - flag server lapex.arena.score.blue:0
    - flag server lapex.arena.players.red:<list>
    - flag server lapex.arena.players.blue:<list>
    - flag server lapex.arena.bots.red:<list>
    - flag server lapex.arena.bots.blue:<list>
    - flag server lapex.arena.phase_token:<util.random_uuid>
    - run lapex_arena_hud_loop def.session:<[session]>

# Save once, before the lobby changes any player-owned state.
lapex_arena_save_player:
    type: task
    debug: false
    definitions: target
    script:
    - if <[target].has_flag[lapex.arena_saved.location]>:
        - stop
    - flag <[target]> lapex.arena_saved.inventory:<[target].inventory.list_contents>
    - flag <[target]> lapex.arena_saved.location:<[target].location>
    - flag <[target]> lapex.arena_saved.gamemode:<[target].gamemode>
    - flag <[target]> lapex.arena_saved.health:<[target].health>
    - flag <[target]> lapex.arena_saved.absorption:<[target].absorption_health>
    - flag <[target]> lapex.arena_saved.food:<[target].food_level>
    - flag <[target]> lapex.arena_saved.effects:<[target].effects_data>
    - foreach <list[tactical|ultimate]> as:slot:
        - define cooldown_key lapex.cooldown.<[slot]>
        - flag <[target]> lapex.arena_saved.cooldown.<[slot]>.present:<[target].has_flag[<[cooldown_key]>]>
        - if <[target].has_flag[<[cooldown_key]>]>:
            - flag <[target]> lapex.arena_saved.cooldown.<[slot]>.expiration:<[target].flag_expiration[<[cooldown_key]>]||null>
    - foreach <list[charges|charge_due|charge_groups]> as:state:
        - flag <[target]> lapex.arena_saved.<[state]>.present:<[target].has_flag[lapex.<[state]>]>
        - if <[target].has_flag[lapex.<[state]>]>:
            - flag <[target]> lapex.arena_saved.<[state]>.value:<[target].flag[lapex.<[state]>]>
    - flag <[target]> lapex.arena_saved.had_team:<[target].has_flag[lapex.team]>
    - if <[target].has_flag[lapex.team]>:
        - flag <[target]> lapex.arena_saved.team:<[target].flag[lapex.team]>

lapex_arena_restore_player:
    type: task
    debug: false
    definitions: target
    script:
    - if !<[target].is_online>:
        - flag <[target]> lapex.arena_restore_pending
        - stop
    - if <script[lapex_crypto_exit]||null> != null && <[target].has_flag[lapex.crypto_active]>:
        - run lapex_crypto_exit def.owner:<[target]> def.reason:arena_restore
    - if <script[lapex_deployable_cleanup_owner]||null> != null:
        - run lapex_deployable_cleanup_owner def.owner:<[target]>
    - if <script[lapex_mobility_cleanup_player]||null> != null:
        - run lapex_mobility_cleanup_player def.target:<[target]> def.reason:arena_restore
    - if <script[lapex_weapon_reset_transient]||null> != null:
        - run lapex_weapon_reset_transient def.target:<[target]>
    - run lapex_arena_cancel_ability_queues def.target:<[target]>
    - run lapex_arena_clear_player_transients def.target:<[target]>
    - inventory clear destination:<[target].inventory>
    # Saved inventory contents are a ListTag. Denizen only populates foreach's
    # key definition for maps, so use the one-based loop index as the slot.
    - foreach <[target].flag[lapex.arena_saved.inventory]||<list>> as:item:
        - inventory set destination:<[target].inventory> origin:<[item]> slot:<[loop_index]>
    - define old_gamemode <[target].flag[lapex.arena_saved.gamemode]||survival>
    - adjust <[target]> gamemode:<[old_gamemode]>
    - define old_location <[target].flag[lapex.arena_saved.location]||null>
    - if <[old_location]> != null:
        - flag <[target]> lapex.arena_transfer expire:2s
        - teleport <[target]> <[old_location]>
    - define old_health <[target].flag[lapex.arena_saved.health]||<[target].health_max>>
    - adjust <[target]> health:<[old_health].min[<[target].health_max>]>
    - adjust <[target]> absorption_health:<[target].flag[lapex.arena_saved.absorption]||0>
    - adjust <[target]> food_level:<[target].flag[lapex.arena_saved.food]||20>
    - define saved_effects <[target].flag[lapex.arena_saved.effects]||<list>>
    - if !<[saved_effects].is_empty>:
        - adjust <[target]> potion_effects:<[saved_effects]>
    - flag <[target]> lapex.cooldown:!
    - foreach <list[tactical|ultimate]> as:slot:
        - if <[target].flag[lapex.arena_saved.cooldown.<[slot]>.present]||false>:
            - define expiration <[target].flag[lapex.arena_saved.cooldown.<[slot]>.expiration]||null>
            - if <[expiration]> == null:
                - flag <[target]> lapex.cooldown.<[slot]>
            - else if <[expiration].is_after[<util.time_now>]>:
                - flag <[target]> lapex.cooldown.<[slot]> expire:<[expiration].duration_since[<util.time_now>]>
    - foreach <list[charges|charge_due|charge_groups]> as:state:
        - flag <[target]> lapex.<[state]>:!
        - if <[target].flag[lapex.arena_saved.<[state]>.present]||false>:
            - flag <[target]> lapex.<[state]>:<[target].flag[lapex.arena_saved.<[state]>.value]>
    - flag <[target]> lapex.charge_transaction:!
    - if <[target].flag[lapex.arena_saved.had_team]||false>:
        - flag <[target]> lapex.team:<[target].flag[lapex.arena_saved.team]>
    - else:
        - flag <[target]> lapex.team:!
    - flag <[target]> lapex.arena_session:!
    - flag <[target]> lapex.arena_team:!
    - flag <[target]> lapex.arena_eliminated:!
    - flag <[target]> lapex.arena_prep_spawn:!
    - flag <[target]> lapex.arena_restore_pending:!
    - flag <[target]> lapex.arena_saved:!

# Match rounds may create potion, movement, shield, scan, and protection state.
# Keep those short-lived combat flags inside the session and restore the saved
# potion list separately when the player leaves.
lapex_arena_clear_player_transients:
    type: task
    debug: false
    definitions: target
    script:
    - adjust <[target]> remove_effects
    - burn <[target]> duration:0s
    - foreach <list[legend_lock|legend_protected|legend_silenced|legend_grounded|phased|tempest|amped_cover|pylon_protected|halo_active|lifeline_halo_active|forged_shadows|stim_active|stim_surge|stim_surge_cooldown|low_health|recent_damage|threatened_by]> as:state:
        - flag <[target]> lapex.<[state]>:!

# Legend actives run in child queues. Stop queues linked to this participant so
# an effect cast at the end of one round cannot resume in the next live phase.
lapex_arena_cancel_ability_queues:
    type: task
    debug: false
    definitions: target
    script:
    - define ability_scripts <list[lapex_caustic_gas_pulse|lapex_legend_scan|lapex_whistler_mine]>
    - foreach <script[lapex_legend_data].data_key[all_ids]> as:id:
        - define ability_scripts <[ability_scripts].include[lapex_tactical_<[id]>].include[lapex_ultimate_<[id]>]>
    - foreach <[ability_scripts]> as:script_id:
        - define active_script <script[<[script_id]>]||null>
        - if <[active_script]> == null:
            - foreach next
        - foreach <[active_script].queues> as:ability_queue:
            - if <[ability_queue].linked_player||null> == <[target]>:
                - queue <[ability_queue]> stop

lapex_arena_send_to_staging:
    type: task
    debug: false
    definitions: target|session
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || !<[target].is_online>:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define coordinates <script[lapex_arena_data].data_key[staging]||0,125,0>
    - flag <[target]> lapex.arena_transfer expire:2s
    - teleport <[target]> <location[<[coordinates]>,<[world_name]>]>

lapex_arena_send_to_spectator:
    type: task
    debug: false
    definitions: target|session
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || !<[target].is_online>:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define coordinates <script[lapex_arena_data].data_key[spectator_spawn]||<script[lapex_arena_data].data_key[staging]||0,125,0>>
    - flag <[target]> lapex.arena_transfer expire:2s
    - teleport <[target]> <location[<[coordinates]>,<[world_name]>]>

lapex_arena_leave:
    type: task
    debug: false
    definitions: target|session|reason
    script:
    - define team <[target].flag[lapex.arena_team]||null>
    - if <server.flag[lapex.arena.session]||null> == <[session]> && <list[red|blue].contains[<[team]>]>:
        - define roster <server.flag[lapex.arena.players.<[team]>]||<list>>
        - flag server lapex.arena.players.<[team]>:<[roster].exclude[<[target]>]>
    - run lapex_arena_restore_player def.target:<[target]>
    - if <[target].is_online>:
        - narrate "<yellow>You left Arena Foundry." targets:<[target]>
    - if <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.state]||none> == live:
        - run lapex_arena_check_round def.session:<[session]> delay:1t

# Quit cannot safely write an offline inventory. Remove the combat slot now and
# defer the exact snapshot restoration until the player's next join.
lapex_arena_disconnect:
    type: task
    debug: false
    definitions: target|session
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]>:
        - stop
    - define team <[target].flag[lapex.arena_team]||null>
    - if <list[red|blue].contains[<[team]>]>:
        - define roster <server.flag[lapex.arena.players.<[team]>]||<list>>
        - flag server lapex.arena.players.<[team]>:<[roster].exclude[<[target]>]>
    - flag <[target]> lapex.arena_eliminated
    - flag <[target]> lapex.arena_restore_pending
    - run lapex_arena_cancel_ability_queues def.target:<[target]>
    - if <script[lapex_deployable_cleanup_owner]||null> != null:
        - run lapex_deployable_cleanup_owner def.owner:<[target]>
    - if <server.flag[lapex.arena.state]||none> == live:
        - run lapex_arena_check_round def.session:<[session]> delay:1t

lapex_arena_prepare_round:
    type: task
    debug: false
    definitions: session
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]>:
        - stop
    - define old_state <server.flag[lapex.arena.state]||lobby>
    - if !<proc[lapex_arena_phase_can_transition].context[<[old_state]>|prep]>:
        - narrate "<red>[Arena] Refused invalid phase <[old_state]> -> prep."
        - stop
    - flag server lapex.arena.state:prep
    - flag server lapex.arena.phase_token:<util.random_uuid>
    - flag server lapex.arena.round:<server.flag[lapex.arena.round].add[1]||1>
    - define round <server.flag[lapex.arena.round]>
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> == null:
        - run lapex_arena_cleanup def.session:<[session]> def.reason:missing_world
        - stop
    - if <script[lapex_arena_bots_cleanup]||null> != null:
        - run lapex_arena_bots_cleanup def.session:<[session]>
    - if <script[lapex_arena_loot_reset]||null> != null:
        - run lapex_arena_loot_reset def.session:<[session]> def.round:<[round]>
    - define center <location[0,<script[lapex_arena_data].data_key[floor_y]||63>,0,<[world_name]>]>
    - define ring_start <script[lapex_arena_data].data_key[ring.start_size]||208>
    - worldborder <[map_world]> center:<[center]> size:<[ring_start]> warningdistance:8 damage:8 damagebuffer:0
    - foreach <list[red|blue]> as:team:
        - define spawns <script[lapex_arena_data].data_key[team_spawns.<[team]>]||<list>>
        - define slot 1
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if !<[target].is_online> || <[target].flag[lapex.arena_session]||null> != <[session]>:
                - define slot <[slot].add[1]>
                - foreach next
            - if <script[lapex_crypto_exit]||null> != null && <[target].has_flag[lapex.crypto_active]>:
                - run lapex_crypto_exit def.owner:<[target]> def.reason:arena_round
            - if <script[lapex_deployable_cleanup_owner]||null> != null:
                - run lapex_deployable_cleanup_owner def.owner:<[target]>
            - if <script[lapex_mobility_cleanup_player]||null> != null:
                - run lapex_mobility_cleanup_player def.target:<[target]> def.reason:arena_round
            - run lapex_arena_cancel_ability_queues def.target:<[target]>
            - run lapex_arena_clear_player_transients def.target:<[target]>
            - flag <[target]> lapex.arena_eliminated:!
            - flag <[target]> lapex.team:arena_<[session]>_<[team]>
            - flag <[target]> lapex.cooldown:!
            - flag <[target]> lapex.charges:!
            - flag <[target]> lapex.charge_due:!
            - flag <[target]> lapex.charge_groups:!
            - inventory clear destination:<[target].inventory>
            - define primary <[target].flag[lapex.arena_loadout]||r301>
            - if !<script[lapex_weapon_data].data_key[standard_ids].contains[<[primary]>]>:
                - define primary r301
            - give <item[apex_<[primary]>]> to:<[target].inventory> slot:1
            - give <item[apex_p2020]> to:<[target].inventory> slot:2
            - adjust <[target]> gamemode:adventure
            - adjust <[target]> health:<[target].health_max>
            - adjust <[target]> absorption_health:0
            - adjust <[target]> food_level:20
            - define coordinates <[spawns].get[<[slot]>]||<[spawns].first||0,65,0>>
            - define spawn <location[<[coordinates]>,<[world_name]>]>
            - flag <[target]> lapex.arena_prep_spawn:<[spawn]>
            - flag <[target]> lapex.arena_transfer expire:2s
            - teleport <[target]> <[spawn]>
            - title "title:<[team].to_uppercase> TEAM" "subtitle:<yellow>Round <[round]> starts in <script[lapex_arena_data].data_key[prep_seconds]||30>s" fade_in:5t stay:2s fade_out:10t targets:<[target]>
            - define slot <[slot].add[1]>
    - define prep_seconds <script[lapex_arena_data].data_key[prep_seconds]||30>
    - flag server lapex.arena.phase_remaining:<[prep_seconds]>
    - run lapex_arena_prep_countdown def.session:<[session]> def.round:<[round]> def.remaining:<[prep_seconds]>

lapex_arena_prep_countdown:
    type: task
    debug: false
    definitions: session|round|remaining
    script:
    - repeat <[remaining]>:
        - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != prep || <server.flag[lapex.arena.round]||0> != <[round]>:
            - stop
        - define left <[remaining].sub[<[value]>].add[1]>
        - flag server lapex.arena.phase_remaining:<[left]>
        - if <[left]> <= 5:
            - run lapex_arena_announce def.session:<[session]> "def.message:<yellow>Round <[round]> starts in <white><[left]>"
        - wait 1s
    - if <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.state]||none> == prep && <server.flag[lapex.arena.round]||0> == <[round]>:
        - run lapex_arena_begin_live def.session:<[session]> def.round:<[round]>

lapex_arena_begin_live:
    type: task
    debug: false
    definitions: session|round
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != prep || <server.flag[lapex.arena.round]||0> != <[round]>:
        - stop
    - if !<proc[lapex_arena_phase_can_transition].context[prep|live]>:
        - stop
    - flag server lapex.arena.state:live
    - flag server lapex.arena.phase_token:<util.random_uuid>
    - flag server lapex.arena.phase_remaining:!
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if <[target].is_online> && <[target].flag[lapex.arena_session]||null> == <[session]>:
                - adjust <[target]> gamemode:survival
                - title "title:<gold>ROUND <[round]>" "subtitle:<white>Fight! Last team standing wins." fade_in:2t stay:1s fade_out:8t targets:<[target]>
    # External systems must receive the UUID and reject stale invocations.
    - if <script[lapex_arena_bots_fill]||null> != null:
        - ~run lapex_arena_bots_fill def.session:<[session]>
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - run lapex_arena_ring def.session:<[session]> def.round:<[round]>
    - run lapex_arena_round_timeout def.session:<[session]> def.round:<[round]>
    - run lapex_arena_check_round def.session:<[session]> delay:2t

lapex_arena_ring:
    type: task
    debug: false
    definitions: session|round
    script:
    - define delay <script[lapex_arena_data].data_key[ring.delay]||45s>
    - wait <[delay]>
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <server.flag[lapex.arena.round]||0> != <[round]>:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> == null:
        - stop
    - define center <location[0,<script[lapex_arena_data].data_key[floor_y]||63>,0,<[world_name]>]>
    - define start_size <script[lapex_arena_data].data_key[ring.start_size]||208>
    - define final_size <script[lapex_arena_data].data_key[ring.final_size]||44>
    - define shrink <script[lapex_arena_data].data_key[ring.shrink]||90s>
    - worldborder <[map_world]> center:<[center]> current_size:<[start_size]> size:<[final_size]> duration:<[shrink]> warningdistance:8 damage:8 damagebuffer:0
    # `shrink` is already a DurationTag (for example `90s`). Its plain text is
    # valid player-facing output; `.formatted` is not a DurationTag mechanism.
    - run lapex_arena_announce def.session:<[session]> "def.message:<red>Ring closing <dark_gray>| <white><[shrink]>"

# A normal timeout starts Apex-style sudden death instead of selecting a winner
# by arbitrary health math. The lethal final ring keeps the result combat-owned.
lapex_arena_round_timeout:
    type: task
    debug: false
    definitions: session|round
    script:
    - wait <script[lapex_arena_data].data_key[round_seconds]||180>s
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live || <server.flag[lapex.arena.round]||0> != <[round]>:
        - stop
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> == null:
        - stop
    - define center <location[0,<script[lapex_arena_data].data_key[floor_y]||63>,0,<[world_name]>]>
    - worldborder <[map_world]> center:<[center]> size:2 duration:15s warningdistance:2 damage:20 damagebuffer:0
    - run lapex_arena_announce def.session:<[session]> "def.message:<red><bold>SUDDEN DEATH <gray>- the ring is collapsing"

# Called by player deaths and by lapex_arena_bots.dsc after a bot death.
lapex_arena_check_round:
    type: task
    debug: false
    definitions: session
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - define red_alive 0
    - define blue_alive 0
    - foreach <list[red|blue]> as:team:
        - define alive 0
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if <[target].is_online> && <[target].flag[lapex.arena_session]||null> == <[session]> && !<[target].has_flag[lapex.arena_eliminated]> && <[target].health> > 0:
                - define alive <[alive].add[1]>
        - foreach <server.flag[lapex.arena.bots.<[team]>]||<list>> as:bot:
            - if <[bot].is_spawned||false> && <[bot].flag[lapex.arena_bot_session]||null> == <[session]> && <[bot].health||0> > 0:
                - define alive <[alive].add[1]>
        - define <[team]>_alive <[alive]>
    - if <[red_alive]> > 0 && <[blue_alive]> > 0:
        - stop
    - if <[red_alive]> == 0 && <[blue_alive]> == 0:
        - run lapex_arena_end_round def.session:<[session]> def.winner:draw
    - else if <[red_alive]> > 0:
        - run lapex_arena_end_round def.session:<[session]> def.winner:red
    - else:
        - run lapex_arena_end_round def.session:<[session]> def.winner:blue

lapex_arena_end_round:
    type: task
    debug: false
    definitions: session|winner
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != live:
        - stop
    - if !<proc[lapex_arena_phase_can_transition].context[live|round_end]>:
        - stop
    - flag server lapex.arena.state:round_end
    - flag server lapex.arena.phase_token:<util.random_uuid>
    - if <list[red|blue].contains[<[winner]>]>:
        - flag server lapex.arena.score.<[winner]>:<server.flag[lapex.arena.score.<[winner]>].add[1]||1>
    - if <script[lapex_arena_bots_cleanup]||null> != null:
        - run lapex_arena_bots_cleanup def.session:<[session]>
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if <[target].is_online> && <[target].flag[lapex.arena_session]||null> == <[session]>:
                - adjust <[target]> gamemode:spectator
                - if <[winner]> == draw:
                    - title "title:<yellow>ROUND DRAW" "subtitle:<white>The round will be replayed." fade_in:5t stay:3s fade_out:10t targets:<[target]>
                - else:
                    - title "title:<[winner].to_uppercase> WINS" "subtitle:<red><server.flag[lapex.arena.score.red]||0> <gray>- <blue><server.flag[lapex.arena.score.blue]||0>" fade_in:5t stay:3s fade_out:10t targets:<[target]>
    - define round <server.flag[lapex.arena.round]||0>
    - if <[winner]> == draw:
        - if <[round]> >= <script[lapex_arena_data].data_key[max_rounds]||9>:
            # Round nine is replayed until combat produces one survivor.
            - flag server lapex.arena.round:<[round].sub[1]>
        - wait 5s
        - if <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.state]||none> == round_end:
            - run lapex_arena_prepare_round def.session:<[session]>
        - stop
    - define decision <proc[lapex_arena_match_decision].context[<server.flag[lapex.arena.score.red]||0>|<server.flag[lapex.arena.score.blue]||0>|<[round]>|<[winner]>]>
    - if <[decision]> == red || <[decision]> == blue:
        - run lapex_arena_match_end def.session:<[session]> def.winner:<[decision]>
        - stop
    - wait 5s
    - if <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.state]||none> == round_end:
        - run lapex_arena_prepare_round def.session:<[session]>

lapex_arena_match_end:
    type: task
    debug: false
    definitions: session|winner
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]> || <server.flag[lapex.arena.state]||none> != round_end:
        - stop
    - if !<proc[lapex_arena_phase_can_transition].context[round_end|match_end]>:
        - stop
    - flag server lapex.arena.state:match_end
    - flag server lapex.arena.phase_token:<util.random_uuid>
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if <[target].is_online> && <[target].flag[lapex.arena_session]||null> == <[session]>:
                - title "title:<gold><bold><[winner].to_uppercase> VICTORY" "subtitle:<red><server.flag[lapex.arena.score.red]||0> <gray>- <blue><server.flag[lapex.arena.score.blue]||0>" fade_in:10t stay:5s fade_out:1s targets:<[target]>
    - wait 8s
    - if <server.flag[lapex.arena.session]||null> == <[session]> && <server.flag[lapex.arena.state]||none> == match_end:
        - run lapex_arena_cleanup def.session:<[session]> def.reason:match_complete

lapex_arena_cleanup:
    type: task
    debug: false
    definitions: session|reason
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]>:
        - stop
    - if <script[lapex_arena_bots_cleanup]||null> != null:
        - run lapex_arena_bots_cleanup def.session:<[session]>
    - if <script[lapex_arena_loot_reset]||null> != null:
        - run lapex_arena_loot_reset def.session:<[session]> def.round:0
    - define participants <server.flag[lapex.arena.players.red]||<list>>
    - define participants <[participants].include[<server.flag[lapex.arena.players.blue]||<list>>].deduplicate>
    - foreach <[participants]> as:target:
        - if <[target].is_online>:
            - run lapex_arena_restore_player def.target:<[target]>
        - else:
            - flag <[target]> lapex.arena_restore_pending
    - define world_name <script[lapex_arena_data].data_key[world]||lapex_arena_foundry>
    - define map_world <world[<[world_name]>]||null>
    - if <[map_world]> != null:
        - define center <location[0,<script[lapex_arena_data].data_key[floor_y]||63>,0,<[world_name]>]>
        - worldborder <[map_world]> center:<[center]> size:<script[lapex_arena_data].data_key[border_size]||224> warningdistance:8 damage:4 damagebuffer:0
    - flag server lapex.arena.session:!
    - flag server lapex.arena.state:!
    - flag server lapex.arena.round:!
    - flag server lapex.arena.score:!
    - flag server lapex.arena.players:!
    - flag server lapex.arena.bots:!
    - flag server lapex.arena.phase_token:!
    - flag server lapex.arena.phase_remaining:!

lapex_arena_announce:
    type: task
    debug: false
    definitions: session|message
    script:
    - if <server.flag[lapex.arena.session]||null> != <[session]>:
        - stop
    - foreach <list[red|blue]> as:team:
        - foreach <server.flag[lapex.arena.players.<[team]>]||<list>> as:target:
            - if <[target].is_online> && <[target].flag[lapex.arena_session]||null> == <[session]>:
                - actionbar "<[message]>" targets:<[target]>

lapex_arena_hud_loop:
    type: task
    debug: false
    definitions: session
    script:
    - while <server.flag[lapex.arena.session]||null> == <[session]>:
        - define state <server.flag[lapex.arena.state]||lobby>
        - define round <server.flag[lapex.arena.round]||0>
        - define suffix ""
        - if <[state]> == prep:
            - define suffix " <dark_gray>| <yellow><server.flag[lapex.arena.phase_remaining]||0>s"
        - define message "<red>RED <white><server.flag[lapex.arena.score.red]||0> <dark_gray>| <gold>R<[round]> <[state].to_uppercase><[suffix]> <dark_gray>| <blue>BLUE <white><server.flag[lapex.arena.score.blue]||0>"
        - run lapex_arena_announce def.session:<[session]> def.message:<[message]>
        - wait 1s

# Legal phase edges are centralized so validation and runtime use one contract.
lapex_arena_phase_can_transition:
    type: procedure
    debug: false
    definitions: from|to
    script:
    - define edge <[from]>_<[to]>
    - determine <list[lobby_prep|prep_live|live_round_end|round_end_prep|round_end_match_end|match_end_cleanup].contains[<[edge]>]>

# Win by at least three round wins and a two-round lead. Round nine is the
# sudden-death ceiling: its surviving team wins even with only a one-round lead.
lapex_arena_match_decision:
    type: procedure
    debug: false
    definitions: red|blue|round|winner
    script:
    - if <[winner]> == red && <[red]> >= 3 && <[red].sub[<[blue]>]> >= 2:
        - determine red
    - if <[winner]> == blue && <[blue]> >= 3 && <[blue].sub[<[red]>]> >= 2:
        - determine blue
    - if <[round]> >= <script[lapex_arena_data].data_key[max_rounds]||9> && <list[red|blue].contains[<[winner]>]>:
        - determine <[winner]>
    - determine continue

# Console-safe smoke test. It does not create a session or alter a live match.
lapex_arena_match_validate:
    type: task
    debug: false
    script:
    - define failures 0
    - narrate "<yellow>Arena match validation started..."
    - if <script[lapex_arena_data]||null> == null:
        - narrate "<red>[Arena] Missing lapex_arena_data."
        - define failures <[failures].add[1]>
    - else:
        - foreach <list[red|blue]> as:team:
            - define spawns <script[lapex_arena_data].data_key[team_spawns.<[team]>]||<list>>
            - if <[spawns].size> < 5:
                - narrate "<red>[Arena] <[team]> needs five team_spawns; found <[spawns].size>."
                - define failures <[failures].add[1]>
    - foreach <list[apex_r301|apex_p2020]> as:item_id:
        - if <item[<[item_id]>]||null> == null:
            - narrate "<red>[Arena] Missing round item <[item_id]>."
            - define failures <[failures].add[1]>
    - foreach <list[lapex_arena_prepare_round|lapex_arena_begin_live|lapex_arena_ring|lapex_arena_round_timeout|lapex_arena_check_round|lapex_arena_end_round|lapex_arena_match_end|lapex_arena_cleanup|lapex_arena_phase_can_transition|lapex_arena_match_decision]> as:script_id:
        - if <script[<[script_id]>]||null> == null:
            - narrate "<red>[Arena] Missing controller script <[script_id]>."
            - define failures <[failures].add[1]>
    - foreach <list[lapex_arena_loot_reset|lapex_arena_bots_fill|lapex_arena_bots_cleanup]> as:integration:
        - if <script[<[integration]>]||null> == null:
            - narrate "<red>[Arena] Missing integration task <[integration]>."
            - define failures <[failures].add[1]>
    - foreach <list[lobby|prep|live|round_end|match_end]> as:phase:
        - if !<list[lobby|prep|live|round_end|match_end].contains[<[phase]>]>:
            - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[lobby|prep]>:
        - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[prep|live]>:
        - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[live|round_end]>:
        - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[round_end|prep]>:
        - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[round_end|match_end]>:
        - define failures <[failures].add[1]>
    - if !<proc[lapex_arena_phase_can_transition].context[match_end|cleanup]>:
        - define failures <[failures].add[1]>
    - if <proc[lapex_arena_phase_can_transition].context[lobby|live]>:
        - narrate "<red>[Arena] Illegal lobby -> live transition was accepted."
        - define failures <[failures].add[1]>
    - define score_tests <list[3|0|3|red|red|3|2|5|red|continue|0|3|3|blue|blue|4|3|9|red|red]>
    - repeat 4:
        - define offset <[value].sub[1].mul[5]>
        - define red <[score_tests].get[<[offset].add[1]>]>
        - define blue <[score_tests].get[<[offset].add[2]>]>
        - define round <[score_tests].get[<[offset].add[3]>]>
        - define winner <[score_tests].get[<[offset].add[4]>]>
        - define expected <[score_tests].get[<[offset].add[5]>]>
        - define actual <proc[lapex_arena_match_decision].context[<[red]>|<[blue]>|<[round]>|<[winner]>]>
        - if <[actual]> != <[expected]>:
            - narrate "<red>[Arena] Score path <[red]>-<[blue]> round <[round]> returned <[actual]>, expected <[expected]>."
            - define failures <[failures].add[1]>
    - if <[failures]> == 0:
        - narrate "<green>Arena match validation passed: phase contract, score paths, 5v5 spawns, loadout items, and integrations."
    - else:
        - narrate "<red>Arena match validation failed with <[failures]> issue(s)."
