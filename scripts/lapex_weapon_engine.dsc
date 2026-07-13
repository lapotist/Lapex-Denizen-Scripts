# Shared runtime for every Lapex firearm. Requires Paper for camera look packets
# and Denizen 1.3.3+ for the current ray trace and inventory APIs.

lapex_weapon_events:
    type: world
    debug: false
    events:
        # Right-click owns firing because carrot-on-a-stick use packets repeat
        # while held. Left-click is a discrete, reliable ADS toggle and never
        # needs release inference to restore the camera.
        on player animates ARM_SWING:
        - define item <player.item_in_hand>
        - if <[item].flag[lapex.id]||null> == null:
            - stop
        - run lapex_weapon_ads_toggle def.item:<[item]>
        - determine cancelled

        # A gun swing must never also mine a block or deal vanilla melee damage.
        on player left clicks block using:hand:
        - if <context.item.flag[lapex.id]||null> == null:
            - stop
        - determine cancelled

        on entity damaged by player:
        - if <context.cause> != ENTITY_ATTACK || <context.damager.item_in_hand.flag[lapex.id]||null> == null:
            - stop
        - determine cancelled

        # Both use paths feed one rate-limited trigger. Automatic modes refresh
        # a short lease on every repeated packet, so releasing right-click ends
        # their cadence without requiring a client mod.
        on player right clicks block using:hand:
        - define item <context.item>
        - if <[item].flag[lapex.id]||null> == null:
            - stop
        - run lapex_weapon_trigger def.item:<[item]>
        - determine cancelled

        on player right clicks entity:
        - if <context.hand> != mainhand:
            - stop
        - define item <context.item>
        - if <[item].flag[lapex.id]||null> == null:
            - stop
        - run lapex_weapon_trigger def.item:<[item]>
        - determine cancelled

        # Swapping hands is the reload key. Sneak + swap activates supported
        # secondary charges without making a second command or custom keybind.
        on player swaps items:
        - define id <player.item_in_hand.flag[lapex.id]||null>
        - if <[id]> == null:
            - stop
        - define arena_session <player.flag[lapex.arena_session]||null>
        - if <[arena_session]> != null:
            - if <server.flag[lapex.arena.session]||null> != <[arena_session]> || <server.flag[lapex.arena.state]||none> != live || <player.has_flag[lapex.arena_eliminated]>:
                - determine passively cancelled
                - stop
        - if <player.has_flag[lapex.reloading]> || <player.has_flag[lapex.action_lock]> || <player.has_flag[lapex.secondary]>:
            - determine passively cancelled
            - stop
        - if <player.is_sneaking> && <list[hemlok_breach|sentinel|rampage].contains[<[id]>]>:
            - determine passively cancelled
            - run lapex_weapon_secondary def.id:<[id]>
        - else if <player.is_sneaking> && <player.flag[lapex.legend]||bangalore> == ballistic && <context.main.flag[lapex.id]||null> != null:
            - flag player lapex.sling_draw_cooldown expire:2s
            - flag player lapex.trigger:!
            - flag player lapex.action_lock:!
            - flag player lapex.charging:!
            - flag player lapex.burst:!
            - flag player lapex.spinup:!
            - flag player lapex.reloading:!
        - else:
            - determine passively cancelled
            - run lapex_weapon_reload def.id:<[id]>

        # Weapon changes cancel pending fire, charge, and reload state at once.
        # Delayed queues also verify this token before touching the new item.
        on player holds item:
        - run lapex_weapon_ads_cancel def.target:<player>
        - flag player lapex.trigger:!
        - flag player lapex.action_lock:!
        - flag player lapex.charging:!
        - flag player lapex.burst:!
        - flag player lapex.spinup:!
        - flag player lapex.spinup_ready:!
        - flag player lapex.auto_loop:!
        - flag player lapex.auto_probe:!
        - flag player lapex.secondary:!
        - flag player lapex.reloading:!
        - wait 1t
        - run lapex_weapon_migrate_held

        on player joins:
        - run lapex_weapon_reset_transient def.target:<player>
        - wait 1t
        - run lapex_weapon_migrate_held

        on player quits:
        - run lapex_weapon_reset_transient def.target:<player>

        on player dies:
        - run lapex_weapon_reset_transient def.target:<player>
        - run lapex_weapon_clear_item_charges def.target:<player>

        on player respawns:
        - run lapex_weapon_reset_transient def.target:<player>

        on player changes world:
        - run lapex_weapon_reset_transient def.target:<player>

        # Script replacement must clear packet-level camera overrides before
        # the old task definitions disappear.
        on pre script reload:
        - foreach <server.online_players> as:target:
            - run lapex_weapon_ads_cancel def.target:<[target]>

        # This also repairs camera state when first deploying the cleanup fix.
        on scripts loaded:
        - foreach <server.online_players> as:target:
            - run lapex_weapon_ads_cancel def.target:<[target]>

lapex_weapon_reset_transient:
    type: task
    debug: false
    definitions: target
    script:
    - foreach <list[trigger|action_lock|burst|charging|spinup|spinup_ready|auto_loop|auto_probe|secondary|reloading|ads|ads_token|ads_monitor|fire_phase|recoil_shot|jammed|whistler_heat|whistler_source|sentinel_amped|rampage_amped]> as:state:
        - flag <[target]> lapex.<[state]>:!
    - if <[target].is_online||false>:
        # Denizen resets its packet-level FOV override only when this mechanism
        # has no value. A literal value of 1 is still an override, not a reset.
        - adjust <[target]> fov_multiplier

lapex_weapon_clear_item_charges:
    type: task
    debug: false
    definitions: target
    script:
    - foreach <[target].inventory.list_contents> key:slot as:item:
        - if <[item].has_flag[lapex.sentinel_amped]>:
            - inventory flag destination:<[target].inventory> slot:<[slot]> lapex.sentinel_amped:!
        - if <[item].has_flag[lapex.rampage_amped]>:
            - inventory flag destination:<[target].inventory> slot:<[slot]> lapex.rampage_amped:!

lapex_weapon_ads_toggle:
    type: task
    debug: false
    definitions: item
    script:
    - define id <[item].flag[lapex.id]||null>
    - if <[id]> == null || <player.item_in_hand.flag[lapex.id]||null> != <[id]>:
        - stop
    - if <player.flag[lapex.ads]||null> == <[id]>:
        - run lapex_weapon_ads_cancel def.target:<player>
        - stop
    - run lapex_weapon_ads_cancel def.target:<player>
    - flag player lapex.ads:<[id]>
    - adjust <player> fov_multiplier:0.72

lapex_weapon_ads_cancel:
    type: task
    debug: false
    definitions: target
    script:
    - flag <[target]> lapex.ads:!
    - flag <[target]> lapex.ads_token:!
    - flag <[target]> lapex.ads_monitor:!
    - if <[target].is_online||false>:
        - adjust <[target]> fov_multiplier

