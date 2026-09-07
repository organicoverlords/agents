# Macaw / Fennec Frozen Assets — p3 Import Reference (CPU/source only)

No Unreal, Blender, TRELLIS, or Priority-queue work performed. This is a source-only inventory.

## 1) c9710de — already pushed

- Repo: `C:\Users\Lauri\Desktop\lowvram3d-master-unif-20260816` (`origin https://github.com/organicoverlords/lowvram3d-studio.git`)
- Branch: `integration/master-unification-macaw-fennec-20260816` — **is on origin** (`git branch -r --contains c9710de` → `origin/integration/master-unification-macaw-fennec-20260816`)
- `cdae2f4 macaw: integrate preserved 151-file subtree into master-unification` (151 files, authoring/scripts + `macaw/MACAW_*.md` + evidence PNG/JSON)
- `c9710de fennec: integrate 44-file additive preservation into master-unification` (44 files, `blender/fennec_*`, `proof/rig/fennec_*`, `unreal/p3_fennec/*`, `unreal/fennec_import_handoff.json`)

No reset/clean/force-push/main-merge performed here; verification was read-only.

## 2) Macaw — frozen package expected for p3 import

Source docs: `macaw/MACAW_LANE_FROZEN.md` (FROZEN 2026-08-14), `macaw/MACAW_MASTER_RIG_FROZEN.md`, `macaw/MACAW_LOWRES_DERIVATIVE.md`, `macaw/MACAW_MOTION_PROOF_V2.md`.

### Frozen FBX/GLB paths

These live under `macaw/out/` which is **gitignored** — the freeze is reproducible, not stored. Rebuild via commands in `MACAW_LANE_FROZEN.md`; checksums assert identity.

```
macaw/out/macaw_lowres_035_skinned.blend    fb9e250650c59899060aa412cd8cd901b2d543cc8b3e7d8d9d757c755c817ad2  <- skinned rig (mesh+rig source)
macaw/out/macaw_lowres_035_animated.blend   38a9ab08a7e14bbc39ad065e620bebec114b9af00669d3a7bce9a2799cc93853  <- clips + proof tint (actions appended from here)
macaw/out/package/macaw_lowres_035_rigged.fbx  494207a3e3a4901cbd120fbcf97e4ed6a86e4e578a87f89f24a3cbf133ceebc0  <- p3 import: FBX
macaw/out/package/macaw_lowres_035_rigged.glb  45cde48bf659d0d39ed930f584441cb77070d3341cb392e2a2d2          <- p3 import: GLB (same 17-degenerate tri delta)
```

Repro commands (for reference, not run):

```
blender --background --python package_macaw.py -- --blend out/macaw_lowres_035_skinned.blend --actions out/macaw_lowres_035_animated.blend --out out/package
blender --background --python verify_package.py -- --fbx out/package/macaw_lowres_035_rigged.fbx --out out/package
```

Master lineage (not imported to p3, but provenance): `macaw/out/macaw_master_released_skinned.blend a7fd04b34da1cd2bbc62cd6536f776fc65933b15d3cb7aaff1ec532a0bd62f39` (135k → derivative 24k).

### Skeleton / mesh

- **34 bones** (28 carried from donor + `wing_L_prox/mid/dist` + `wing_R_prox/mid/dist`, parented to `bone_3`)
- **24343 vertices, 52001 triangles** in `.blend`; **51984 triangles** after FBX/GLB export (17 degenerate faces removed, 0.033% < 0.1% gate)
- 34 vertex groups, 1 `ARMATURE` modifier, `Material_0`, one UV map
- Unreal import scale **NOT** established — verify on import (see `MACAW_LANE_FROZEN.md`).

### Four clips (frozen, verified moving)

| Clip | Frames | Loops | Provenance |
|---|---|---|---|
| `Macaw_WingSpread` | 24 | no | dorsal-axis spread, proximal 0.6 / mid 0.4 / distal 0 |
| `Macaw_WingFold` | 24 | no | inverse of spread |
| `Macaw_Flap` | 16 | yes | span-perpendicular lift axis, 0.45/0.35/0.20, ±22°, loop error 0.0e+00 |
| `Macaw_Glide` | 48 | yes | gentler breathing, loop error 0.0e+00 |

Re-import verification (`verify_package.py`): all four takes present and each **moves** the mesh (displacements 0.31459 / 0.29573 / 0.16090 / 0.02666). Tail travel exactly 0 in every stage; `tip/root` 41–44 (not a rigid slab); no wing crossing; ≤62 edges >3× (inherited residual, not new).

## 3) Fennec — production assets that matter for later p3 import

Source docs: `proof/rig/fennec_playable_receipt.json`, `unreal/fennec_import_handoff.json`, `unreal/p3_fennec/fennec_variant_manifest.json`, `docs/rigging/FENNEC_PLAYABLE_HANDOFF.md`, `proof/rig/fennec_current_gate_receipt.json`.

### Offline-generated payloads (outside Git, preserved)

