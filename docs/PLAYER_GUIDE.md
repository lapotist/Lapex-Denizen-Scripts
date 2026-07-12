# Lapex Player Guide

Lapex brings Apex-style guns and powers into Minecraft. This page uses short
steps and simple words. You do not need to know how the code works.

## Before You Play

Use a Minecraft 26.1.2 client. Ask the server owner for the Lapex resource-pack
ZIP. Turn the pack on before joining.

The pack changes each gun into a low-poly weapon. It also shows models for the
first eight physical legend devices. The game still works when the pack is off,
but guns and devices use their vanilla carrot-on-a-stick appearance.

## Your First Gun

An operator can give you a gun with:

```text
/lapex give r301
```

An operator can give every gun with:

```text
/lapex giveall
```

Hold the gun in your main hand. The last lore line shows its controls.

## Gun Controls

| What you want to do | Control |
| --- | --- |
| Shoot | Left-click |
| Keep shooting an automatic gun | Hold left-click |
| Aim down sights, called ADS | Hold right-click |
| Reload | Press F, the swap-hands key |
| Use a special gun charge | Sneak and press F on a supported gun |
| Use your tactical power | Press Q while holding a Lapex gun |
| Use your ultimate power | Sneak and press Q while holding a Lapex gun |

Lapex cancels the Q drop when you hold a Lapex gun. Your gun should stay in your
hand.

## Shooting

Point at a living target and left-click.

- The gun shoots from the camera.
- A colored tracer shows the shot path.
- A hit near the head deals more damage.
- A hit near the legs deals less damage.
- Shotguns send more than one pellet.
- Automatic guns keep firing while the client keeps sending left-click swings.

Recoil moves the camera up and a little sideways. It does not move your feet,
change your speed, or teleport you. If your body changes place when you shoot,
stop testing and report it as a bug.

## Aiming Down Sights

Hold right-click to zoom in and make the shot spread smaller. Let go to return
to the normal view.

Sneaking by itself does not improve gun accuracy. It is only a modifier for
some legend and special-gun powers. This keeps ADS predictable: right-click is
the one aiming control.

## Reloading

Press F while holding a gun.

- Most guns replace the full magazine at once.
- The Mastiff and 30-30 load one round at a time.
- The Bocek nocks its next arrow by itself.
- The test range has unlimited reserve ammo.
- You cannot shoot during the part of a reload that locks the gun.

Some guns use Sneak + F for a special action:

- Hemlok Breach: Breach Charge
- Sentinel: amp the rifle
- Rampage: load thermite
- Ballistic with a gun in the offhand: use the Sling behavior

## Choosing a Legend

See every legend:

```text
/legend list
```

Choose one:

```text
/legend crypto
```

Read that legend's powers:

```text
/legend info
```

Check power cooldowns:

```text
/legend status
```

Some current powers store two charges. The status command shows how many are
ready. Each spent charge gets its own timer, so one can return while another is
still charging.

You can always use these command backups:

```text
/legend tactical
/legend ultimate
```

The command backup is useful when Minecraft does not send a Q/drop action, such
as in some spectator views.

## Teams

Players with the same Lapex team name are allies. Many powers and guns avoid
hurting allies.

This team rule covers Lapex systems. It does not stop ordinary Minecraft falls,
lava, swords, or damage from another plugin.

An operator can set a team:

```text
/lapex setteam Alex red
/lapex setteam Sam red
```

The server owner may also let players manage their own team with:

```text
/legend team red
```

With no team name, only the caster counts as their own ally.

## Physical Powers

Some powers now place a real object instead of a hidden particle point.

- **Caustic trap:** arms, watches for enemies, can be shot, and shows its health.
- **Horizon N.E.W.T.:** can be shot while it pulls nearby enemies.
- **Ash Phase Breach:** Ash travels first. Other players enter the purple start
  portal only when they choose to. The exit never sends them backward.
- **Octane pad:** anyone can launch. Sneak once while airborne to turn your
  double jump toward the camera. Octane can store two pad charges.
- **Axle gate:** anyone entering gets a steerable slide. Sneak once to cancel it.
  Axle may keep two 100 HP gates.
- **Gibraltar Dome:** shots stop when they cross the blue shell in either
  direction. Players and shots already staying inside may move normally.
