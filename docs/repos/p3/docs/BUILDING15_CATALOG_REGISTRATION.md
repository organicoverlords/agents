# Building15 Catalog Registration — 14 PASS / 1 REJECT (source-only, no new framework)

Status: **proposal only** — no editor import, no new `Ap3*` classes, no `GC` fracture. Records what catalog entries would map where so an editor pass can bind them verbatim.

Source receipts:
- `scripts/visual_qa_receipt.json` `p3_building15_visual_qa_v1` generated `2026-08-16T05:45:00Z` → now **14 PASS, 1 REJECT** (all 15 inspected, one-at-a-time protocol respected; `simultaneous_grids_open: 0`).
- `scripts/building15_registration_map.json` `p3_building15_registration_v1` — maps 15 assets to **existing** `EP3BuildPieceKind` / `Ap3*` families only. No new framework per instruction and per `NEXT_EDITOR_HANDOFF.md §F`.

## Contract

- Only the 14 PASS assets are production-approved for catalog binding. Hash existence was never proof; visual `PASS` is the gate.
- `mossy_stone_wall_fragment` is **REJECT** (hollow shell / paper-thin, no real depth) and stays **disabled** — no catalog entry, no binding, no GC.
- Families used are exactly `Source/p3/p3BuildTypes.h:EP3BuildPieceKind {Foundation,Floor,Wall,Ramp,Roof,Tower}` and `Source/p3/p3BuildPiece.h {Ap3FoundationPiece, Ap3PlankWallPiece, Ap3BrickWallPiece, Ap3DefenseTower}`. Variants are **SM swaps on the same kind/class**, not new piece classes.

## 14 PASS — where they would register (catalog-only)

All paths are the already-imported Nanite SMs at `/Game/Building/Mechanics15/<Asset>/SM_<Asset>` (verified `Saved/Automation/Building15/import_verification.json` 15/15, Nanite 848k–993k, collision 1–2). GC binding already exists only for `WeatheredWoodWallBrace` at `6334674`/`24f096c`; other GCs are deferred to editor fracture and are **not** source changes.

| # | Asset (visual_qa key) | Verdict | SM Content path | Catalog family | Existing kind / class | Binding note |
|---|---|---|---|---|---|---|
| 1 | `aged_mossy_wood_panel` | **PASS** | `/Game/Building/Mechanics15/AgedMossyWoodPanel/SM_AgedMossyWoodPanel` | `roof` | `Roof` (Floor/Roof kind) | Roof SM variant — catalog only, no new class |
| 2 | `rotted_wood_wall_panel` | **PASS** | `/Game/Building/Mechanics15/RottedWoodWallPanel/SM_RottedWoodWallPanel` | `wall` | `Wall` / `Ap3PlankWallPiece` | Wall variant on same `Wall` kind |
| 3 | `rustic_open_shutter_window_02` | **PASS** | `/Game/Building/Mechanics15/RusticOpenShutterWindow02/SM_RusticOpenShutterWindow02` | `window` | `Wall` | Wall-kind window SM |
| 4 | `rustic_wood_door` | **PASS** | `/Game/Building/Mechanics15/RusticWoodDoor/SM_RusticWoodDoor` | `gate` | `Wall` | Wall-kind door/gate SM |
| 5 | `stone_brick_chimney` | **PASS** | `/Game/Building/Mechanics15/StoneBrickChimney/SM_StoneBrickChimney` | `utility` | `Wall`/`Tower` | Utility as Wall/Tower variant |
| 6 | `ironbound_wooden_beam` | **PASS** | `/Game/Building/Mechanics15/IronboundWoodenBeam/SM_IronboundWoodenBeam` | `support` | `Wall` (100×12.5×100) | Narrow Wall piece — 848k lean, readable |
| 7 | `rustic_open_shutter_window` | **PASS** | `/Game/Building/Mechanics15/RusticOpenShutterWindow/SM_RusticOpenShutterWindow` | `window` | `Wall` | Wall-kind shutter window, 4-pane |
| 8 | `weathered_platform_with_stairs` | **PASS** | `/Game/Building/Mechanics15/WeatheredPlatformWithStairs/SM_WeatheredPlatformWithStairs` | `platform` | `Floor` | Floor-kind platform+stair |
| 9 | `weathered_roof_segment` | **PASS** | `/Game/Building/Mechanics15/WeatheredRoofSegment/SM_WeatheredRoofSegment` | `roof` | `Roof/Floor` | Gable roof w/ ridge beam |
| 10 | `weathered_wood_gate` | **PASS** | `/Game/Building/Mechanics15/WeatheredWoodGate/SM_WeatheredWoodGate` | `gate` | `Wall` | Gate Z-brace variant |
| 11 | `weathered_wood_gate_02` | **PASS** | `/Game/Building/Mechanics15/WeatheredWoodGate02/SM_WeatheredWoodGate02` | `gate` | `Wall` | Second gate Z-brace variant |
| 12 | `weathered_wood_platform` | **PASS** | `/Game/Building/Mechanics15/WeatheredWoodPlatform/SM_WeatheredWoodPlatform` | `platform` | `Floor` | X-braced deck |
| 13 | `weathered_wood_support` | **PASS** | `/Game/Building/Mechanics15/WeatheredWoodSupport/SM_WeatheredWoodSupport` | `support` | `Wall` | L-bracket+diagonal |
| 14 | `weathered_wood_wall_brace` | **PASS** | `/Game/Building/Mechanics15/WeatheredWoodWallBrace/SM_WeatheredWoodWallBrace` | `wall` | `Wall` / `Ap3PlankWallPiece` | **Already wired** — `GC_WeatheredWoodWallBrace` + `DF_WallBrace` + `Visual` path at `6334674` |