| Artifact | Path | SHA-256 |
|---|---|---|
| Blender master (source-preserving) | `C:\Users\Lauri\Desktop\lowvram3d-fennec-rig-20260812\fennec_playable.blend` | `32e52333585706ab6f495cd72562aced6e616094ef058bfe045982005aff2afe` |
| Skinned GLB (Unreal-compatible) | `C:\Users\Lauri\Desktop\lowvram3d-fennec-rig-20260812\fennec_playable.glb` | `503184779aef18c5fecc8ae47c479b291145013cf5d9066a463b416e22eaa11c` |
| FBX export (repo `-Y/Z`; Unreal import pending) | `C:\Users\Lauri\Desktop\lowvram3d-fennec-rig-20260812\fennec_playable.fbx` | `b9aae905aa294ec826b87f0f13ec655f9487d4f1ea236b3d9b533742a43c8d4c` |
| 75k proxy GLB | `C:\Users\Lauri\Desktop\lowvram3d-fennec-rig-20260812\fennec_proxy_75k.glb` | `2a04839bb7358155778d5c41161bb2c31db69a91e76313a99ab7292e347f6665` |
| Source (read-only, skins:0/anim:0) | `C:\Users\Lauri\Desktop\lowvram3d-scene-smoke-20260803\evidence\compare\fennec\fennec_mt_hypaint2048.glb` | `2adc4b2c0f8aaf5d90e0c01ffdde835c5910abcda025f5efbcf795e67d9c7aad` (14,995,432 bytes) |

GLB structural validation after export: 1 mesh, 1 skin, **29 joints**, `JOINTS/WEIGHTS`, 4 animations, 100% weight coverage (4 influences/vertex, sums 0.9999999553–1.0000000447).

### Skeleton / bone count

- **29 bones**, `Fennec_Skeleton` (`tail_01..tail_05` + `ear_L/ear_tip_L/ear_R/ear_tip_R` chains), `ARMATURE` modifier target `Fennec_Skeleton`.
- Geometry at export: 307673 vertices, 400000 faces, dimensions ~0.98×0.98×1.97 m, canonical `+X` forward / `+Z` up (`Rz+90°: -Y→+X`).
- Proxy: exactly 75,000 faces.

### Four clips

`Fennec_Idle`, `Fennec_Walk`, `Fennec_Run`, `Fennec_Turn` — authored in `blender/fennec_playable_rig.py` with tail secondary; offline max displacement/height: idle 0.043, walk 0.086, run 0.131, turn 0.608.

### p3 import target paths (what the later editor pass must create)

Two conventions exist in-repo; **both** describe the same payload — the `p3_fennec` isolated acceptance lane vs the `p3` native `Ap3Character` patch. Pick one target tree and keep it consistent; do not duplicate.

**A) Manifest convention** (`unreal/p3_fennec/fennec_variant_manifest.json`, `unreal/fennec_import_handoff.json`):

```
SkeletalMesh: /Game/Fennec/Fennec_Playable_SKM.Fennec_Playable_SKM
Skeleton:     /Game/Fennec/Fennec_Skeleton.Fennec_Skeleton
Idle:         /Game/Fennec/Animations/Fennec_Idle.Fennec_Idle
Walk:         /Game/Fennec/Animations/Fennec_Walk.Fennec_Walk
Run:          /Game/Fennec/Animations/Fennec_Run.Fennec_Run
Turn:         /Game/Fennec/Animations/Fennec_Turn.Fennec_Turn
Source FBX on disk: C:\Users\Lauri\Desktop\lowvram3d-fennec-rig-20260812\fennec_playable.fbx
```

**B) Native p3 patch convention** (`unreal/p3_fennec/p3_current_fennec.patch`, already present as dirty integration in that lane's `p3Character.*` per `proof/rig/fennec_current_gate_receipt.json`):

```
Mesh:  /Game/Playable/Fennec/fennec_playable.fennec_playable
Idle:  /Game/Playable/Fennec/fennec_playableFennec_Skeleton_Fennec_Idle.fennec_playableFennec_Skeleton_Fennec_Idle
Walk:  /Game/Playable/Fennec/fennec_playableFennec_Skeleton_Fennec_Walk.fennec_playableFennec_Skeleton_Fennec_Walk
Run:   /Game/Playable/Fennec/fennec_playableFennec_Skeleton_Fennec_Run.fennec_playableFennec_Skeleton_Fennec_Run
Turn:  /Game/Playable/Fennec/fennec_playableFennec_Skeleton_Fennec_Turn.fennec_playableFennec_Skeleton_Fennec_Turn
Key:   6 (SelectFennecVariant), selector +X, zero relative yaw
```

Integration files that carry the contract into p3 (patch-only, editor import pending): `p3_fennec/FennecVariantComponent.h/.cpp`, `p3_fennec/FennecVariantIntegration.patch`, `p3_fennec/p3_current_fennec.patch`, `p3_fennec/fennec_variant_manifest.json`, `unreal/fennec_import_handoff.json`.

### Gates / blockers

Offline: `FENNEC_SOURCE_PRESERVED` PASS, `FACING_PROVEN` PASS, `SKELETON_FIT` PASS, `WEIGHT_ISOLATION` PASS, `DEFORMATION` PASS, `UNREAL_EXPORT` PASS_OFFLINE_STRUCTURAL.

Hard-gated (explicitly not claimed offline, per `fennec_current_gate_receipt.json`): `FBX_AXIS_IMPORT`, `IK_RETARGET_ANIMBP` (IK_Rig + Retargeter + `ABP_Fennec`/`BP_FennecCharacter`), `PLAYABLE_PIE` (idle/walk/run/turn + PIE traversal + screenshots). Historical isolated PIE acceptance exists in that lane (`proof/rig/fennec_live_runtime_acceptance_receipt.json`, `fennec_extended_qa_receipt.json`) but current movement is `WAITING_REAL_DEPENDENCY` with no owned editor — do not claim as current.

No Fennec/Blender/queue/editor work done in this turn.

## 4) No bespoke controllers

Per instruction: no Owl/Hummingbird/Macaw `UFlightMovementComponent` subclasses or bespoke controllers were implemented. Flight differences remain data in `flight/flight_profiles.json` + the proposed `FFlightProfile` struct (`docs/FLIGHT_PROFILE_PROPOSAL.md`). Adding a species = adding a profile, not editing the controller.