lapex_weapon_trigger:
    type: task
    debug: false
    definitions: item
    script:
    # One shared line collapses offhand/entity/block double events.
    - ratelimit <player> 1t
    - define id <[item].flag[lapex.id]||null>
    - if <[id]> == null:
        - stop
    - define arena_session <player.flag[lapex.arena_session]||null>
    - if <[arena_session]> != null:
        - if <server.flag[lapex.arena.session]||null> != <[arena_session]> || <server.flag[lapex.arena.state]||none> != live || <player.has_flag[lapex.arena_eliminated]>:
            - actionbar "<yellow>Weapons unlock when the Arena round begins"
            - stop
    - define registry <script[lapex_weapon_data].data_key[weapons]>
    - if !<[registry].keys.contains[<[id]>]>:
        - stop
    - if <[id]> == sheila && <player.flag[lapex.legend]||bangalore> != rampart:
        - actionbar "<red>Sheila requires Rampart"
        - stop
    - if <[id]> == a13_sentry && <player.flag[lapex.legend]||bangalore> != vantage:
        - actionbar "<red>A-13 Sentry requires Vantage"
        - stop
    - if <[id]> == whistler && <player.flag[lapex.legend]||bangalore> != ballistic:
        - actionbar "<red>Whistler requires Ballistic"
        - stop
    - define weapon <[registry].get[<[id]>]>
    # The first packet only arms the probe and produces one round. A second
    # packet inside the repeat window confirms a hold and starts refreshing the
    # trigger lease. This keeps a single tap from becoming a hidden burst.
    - if <[weapon].get[mode]> == auto:
        - if <player.flag[lapex.auto_probe]||null> == <[id]>:
            - flag player lapex.trigger:<[id]> expire:6t
        - flag player lapex.auto_probe:<[id]> expire:6t
    - if <player.has_flag[lapex.reloading]>:
        - if <[weapon].get[reload_style]||magazine> == shell && <player.item_in_hand.flag[lapex.ammo]||0> > 0:
            - flag player lapex.reloading:!
        - else:
            - stop
    - if <player.has_flag[lapex.action_lock]> || <player.has_flag[lapex.jammed]> || <player.has_flag[lapex.phased]>:
        - stop
    - choose <[weapon].get[mode]>:
        - case auto:
            - run lapex_weapon_auto def.id:<[id]>
        - case burst:
            - run lapex_weapon_burst def.id:<[id]>
        - case charge:
            - run lapex_weapon_charge def.id:<[id]>
        - default:
            - run lapex_weapon_semi def.id:<[id]>

lapex_weapon_semi:
    type: task
    definitions: id
    script:
    - if <player.has_flag[lapex.action_lock]>:
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - define phase <player.flag[lapex.fire_phase.<[id]>]||0.5>
    - define cadence <proc[lapex_weapon_cadence_step].context[<[weapon].get[rpm]>|<[phase]>]>
    - define lock_ticks <[cadence].get[delay]>
    - flag player lapex.fire_phase.<[id]>:<[cadence].get[phase]> expire:30s
    - flag player lapex.action_lock expire:<[lock_ticks]>t
    - flag player lapex.trigger:<[id]> expire:<[lock_ticks]>t
    - ~run lapex_weapon_fire_once def.id:<[id]>

lapex_weapon_burst:
    type: task
    definitions: id
    script:
    - if <player.has_flag[lapex.action_lock]>:
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - define count <[weapon].get[burst_count]||3>
    - define ticks_per_shot <element[1200].div[<[weapon].get[rpm]>]>
    - define lock <[weapon].get[burst_lock_ticks]||<[count].mul[<[ticks_per_shot]>].round.add[3]>>
    - define minimum_lock <[count].sub[1].mul[<[ticks_per_shot]>].round.add[1]>
    - if <[lock]> < <[minimum_lock]>:
        - define lock <[minimum_lock]>
    - flag player lapex.action_lock expire:<[lock]>t
    - flag player lapex.trigger:<[id]> expire:<[lock]>t
    - flag player lapex.burst:<[id]> expire:<[lock].add[5]>t
    # Carry sub-tick remainder across bursts. Resetting here would make a
    # 1080-RPM Nemesis use three one-tick gaps every time (1200 RPM in-burst).
    - define phase <player.flag[lapex.fire_phase.<[id]>]||0.5>
    - repeat <[count]> as:round:
        - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.flag[lapex.burst]||null> != <[id]> || <player.has_flag[lapex.jammed]>:
            - repeat stop
        - if <player.item_in_hand.flag[lapex.ammo]||0> <= 0 && !<player.has_flag[lapex.tempest]>:
            - repeat stop
        - ~run lapex_weapon_fire_once def.id:<[id]>
        - if <[round]> < <[count]>:
            - define cadence <proc[lapex_weapon_cadence_step].context[<[weapon].get[rpm]>|<[phase]>]>
            - define phase <[cadence].get[phase]>
            - flag player lapex.fire_phase.<[id]>:<[phase]> expire:30s
            - wait <[cadence].get[delay]>t
    - flag player lapex.burst:!
    - flag player lapex.trigger:!

lapex_weapon_charge:
    type: task
    definitions: id
    script:
    - if <player.has_flag[lapex.action_lock]>:
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - if <player.item_in_hand.flag[lapex.ammo]||0> <= 0 && !<player.has_flag[lapex.tempest]>:
        - run lapex_weapon_dry def.id:<[id]>
        - stop
    - define charge <[weapon].get[charge_ticks]||10>
    - define fire_lock <element[1200].div[<[weapon].get[rpm]>].round_up>
    - if <[fire_lock]> < <[charge]>:
        - define fire_lock <[charge]>
    - flag player lapex.action_lock expire:<[fire_lock]>t
    - flag player lapex.charging:<[id]> expire:<[charge].add[5]>t
    - actionbar "<aqua><[weapon].get[name]> <gray>charging..."
    - playsound <player.eye_location> sound:block.beacon.power_select pitch:1.7 volume:0.55
    - wait <[charge]>t
    - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.flag[lapex.charging]||null> != <[id]>:
        - flag player lapex.charging:!
        - stop
    - playeffect effect:electric_spark at:<player.eye_location.forward[0.8]> offset:0.05 quantity:8
    - ~run lapex_weapon_fire_once def.id:<[id]>
    - flag player lapex.charging:!

lapex_weapon_auto:
    type: task
    debug: false
    definitions: id
    script:
    - if <player.has_flag[lapex.auto_loop]> || <player.has_flag[lapex.action_lock]>:
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - if <player.item_in_hand.flag[lapex.ammo]||0> <= 0 && !<player.has_flag[lapex.tempest]>:
        - run lapex_weapon_dry def.id:<[id]>
        - stop
    - define spinup <[weapon].get[spinup_ticks]||0>
    - flag player lapex.auto_loop:<[id]> expire:<[spinup].add[10]>t
    - if <[spinup]> > 0 && !<player.has_flag[lapex.spinup_ready.<[id]>]>:
        - flag player lapex.action_lock expire:<[spinup]>t
        - flag player lapex.spinup:<[id]> expire:<[spinup].add[5]>t
        - actionbar "<yellow><[weapon].get[name]> <gray>spinning up..."
        - playsound <player> sound:block.respawn_anchor.charge pitch:1.6 volume:0.45
        - wait <[spinup]>t
        - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.flag[lapex.spinup]||null> != <[id]>:
            - flag player lapex.auto_loop:!
            - flag player lapex.spinup:!
            - stop
        - flag player lapex.spinup:!
        - flag player lapex.action_lock:!
    - if <[spinup]> > 0:
        - flag player lapex.spinup_ready.<[id]> expire:10t
    - define phase <player.flag[lapex.fire_phase.<[id]>]||0.5>
    - define first_shot true
    - while <player.is_online> && <player.health||0> > 0:
        - flag player lapex.auto_loop:<[id]> expire:10t
        - if !<[first_shot]> && <player.flag[lapex.trigger]||null> != <[id]>:
            - while stop
        - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.has_flag[lapex.reloading]> || <player.has_flag[lapex.action_lock]> || <player.has_flag[lapex.jammed]> || <player.has_flag[lapex.phased]>:
            - while stop
        - if <player.item_in_hand.flag[lapex.ammo]||0> <= 0 && !<player.has_flag[lapex.tempest]>:
            - run lapex_weapon_dry def.id:<[id]>
            - while stop
        - ~run lapex_weapon_fire_once def.id:<[id]>
        - define first_shot false
        # Rev state can expire during a hold, so cadence is re-read per round.
        - define rpm <[weapon].get[rpm]>
        - if <[id]> == rampage && <player.item_in_hand.has_flag[lapex.rampage_amped]>:
            - define rpm 390
        - define cadence <proc[lapex_weapon_cadence_step].context[<[rpm]>|<[phase]>]>
        - define phase <[cadence].get[phase]>
        - flag player lapex.fire_phase.<[id]>:<[phase]> expire:30s
        - wait <[cadence].get[delay]>t
    - flag player lapex.auto_loop:!

