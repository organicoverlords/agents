# p3 base-building / RTS / tower-defense foundation

Status: **SOURCE IMPLEMENTED; BUILD AND PIE RUNTIME NOT YET PROVEN**.

Branch: `implementation/basebuilding-rts-towerdefense-20260815`
Base source anchor: `agent/fennec-runtime-production-20260814` @ `e25e6cbce39aae6f53b94cc4bcfea49b59370acc`.

## Intended player loop

The normal third-person game remains the default. `Ap3PlayerController` owns construction inventory so resources survive possession changes.

- `T`: enter/exit RTS build view with a cubic camera blend instead of a teleport. Entering preserves the exact gameplay pawn, freezes move/look input during the transition, blends from the character camera upward to `Ap3RTSCameraPawn`, and only then possesses the RTS camera. Returning performs the reverse blend first and repossesses the original pawn only after the view has arrived back on it.
- RTS `WASD`: pan camera.
- Mouse wheel: zoom.
- `1`: plank foundation (4 planks).
- `2`: plank wall (3 planks; requires structural snap support).
- `3`: brick wall (6 bricks; requires structural snap support).
- `4`: defense tower (8 planks + 12 bricks).
- `R`: rotate current preview in 90-degree steps.
- `LMB`: place if valid and affordable.
- `RMB`: cancel current build selection.

The camera transition duration is exposed as `RTSCameraBlendSeconds` (default 0.9 s). Build controls are locked until the upward/downward blend is complete, preventing accidental placement or a visible possession cut during the swing.

## Snapping / placement contract

Placement starts on a 100 cm XY grid from the visibility trace under the cursor. `Ap3BuildPiece` exposes typed `Up3BuildSnapPointComponent` points. Foundations expose foundation-edge adjacency plus four wall anchors on their top perimeter; walls expose bottom/end wall anchors; towers expose a base anchor. Unused snap points are disabled rather than universally compatible.

The preview chooses the nearest compatible point within the snap radius and applies a positional correction. Wall classes are fail-closed unless they acquired compatible snap support. Placement also runs an oriented overlap query against already finalized `Ap3BuildPiece` actors; touching neighbors are tolerated by shrinking the validation box, but penetrating existing construction is rejected.

All current meshes are `/Engine/BasicShapes/Cube` placeholders. Real planks/bricks/walls/roofs generated later should replace presentation only, not inventory, snapping, placement or health code.

## Inventory

`Up3InventoryComponent` stores Plank, Brick, Stone and Metal stacks and supports add/remove/CanAfford/ConsumeCost/RefundCost. The PlayerController seeds prototype quantities (100 planks, 100 bricks, 50 stone, 25 metal) only when all counts start at zero. `Ap3ResourcePickup` is a placeholder pickup actor that adds resources on authoritative pawn overlap.

`Up3BuildRecipe` is the future data-driven bridge for generated architectural modules; the initial prototype deliberately uses concrete native classes so it can work before content assets exist.

## Tower-defense contract

All finalized construction has health and standard `TakeDamage` destruction. `Ap3DefenseTower` runs an authority-side attack timer, selects the nearest actor inside range carrying tag `TowerDefenseEnemy`, and applies standard Unreal damage.

The model-free test loop now also includes:

- `Ap3DefenseCore`: damageable cube tagged `TowerDefenseCore`.
- `Ap3TowerDefenseEnemy`: `ACharacter` tagged `TowerDefenseEnemy`; an ordinary `AAIController` repeatedly requests movement toward the core, attacks it at melee range, receives normal UE damage, and dies at zero health.
- `Ap3TowerDefenseWaveSpawner`: authority-side timed waves using the placeholder enemy class. `MaxWaves=0` means endless waves.

These actors are not injected into existing p3 maps. A dedicated TD test map can place one core and spawner without changing the current showroom/gameplay maps. Player-built pieces already mark their finalized collision as navigation-relevant; for enemies to route around structures placed during play, that dedicated map should use a NavMeshBoundsVolume with Dynamic runtime navigation instead of changing the whole project's navigation policy.

## Required next proof

1. Normal UE5.8 editor-closed compile because this adds reflected classes/layout.
2. Fresh owned PIE: confirm T visibly blends upward from the current playable pawn to the RTS sky camera, with no one-frame possession cut, and blends back down to the same pawn.
3. Confirm camera WASD + zoom.
4. Confirm preview follows cursor and grid.
5. Place two adjacent foundations and prove edge snap.
6. Place plank and brick walls on foundation wall anchors; free-floating wall must be rejected.
7. Confirm resources decrement exactly once per placement and insufficient resources fail closed.
8. Dedicated TD map: add NavMeshBoundsVolume with Dynamic runtime generation, one `Ap3DefenseCore`, and one `Ap3TowerDefenseWaveSpawner`.
9. Prove enemies path toward the core; place walls and verify navigation reacts to newly built obstacles.
10. Prove a defense tower acquires and kills tagged enemies before they reach the core.
11. Capture native PIE evidence and leave unrelated editors/PIE untouched.

Do not call any of these runtime gates PROVEN from source alone.
