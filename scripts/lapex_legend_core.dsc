# Shared selection, input, cooldown, and targeting runtime for every legend.
# Q (drop) uses the tactical while a Lapex gun is held; sneak + Q uses the
# ultimate. The public /legend command provides a keyboard-independent path.

lapex_legend_events:
    type: world
    debug: false
    events:
        on player joins:
        - define reconnect <player.flag[lapex.crypto_reconnect_location]||null>
        - if <[reconnect]> != null:
            - teleport <player> <[reconnect]>
            - flag player lapex.crypto_reconnect_location:!
        - if <player.has_flag[lapex.crypto_active]>:
            - run lapex_crypto_exit def.owner:<player> def.reason:reconnect
        - if !<player.has_flag[lapex.legend]>:
            - flag player lapex.legend:bangalore
            - narrate "<gold>Lapex <gray>- selected <yellow>Bangalore<gray>. Use <white>/legend list<gray> to change legend."

        on player drops item:
        - if <context.item.flag[lapex.id]||null> == null:
            - stop
        - determine passively cancelled
        - if <player.is_sneaking>:
            - run lapex_legend_activate def.slot:ultimate
        - else:
            - run lapex_legend_activate def.slot:tactical

        # Spectator left-click normally attaches the camera to an entity.
        # Crypto owns free-flight camera movement, so that vanilla switch must
        # never replace the drone pilot's position.
        on player spectates entity:
        - if <player.has_flag[lapex.crypto_active]>:
            - determine cancelled

        on player quits:
        - if <player.has_flag[lapex.crypto_active]>:
            - run lapex_crypto_exit def.owner:<player> def.reason:quit
        - flag player lapex.legend_lock:!
        - flag player lapex.legend_protected:!
        - flag player lapex.legend_silenced:!
        - flag player lapex.tempest:!

        on player dies:
        - if <player.has_flag[lapex.crypto_active]>:
            - run lapex_crypto_exit def.owner:<player> def.reason:death

        on pre script reload:
        - foreach <server.online_players> as:target:
            - if <[target].has_flag[lapex.crypto_active]>:
                - run lapex_crypto_exit def.owner:<[target]> def.reason:reload

        # Persistent proxies can load before scripts on a hard restart, or much
        # later when their chunk returns. Reconcile both paths.
        on scripts loaded:
        - foreach <server.worlds> as:world:
            - foreach <[world].entities> as:proxy:
                - if <[proxy].has_flag[lapex.crypto_body_owner]> || <[proxy].has_flag[lapex.crypto_drone_owner]>:
                    - run lapex_crypto_reconcile_proxy def.proxy:<[proxy]>

        on chunk loads entities:
        - foreach <context.entities> as:proxy:
            - if <[proxy].has_flag[lapex.crypto_body_owner]> || <[proxy].has_flag[lapex.crypto_drone_owner]>:
                - run lapex_crypto_reconcile_proxy def.proxy:<[proxy]>

        # Crypto's body and drone are real living entities so hitscan and
        # vanilla attacks can reach them. Cancel proxy damage here, then route
        # it through the owning session with normal team rules.
        on entity damaged:
        - define proxy <context.entity>
        - define owner <[proxy].flag[lapex.crypto_body_owner]||<[proxy].flag[lapex.crypto_drone_owner]||null>>
        - if <[owner]> == null:
            - stop
        - if <context.cause> == ENTITY_ATTACK && <context.damager.is_player||false> && <context.damager.item_in_hand.flag[lapex.id]||null> != null:
            - determine passively cancelled
            - stop
        # Owner flags alone are not authority: an entity left by an old queue or
        # crash must match both the current session and the owner's exact proxy.
        - define session <[proxy].flag[lapex.crypto_session]||null>
        - if <[session]> == null || !<[owner].is_online||false>:
            - remove <[proxy]>
            - stop
        - if <[owner].flag[lapex.crypto_active]||null> != <[session]>:
            - remove <[proxy]>
            - stop
        - if <[proxy].has_flag[lapex.crypto_body_owner]>:
            - define expected <[owner].flag[lapex.crypto_body_entity]||null>
        - else:
            - define expected <[owner].flag[lapex.crypto_drone_entity]||null>
        - if <[expected]> != <[proxy]>:
            - remove <[proxy]>
            - stop
        - determine passively cancelled
        - define attacker <context.damager||null>
        - define source null
        - if <[attacker]> != null:
            - define source <[attacker].shooter||<[attacker]>>
        - if <[source]> != null && <[source].is_player||false> && <proc[lapex_legend_is_ally].context[<[owner]>|<[source]>]>:
            - stop
        - if <[source]> != null && <[source].is_player||false> && <[source].has_flag[lapex.phased]>:
            - stop
        - if <[proxy].has_flag[lapex.crypto_body_owner]>:
            # Protection belongs to the real combat player. Do not begin a body
            # hit transaction that would eject Crypto before the forwarded
            # player damage has a chance to be cancelled.
            - define body_protected <[owner].has_flag[lapex.phased]>
            - if <[source]> != null && <[source]> != <[owner]> && <[owner].has_flag[lapex.legend_protected]>:
                - define body_protected true
            - if <[body_protected]>:
                - playeffect effect:electric_spark at:<[proxy].location.above[1]> offset:0.25 quantity:5
                - stop
            - if <[owner].has_flag[lapex.pylon_protected]>:
                - if <context.projectile||null> != null || <list[BLOCK_EXPLOSION|ENTITY_EXPLOSION].contains[<context.cause>]||false>:
                    - playeffect effect:electric_spark at:<[proxy].location.above[1]> offset:0.25 quantity:5
                    - stop
            # The proxy wears a copy of the owner's armor. Forward base damage
            # so armor is applied once to the restored real player, not twice.
            - run lapex_crypto_body_hit def.owner:<[owner]> def.damage:<context.damage> def.attacker:<[source]> def.cause:<context.cause> def.session:<[session]> def.proxy:<[proxy]>
            - stop
        - run lapex_crypto_drone_hit def.owner:<[owner]> def.damage:<context.final_damage||<context.damage>> def.attacker:<[source]> def.session:<[session]> def.proxy:<[proxy]>

