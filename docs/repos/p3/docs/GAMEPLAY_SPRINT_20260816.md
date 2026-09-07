# Rapid gameplay sprint — 2026-08-16

This branch is intentionally optimized for fast user playtesting rather than exhaustive agent PIE acceptance.

## Branch

`agent/chatgpt-gameplay-sprint-20260816`

Base: `integration/master-unification-20260816 @ 237120f24443cf94ab587f3c332abcb333bf3632`

## Auto-wired playtest controls

The `UP3GameplaySprintWorldSubsystem` follows player 0's possessed `ACharacter`, attaches `UP3GameplaySprintComponent` at runtime when needed, and reads direct keys without changing shared Input Mapping Context assets or `p3Character.cpp`.

- **G — Kinetic Pulse**
  - 725 cm radial pulse.
  - Applies 15 radial damage.
  - Launches nearby characters and pushes simulating physics bodies.
  - 1.75 s cooldown.

- **R — Gravity Pull**
  - 1100 cm radial pull.
  - Drags nearby characters toward the player.
  - Pulls simulating physics props inward with a mass-independent velocity impulse.
  - 2.25 s cooldown.

- **V — Ground Slam**
  - Available only while airborne and not in `MOVE_Flying`.
  - Forces a 2500 cm/s downward slam while preserving horizontal momentum.
  - On landing: 900 cm blast, 30 radial damage, stronger knockback.

- **F — Air Recovery**
  - One upward recovery hop per airborne cycle.
  - Resets on landing.
  - Disabled for true `MOVE_Flying` pawns so it does not interfere with Owl/Hummingbird flight controllers.

- **Tab — Shoulder Camera Swap**
  - Alternates the current follow spring arm between +82 cm and -82 cm lateral socket offset.
  - Works on any possessed character that owns a `USpringArmComponent`.

Development/test builds draw short-lived debug spheres for pulse, gravity pull, recovery hop, and slam impact so the mechanics are immediately readable before bespoke VFX exists.

## Integration policy

This slice is additive-only and deliberately does not modify:

- `p3Character.cpp/.h`
- Bird flight source/assets
- Fennec source
- fracture/RTS modules
- `p3.uproject`
- shared input assets

The Unreal worker should build, smoke, and autonomously exercise the slice. User playtesting is for product feel/design feedback when useful; it is not a technical completion gate or substitute for agent-run QA.
