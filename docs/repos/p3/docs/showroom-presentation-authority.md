# Showroom presentation authority

This is the durable source contract for ALL_ASSETS_Lineup. Live state is proven only by same-world MCP receipts paired with inspected PNGs.

| Surface | Permanent owner | Contract |
| --- | --- | --- |
| Floor | Content/Python/RepairShowroomVisuals.py | Existing SHOWROOM_Floor, neutral material /Game/Showroom/Materials/MI_ShowroomGround_Neutral, QueryAndPhysics / BlockAll; no mesh replacement. |
| Grass | Content/Python/ImproveShowroomGrassField.py | Existing InstancedFoliageActor0 is canonical; preserve authored instances; LOD1200 broad/ferny/upright use MI_Grass_Wind_*; verified SimpleGrassWind -> MP_WORLD_POSITION_OFFSET; cull 600/9000; no parallel actor/HISM fallback. |
| Fallback cleanup | Content/Python/FinishShowroomGrass.py | Removes only legacy SHOWROOM_FoliageField_* actors when explicitly run; never spawns replacements. |
| Lighting | Content/Python/TuneShowroomLighting.py | Sole named-showroom writer; guarded to ALL_ASSETS_Lineup. Repair and ring scripts do not write light intensity. |
| Player entry / framing | Content/Python/TuneShowroomComposition.py | Sole legacy PlayerStart composition owner; exact `SHOWROOM_PlayerStart_Cluster` only; `(335,-26000,180)` facing inward at yaw 90; no lighting/ring/showcase actor writes. |
| Signs/ring | Content/Python/showroom_asset_ring.py | Stable first-seen ordering; one plaque, board, and post per accepted mesh; SIGN_TAG excluded from ring scope; 184-sign receipt contract. |
| Effects | Mountain/Fennec owners | This lane does not edit character/effect source; lightning/weather claims remain separate runtime gates. |

## Live evidence

Saved/AgentGrassFieldProbeReceipt.json proves the current world is /Game/Showroom/Maps/ALL_ASSETS_Lineup.ALL_ASSETS_Lineup, the foliage owner is InstancedFoliageActor0, and 25,780 authored instances are preserved: 8,622 broad, 8,597 ferny, and 8,561 upright. Each populated component has its wind MI, cull 600/9000, no collision, and no shadow casting. The probe also proves the three material WPO input nodes are SimpleGrassWind calls.

Saved/ShowroomAssetRingReceipt.json proves 184 accepted meshes and equal plaque/board/post totals. Saved/ShowroomVisualRepairReceipt.json records the floor material and lighting authority application.

## Low-VRAM constraints

Use instancing, simple opaque materials, existing WPO wind, bounded culling, and no extra lights, translucent shader layers, Lumen/VSM additions, or temporary actors.

## Visual policy

Every floor/grass/sign/lighting/composition claim requires a same-world MCP inventory receipt paired with an inspected PNG. The fresh 2026-09-06 worker-owned PIE baseline (SHA-256 `e4d06efccf6b4a9474363725bbf207a90dd9d216d1f07d57d9a822c1b5b2027d`) is bright enough but is an honest visual FAIL because the center-spawn player camera is obstructed by a large center display. Live actor evidence places `SHOWROOM_PlayerStart_Cluster` at `(335,0,180)` between center rideables at `x=+1200/-1200`; the composition owner moves only that start to the proven outside-in approach used by Showroom V2. A post-change same-world inspected PNG is still required before beauty-pass completion. Historical screenshots remain context only.