lapex_crypto_reconcile_proxy:
    type: task
    debug: false
    definitions: proxy
    script:
    - define owner <[proxy].flag[lapex.crypto_body_owner]||<[proxy].flag[lapex.crypto_drone_owner]||null>>
    - define session <[proxy].flag[lapex.crypto_session]||null>
    - if <[owner]> == null || <[session]> == null || !<[owner].is_online||false> || <[owner].flag[lapex.crypto_active]||null> != <[session]>:
        - remove <[proxy]>
        - stop
    - if <[proxy].has_flag[lapex.crypto_body_owner]>:
        - define expected <[owner].flag[lapex.crypto_body_entity]||null>
    - else:
        - define expected <[owner].flag[lapex.crypto_drone_entity]||null>
    - if <[expected]> != <[proxy]>:
        - remove <[proxy]>

# Paper 26 accepts native summons for these entity types while the matching
# Denizen spawn adapter is rejected. A unique scoreboard tag lets the caller
# bind exactly the entity it requested, even when several players deploy at the
# same coordinates in one tick. The short server flag is only a return value.
lapex_native_spawn_armor_stand:
    type: task
    debug: false
    definitions: location|tag|arms|small|marker
    script:
    - define dimension minecraft:<[location].world.name>
    - if <[location].world.name> == world:
        - define dimension minecraft:overworld
    - else if <[location].world.name> == world_nether:
        - define dimension minecraft:the_nether
    - else if <[location].world.name> == world_the_end:
        - define dimension minecraft:the_end
    - if <[arms]||false>:
        - define show_arms 1b
    - else:
        - define show_arms 0b
    - if <[small]||false>:
        - define is_small 1b
    - else:
        - define is_small 0b
    - if <[marker]||false>:
        - define is_marker 1b
    - else:
        - define is_marker 0b
    - execute as_server "execute in <[dimension]> run summon minecraft:armor_stand <[location].x> <[location].y> <[location].z> {Tags:['<[tag]>'],Invisible:1b,NoGravity:1b,Silent:1b,NoBasePlate:1b,ShowArms:<[show_arms]>,Small:<[is_small]>,Marker:<[is_marker]>,PersistenceRequired:1b}" silent
    - wait 2t
    - foreach <[location].find_entities[armor_stand].within[0.75]> as:candidate:
        - if <[candidate].scoreboard_tags.contains[<[tag]>]>:
            - flag server lapex.native_spawn_result.<[tag]>:<[candidate]> expire:1m
            - foreach stop

