# Shared selection, input, cooldown, and targeting runtime for every legend.
# Q (drop) uses the tactical while a Lapex gun is held; sneak + Q uses the
# ultimate. The public /legend command provides a keyboard-independent path.

lapex_legend_events:
    type: world
    events:
        on player joins:
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

        on player quits:
        - if <player.has_flag[lapex.crypto_active]>:
            - run lapex_crypto_exit def.owner:<player> def.reason:quit
        - flag player lapex.legend_lock:!
        - flag player lapex.legend_protected:!
        - flag player lapex.legend_silenced:!
        - flag player lapex.tempest:!

        on pre script reload:
        - foreach <server.online_players> as:target:
            - if <[target].has_flag[lapex.crypto_active]>:
                - run lapex_crypto_exit def.owner:<[target]> def.reason:reload

        # Crypto's body and drone are real living entities so hitscan and
        # vanilla attacks can reach them. Cancel proxy damage here, then route
        # it through the owning session with normal team rules.
        on entity damaged:
        - define proxy <context.entity>
        - define owner <[proxy].flag[lapex.crypto_body_owner]||<[proxy].flag[lapex.crypto_drone_owner]||null>>
        - if <[owner]> == null:
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
        - if <[proxy].has_flag[lapex.crypto_body_owner]>:
            - run lapex_crypto_body_hit def.owner:<[owner]> def.damage:<context.damage> def.attacker:<[source]> def.session:<[session]> def.proxy:<[proxy]>
            - stop
        - run lapex_crypto_drone_hit def.owner:<[owner]> def.damage:<context.damage> def.attacker:<[source]> def.session:<[session]> def.proxy:<[proxy]>

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
            - if <player.has_flag[lapex.cooldown.tactical]>:
                - narrate "<aqua>Tactical <red>cooling down"
            - else:
                - narrate "<aqua>Tactical <green>ready"
            - if <player.has_flag[lapex.cooldown.ultimate]>:
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
                - flag player lapex.team:!
                - narrate "<green>Legend team cleared."
            - else:
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
    - if <player.has_flag[lapex.legend_lock]> || <player.has_flag[lapex.phased]>:
        - stop
    - define kit <script[lapex_legend_data].data_key[legends.<[id]>]||null>
    - if <[kit]> == null:
        - flag player lapex.legend:bangalore
        - narrate "<red>Your selected legend no longer exists; reset to Bangalore."
        - stop
    - if <player.has_flag[lapex.cooldown.<[slot]>]>:
        - actionbar "<red><[kit].get[<[slot]>]> is cooling down"
        - playsound <player> sound:block.dispenser.fail pitch:1.2 volume:0.55
        - stop
    - flag player lapex.legend_lock expire:4t
    - flag player lapex.cooldown.<[slot]> expire:<[kit].get[<[slot]>_cooldown]>
    - actionbar "<gold><[kit].get[name]> <gray>- <white><[kit].get[<[slot]>]>"
    - run lapex_legend_<[slot]> def.id:<[id]>

# Teams are optional. With no team flag, only the caster counts as an ally.
lapex_legend_is_ally:
    type: procedure
    definitions: source|target
    script:
    - define proxy_owner <[target].flag[lapex.crypto_body_owner]||<[target].flag[lapex.crypto_drone_owner]||null>>
    - if <[proxy_owner]> != null:
        - define proxy_session <[target].flag[lapex.crypto_session]||null>
        - if <[proxy_session]> != null && <[proxy_owner].flag[lapex.crypto_active]||null> == <[proxy_session]>:
            - define target <[proxy_owner]>
    - if <[source]> == <[target]>:
        - determine true
    - if !<[target].is_player||false>:
        - determine false
    - define source_team <[source].flag[lapex.team]||null>
    - if <[source_team]> != null && <[target].flag[lapex.team]||null> == <[source_team]>:
        - determine true
    - determine false

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
    definitions: location|radius|damage|effect|pylon_blockable
    script:
    - foreach <[location].find_entities[player].within[<[radius]>]> as:target:
        - if <proc[lapex_legend_is_ally].context[<player>|<[target]>]>:
            - foreach next
        - if <[target].has_flag[lapex.legend_protected]> || <[target].has_flag[lapex.phased]>:
            - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.25 quantity:5
            - foreach next
        - if <[pylon_blockable]||false> && <[target].has_flag[lapex.pylon_protected]>:
            - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.25 quantity:5
            - foreach next
        # Overlapping nodes from one fence/ring should count as one pulse.
        - if <[target].has_flag[lapex.legend_damage_lock.<player.uuid>]>:
            - foreach next
        - flag <[target]> lapex.legend_damage_lock.<player.uuid> expire:2t
        - define old_velocity <[target].velocity>
        - hurt <[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]> <[target]> cause:MAGIC source:<player>
        - adjust <[target]> no_damage_duration:0s
        - adjust <[target]> velocity:<[old_velocity]>
        - if <[effect]||none> == slow:
            - cast slowness duration:2s amplifier:1 <[target]>
        - else if <[effect]||none> == burn:
            - burn <[target]> duration:4s
        - else if <[effect]||none> == silence:
            - if <[target].is_player||false>:
                - flag <[target]> lapex.legend_silenced expire:8s

# Per-viewer glow keeps recon scans private to their caster.
lapex_legend_scan:
    type: task
    definitions: location|radius|duration
    script:
    - define targets <list>
    - foreach <[location].find_entities[player].within[<[radius]>]> as:target:
        - if !<proc[lapex_legend_is_ally].context[<player>|<[target]>]> && !<[target].has_flag[lapex.phased]>:
            - define targets <[targets].include[<[target]>]>
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
    - foreach <[location].find_entities[player].within[<[radius]>]> as:target:
        - if <proc[lapex_legend_is_ally].context[<[source]>|<[target]>]>:
            - define allies <[allies].include[<[target]>]>
    - determine <[allies]>
