# Lapex Player Guide

Lapex brings Apex-style guns and powers into Minecraft. This page uses short
steps and simple words. You do not need to know how the code works.

## Before You Play

Use a Minecraft 26.1.2 client. Ask the server owner for the Lapex resource-pack
ZIP. Turn the pack on before joining.

The pack changes each gun from a carrot on a stick into a low-poly weapon. The
game still works when the pack is off, but every gun will look like a carrot on
a stick.

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

Sneaking also uses the tighter accuracy value. Right-click is the normal ADS
control. Sneak is kept as a Minecraft-friendly backup and as a modifier for
some gun powers.

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

## Crypto Drone

Crypto has the most unusual control flow in Lapex.

1. Choose Crypto with `/legend crypto`.
2. Hold a Lapex gun.
3. Press Q, or run `/legend tactical`.
4. Your camera enters spectator flight.
5. A glowing allay marks the drone for other players.
6. A player-shaped Paper mannequin stays where you started. An armor stand is
   used if the server cannot create the mannequin.
7. Fly up to 200 blocks from that starting point.
8. Press Q again, or run `/legend tactical`, to recall the drone.

The drone has 50 Apex HP. Lapex shows this as `50/50` in the action bar. Enemies
can shoot the glowing drone. When it breaks, Crypto returns and the 30-second
drone cooldown starts.

Enemies can also shoot the body left behind. That hit returns Crypto to the body
and deals the hit to the real player. Allies cannot use the proxy to hurt their
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
Wait for a reload or action lock to finish. Then check the server console.

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