lapex_native_spawn_allay:
    type: task
    debug: false
    definitions: location|tag
    script:
    - define dimension minecraft:<[location].world.name>
    - if <[location].world.name> == world:
        - define dimension minecraft:overworld
    - else if <[location].world.name> == world_nether:
        - define dimension minecraft:the_nether
    - else if <[location].world.name> == world_the_end:
        - define dimension minecraft:the_end
    - execute as_server "execute in <[dimension]> run summon minecraft:allay <[location].x> <[location].y> <[location].z> {Tags:['<[tag]>'],NoAI:1b,NoGravity:1b,Silent:1b,Glowing:1b,PersistenceRequired:1b}" silent
    - wait 2t
    - foreach <[location].find_entities[allay].within[0.75]> as:candidate:
        - if <[candidate].scoreboard_tags.contains[<[tag]>]>:
            - flag server lapex.native_spawn_result.<[tag]>:<[candidate]> expire:1m
            - foreach stop

lapex_legend_command:
    type: command
    name: legend
    description: Selects and uses a Lapex legend.
    usage: /legend <&lt>list|info|legend_id|tactical|ultimate|status|team<&gt>
    tab completions:
        1: <script[lapex_legend_data].data_key[all_ids].include[list|info|tactical|ultimate|status|team]>
        2: <script[lapex_legend_data].data_key[all_ids]>
    script:
    - define action <context.args.get[1]||status>
    - define ids <script[lapex_legend_data].data_key[all_ids]>
    - define registry <script[lapex_legend_data].data_key[legends]>
    - if <context.source_type> != player:
        - if <[ids].contains[<[action]>]> || <list[status|tactical|ultimate|team].contains[<[action]>]>:
            - narrate "<red>This action requires a player command source."
            - stop
    - if <[ids].contains[<[action]>]>:
        - run lapex_legend_select def.id:<[action]>
        - stop
    - choose <[action]>:
        - case list:
            - narrate "<gold><bold>Lapex Legends <gray>- 28 playable kits"
            - narrate "<red>Assault <dark_gray>| <white>ballistic, bangalore, fuse, mad_maggie, revenant"
            - narrate "<aqua>Skirmisher <dark_gray>| <white>alter, ash, axle, horizon, octane, pathfinder, wraith"
            - narrate "<green>Recon <dark_gray>| <white>bloodhound, crypto, seer, sparrow, valkyrie, vantage"
            - narrate "<yellow>Controller <dark_gray>| <white>catalyst, caustic, rampart, wattson"
            - narrate "<blue>Support <dark_gray>| <white>conduit, gibraltar, lifeline, loba, mirage, newcastle"
        - case info:
            - define id <context.args.get[2]||null>
            - if <[id]> == null:
                - if <context.source_type> != player:
                    - narrate "<red>Usage from console: <white>legend info <legend_id>"
                    - stop
                - define id <player.flag[lapex.legend]||bangalore>
            - if !<[ids].contains[<[id]>]>:
                - narrate "<red>Unknown legend. Use <white>/legend list<red>."
                - stop
            - define kit <[registry].get[<[id]>]>
            - narrate "<gold><bold><[kit].get[name]> <gray>- <[kit].get[class]>"
            - narrate "<yellow>Passive: <white><[kit].get[passive]> <dark_gray>| <gray><[kit].get[passive_note]>"
            - narrate "<aqua>Tactical: <white><[kit].get[tactical]> <dark_gray>| <gray><[kit].get[tactical_note]> <dark_gray>(<[kit].get[tactical_cooldown]>)"
            - narrate "<gold>Ultimate: <white><[kit].get[ultimate]> <dark_gray>| <gray><[kit].get[ultimate_note]> <dark_gray>(<[kit].get[ultimate_cooldown]>)"
        - case tactical:
            - run lapex_legend_activate def.slot:tactical
        - case ultimate:
            - run lapex_legend_activate def.slot:ultimate
        - case status:
            - define id <player.flag[lapex.legend]||bangalore>
            - define kit <[registry].get[<[id]>]>
            - narrate "<gold><[kit].get[name]> <gray>- <yellow><[kit].get[passive]><gray>, <aqua><[kit].get[tactical]><gray>, <gold><[kit].get[ultimate]>"
            - define tactical_max <[kit].get[tactical_charges]||1>
            - if <[tactical_max]> > 1:
                - narrate "<aqua>Tactical charges <white><player.flag[lapex.charges.<[id]>.tactical]||<[tactical_max]>>/<[tactical_max]>"
            - else if <player.has_flag[lapex.cooldown.tactical]>:
                - narrate "<aqua>Tactical <red>cooling down"
            - else:
                - narrate "<aqua>Tactical <green>ready"
            - define ultimate_max <[kit].get[ultimate_charges]||1>
            - if <[ultimate_max]> > 1:
                - narrate "<gold>Ultimate charges <white><player.flag[lapex.charges.<[id]>.ultimate]||<[ultimate_max]>>/<[ultimate_max]>"
            - else if <player.has_flag[lapex.cooldown.ultimate]>:
                - narrate "<gold>Ultimate <red>cooling down"
            - else:
                - narrate "<gold>Ultimate <green>ready"
            - narrate "<gray>Team: <white><player.flag[lapex.team]||none>"
        - case team:
            - define team <context.args.get[2]||null>
            - if <[team]> == null:
                - narrate "<gray>Team: <white><player.flag[lapex.team]||none><gray>. Use <white>/legend team <name><gray> or <white>/legend team clear<gray>."
            - else if !<player.has_permission[lapex.team.manage]>:
                - narrate "<red>Team assignment requires <white>lapex.team.manage<red>."
            - else if <[team]> == clear:
                - if <player.has_flag[lapex.crypto_active]>:
                    - run lapex_crypto_exit def.owner:<player> def.reason:team_change
                - run lapex_deployable_cleanup_owner def.owner:<player>
                - flag player lapex.team:!
                - narrate "<green>Legend team cleared."
            - else:
                - if <player.has_flag[lapex.crypto_active]>:
                    - run lapex_crypto_exit def.owner:<player> def.reason:team_change
                - run lapex_deployable_cleanup_owner def.owner:<player>
                - flag player lapex.team:<[team].to_lowercase>
                - narrate "<green>Legend team set to <white><[team].to_lowercase><green>."
        - default:
            - narrate "<gold>/legend list <gray>- show every legend"
            - narrate "<gold>/legend <white><legend_id> <gray>- select a legend"
            - narrate "<gold>/legend info <white>[legend_id]"
            - narrate "<gold>/legend tactical <dark_gray>| <gold>/legend ultimate"

