# Feature: Short Name

## Status

- Owner:
- Research date:
- Apex season or event:
- Lapex issue or pull request:
- Fidelity goal: exact / adapted / analogue

## Player Story

In simple words, what can the player do? What should the other players see?

## Official Behavior

List one rule per row. Write `not published` instead of guessing.

| Rule | Current value or behavior | Source | Checked on |
| --- | --- | --- | --- |
| Input |  |  |  |
| Cooldown |  |  |  |
| Range |  |  |  |
| Damage or healing |  |  |  |
| Duration |  |  |  |
| Charges |  |  |  |
| Team behavior |  |  |  |
| Cancel or failure rules |  |  |  |
| Visual and sound cues |  |  |  |

## Minecraft Plan

Describe the full flow from input to cleanup. Name the entity, particle, block,
flag, and task choices. Explain why each choice is safe.

## Fidelity Decisions

| Part | Exact, adapted, analogue, or not implemented | Reason |
| --- | --- | --- |
|  |  |  |

## State and Cleanup

- Flags created:
- Entities or blocks created:
- Chunk tickets created:
- Cleanup on normal end:
- Cleanup on death, quit, legend switch, reload, and server restart:
- What happens when two players use it in the same place:

## Interactions

Cover allies, enemies, armor, shields, protected or phased players, portals,
pylons, guns, movement, world changes, and any other feature that can overlap.

## Test Cases

- [ ] Normal use works.
- [ ] The cooldown begins at the correct moment.
- [ ] Allies and enemies are treated correctly.
- [ ] Cancel and failure paths give clear feedback.
- [ ] Death, quit, legend switch, and script reload leave no state behind.
- [ ] Two players can use the feature at once.
- [ ] The feature works near unloaded chunks and world borders when relevant.
- [ ] The visible result matches the research note.
- [ ] Server console shows no errors.

## Known Gaps

List every missing part. Do not hide a gap in a comment or commit message.
