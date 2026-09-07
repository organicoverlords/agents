# p3 master unification — 2026-08-16

Branch: `integration/master-unification-20260816`
Initial anchor: `implementation/basebuilding-rts-towerdefense-20260815` @ `271f65f9306e606d116bf8118c7d43923f95e3d5`

This branch is the non-destructive gameplay convergence lane. It inherits the current Survival/Basebuilding/RTS/Tower Defense source foundation plus already-integrated showroom, MCP, Fennec and Eagle work. Do not rewrite active source branches or convert source-only claims into runtime proof.

## Current branch inventory

| Lane | HEAD | State |
| --- | --- | --- |
| p3 main | `dd562269e8bad68adf35e0992f9c28493416d271` | ancestor; already contained |
| Showroom spawn/effects | `6b4af5e2f0658f06d209e373614e6f8e41e58e3f` | ancestor; already contained |
| Claude character/showroom | `c5a14f06d03fd5d2675b126d6c8eef230a1a8b97` | ancestor; already contained |
| Fennec runtime production | `e25e6cbce39aae6f53b94cc4bcfea49b59370acc` | ancestor; already contained |
| Eagle runtime | source `18012d5b8b9c815a1d7cf9c5070df83cf6389642` | proven unique content transplanted as integration commit `591698fb2d58145988d0299dd90ccca1f823b4d4` |
| Asylum historical character/showroom publish | `e1955863beaaecae058bcacfe831a893a2b1e08f` | HOLD wholesale; historical runtime proof was broken; later independently proven Asylum lane is authoritative |
| Current Survival/RTS/Tower Defense | `271f65f9306e606d116bf8118c7d43923f95e3d5` | source implemented; build/PIE runtime NOT YET PROVEN |

## Gameplay foundation currently present

The integration head includes native source for:

- resource inventory and pickups;
- grid/snap-aware build pieces and recipes;
- construction health/damage;
- RTS camera pawn and possession/blend flow;
- survival stats;
- procedural survival world support;
- character combat, projectiles and health routing;
- RTS abilities;
- defense towers, defense core, enemy actor and wave spawning;
- world/environment director;
- current Fennec runtime/input lineage;
- integrated Eagle runtime proof content;
- existing showroom/MCP history;
- Asylum Demon content already inherited through current p3 history, without treating the old broken publish commit as proof.

## Next acceptance sequence

Do not expand feature scope until the existing gameplay foundation is runtime-proven. The next production action is one owned UE5.8 acceptance pass, preserving unrelated editor/process ownership.

1. Editor-closed compile of the current integration head.
2. Fresh owned PIE using the ordinary third-person pawn.
3. Press `T`: visually prove the camera blends upward into RTS mode without a one-frame cut and input stays locked during the blend.
4. Prove RTS WASD pan and mouse-wheel zoom.
5. Return with `T`: prove the camera blends back and repossesses the exact original pawn.
6. Prove build preview follows cursor/grid.
7. Place adjacent foundations and prove edge snapping.
8. Prove plank/brick walls require valid structural snap support; free-floating wall must fail closed.
9. Prove resource cost is consumed exactly once; insufficient resources reject placement.
10. In a dedicated TD test map, use Dynamic runtime NavMesh, one defense core and one wave spawner.
11. Prove enemies path to the core, then react to newly placed construction.
12. Prove a player-built defense tower acquires and kills tagged enemies.
13. Capture native PIE visual evidence plus a machine-readable receipt.

Until that sequence passes, report the RTS/Basebuilding lane as `SOURCE_IMPLEMENTED / RUNTIME_NOT_PROVEN`.

## Cross-repo dependency

LowVRAM3D master convergence is tracked on `organicoverlords/lowvram3d-studio` branch `integration/master-unification-20260816`. Generated/rigged character, Asylum, bird, renderer and view-contract updates must enter p3 only after their own source/evidence lanes are reconciled. p3 integration must not become a dumping ground for unproven asset snapshots.

## Ongoing rule

Re-read all branch heads before each integration write. A newer active agent result supersedes the SHA recorded here for its own subsystem, but not unrelated proven work.
