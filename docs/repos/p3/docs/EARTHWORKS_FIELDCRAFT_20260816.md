# Earthworks fieldcraft sprint — 2026-08-16

Branch: `agent/chatgpt-earthworks-fieldcraft-20260816`

Parent: `agent/chatgpt-basebuilding-materials-terrain-20260816 @ 600c274e38d09ac60c5ce0ba880e8532ef6e7e45`

Status: SOURCE COMPLETE / UE5.8 BUILD + USER PLAYTEST PENDING.

This child lane deliberately leaves the parent terrain/material commit frozen so another worker can integrate that exact parent while this sprint continues independently.

## New RTS earthwork controls

- **B — cycle sculpt brush size**
  - precision: 180 uu radius / 1 Soil unit
  - standard: 340 uu radius / 3 Soil units
  - large: 560 uu radius / 8 Soil units
  - Dig yield and Fill cost scale together so changing brush size is not a material exploit.

- **Z — dig with selected brush**
  - lowers terrain
  - yields Soil using the selected brush economy
  - Stone progress scales with the same excavation units

- **X — fill with selected brush**
  - raises terrain
  - spends Soil using the selected brush economy
  - refunds the Soil automatically if no terrain sample can change

- **C — flatten with selected brush**
  - remains mass-neutral
  - flatten radius follows the selected brush

- **H — quick trench**
  - cuts one 14 m long capsule-shaped trench across the cursor
  - yields 6 Soil plus normal proportional Stone progress
  - one keypress is one undoable terrain operation

- **J — quick berm**
  - raises one matching elongated earth berm
  - costs 6 Soil
  - automatically refunds if the heightfield cannot change

- **Backspace — undo last successful terrain sculpt**
  - restores the prior heightfield snapshot
  - keeps at most 12 terrain operations
  - also reverses Soil/Stone inventory deltas and excavation progress
  - an excavation undo is blocked if the player already spent the Soil/Stone it yielded, preventing material duplication

## Isolation

This sprint does not edit:

- `p3Character`
- bird flight source
- Fennec source
- shared Enhanced Input assets
- RTS ability hotbar
- gameplay-sprint shockwave/pull/slam source
- TRELLIS/image-to-3D infrastructure

It only extends the already-isolated earthworks actor/subsystem from the parent branch plus this documentation file.

## Fast gate only

The integration worker should not perform extended gameplay QA. Minimum check:

1. UE5.8 C++ build succeeds.
2. Start one short owned PIE session.
3. Enter RTS mode with **T** and create/locate the deformable worksite.
4. Tap **B** and confirm the brush log cycles 180 -> 340 -> 560.
5. **Z/X/C** still change terrain without a crash.
6. **H** cuts one elongated trench.
7. **J** creates one elongated berm and spends Soil.
8. **Backspace** reverses the last sculpt and its resource change.
9. Stop. User playtest owns feel/tuning acceptance.

Known status: no claim of UE5.8 compile/runtime proof is made by the cloud lane itself.