## 1 REJECT — disabled, no catalog entry

| Asset | Verdict | Path (exists but gated) | Action |
|---|---|---|---|
| `mossy_stone_wall_fragment` | **REJECT** 2026-08-16T06:01Z — hollow underside/bottom, collapsed inner faces, no thickness | `/Game/Building/Mechanics15/MossyStoneWallFragment/SM_MossyStoneWallFragment` | **Keep disabled.** No catalog binding, no GC, do not surface in build menu/recipe. SM stays on disk but is not referenced by any `Up3BuildRecipe` or placed actor. |

## Remaining editor work

- For the 14 PASS: add/find `Up3BuildRecipe` (`Source/p3/p3BuildRecipe.h`) or existing catalog DataAsset entry pointing `BuildActorClass` at the already-existing `Ap3*` class above and swapping `Visual` to the listed SM path. Cost/recipe unchanged unless design wants it. No new `AActor` subclass.
- For the REJECT: ensure no recipe references `SM_MossyStoneWallFragment`; if a prior draft did, remove it.
- GC: fracture remains editor-only per asset (Dataflow/PlanarCut), not source. Only `WeatheredWoodWallBrace` is already source-bound; do not invent bindings for the other 13 in source.

## Lane B source update (2026-08-16)

This historical source-only turn made the source/catalog changes below. Its old tool limitation has no current authority:

- **`stone_brick_chimney` is now source-bound**, the same way `weathered_wood_wall_brace` already was: `Ap3BrickWallPiece`'s constructor (`Source/p3/p3BuildPiece.cpp`) now calls `ApplyProductionVisual(StoneBrickChimneyMeshPath)`, so it renders on the existing brick-wall build hotkey today, no editor step needed. No GC yet (fracture stays editor-only, unchanged from the plan above).
- **`Up3BuildRecipe` (`Source/p3/p3BuildRecipe.h`) gained a `VisualMesh` field.** The struct previously had `BuildActorClass`/`Kind`/`Cost` but nowhere to declare which static mesh a recipe should bind — which is exactly what "swapping `Visual` to the listed SM path" (this doc's own plan, above) needed and didn't have. That gap is closed.
- **`Ap3BuildPiece::ApplyRecipe(const Up3BuildRecipe*)` was added** (`p3BuildPiece.h/.cpp`), along with a shared `ApplyProductionVisual()` helper (refactored out of the pre-existing WeatheredWoodWallBrace wiring, now reused for StoneBrickChimney). `ApplyRecipe` is the first and only place anywhere in the codebase that reads fields off an `Up3BuildRecipe` — before this, nothing consumed the DataAsset type at all, so even a hand-authored recipe asset would have been inert.
- The other **12 PASS assets are unchanged** and still need one `Up3BuildRecipe` DataAsset instance per asset (or equivalent spawn-from-recipe content). This is ordinary remaining editor/content work for an agent with Unreal access.

## Verification

- `scripts/visual_qa_receipt.json` is the single visual authority (criteria: silhouette/readability, real depth/thickness, missing parts, holes, floaters, duplication, underside/rear, warping; **not** tri count or hash presence).
- `scripts/building15_registration_map.json` updated in this turn to reflect 14 PASS / 1 REJECT (see diff). No framework files changed.

No Unreal, Blender, TRELLIS, or Priority-queue work performed (CPU/source/git only).
