# Basebuilding Materials + Earthworks Playtest

STATUS=SOURCE_ONLY
BUILD=NOT_PROVEN
RUNTIME=NOT_PROVEN

This sprint extends the existing p3 construction system. It does **not** create a parallel inventory, placement system, or build menu. `Ap3PlayerController::ConstructionInventory` / `Up3InventoryComponent` remains the authoritative material ledger used by harvesting, building, repair, salvage, upgrades, and earthworks.

## Material loop

Generated survival maps now spawn 20 persistent harvest deposits as part of `Ap3ProceduralSurvivalWorld`. On maps without that generated survival deposit field, a deterministic 19-node fallback cluster bootstraps around the first real player pawn in standalone/server play. Hand-authored harvest nodes may coexist with either path; the fallback only suppresses itself when a generated deposit field already exists.

Resources:
- Plank
- Brick
- Stone
- Metal
- Soil

In survivor mode, look directly at a harvest deposit and press **M**. One configured batch transfers into the existing construction inventory; the node visually shrinks and is destroyed when depleted.

## Existing RTS construction controls

- **T** — enter/leave RTS build mode
- **1** — Foundation
- **2** — Plank Wall
- **3** — Brick Wall
- **4** — Defense Tower
- **[ / ]** — previous/next Building15 catalog entry
- **R** — rotate build preview
- **LMB** — place selected build
- **RMB** — cancel placement
- **Mouse wheel** — zoom RTS camera

Existing placement still owns preview, grid/snap, overlap validation, material consumption, spawn, and refund-on-spawn-failure.

## Earthworks and base management

These keys are active in RTS build mode:

- **N — Create/select deformable worksite**
  - costs 12 Soil
  - first sprint permits one runtime worksite per world to prevent spawned-ground material duplication
  - worksite is an actual `UProceduralMeshComponent` collision surface, not a decal
- **Z — Dig**
  - deforms the worksite downward
  - yields 3 Soil when deformation succeeds
  - does **not** mint Stone; Stone must come from world deposits
- **X — Fill**
  - raises deformable ground
  - costs 3 Soil
  - refunds the Soil if the terrain cannot change
- **C — Flatten**
  - redistributes local height toward the selected area's average
  - volume-conserving; creates/destroys no inventory material
- **Delete — Salvage structure**
  - dismantles a placed, intact `Ap3BuildPiece`
  - refunds 70% of positive recipe costs, rounded down
- **Y — Repair structure**
  - spends 1 unit of the first positive recipe material
  - restores up to 30 health
  - refunds the material if no healing occurs
- **U — Fortify plank wall**
  - replaces a placed intact plank wall with a brick wall at the same transform
  - costs 4 Brick + 2 Stone
  - refunds 70% of the removed plank wall's recipe material
  - refunds upgrade cost if the replacement spawn fails

## Terrain implementation scope

This sprint intentionally does **not** mutate Unreal Landscape at runtime. The editable construction worksite is a runtime procedural mesh with generated collision and a bounded height grid. That gives the player real digging/filling/flattening behavior without relying on editor-only Landscape deformation paths.

The first worksite is intentionally bounded and single-instance. A later sprint can replace it with streamed/chunked deformable terrain once the user has tested whether the interaction itself is fun.

## Presentation scope

Harvest nodes currently use model-independent placeholder geometry so the gameplay loop can be tested before art integration. They should later map to tree/log piles, quarry stone, brick/masonry stock, scrap/ore, and soil/clay visuals.

The HUD displays Plank / Brick / Stone / Metal / Soil counts and the RTS earthwork hotkeys.

## Known NOT_PROVEN items

- UE5.8 compile of this exact branch head
- runtime startup/smoke
- procedural ground collision feel under the player/build pieces
- cursor targeting ergonomics for earthworks
- user-facing tuning of dig radius/depth, fill height, worksite size and costs
- multiplayer harvest-stock replication/authority beyond the current standalone/server bootstrap
- production art for material deposits

The intended acceptance gate is deliberately small:

SOURCE -> UE5.8 COMPILE -> SHORT STARTUP/PIE SMOKE -> USER PLAYTEST -> TARGETED FIX
