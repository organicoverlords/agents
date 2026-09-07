# Base-building materials + earthworks sprint — 2026-08-16

Branch: `agent/chatgpt-basebuilding-materials-terrain-20260816`

Base: `integration/master-unification-20260816 @ 237120f24443cf94ab587f3c332abcb333bf3632`

Status: SOURCE COMPLETE / UE5.8 BUILD + USER PLAYTEST PENDING.

This sprint extends the existing construction system rather than creating a parallel builder. `Ap3PlayerController`, `Up3InventoryComponent`, `Ap3BuildPiece`, existing preview/grid/snap placement and recipe costs remain authoritative.

## Material loop

Construction inventory now contains:

- Plank
- Brick
- Stone
- Metal
- Soil

The procedural survival world keeps a smaller number of legacy walk-over resource caches and adds persistent harvestable deposits:

- timber -> Plank
- boulder -> Stone
- ore -> Metal
- ruined masonry -> Brick

Look at a persistent deposit in survivor mode and press **M**. One harvest batch moves into the same PlayerController-owned construction inventory. The deposit visibly shrinks and is destroyed only when its stock reaches zero.

Soil is intentionally different: it comes from earthworks rather than random pickups.

## Existing building controls preserved

Enter/leave RTS build mode: **T**

- 1 Foundation
- 2 Plank Wall
- 3 Brick Wall
- 4 Defense Tower
- [ / ] cycle Building15 catalog
- R rotate preview
- LMB place
- RMB cancel
- mouse wheel zoom

Placed structures still consume their existing `FP3BuildCost` through `ConstructionInventory->ConsumeCost()`. A failed spawn still refunds through the existing inventory path.

## New RTS material/earthwork tools

- **N — create earthwork site**
  - Converts the targeted ground position into one 24 m x 24 m runtime-deformable construction patch.
  - Costs 12 Soil for this first playtest.
  - This sprint intentionally allows only one live deformable worksite per world, preventing repeated worksite spawning from becoming an infinite Soil source.

- **Z — dig**
  - Lowers a radial area of the deformable ground.
  - Only a successful height change yields resources.
  - +3 Soil per successful dig.
  - Every fourth successful dig also yields +1 Stone.
  - Hitting the minimum terrain height gives no further resources.

- **X — fill / build earth**
  - Costs 3 Soil per successful operation.
  - Raises a radial area, allowing berms, raised pads and grading.
  - If the terrain cannot change, the 3 Soil is refunded.

- **C — flatten / grade**
  - Redistributes earth inside the brush without changing inventory.
  - It blends every affected height sample toward their mean with a common alpha, mathematically preserving the sum of the affected heights. It therefore cannot create free earth volume.

- **Y — repair targeted building**
  - Uses one unit of the first positive resource in that building's recipe as its repair material.
  - Restores 30 health.
  - If no health is restored, the material is refunded.
  - Fractured pieces are not repaired by this first-pass tool.

- **U — fortify plank wall to brick**
  - Targets an intact `Ap3PlankWallPiece`.
  - Consumes the normal `Ap3BrickWallPiece` recipe cost before replacement.
  - Spawns the brick wall at the exact old transform, finalizes it, then refunds 70% of the old plank-wall recipe and removes the old wall.
  - If the replacement spawn fails, the Brick cost is refunded and the old wall stays.

- **Delete — dismantle/salvage targeted building**
  - Works on placed, unfractured build pieces.
  - Refunds `floor(original recipe quantity * 0.70)` for each positive recipe resource.
  - Then destroys the structure.

## Terrain implementation

Runtime Landscape editing is deliberately not used in this sprint. `Ap3DeformableGround` owns a 17 x 17 `UProceduralMeshComponent` heightfield with generated triangle collision and side skirts. UE5.8's ProceduralMeshComponent runtime plugin is enabled by the branch.

The worksite uses per-poly geometry as simple collision, so the sculpted mesh is intended to be the actual walk/build surface rather than a visual-only deformation.

The existing PCG/environment terrain remains unchanged. The first worksite is a bounded prototype for eventual chunked/runtime terrain conversion.

## Fast acceptance gate

Do not spend time on exhaustive autonomous PIE testing. The Unreal worker should:

1. Build `p3Editor` in UE5.8.
2. Start one owned editor/short PIE smoke.
3. Confirm no startup crash and Soil appears in the RTS resource HUD.
4. Confirm M harvests a persistent deposit.
5. T -> N creates one worksite.
6. Z changes terrain and increases Soil.
7. X spends Soil and raises terrain.
8. C visibly grades terrain.
9. Place one existing structure with LMB.
10. Y repair and Delete salvage do not crash and change inventory as expected.
11. U upgrades one intact plank wall into a brick wall and charges/refunds materials correctly.
12. Hand the build to the user for actual feel/tuning acceptance.

Anything beyond that is user-playtest territory unless a concrete failure needs diagnosis.