lapex_legend_select:
    type: task
    definitions: id
    script:
    - define registry <script[lapex_legend_data].data_key[legends]>
    - if !<[registry].keys.contains[<[id]>]>:
        - narrate "<red>Unknown legend. Use <white>/legend list<red>."
        - stop
    - if <player.has_flag[lapex.crypto_active]>:
        - run lapex_crypto_exit def.owner:<player> def.reason:legend_switch
    - run lapex_mobility_cleanup_player def.target:<player> def.reason:legend_switch
    - run lapex_deployable_cleanup_owner def.owner:<player>
    - flag player lapex.legend:<[id]>
    - flag player lapex.legend_lock:!
    - flag player lapex.tempest:!
    - define kit <[registry].get[<[id]>]>
    - narrate "<green>Selected <gold><[kit].get[name]><green>. <gray>Q: <[kit].get[tactical]> | Sneak+Q: <[kit].get[ultimate]>"
    - playsound <player> sound:block.beacon.power_select pitch:1.35 volume:0.65

lapex_legend_activate:
    type: task
    definitions: slot
    script:
    - if !<list[tactical|ultimate].contains[<[slot]>]>:
        - stop
    - define id <player.flag[lapex.legend]||bangalore>
    - if <[id]> == crypto && <[slot]> == tactical && <player.has_flag[lapex.crypto_active]>:
        - run lapex_crypto_exit def.owner:<player> def.reason:manual
        - stop
    - if <[id]> == crypto && <[slot]> == ultimate && !<player.has_flag[lapex.crypto_active]>:
        - actionbar "<red>DEPLOY THE DRONE BEFORE USING EMP"
        - playsound <player> sound:block.dispenser.fail pitch:1.2 volume:0.55
        - stop
    - if <player.has_flag[lapex.legend_silenced]>:
        - actionbar "<red>ABILITIES SILENCED"
        - stop
    - if <player.has_flag[lapex.legend_grounded]>:
        - actionbar "<red>ABILITIES GROUNDED BY NOX GAS"
        - stop
    - if <player.has_flag[lapex.legend_lock]> || <player.has_flag[lapex.phased]>:
        - stop
    - define kit <script[lapex_legend_data].data_key[legends.<[id]>]||null>
    - if <[kit]> == null:
        - flag player lapex.legend:bangalore
        - narrate "<red>Your selected legend no longer exists; reset to Bangalore."
        - stop
    # A second D.O.C. input changes its follow target. Reassignment is control
    # of the existing device, not a new tactical use or cooldown transaction.
    - if <[id]> == lifeline && <[slot]> == tactical:
        - define doc <proc[lapex_current_deployable_for_owner].context[<player>|lifeline_doc]>
        - if <[doc]> != null:
            - run lapex_lifeline_doc_assign def.owner:<player> def.entity:<[doc]>
            - stop
    - define max_charges <[kit].get[<[slot]>_charges]||1>
    - if <[max_charges]> > 1:
        - define charge_key <[id]>.<[slot]>
        - define charges <player.flag[lapex.charges.<[charge_key]>]||<[max_charges]>>
        - if <[charges]> <= 0:
            - actionbar "<red><[kit].get[<[slot]>]> HAS NO CHARGES"
            - playsound <player> sound:block.dispenser.fail pitch:1.2 volume:0.55
            - stop
        - define recharge <[kit].get[<[slot]>_recharge]||<[kit].get[<[slot]>_cooldown]>>
        - define due <util.time_now.add[<[recharge]>]>
        - flag player lapex.charges.<[charge_key]>:<[charges].sub[1]>
        - define due_list <player.flag[lapex.charge_due.<[charge_key]>]||<list>>
        - flag player lapex.charge_due.<[charge_key]>:<[due_list].include[<[due]>]>
        - define groups <player.flag[lapex.charge_groups]||<list>>
        - flag player lapex.charge_groups:<[groups].include[<[charge_key]>].deduplicate>
        - flag player lapex.charge_transaction.<[slot]>.id:<[id]> expire:10s
        - flag player lapex.charge_transaction.<[slot]>.due:<[due]> expire:10s
    - else:
        - if <player.has_flag[lapex.cooldown.<[slot]>]>:
            - actionbar "<red><[kit].get[<[slot]>]> is cooling down"
            - playsound <player> sound:block.dispenser.fail pitch:1.2 volume:0.55
            - stop
    - flag player lapex.legend_lock expire:4t
    - if <[max_charges]> <= 1:
        - flag player lapex.cooldown.<[slot]> expire:<[kit].get[<[slot]>_cooldown]>
        - actionbar "<gold><[kit].get[name]> <gray>- <white><[kit].get[<[slot]>]>"
    - else:
        - actionbar "<gold><[kit].get[name]> <gray>- <white><[kit].get[<[slot]>]> <dark_gray>| <yellow><[charges].sub[1]>/<[max_charges]> CHARGES"
    - run lapex_legend_<[slot]> def.id:<[id]>