# Converts a fractional rounds-per-minute interval into integer server ticks
# while carrying the fractional remainder. Repeated calls stay within one tick
# of the requested cadence instead of rounding every shot down to a slower gun.
lapex_weapon_cadence_step:
    type: procedure
    debug: false
    definitions: rpm|phase
    script:
    - if <[rpm]> <= 0:
        - determine <map[delay=1;phase=0]>
    - define exact <element[1200].div[<[rpm]>].max[1]>
    - define delay <[exact].round_down>
    - define remainder <[exact].sub[<[delay]>]>
    - define next_phase <[phase].add[<[remainder]>]>
    - if <[next_phase]> >= 1:
        - define delay <[delay].add[1]>
        - define next_phase <[next_phase].sub[1]>
    - determine <map[delay=<[delay]>;phase=<[next_phase]>]>

# Registry patterns store signed shot counts: positive segments kick right and
# negative segments kick left. The sequence wraps only for magazines longer
# than the sampled pattern. Zero means the weapon retains random horizontal
# recoil because no trustworthy pattern has been entered yet.
lapex_weapon_recoil_direction:
    type: procedure
    debug: false
    definitions: id|shot
    script:
    # Fetch the list here instead of passing a ListTag through procedure
    # context, whose pipe separator would split the pattern into definitions.
    - define pattern <script[lapex_weapon_data].data_key[weapons.<[id]>.recoil_pattern]||<list>>
    - if <[pattern].is_empty>:
        - determine 0
    - define total 0
    - foreach <[pattern]> as:segment:
        - define total <[total].add[<[segment].abs>]>
    - if <[total]> <= 0:
        - determine 0
    - define position <[shot].sub[1].mod[<[total]>].add[1]>
    - foreach <[pattern]> as:segment:
        - define count <[segment].abs>
        - if <[position]> <= <[count]>:
            - if <[segment]> > 0:
                - determine 1
            - determine -1
        - define position <[position].sub[<[count]>]>
    - determine 0

# Converts Minecraft's accepted health/absorption changes back to the Apex HP
# scale used by the registry and player-facing damage numbers.
lapex_weapon_health_delta:
    type: procedure
    debug: false
    definitions: before_health|before_absorption|after_health|after_absorption
    script:
    - define scale <script[lapex_weapon_data].data_key[damage_scale]||0.2>
    - define health <[before_health].sub[<[after_health]>].max[0].div[<[scale]>]>
    - define shield <[before_absorption].sub[<[after_absorption]>].max[0].div[<[scale]>]>
    - define remaining <[after_health].add[<[after_absorption]>].div[<[scale]>]>
    - determine <map[health=<[health]>;shield=<[shield]>;total=<[health].add[<[shield]>]>;remaining=<[remaining]>]>

# Arena eliminates without a Minecraft death screen by canceling the lethal
# event and leaving one internal HP. Convert that sentinel to a truthful zero
# while keeping normal health/absorption math shared everywhere else.
lapex_weapon_resolve_damage:
    type: procedure
    debug: false
    definitions: before_health|before_absorption|after_health|after_absorption|was_eliminated|is_eliminated
    script:
    - if !<[was_eliminated]> && <[is_eliminated]>:
        - define scale <script[lapex_weapon_data].data_key[damage_scale]||0.2>
        - define health <[before_health].div[<[scale]>]>
        - define shield <[before_absorption].div[<[scale]>]>
        - determine <map[health=<[health]>;shield=<[shield]>;total=<[health].add[<[shield]>]>;remaining=0]>
    - determine <proc[lapex_weapon_health_delta].context[<[before_health]>|<[before_absorption]>|<[after_health]>|<[after_absorption]>]>

lapex_weapon_migrate_held:
    type: task
    script:
    # Previously issued guns used horse armor, which cannot emit air-use ADS
    # input. Replace them lazily while preserving the current magazine.
    - define legacy <player.item_in_hand>
    - define id <[legacy].flag[lapex.id]||null>
    - if <[id]> == null || <[legacy].material.name> != iron_horse_armor:
        - stop
    - if !<script[lapex_weapon_data].data_key[weapons].keys.contains[<[id]>]>:
        - stop
    - define ammo <[legacy].flag[lapex.ammo]||<script[lapex_weapon_data].data_key[weapons.<[id]>.mag]>>
    - inventory set origin:<item[apex_<[id]>]> slot:hand
    - inventory flag slot:hand lapex.ammo:<[ammo]>

