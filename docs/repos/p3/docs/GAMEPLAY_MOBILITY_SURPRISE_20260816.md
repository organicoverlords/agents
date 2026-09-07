# Gameplay mobility surprise — 2026-08-16

Branch: `agent/chatgpt-mobility-surprise-20260816`

Parent: `agent/chatgpt-gameplay-sprint-20260816 @ 86f106440ad94eeb0fcf8e8825f6f7e8bdc1a87b`

Status: SOURCE COMPLETE / UE5.8 BUILD + USER PLAYTEST PENDING.

This child branch leaves the original gameplay-sprint integration target frozen while adding two more asset-free mobility toys to the existing runtime component.

## New controls

- **K — grapple burst**
  - traces from the player camera up to 3200 uu
  - if the aim hits a blocking surface, launches the character toward that point with a small upward bias
  - 1.25 second cooldown
  - refuses `MOVE_Flying` so Owl/Hummingbird flight remains authoritative
  - no target means no cooldown is consumed

- **L — directional dash**
  - uses the latest movement-input direction
  - falls back to actor forward when no movement input is active
  - short 1450 uu/s burst with a tiny upward bias
  - 0.70 second cooldown
  - refuses `MOVE_Flying`

Existing sprint controls remain unchanged:

- G kinetic pulse
- R gravity pull
- V ground slam
- F air recovery
- Tab shoulder swap

## Isolation

Only the existing additive sprint component and sprint world subsystem are extended. This branch does not edit:

- `p3Character`
- Fennec source
- bird flight source
- Enhanced Input assets
- RTS/base-building source
- project configuration

## Fast smoke only

1. UE5.8 C++ build succeeds.
2. Start one short owned PIE session.
3. K with a visible wall/ground target launches toward the hit point and does not crash.
4. K pointed into empty space does nothing.
5. L produces a short directional burst.
6. Existing G/R/V/F/Tab still dispatch without a crash.
7. Stop and hand to the user for feel/tuning acceptance.

No cloud-side compile/runtime proof is claimed.