lapex_legend_refund_charge:
    type: task
    debug: false
    definitions: target|id|slot
    script:
    - if <[target].flag[lapex.charge_transaction.<[slot]>.id]||null> != <[id]>:
        - stop
    - define due <[target].flag[lapex.charge_transaction.<[slot]>.due]||null>
    - define kit <script[lapex_legend_data].data_key[legends.<[id]>]>
    - define max_charges <[kit].get[<[slot]>_charges]||1>
    - define charge_key <[id]>.<[slot]>
    - define charges <[target].flag[lapex.charges.<[charge_key]>]||0>
    - flag <[target]> lapex.charges.<[charge_key]>:<[charges].add[1].min[<[max_charges]>]>
    - define due_list <[target].flag[lapex.charge_due.<[charge_key]>]||<list>>
    - define due_list <[due_list].exclude[<[due]>]>
    - if <[due_list].is_empty>:
        - flag <[target]> lapex.charge_due.<[charge_key]>:!
        - define groups <[target].flag[lapex.charge_groups]||<list>>
        - flag <[target]> lapex.charge_groups:<[groups].exclude[<[charge_key]>]>
    - else:
        - flag <[target]> lapex.charge_due.<[charge_key]>:<[due_list]>
    - flag <[target]> lapex.charge_transaction.<[slot]>:!