lapex_weapon_fire_once:
    type: task
    debug: false
    definitions: id
    script:
    - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.has_flag[lapex.reloading]> || <player.has_flag[lapex.phased]>:
        - stop
    - define shooter_arena <player.flag[lapex.arena_session]||null>
    - if <[shooter_arena]> != null:
        - if <server.flag[lapex.arena.session]||null> != <[shooter_arena]> || <server.flag[lapex.arena.state]||none> != live || <player.has_flag[lapex.arena_eliminated]>:
            - stop
    - define registry <script[lapex_weapon_data].data_key[weapons]>
    - define weapon <[registry].get[<[id]>]>
    - define max_mag <[weapon].get[mag]>
    - if <player.flag[lapex.legend]||bangalore> == rampart && <[weapon].get[class]> == "Light Machine Gun":
        - define max_mag <[max_mag].mul[1.15].round>
    - define ammo <player.item_in_hand.flag[lapex.ammo]||0>
    - if <player.has_flag[lapex.tempest]>:
        - define ammo <[max_mag]>
        - inventory flag slot:hand lapex.ammo:<[max_mag]>
    - else:
        - if <[ammo]> <= 0:
            - run lapex_weapon_dry def.id:<[id]>
            - stop
        - define ammo <[ammo].sub[1]>
        - inventory flag slot:hand lapex.ammo:-:1

    - if <player.flag[lapex.legend]||bangalore> == mad_maggie && <[weapon].get[class]> == Shotgun:
        - cast speed duration:1.5s amplifier:0 <player> no_ambient hide_particles

    # Firing while tagged by Whistler adds heat. At the threshold the weapon
    # overheats, damages its user, and briefly interrupts their next action.
    - if <player.has_flag[lapex.whistler_heat]> && !<list[sheila|a13_sentry].contains[<[id]>]>:
        - flag player lapex.whistler_heat:+:1 expire:15s
        - define heat_limit <script[lapex_weapon_data].data_key[whistler_overheat_shots]>
        - if <player.flag[lapex.whistler_heat]> >= <[heat_limit]>:
            - define source <player.flag[lapex.whistler_source]||<player>>
            - define overheat <script[lapex_weapon_data].data_key[whistler_overheat_damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
            - if <[overheat]> > 0:
                - hurt <[overheat]> <player> cause:CUSTOM source:<[source]>
            - cast slowness duration:1.2s amplifier:1 <player>
            - playeffect effect:large_smoke at:<player.location.above[1]> offset:0.3 quantity:16
            - playsound <player> sound:block.fire.extinguish pitch:0.7 volume:1
            - actionbar "<red>WEAPON OVERHEATED"
            - flag player lapex.whistler_heat:!
            - flag player lapex.whistler_source:!
            - flag player lapex.action_lock expire:1.2s
            - flag player lapex.jammed expire:1.2s

    # Capture click-time aim, then send only a look packet for recoil. This
    # never changes player position or velocity.
    - define eye <player.eye_location>
    - define recoil_scale <script[lapex_weapon_data].data_key[recoil_scale]||1>
    - define recoil_pitch <[weapon].get[recoil_pitch].mul[<[recoil_scale]>]>
    - define recoil_yaw <[weapon].get[recoil_yaw].mul[<[recoil_scale]>]>
    - define kick_pitch <[recoil_pitch].mul[-1]>
    - define recoil_pattern <[weapon].get[recoil_pattern]||<list>>
    - if <[recoil_pattern].is_empty>:
        - define kick_yaw <util.random_decimal.sub[0.5].mul[<[recoil_yaw]>]>
    - else:
        - define recoil_shot <player.flag[lapex.recoil_shot.<[id]>]||0>
        - define recoil_shot <[recoil_shot].add[1]>
        - flag player lapex.recoil_shot.<[id]>:<[recoil_shot]> expire:12t
        - define recoil_direction <proc[lapex_weapon_recoil_direction].context[<[id]>|<[recoil_shot]>]>
        # Keep a little per-shot variance inside the sourced left/right shape.
        - define recoil_jitter <util.random_decimal.sub[0.5].mul[<[recoil_yaw]>].mul[0.16]>
        - define kick_yaw <[recoil_yaw].mul[0.32].mul[<[recoil_direction]>].add[<[recoil_jitter]>]>
    - define recoil_view <[eye].with_yaw[<[eye].yaw.add[<[kick_yaw]>]>].with_pitch[<[eye].pitch.add[<[kick_pitch]>]>]>
    - look <player> yaw:<[recoil_view].yaw> pitch:<[recoil_view].pitch>

    - define is_ads false
    - if <player.flag[lapex.ads]||null> == <[id]>:
        - define is_ads true
    - if <[is_ads]>:
        - define base_spread <[weapon].get[ads_spread]>
    - else:
        - define base_spread <[weapon].get[hip_spread]>
    - define pellets <[weapon].get[pellets]||1>
    - define pellet_spread <[weapon].get[pellet_spread]||0>
    - if <[is_ads]>:
        - define pellet_spread <[pellet_spread].mul[0.45]>
    - define range <[weapon].get[range]>
    - define raysize <[weapon].get[homing_raysize]||0.18>
    - define muzzle <[eye].forward[0.8].right[0.22].below[0.16]>
    - flag player lapex.last_shot_location:<[muzzle]> expire:10s
    - playeffect effect:small_flame at:<[muzzle]> offset:0.03 quantity:2 data:0.01
    - playeffect effect:dust at:<[muzzle]> offset:0.035 quantity:3 special_data:[size=0.8;color=<[weapon].get[tracer]>]
    - playsound <[eye]> sound:item.crossbow.shoot pitch:<[weapon].get[sound_pitch]> volume:0.75

    # Denser layered tracers are cadence-limited for automatic weapons. This
    # keeps their particle budget bounded while semi-auto and precision rounds
    # remain visible on every shot.
    - define tracer_interval 1
    - if <[weapon].get[mode]> == auto:
        - define tracer_interval 2
    - if <[id]> == sheila:
        - define tracer_interval 4
    - define draw_tracer true
    - if <[tracer_interval]> > 1 && <[ammo].mod[<[tracer_interval]>]> != 0:
        - define draw_tracer false
    - define tracer_style standard
    - if <[weapon].get[class]> == Shotgun:
        - define tracer_style shotgun
    - else if <[weapon].get[mode]> == charge:
        - define tracer_style charge
    - else if <[weapon].get[class]> == "Sniper Rifle" || <[weapon].get[class]> == Marksman:
        - define tracer_style precision
    - define tracer_center <[pellets].add[1].div[2].round>
    # Feedback is accumulated per trigger, not per pellet. This prevents a
    # shotgun from producing nine stacked sounds and lets the final actionbar
    # show the damage that the server actually accepted after armor, shields,
    # protection events, and virtual device health routing.
    - define confirmed_damage 0
    - define confirmed_health_damage 0
    - define confirmed_shield_damage 0
    - define confirmed_remaining null
    - define confirmed_targets <list>
    - define confirmed_headshot false
    - define confirmed_impact null

    - repeat <[pellets]> as:pellet:
        - if <[weapon].get[horizontal_pellets]||false>:
            - define center <[pellets].add[1].div[2]>
            - define yaw_offset <[pellet].sub[<[center]>].mul[<[pellet_spread]>]>
            - define pitch_offset <util.random_decimal.sub[0.5].mul[0.35]>
        - else:
            - define yaw_offset <util.random_decimal.sub[0.5].mul[<[base_spread].add[<[pellet_spread]>].mul[2]>]>
            - define pitch_offset <util.random_decimal.sub[0.5].mul[<[base_spread].add[<[pellet_spread]>].mul[2]>]>
        - define aim <[eye].with_yaw[<[eye].yaw.add[<[yaw_offset]>]>].with_pitch[<[eye].pitch.add[<[pitch_offset]>]>]>
        - define target <[aim].ray_trace_target[range=<[range]>;entities=living;ignore=<player>;raysize=<[raysize]>]||null>
        - define impact <[aim].ray_trace[range=<[range]>;entities=living;ignore=<player>;raysize=<[raysize]>;default=air]>
        # Dome collision is resolved before tracers, misses, Whistler mines, or
        # damage. It is a two-way boundary and deliberately has no team check.
        - define dome_block <proc[lapex_dome_trace_intersection].context[<[eye]>|<[impact]>]||null>
        - if <[dome_block]> != null:
            - if <[draw_tracer]> && <[pellet]> == 1 || <[draw_tracer]> && <[pellet]> == <[tracer_center]> || <[draw_tracer]> && <[pellet]> == <[pellets]>:
                - run lapex_weapon_render_tracer def.start:<[muzzle]> def.end:<[dome_block]> def.color:<[weapon].get[tracer]> def.style:<[tracer_style]>
            - playeffect effect:electric_spark at:<[dome_block]> offset:0.18 quantity:8
            - playsound <[dome_block]> sound:item.shield.block pitch:1.45 volume:0.65
            - repeat next
        - if <[draw_tracer]> && <[pellet]> == 1 || <[draw_tracer]> && <[pellet]> == <[tracer_center]> || <[draw_tracer]> && <[pellet]> == <[pellets]>:
            - run lapex_weapon_render_tracer def.start:<[muzzle]> def.end:<[impact]> def.color:<[weapon].get[tracer]> def.style:<[tracer_style]>
        - if <[target]> == null:
            - if <[id]> == whistler:
                - run lapex_whistler_mine def.location:<[impact]>
            - if <[pellet]> == 1:
                - playeffect effect:smoke at:<[impact]> offset:0.03 quantity:2 data:0.01
            - repeat next

        # A Crypto mannequin is the physical ray target, but combat state
        # belongs to the real player. Ordinary mobs and deployables keep their
        # own state because they have no canonical player mapping.
        - define state_target <[target]>
        - define combat_target <proc[lapex_legend_combat_player].context[<[target]>]||null>
        - if <[combat_target]> != null:
            - define state_target <[combat_target]>
        - define is_deployable <[target].has_flag[lapex.deployable_kind]>
        - if <[is_deployable]> && <[target].has_flag[lapex.deployable_invulnerable]>:
            - playeffect effect:electric_spark at:<[impact]> offset:0.15 quantity:6
            - repeat next
        - if <proc[lapex_legend_is_ally].context[<player>|<[target]>]>:
            - if <[target].flag[lapex.deployable_kind]||null> == caustic_trap:
                - run lapex_caustic_trigger def.entity:<[target]> def.session:<[target].flag[lapex.deployable_session]>
            - repeat next
        # Arena combat is session-owned. A stale bot, a prep/match-end actor,
        # or a player outside the active match must never reach `hurt` and must
        # never receive a hit confirm.
        - define arena_actor <[state_target]>
        - define deployable_owner <[target].flag[lapex.deployable_owner]||null>
        - define drone_owner <[target].flag[lapex.crypto_drone_owner]||null>
        - if <[deployable_owner]> != null:
            - define arena_actor <[deployable_owner]>
        - else if <[drone_owner]> != null:
            - define arena_actor <[drone_owner]>
        - define arena_session <[arena_actor].flag[lapex.arena_session]||<[target].flag[lapex.arena_bot_session]||null>>
        - if <[arena_session]> != null:
            - if <server.flag[lapex.arena.session]||null> != <[arena_session]> || <server.flag[lapex.arena.state]||none> != live || <player.flag[lapex.arena_session]||null> != <[arena_session]> || <player.has_flag[lapex.arena_eliminated]> || <[arena_actor].has_flag[lapex.arena_eliminated]>:
                - repeat next
        - if <[state_target].has_flag[lapex.legend_protected]> || <[state_target].has_flag[lapex.phased]>:
            - playeffect effect:electric_spark at:<[impact]> offset:0.15 quantity:6
            - repeat next
        - if <[id]> == whistler && <[state_target].has_flag[lapex.pylon_protected]>:
            - playeffect effect:electric_spark at:<[impact]> offset:0.15 quantity:6
            - repeat next

        - define damage <[weapon].get[damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
        - define zone body
        - if !<[is_deployable]>:
            - define height_fraction <[impact].y.sub[<[target].location.y>].div[<[target].height||1.8>]>
            - if <[height_fraction]> >= <script[lapex_weapon_data].data_key[head_zone]>:
                - define damage <[damage].mul[<[weapon].get[head_mult]>]>
                - define zone head
            - else if <[height_fraction]> <= <script[lapex_weapon_data].data_key[leg_zone]>:
                - define damage <[damage].mul[<[weapon].get[leg_mult]>]>
                - define zone legs

        # Charge Rifle damage rises at long range. This preserves its current
        # projectile identity while using hitscan at Minecraft distances.
        - if <[id]> == charge_rifle:
            - define distance <[eye].distance[<[impact]>]>
            - if <[distance]> >= 200:
                - define damage <[damage].mul[1.4667]>
            - else if <[distance]> >= 100:
                - define damage <[damage].mul[1.25]>

        # A-13's own follow-up hit is doubled. Every other Lapex gun receives
        # the shared mark bonus while the target remains marked.
        - if !<[is_deployable]>:
            - define mark_owner <[state_target].flag[lapex.vantage_mark]||null>
            - if <[id]> == a13_sentry:
                - if <[mark_owner]> == <player>:
                    - define damage <[damage].mul[<script[lapex_weapon_data].data_key[vantage_followup_multiplier]>]>
                - else if <[mark_owner]> != null && <proc[lapex_legend_is_ally].context[<[mark_owner]>|<player>]>:
                    - define damage <[damage].mul[<script[lapex_weapon_data].data_key[mark_bonus]>]>
            - else if <[mark_owner]> != null && <proc[lapex_legend_is_ally].context[<[mark_owner]>|<player>]>:
                - define damage <[damage].mul[<script[lapex_weapon_data].data_key[mark_bonus]>]>

        # Charge flags live on the gun item, so charging one copy cannot power
        # a different Sentinel or Rampage in the inventory.
        - if <[id]> == sentinel && <player.item_in_hand.has_flag[lapex.sentinel_amped]>:
            - define damage <[damage].mul[1.25]>
        # Amped Cover increases outgoing damage while its pulsed zone flag is
        # active. Maggie's mark and the telemetry flags feed passive scans.
        - if <player.has_flag[lapex.amped_cover]>:
            - define damage <[damage].mul[1.2]>

        # Read the authoritative state on both sides of the synchronous damage
        # event. Deployables and Crypto's drone use virtual HP; Crypto's body
        # batches accepted pellet damage for its one-tick exit transaction.
        - define damage_state standard
        - define before_health <[state_target].health||0>
        - define before_absorption <[state_target].absorption_health||0>
        - define was_eliminated <[state_target].has_flag[lapex.arena_eliminated]>
        - define before_virtual 0
        - define crypto_owner <[target].flag[lapex.crypto_body_owner]||<[target].flag[lapex.crypto_drone_owner]||null>>
        - define crypto_session <[target].flag[lapex.crypto_session]||null>
        - if <[is_deployable]>:
            - define damage_state deployable
            - define before_virtual <[target].flag[lapex.deployable_health]||0>
        - else if <[target].has_flag[lapex.crypto_body_owner]>:
            - define damage_state crypto_body
            - define before_virtual <[crypto_owner].flag[lapex.crypto_body_pending_damage.<[crypto_session]>]||0>
        - else if <[target].has_flag[lapex.crypto_drone_owner]>:
            - define damage_state crypto_drone
            - define before_virtual <[crypto_owner].flag[lapex.crypto_drone_health]||0>
        - define old_velocity <[target].velocity>
        - define old_no_damage <[target].no_damage_duration||0s>
        # Clear native immunity before the request. Clearing only afterward lets
        # another damage source consume the bullet while the old code still
        # played a successful hit sound.
        - adjust <[target]> no_damage_duration:0s
        - flag player lapex.damage_transaction expire:2t
        - hurt <[damage]> <[target]> cause:PROJECTILE source:<player>
        - flag player lapex.damage_transaction:!
        - if <[target].is_spawned||false>:
            - adjust <[target]> no_damage_duration:0s
            - adjust <[target]> velocity:<[old_velocity]>
        - define applied_damage 0
        - define applied_health 0
        - define applied_shield 0
        - define remaining 0
        - if <[damage_state]> == deployable:
            - define after_virtual <[target].flag[lapex.deployable_health]||<[before_virtual]>>
            - define applied_damage <[before_virtual].sub[<[after_virtual]>].max[0]>
            - define applied_health <[applied_damage]>
            - define remaining <[after_virtual]>
        - else if <[damage_state]> == crypto_body:
            - define after_virtual <[crypto_owner].flag[lapex.crypto_body_pending_damage.<[crypto_session]>]||<[before_virtual]>>
            - define queued_damage <[after_virtual].sub[<[before_virtual]>].max[0]>
            - if <[queued_damage]> <= 0:
                - if <[target].is_spawned||false>:
                    - adjust <[target]> no_damage_duration:<[old_no_damage]>
                - repeat next
            # The proxy accepted this pellet, but the real player is damaged one
            # tick later. Preserve one source/weapon record for the flush and do
            # not emit numeric feedback or telemetry until that damage lands.
            - define feedback_root lapex.crypto_body_feedback.<[crypto_session]>
            - if !<[crypto_owner].has_flag[<[feedback_root]>.shooter]>:
                - flag <[crypto_owner]> <[feedback_root]>.shooter:<player>
                - flag <[crypto_owner]> <[feedback_root]>.weapon_id:<[id]>
                - flag <[crypto_owner]> <[feedback_root]>.ammo:<[ammo]>
                - flag <[crypto_owner]> <[feedback_root]>.max_mag:<[max_mag]>
                - flag <[crypto_owner]> <[feedback_root]>.impact:<[impact]>
            - else:
                - define stored_shooter <[crypto_owner].flag[<[feedback_root]>.shooter]||null>
                - define stored_weapon <[crypto_owner].flag[<[feedback_root]>.weapon_id]||null>
                - if <[stored_shooter]> != <player> || <[stored_weapon]> != <[id]>:
                    - flag <[crypto_owner]> <[feedback_root]>.mixed:true
                - else:
                    - flag <[crypto_owner]> <[feedback_root]>.impact:<[impact]>
            - if <[zone]> == head:
                - flag <[crypto_owner]> <[feedback_root]>.headshot:true
            - repeat next
        - else if <[damage_state]> == crypto_drone:
            - define after_virtual <[crypto_owner].flag[lapex.crypto_drone_health]||<[before_virtual]>>
            - define applied_damage <[before_virtual].sub[<[after_virtual]>].max[0].div[<script[lapex_weapon_data].data_key[damage_scale]>]>
            - define applied_health <[applied_damage]>
            - define remaining <[after_virtual].div[<script[lapex_weapon_data].data_key[damage_scale]>]>
        - else:
            - define after_health <[state_target].health||0>
            - define after_absorption <[state_target].absorption_health||0>
            - define accepted <proc[lapex_weapon_resolve_damage].context[<[before_health]>|<[before_absorption]>|<[after_health]>|<[after_absorption]>|<[was_eliminated]>|<[state_target].has_flag[lapex.arena_eliminated]>]>
            - define applied_health <[accepted].get[health]>
            - define applied_shield <[accepted].get[shield]>
            - define applied_damage <[accepted].get[total]>
            - define remaining <[accepted].get[remaining]>
        - if <[applied_damage]> <= 0:
            - if <[target].is_spawned||false>:
                - adjust <[target]> no_damage_duration:<[old_no_damage]>
            - repeat next

        # Telemetry and weapon debuffs are damage-confirmed. A canceled event no
        # longer marks an enemy, reveals it, or drives a passive.
        - flag <[state_target]> lapex.last_attacker:<player> expire:10s
        - flag <[state_target]> lapex.last_damage_location:<[impact]> expire:10s
        - flag <[state_target]> lapex.threatened_by:<player> expire:4s
        - flag player lapex.last_target:<[state_target]> expire:10s
        - if !<[is_deployable]>:
            - define max_apex_health <[state_target].health_max.div[<script[lapex_weapon_data].data_key[damage_scale]||0.2>]||100>
            - if <[remaining].div[<[max_apex_health]>]> <= 0.4:
                - flag <[state_target]> lapex.low_health expire:6s
        - if !<[is_deployable]> && <player.flag[lapex.legend]||bangalore> == mad_maggie:
            - flag <[state_target]> lapex.maggie_mark:<player> expire:3s
            - run lapex_legend_private_outline def.viewer:<player> def.targets:<list[<[target]>]> def.duration:3s
        - define confirmed_damage <[confirmed_damage].add[<[applied_damage]>]>
        - define confirmed_health_damage <[confirmed_health_damage].add[<[applied_health]>]>
        - define confirmed_shield_damage <[confirmed_shield_damage].add[<[applied_shield]>]>
        - define confirmed_remaining <[remaining]>
        - define confirmed_targets <[confirmed_targets].include[<[state_target]>].deduplicate>
        - define confirmed_impact <[impact]>
        - if <[zone]> == head:
            - define confirmed_headshot true

        - if !<[is_deployable]> && <[id]> == a13_sentry:
            - flag <[state_target]> lapex.vantage_mark:<player> expire:10s
            - playeffect effect:dust at:<[target].location.above[<[target].height||1.8>]> offset:0.2 quantity:8 special_data:[size=0.7;color=255,55,75]
        - if !<[is_deployable]> && <[id]> == whistler:
            - if !<[state_target].has_flag[lapex.whistler_heat]>:
                - flag <[state_target]> lapex.whistler_heat:1 expire:15s
                - flag <[state_target]> lapex.whistler_source:<player> expire:15s
                - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.35 quantity:12
                - actionbar "<gold>Whistler <red>LOCKED"

    - if <[confirmed_damage]> > 0:
        - if <[confirmed_targets].size> > 1:
            - define confirmed_remaining null
        - run lapex_weapon_confirm_feedback def.shooter:<player> def.weapon_id:<[id]> def.ammo:<[ammo]> def.max_mag:<[max_mag]> def.damage:<[confirmed_damage]> def.health_damage:<[confirmed_health_damage]> def.shield_damage:<[confirmed_shield_damage]> def.remaining:<[confirmed_remaining]> def.headshot:<[confirmed_headshot]> def.impact:<[confirmed_impact]>
    - else:
        - actionbar "<gold><[weapon].get[name]> <white><[ammo]><gray>/<[max_mag]>"
    - if <[ammo]> <= 0 && <[weapon].get[auto_reload]||false>:
        - run lapex_weapon_reload def.id:<[id]>

# One truthful feedback path serves bullets, pellets, armor, absorption, and
# virtual devices. Values are displayed in Apex HP (Minecraft HP / 0.2).
lapex_weapon_confirm_feedback:
    type: task
    debug: false
    definitions: shooter|weapon_id|ammo|max_mag|damage|health_damage|shield_damage|remaining|headshot|impact
    script:
    - if <[shooter]||null> == null || !<[shooter].is_online||false> || <[damage]||0> <= 0:
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[weapon_id]>]||null>
    - if <[weapon]> == null:
        - stop
    - if <[impact]||null> != null:
        - if <[shield_damage]||0> > 0:
            - playeffect effect:electric_spark at:<[impact]> offset:0.1 quantity:5
        - if <[health_damage]||0> > 0:
            - playeffect effect:crit at:<[impact]> offset:0.08 quantity:4
    - define damage_text ""
    - if <[shield_damage]||0> > 0:
        - define damage_text "<aqua><[shield_damage].round> SHIELD"
        - playsound <[shooter]> sound:item.shield.block pitch:1.75 volume:0.6
    - if <[health_damage]||0> > 0:
        - if <[damage_text]> != "":
            - define damage_text "<[damage_text]> <dark_gray>+ "
        - define damage_text "<[damage_text]><red><[health_damage].round> DMG"
        - playsound <[shooter]> sound:entity.arrow.hit_player pitch:1.45 volume:0.68
    - if <[headshot]||false>:
        - playsound <[shooter]> sound:block.note_block.bell pitch:2 volume:0.6
    - define remaining_text ""
    - if <[remaining]||null> != null:
        - define remaining_text " <dark_gray>| <gray><[remaining].round> HP"
    - actionbar "<gold><[weapon].get[name]> <white><[ammo]><gray>/<[max_mag]> <dark_gray>| <[damage_text]><[remaining_text]>" targets:<[shooter]>

# Pure calculation smoke. Runtime combat tests cover event cancellation and
# virtual devices; this catches accidental unit or absorption regressions.
lapex_weapon_damage_feedback_smoke:
    type: task
    debug: false
    script:
    - define failures 0
    - define body <proc[lapex_weapon_health_delta].context[20|0|17|0]>
    - if <[body].get[health]> != 15 || <[body].get[shield]> != 0 || <[body].get[remaining]> != 85:
        - narrate "<red>[Lapex Damage] Health conversion failed: <[body]>"
        - define failures <[failures].add[1]>
    - define shield <proc[lapex_weapon_health_delta].context[20|4|20|1]>
    - if <[shield].get[health]> != 0 || <[shield].get[shield]> != 15 || <[shield].get[remaining]> != 105:
        - narrate "<red>[Lapex Damage] Shield conversion failed: <[shield]>"
        - define failures <[failures].add[1]>
    - define cancelled <proc[lapex_weapon_health_delta].context[20|0|20|0]>
    - if <[cancelled].get[total]> != 0:
        - narrate "<red>[Lapex Damage] Canceled-hit conversion failed: <[cancelled]>"
        - define failures <[failures].add[1]>
    - define eliminated <proc[lapex_weapon_resolve_damage].context[7|2|1|2|false|true]>
    - if <[eliminated].get[health]> != 35 || <[eliminated].get[shield]> != 10 || <[eliminated].get[total]> != 45 || <[eliminated].get[remaining]> != 0:
        - narrate "<red>[Lapex Damage] Arena elimination conversion failed: <[eliminated]>"
        - define failures <[failures].add[1]>
    - define feedback_root lapex.damage_smoke.<util.random_uuid>
    - flag server <[feedback_root]>.before_health:20
    - if <server.flag[<[feedback_root]>.before_health]||0> != 20:
        - narrate "<red>[Lapex Damage] Dynamic Crypto feedback path failed."
        - define failures <[failures].add[1]>
    - flag server <[feedback_root]>:!
    - if <[failures]> == 0:
        - narrate "<green>Lapex damage feedback smoke passed: health, shield, remaining HP, Arena elimination, and zero-delta cancellation."
    - else:
        - narrate "<red>Lapex damage feedback smoke failed with <[failures]> issue(s)."

lapex_weapon_render_tracer:
    type: task
    debug: false
    definitions: start|end|color|style
    script:
    - if <[start].world> != <[end].world> || <[start].distance[<[end]>]> < 0.25:
        - stop
    - define spacing 1.25
    - define size 0.68
    - if <[style]> == shotgun:
        - define spacing 1.6
        - define size 0.5
    - else if <[style]> == precision:
        - define spacing 1
        - define size 0.72
    - else if <[style]> == charge:
        - define spacing 0.8
        - define size 0.82
    - playeffect effect:dust at:<[start].points_between[<[end]>].distance[<[spacing]>]> offset:0 quantity:1 visibility:256 special_data:[size=<[size]>;color=<[color]>]
    - if <[style]> == precision:
        - playeffect effect:end_rod at:<[start].points_between[<[end]>].distance[4]> offset:0 quantity:1 visibility:256
    - else if <[style]> == charge:
        - playeffect effect:electric_spark at:<[start].points_between[<[end]>].distance[2.5]> offset:0.015 quantity:1 visibility:256

lapex_weapon_dry:
    type: task
    definitions: id
    script:
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - playsound <player> sound:block.dispenser.fail pitch:1.6 volume:0.65
    - actionbar "<red>0/<[weapon].get[mag]> <gray>- press <white>[F]<gray> to reload"
    - flag player lapex.trigger:!
    - flag player lapex.auto_probe:!

lapex_weapon_reload:
    type: task
    definitions: id
    script:
    - if <player.has_flag[lapex.reloading]> || <player.has_flag[lapex.action_lock]> || <player.has_flag[lapex.secondary]> || <player.item_in_hand.flag[lapex.id]||null> != <[id]>:
        - stop
    - run lapex_weapon_ads_cancel def.target:<player>
    - if <[id]> == a13_sentry:
        - actionbar "<red>A-13 rounds regenerate automatically"
        - stop
    - define weapon <script[lapex_weapon_data].data_key[weapons.<[id]>]>
    - define max_mag <[weapon].get[mag]>
    - if <player.flag[lapex.legend]||bangalore> == rampart && <[weapon].get[class]> == "Light Machine Gun":
        - define max_mag <[max_mag].mul[1.15].round>
    - define ammo <player.item_in_hand.flag[lapex.ammo]||0>
    - if <[ammo]> >= <[max_mag]>:
        - actionbar "<gold><[weapon].get[name]> <white><[ammo]><gray>/<[max_mag]> <gray>- full"
        - stop
    - flag player lapex.trigger:!
    - flag player lapex.auto_probe:!
    - flag player lapex.reloading:<[id]> expire:10m
    - define label <[weapon].get[reload_label]||Reloading>
    - define reload_factor 1
    - if <player.has_flag[lapex.tempest]>:
        - define reload_factor 0.55
    - else if <player.flag[lapex.legend]||bangalore> == rampart:
        - if <[weapon].get[class]> == "Light Machine Gun" || <[id]> == sheila:
            - define reload_factor 0.75

    - if <[weapon].get[reload_style]||magazine> == shell:
        - define shell_ticks <duration[<[weapon].get[reload]>].in_ticks.mul[<[reload_factor]>].round>
        - while <[ammo]> < <[max_mag]> && <player.item_in_hand.flag[lapex.id]||null> == <[id]> && <player.flag[lapex.reloading]||null> == <[id]>:
            - actionbar "<yellow><[label]><gray>... <white><[ammo]><gray>/<[max_mag]>"
            - playsound <player> sound:item.armor.equip_generic pitch:1.35 volume:0.7
            - wait <[shell_ticks]>t
            - if <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.flag[lapex.reloading]||null> != <[id]>:
                - while stop
            - inventory flag slot:hand lapex.ammo:+:1
            - define ammo <[ammo].add[1]>
        - if <player.flag[lapex.reloading]||null> != <[id]>:
            - flag player lapex.reloading:!
            - stop
        - flag player lapex.reloading:!
        - if <player.item_in_hand.flag[lapex.id]||null> == <[id]>:
            - playsound <player> sound:block.lever.click pitch:1.35 volume:0.8
            - actionbar "<gold><[weapon].get[name]> <white><[ammo]><gray>/<[max_mag]> <green>Ready"
        - stop

    - if <[ammo]> > 0:
        - define reload_ticks <duration[<[weapon].get[reload]>].in_ticks.mul[<[reload_factor]>].round>
    - else:
        - define reload_ticks <duration[<[weapon].get[empty_reload]>].in_ticks.mul[<[reload_factor]>].round>
    - actionbar "<yellow><[label]><gray>..."
    - playsound <player> sound:block.piston.contract pitch:1.35 volume:0.75
    - wait <[reload_ticks].mul[0.45].round>t
    - playsound <player> sound:item.armor.equip_generic pitch:1.2 volume:0.7
    - wait <[reload_ticks].mul[0.4].round>t
    - playsound <player> sound:block.piston.extend pitch:1.65 volume:0.75
    - wait <[reload_ticks].mul[0.15].round>t
    - if !<player.is_online> || <player.item_in_hand.flag[lapex.id]||null> != <[id]> || <player.flag[lapex.reloading]||null> != <[id]>:
        - flag player lapex.reloading:!
        - stop
    - inventory flag slot:hand lapex.ammo:<[max_mag]>
    - flag player lapex.reloading:!
    - playsound <player> sound:block.lever.click pitch:1.4 volume:0.85
    - actionbar "<gold><[weapon].get[name]> <white><[max_mag]><gray>/<[max_mag]> <green>Ready"

lapex_weapon_secondary:
    type: task
    definitions: id
    script:
    - flag player lapex.trigger:!
    - choose <[id]>:
        - case hemlok_breach:
            - run lapex_hemlok_breach_charge
        - case sentinel:
            - run lapex_sentinel_amp
        - case rampage:
            - run lapex_rampage_amp

# A missed Whistler round persists briefly as the tactical's proximity bubble.
# The first living target to enter it receives the same heat state as a direct
# lock, without block damage or an invisible armor-stand dependency.
lapex_whistler_mine:
    type: task
    definitions: location
    script:
    - repeat 40 as:pulse:
        - playeffect effect:electric_spark at:<[location]> offset:0.35 quantity:2
        - define target null
        - define target_state null
        - foreach <[location].find_entities[living].within[2.5].exclude[<player>]> as:possible:
            - define possible_state <[possible]>
            - define combat_possible <proc[lapex_legend_combat_player].context[<[possible]>]||null>
            - if <[combat_possible]> != null:
                - define possible_state <[combat_possible]>
            - if <proc[lapex_legend_is_ally].context[<player>|<[possible]>]> || <[possible_state].has_flag[lapex.legend_protected]> || <[possible_state].has_flag[lapex.pylon_protected]> || <[possible_state].has_flag[lapex.phased]> || <[possible_state].has_flag[lapex.whistler_heat]>:
                - foreach next
            - define target_height <[possible].height||1.8>
            - define target_center <[possible].location.above[<[target_height].div[2]>]>
            - if <proc[lapex_dome_trace_intersection].context[<[location]>|<[target_center]>]||null> != null:
                - foreach next
            - define target <[possible]>
            - define target_state <[possible_state]>
            - foreach stop
        - if <[target]> != null:
            - flag <[target_state]> lapex.whistler_heat:1 expire:15s
            - flag <[target_state]> lapex.whistler_source:<player> expire:15s
            - define damage <script[lapex_weapon_data].data_key[whistler_trap_damage].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
            - adjust <[target]> no_damage_duration:0s
            - hurt <[damage]> <[target]> cause:PROJECTILE source:<player>
            - adjust <[target]> no_damage_duration:0s
            - playeffect effect:electric_spark at:<[target].location.above[1]> offset:0.35 quantity:12
            - playsound <[target]> sound:block.conduit.activate pitch:1.8 volume:0.65
            - stop
        - wait 4t

lapex_hemlok_breach_charge:
    type: task
    script:
    - if <player.has_flag[lapex.breach_cooldown]> || <player.has_flag[lapex.action_lock]>:
        - actionbar "<red>Breach Charge unavailable"
        - stop
    - flag player lapex.secondary:hemlok_breach expire:30s
    - define weapon <script[lapex_weapon_data].data_key[weapons.hemlok_breach]>
    - flag player lapex.breach_cooldown expire:<[weapon].get[breach_cooldown]>
    - flag player lapex.action_lock expire:12t
    - actionbar "<yellow>Breach Charge armed..."
    - playsound <player> sound:block.respawn_anchor.charge pitch:1.25 volume:0.8
    - wait 8t
    - if <player.item_in_hand.flag[lapex.id]||null> != hemlok_breach || <player.flag[lapex.secondary]||null> != hemlok_breach:
        - stop
    - define eye <player.eye_location>
    - define impact <[eye].ray_trace[range=100;entities=living;ignore=<player>;raysize=0.35;default=air]>
    - define dome_block <proc[lapex_dome_trace_intersection].context[<[eye]>|<[impact]>]||null>
    - define damage_origin <[impact]>
    - if <[dome_block]> != null:
        - define impact <[dome_block]>
        - define damage_origin <[impact]>
        # Move radial traces slightly back toward the shooter. Starting exactly
        # on the shell would otherwise make the near boundary ambiguous.
        - define source_distance <[eye].distance[<[impact]>]>
        - if <[source_distance]> > 0.1:
            - define origin_x <[impact].x.add[<[eye].x.sub[<[impact].x>].div[<[source_distance]>].mul[0.1]>]>
            - define origin_y <[impact].y.add[<[eye].y.sub[<[impact].y>].div[<[source_distance]>].mul[0.1]>]>
            - define origin_z <[impact].z.add[<[eye].z.sub[<[impact].z>].div[<[source_distance]>].mul[0.1]>]>
            - define damage_origin <[impact].with_x[<[origin_x]>].with_y[<[origin_y]>].with_z[<[origin_z]>]>
    - playeffect effect:dust at:<[eye].forward[0.8].points_between[<[impact]>].distance[2]> offset:0 quantity:1 special_data:[size=0.6;color=255,125,65]
    - playsound <[eye]> sound:entity.firework_rocket.launch pitch:0.7 volume:0.8
    - if <[dome_block]> != null:
        - playeffect effect:electric_spark at:<[impact]> offset:0.2 quantity:10
        - playsound <[impact]> sound:item.shield.block pitch:1.35 volume:0.7
    - wait 2t
    - if <player.flag[lapex.secondary]||null> != hemlok_breach:
        - stop
    - playeffect effect:explosion at:<[impact]> offset:0.2 quantity:3
    - playeffect effect:large_smoke at:<[impact]> offset:<[weapon].get[breach_radius].div[3]> quantity:24
    - playsound <[impact]> sound:entity.generic.explode pitch:1.15 volume:1.1
    - foreach <[impact].find_entities[living].within[<[weapon].get[breach_radius]>].exclude[<player>]> as:target:
        - define target_state <[target]>
        - define combat_target <proc[lapex_legend_combat_player].context[<[target]>]||null>
        - if <[combat_target]> != null:
            - define target_state <[combat_target]>
        - if <proc[lapex_legend_is_ally].context[<player>|<[target]>]> || <[target_state].has_flag[lapex.legend_protected]> || <[target_state].has_flag[lapex.pylon_protected]> || <[target_state].has_flag[lapex.phased]>:
            - foreach next
        - define target_height <[target].height||1.8>
        - define target_center <[target].location.above[<[target_height].div[2]>]>
        - if <proc[lapex_dome_trace_intersection].context[<[damage_origin]>|<[target_center]>]||null> != null:
            - foreach next
        - define falloff <element[1].sub[<[target].location.distance[<[impact]>].div[<[weapon].get[breach_radius]>].mul[0.6]>]>
        - define damage <[weapon].get[breach_damage].mul[<[falloff]>].mul[<script[lapex_weapon_data].data_key[damage_scale]>]>
        - adjust <[target]> no_damage_duration:0s
        - hurt <[damage]> <[target]> cause:PROJECTILE source:<player>
        - adjust <[target]> no_damage_duration:0s
    - flag player lapex.secondary:!

lapex_sentinel_amp:
    type: task
    script:
    - if <player.item_in_hand.has_flag[lapex.sentinel_amped]> || <player.has_flag[lapex.action_lock]>:
        - actionbar "<aqua>Sentinel is already amped"
        - stop
    - flag player lapex.secondary:sentinel expire:30s
    - flag player lapex.action_lock expire:5s
    - actionbar "<aqua>Charging Sentinel..."
    - playsound <player> sound:block.beacon.activate pitch:1.2 volume:0.7
    - wait 5s
    - if <player.item_in_hand.flag[lapex.id]||null> != sentinel || <player.flag[lapex.secondary]||null> != sentinel:
        - stop
    - inventory flag slot:hand lapex.sentinel_amped expire:120s
    - playeffect effect:electric_spark at:<player.location.above[1]> offset:0.4 quantity:18
    - actionbar "<aqua>Sentinel Amped"
    - flag player lapex.secondary:!

lapex_rampage_amp:
    type: task
    script:
    - if <player.item_in_hand.has_flag[lapex.rampage_amped]> || <player.has_flag[lapex.action_lock]>:
        - actionbar "<red>Rampage is already revved"
        - stop
    - flag player lapex.secondary:rampage expire:30s
    - flag player lapex.action_lock expire:4s
    - actionbar "<gold>Loading thermite..."
    - playsound <player> sound:item.firecharge.use pitch:0.8 volume:0.7
    - wait 4s
    - if <player.item_in_hand.flag[lapex.id]||null> != rampage || <player.flag[lapex.secondary]||null> != rampage:
        - stop
    - inventory flag slot:hand lapex.rampage_amped expire:90s
    - playeffect effect:flame at:<player.location.above[1]> offset:0.35 quantity:15
    - actionbar "<gold>Rampage Revved"
    - flag player lapex.secondary:!
