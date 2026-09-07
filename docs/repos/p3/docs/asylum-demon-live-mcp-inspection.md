# Asylum Demon live MCP inspection

Date: 2026-08-12
Scope: separate UE test-copy inspection only.
Receipt: [`evidence/asylum-demon/live_mcp_inspection_receipt.json`](https://github.com/organicoverlords/p3/blob/main/evidence/asylum-demon/live_mcp_inspection_receipt.json)

## Result

The live UE inspection does not support reimporting, decimating, or replacing the high-detail demon. The primary test copy is a one-LOD skeletal mesh with Nanite enabled, zero morph targets, zero skin-weight profiles, zero clothing assets, disabled per-poly collision, and a small 14-body physics asset. The prior multi-gigabyte measurement is not the `.uasset` size.

The deformation gate remains **NOT PROVEN**. A bounded animation preview rendered the mesh without an obvious exploded duplicate, but the preview was white/untextured and was not a controlled pose or PIE mid-action proof.

## Live package ledger

| UE asset | Package bytes | LODs | Nanite | Morphs | Weight profiles | Clothing | Per-poly collision | Physics |
|---|---:|---:|---|---:|---:|---:|---|---|
| `SK_AsylumDemon_435k` | 66,527,412 | 1 | enabled | 0 | 0 | 0 | disabled | `PHYS_AsylumDemon`, 14 bodies, 30,169 B |
| `FBXTest/...435k` | 66,653,767 | 1 | disabled | 0 | 0 | 0 | disabled | none |
| `FBXTestNoT0/...435k` | 66,653,823 | 1 | disabled | 0 | 0 | 0 | disabled | none |
| `RootTest/...root_weighted` | 66,473,271 | 1 | disabled | 0 | 0 | 0 | disabled | 1 body, 7,772 B |

All four copies report one source model and one material slot. None show the typical pathological multipliers: no extra LOD chain, morph/shape-key payload, clothing payload, skin-weight-profile set, or full-resolution collision package. The primary’s disk package is approximately 66 MB, not 4.6 GB.

## Earlier pipeline ledger

The source/export measurements remain unchanged from the size audit:

| Stage | Vertices | Faces/tris | Meshes | Skin/animation | File size |
|---|---:|---:|---:|---|---:|
| source PLY `00_asylum_demon_1m_s54321_res1024.ply` | 2,806,275 | 5,661,585 faces | 1 | none | 115,694,971 B |
| static 435k GLB | 293,086 | 435,206 tris | 1 | no skin/anim/morph | 64,382,400 B |
| large static GLB | 667,406 | 981,188 tris | 1 | no skin/anim/morph | 90,214,548 B |
| rigged GLB | 293,590 | 435,206 tris | 1 | 21 joints, 4 influences, 1 idle clip | 70,290,508 B |
| rigged FBX | not encoded in filename | not re-counted here | 1 export | 21-joint rig export | 17,478,652 B |
| Blender parented intermediate | n/a | n/a | n/a | rig intermediate | 68,002,616 B |

The previous disk audit found the apparent ~4.6 GB in two generated Unreal shared-PCH files under `Intermediate/Build`, totaling 4,728,815,600 B (~4.404 GiB), while `Content/AsylumDemon` totaled roughly 333 MB. Those files are build intermediates, not demon geometry, and were removed only after confirming no build/compiler process was active. This inspection did not change that result.

## Visual/deformation evidence

The temporary editor-world preview used the live primary skeletal mesh and `idle_validation`, then deleted all temporary actors without saving the map. The three preview files were:

- `Saved/AsylumDemonFocused.png` — 1,624,447 B, SHA256 `e3e8714c943e192b1eba6253535629caa276dd074714cb09480046086cc97383`
- `Saved/AsylumDemonDeformationProbe.png` — 1,173,227 B, SHA256 `3ac608f1ffdf23ed56436769161adbc05d5d44a4eacfa1964b8579a5037e0994`
- `Saved/AsylumDemonDeformationReadable.png` — 1,173,227 B, SHA256 `89c09e75f2fe6d4b609cfe4fe8ceef51a9281d85599bea89bc09beb6f43cfbc8`

The pixels show detailed geometry without an obvious duplicate/explosion, but the white material/stale texture presentation and camera framing prevent a deformation pass. No claim is made for locomotion, melee, Nanite runtime residency, collision quality, or PIE deformation.

## Cleanup and scope

- MCP/bridge was healthy on port 54673; the editor world was `ALL_ASSETS_Lineup`.
- The probe actors `SkeletalMeshActor11`, `AsylumProbe`, and `SkeletalMeshActor13` were deleted.
- The outliner returned to 51 actors; the map was not saved.
- No source, high-detail asset, rigged asset, reimport, decimation, or production queue was changed.
- Any user-owned PIE was left untouched; this lane did not stop PIE.

### Gate summary

- LOD/collision/morph/profile/clothing structure: **PASS**.
- Primary test-copy Nanite setting: **PASS (enabled)**.
- Package-size root cause: **PROVEN as Intermediate shared-PCH output, not the demon asset**.
- Material presentation: **PENDING_REPAIR**.
- Controlled deformation and PIE proof: **NOT PROVEN**.