# Teams are optional. With no team flag, only the caster counts as an ally.
lapex_legend_is_ally:
    type: procedure
    debug: false
    definitions: source|target
    script:
    - define proxy_owner <[target].flag[lapex.crypto_body_owner]||<[target].flag[lapex.crypto_drone_owner]||null>>
    - if <[proxy_owner]> != null:
        - define proxy_session <[target].flag[lapex.crypto_session]||null>
        - if <[proxy_session]> != null && <[proxy_owner].flag[lapex.crypto_active]||null> == <[proxy_session]>:
            - define target <[proxy_owner]>
    - define deployable_owner <[target].flag[lapex.deployable_owner]||null>
    - if <[deployable_owner]> != null:
        - define deployable_session <[target].flag[lapex.deployable_session]||null>
        - if <[deployable_session]> != null && <[deployable_owner].flag[lapex.deployable.<[deployable_session]>]||null> == <[target]>:
            - define target <[deployable_owner]>
    - if <[source]> == <[target]>:
        - determine true
    - if !<[target].is_player||false>:
        - determine false
    - define source_team <[source].flag[lapex.team]||null>
    - if <[source_team]> != null && <[target].flag[lapex.team]||null> == <[source_team]>:
        - determine true
    - determine false

# Inventory-wide check used by legend guns. Looking only at the held slot lets
# repeated tactical or ultimate uses create unlimited special-weapon copies.
lapex_player_has_weapon:
    type: procedure
    debug: false
    definitions: target|id
    script:
    - foreach <[target].inventory.list_contents> as:item:
        - if <[item].flag[lapex.id]||null> == <[id]>:
            - determine true
    - determine false

# Area effects target a Crypto pilot's body, not the spectator camera. Return
# the real combat player for a normal player or a current Crypto body proxy.
# Other living entities are outside the player-only Apex combat contract.
lapex_legend_combat_player:
    type: procedure
    debug: false
    definitions: target
    script:
    - if <[target].is_player||false>:
        - if <[target].has_flag[lapex.crypto_active]>:
            - determine null
        - determine <[target]>
    - define owner <[target].flag[lapex.crypto_body_owner]||null>
    - define session <[target].flag[lapex.crypto_session]||null>
    - if <[owner]> != null && <[session]> != null && <[owner].flag[lapex.crypto_active]||null> == <[session]> && <[owner].flag[lapex.crypto_body_entity]||null> == <[target]>:
        - determine <[owner]>
    - determine null

# Finds nearby two-block headroom with a solid floor. Teleports fall back to
# the caster's current location rather than placing a player inside geometry.
lapex_legend_safe_destination:
    type: procedure
    definitions: desired|fallback
    script:
    - if !<[desired].material.is_solid> && !<[desired].above[1].material.is_solid> && <[desired].below[1].material.is_solid>:
        - determine <[desired]>
    - repeat 6 as:step:
        - define below <[desired].below[<[step]>]>
        - if !<[below].material.is_solid> && !<[below].above[1].material.is_solid> && <[below].below[1].material.is_solid>:
            - determine <[below]>
        - define above <[desired].above[<[step]>]>
        - if !<[above].material.is_solid> && !<[above].above[1].material.is_solid> && <[above].below[1].material.is_solid>:
            - determine <[above]>
    - determine <[fallback]>