- **Lifeline D.O.C.:** heals nearby allies. Press tactical again to make D.O.C.
  follow the ally you aim at; aim at nobody to make it follow Lifeline.
- **Lifeline Halo:** friends see a blue station and enemies see a warning color.
  It does not make anyone invincible. It does not speed healing items yet.

The name above a shootable object shows its game health. Death, leaving,
changing world, changing legend, and script reload all clean up owned objects.

## Octane Stim

Normal Stim costs Lapex-tuned health and gives six seconds of speed. Use tactical
again while Stim is active to trigger Stim Surge. Surge costs no health, lasts
six seconds, and turns on Swift Mend even while Octane takes damage. Surge then
needs 20 seconds before it can be used again.

## Special Legend Guns

- Whistler has two rounds. Its heat state lasts 15 seconds and can cause 50
  overheat damage.
- A-13 starts with two rounds and grows one carried round every 40 seconds up to
  six. Tracking enemy teams while ADS also builds round progress.
- A-13, Whistler, and Sheila cannot be duplicated by repeating their powers.

## Crypto Drone

Crypto has the most unusual control flow in Lapex.

1. Choose Crypto with `/legend crypto`.
2. Hold a Lapex gun.
3. Press Q, or run `/legend tactical`.
4. Your camera can fly freely while your character stays behind.
5. A glowing allay marks the drone for other players.
6. A player-shaped body copy stays where you started. A simple stand is used
   if the server cannot create that body copy.
7. Fly up to 200 blocks from that starting point.
8. Press Q again, or run `/legend tactical`, to recall the drone.

The drone has 50 Apex HP. Lapex shows this as `50/50` in the action bar. Enemies
can shoot the glowing drone. When it breaks, Crypto returns and the 30-second
drone cooldown starts.

Enemies can also shoot the body left behind. That hit returns Crypto to the body
and deals the hit to the real player. Allies cannot use the body copy to hurt their
teammate.

While the drone is active, use the ultimate to start Drone EMP:

```text
/legend ultimate
```

The EMP starts at the drone. It reaches 30 blocks, removes up to 50 Apex shield
health, slows enemies, and reveals targets. It does not deal normal health
damage in this implementation.

## Kings Canyon

An operator creates or loads the arena. Players can ask an operator to teleport
them to the staging area or a named place.

Useful operator commands:

```text
/lapexmap status
/lapexmap list
/lapexmap tp staging
/lapexmap tp skull_town
```

The arena is a Minecraft adaptation of launch-era Kings Canyon. It is not a
block-for-pixel import of the Apex map.

## When Something Looks Wrong

### Every gun looks like a carrot

The resource pack is off, is the wrong version, or did not finish loading. Turn
on the 26.1.2 Lapex pack and reconnect.

### Left-click does not shoot

Make sure the item is a real Lapex gun. Try `/lapex give r301` as an operator.
Wait for the current reload or gun action to finish. Then check the server console.

### Right-click does not stay zoomed

Keep holding right-click. The server refreshes ADS from repeated use input. Test
with the carrot-on-a-stick Lapex item, not an old manually renamed item.

### Q drops the item

The held item is not recognized as a Lapex gun. Ask an operator for a fresh gun.
Use `/legend tactical` while testing.

### Crypto cannot recall with Q

Spectator clients may not send the normal drop packet. Run `/legend tactical`.

### A power says it is cooling down

Wait for its timer. An operator can clear timers in a test range with:

```text
/lapex resetcooldowns
```

## Small Word List

- **ADS:** aiming down sights; hold right-click to zoom and tighten shots.
- **Ally:** a player on your Lapex team.
- **Cooldown:** the wait before a power can be used again.
- **Damage:** health taken away by a hit.
- **EMP:** Crypto's electric ultimate around the drone.
- **FOV:** field of view; the amount of the world the camera can see.
- **Hip fire:** shooting without ADS.
- **Magazine:** the rounds inside the gun before a reload.
- **Passive:** a legend power that works by itself or from a special condition.
- **Recoil:** camera kick after a shot.
- **Spread:** how far a shot may move away from the center aim point.
- **Tactical:** a legend's often-used power.
- **Tracer:** the visible line that shows where a bullet traveled.
- **Ultimate:** a strong legend power with a longer cooldown.