# Apply Apex-scaled radial damage while respecting /legend team assignments.
lapex_legend_damage_sphere:
    type: task
    debug: false
    definitions: location|radius|damage|effect|pylon_blockable|source|lock_duration
    script:
    - define caster <[source]||<player>>
    - foreach <[location].find_entities[living].within[<[radius]>]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> == null:
            - foreach next
        - if <proc[lapex_legend_is_ally].context[<[caster]>|<[target]>]>:
            - foreach next
        - if <[combat_player].has_flag[lapex.legend_protected]> || <[combat_player].has_flag[lapex.phased]>:
            - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.25 quantity:5
            - foreach next
        - if <[pylon_blockable]||false> && <[combat_player].has_flag[lapex.pylon_protected]>:
            - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.25 quantity:5
            - foreach next
        - if <[pylon_blockable]||false>:
            - define dome_block <proc[lapex_dome_trace_intersection].context[<[location]>|<[target].location.above[0.9]>]||null>
            - if <[dome_block]> != null:
                - playeffect effect:electric_spark at:<[dome_block]> offset:0.2 quantity:8
                - foreach next
        # Overlapping nodes from one fence/ring should count as one pulse.
        - if <[combat_player].has_flag[lapex.legend_damage_lock.<[caster].uuid>]>:
            - foreach next
        - flag <[combat_player]> lapex.legend_damage_lock.<[caster].uuid> expire:<[lock_duration]||2t>
        - define old_velocity <[target].velocity>
        - hurt <[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]> <[target]> cause:MAGIC source:<[caster]>
        - adjust <[target]> no_damage_duration:0s
        - adjust <[target]> velocity:<[old_velocity]>
        - if <[effect]||none> == slow:
            - cast slowness duration:2s amplifier:1 <[combat_player]>
        - else if <[effect]||none> == burn:
            - burn <[combat_player]> duration:4s
        - else if <[effect]||none> == silence:
            - flag <[combat_player]> lapex.legend_silenced expire:8s

# Per-viewer glow keeps recon scans private to their caster.
lapex_legend_scan:
    type: task
    definitions: location|radius|duration
    script:
    - define targets <list>
    - define seen_players <list>
    - foreach <[location].find_entities[living].within[<[radius]>]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> != null && !<[seen_players].contains[<[combat_player].uuid>]> && !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[combat_player].has_flag[lapex.phased]>:
            - define targets <[targets].include[<[target]>]>
            - define seen_players <[seen_players].include[<[combat_player].uuid>]>
    - if <[targets].is_empty>:
        - actionbar "<gray>NO HOSTILES DETECTED"
        - stop
    - define token <queue.id>
    - foreach <[targets]> as:target:
        - flag <[target]> lapex.scan_token.<player.uuid>:<[token]> expire:30s
    - glow <[targets]> for:<player>
    - playsound <player> sound:block.note_block.pling pitch:1.8 volume:0.55
    - wait <[duration]>
    - foreach <[targets]> as:target:
        - if <[target].flag[lapex.scan_token.<player.uuid>]||null> == <[token]>:
            - glow <[target]> reset for:<player>
            - flag <[target]> lapex.scan_token.<player.uuid>:!

# Used by shields, healing drones, launch pads, and other persistent zones.
lapex_legend_allies_near:
    type: procedure
    definitions: location|radius|source
    script:
    - define allies <list>
    - foreach <[location].find_entities[living].within[<[radius]>]> as:target:
        - define combat_player <proc[lapex_legend_combat_player].context[<[target]>]>
        - if <[combat_player]> != null && <proc[lapex_legend_is_ally].context[<[source]>|<[target]>]> && !<[allies].contains[<[combat_player]>]>:
            - define allies <[allies].include[<[combat_player]>]>
    - determine <[allies]>
