---
kind: report
title: Asylum Demon size audit
---

# Asylum Demon size audit

Date: 2026-08-12

## Result

`ROOT_CAUSE_PROVEN`: the approximately 4.6 GB growth is not the demon mesh,
rig, skin weights, textures, or an Unreal skeletal-mesh package. It is generated
Unreal C++ build output under `Intermediate/Build`, dominated by two shared
precompiled-header (`.pch`) files:

| Generated file | Bytes | Approx. GiB |
|---|---:|---:|
| `Intermediate/Build/Win64/x64/p3Editor/Development/UnrealEd/SharedPCH.UnrealEd.Project.ValApi.ValExpApi.Cpp20.h.pch` | 2,575,302,640 | 2.398 |
| `Intermediate/Build/Win64/x64/p3/Development/Engine/SharedPCH.Engine.Project.ValApi.ValExpApi.Cpp20.h.pch` | 2,153,512,960 | 2.006 |
| **two PCH files** | **4,728,815,600** | **4.404** |

`Intermediate` measured 5,288,435,621 bytes before cleanup. Unreal Editor,
UnrealBuildTool, Live Coding, and compiler processes were absent, so only these
two exact generated PCH files were removed. The remaining `Intermediate` size
was 559,620,021 bytes. No source, GLB, PLY, FBX, `.uasset`, texture, or
production-queue file was modified.

The separate Unreal log warning that reports `RequiredMemory = 0.000 MiB +
4608.000 MiB` is a transient skinned-asset compilation memory budget. It is not
the disk size of `SK_AsylumDemon_435k`; the same warning appears for unrelated
Sealdiver, Mosstitan, Panda, and Warelephant assets.

## Repository and project

| Item | Value |
|---|---|
| Project | `C:\Users\Lauri\Documents\Unreal Projects\p3` |
| Project branch | `agent/showroom-spawn-and-effects` |
| Project HEAD | `dec49d1abc93fd8a8bfc950473ee068168902ae1` |
| Project remote | `https://github.com/organicoverlords/p3.git` |
| Project status | dirty, ahead 2; unrelated showroom/mountain/Fennec/source changes preserved |
| LOWVRAM3D repo | `C:\Users\Lauri\Desktop\lowvram3d-repo` |
| LOWVRAM3D branch | `production/foundation-freeze-20260812` |
| LOWVRAM3D HEAD | `c8f35c2afa3d4396c3221a9c76d29b5bb16c21d0` |
| LOWVRAM3D status | ahead 1; `workers/production_queue.sh` dirty and untouched |

## Stage ledger

| Stage | File / asset | Faces / tris | Vertices | Mesh copies | LODs | Morphs / shapes | Materials / UVs | Bones / skin | Size |
|---|---|---:|---:|---:|---:|---:|---|---|---:|
| Source PLY | `C:\Users\Lauri\Desktop\PLY_MASTERS\00_asylum_demon_1m_s54321_res1024.ply` | 5,661,585 faces | 2,806,275 | 1 | n/a | n/a | RGB vertex color | n/a | 115,694,971 B |
| Rigging source GLB | `out/00_asylum_demon_retry_20260808/00_asylum_demon_retry_res1024.glb` | 435,206 tris | 293,086 | 1 mesh / 1 primitive | none encoded | none | 1 material / 2 textures / 1 UV | none | 64,382,400 B |
| Alternate static GLB | `out/00_asylum_demon_retry_20260808/00_asylum_demon_1m_s54321_res1024.glb` | 981,188 tris | 667,406 | 1 mesh / 1 primitive | none encoded | none | 1 material / 2 textures / 1 UV | none | 90,214,548 B |
| Rigged GLB | `derived/asylum_demon_rig_apply_435k.glb` | 435,206 tris | 293,590 | 1 mesh / 1 primitive | none encoded | none | 1 material / 2 textures / 1 UV | 21 joints; VEC4 JOINTS + VEC4 WEIGHTS | 70,290,508 B |
| Identity GLB | `derived/asylum_demon_identity_skeleton_parented_435k.glb` | 435,206 tris | 293,590 | 1 mesh / 1 primitive | none encoded | none | 1 material / 2 textures / 1 UV | 21 joints; 4 stored influences/vertex | 70,279,800 B |
| Rigged FBX | `derived/asylum_demon_rig_working_435k.fbx` | same 435,206-tri mesh | same | one exported mesh in the validated handoff | not proven from binary | not proven from binary | preserved material payload | 21-joint handoff | 17,478,652 B |
| Blender rig intermediate | `derived/asylum_demon_identity_skeleton_parented_435k.blend` | same source-derived mesh | same | one validated mesh object | n/a | n/a | source material payload | 21-bone rig | 68,002,616 B |
| UE skeletal test copies | `Content/AsylumDemon/SK_AsylumDemon_435k.uasset`, `FBXTest`, `FBXTestNoT0`, `RootTest` | 435,206 tris in source handoff | 293,590 source handoff | 4 separate packages | UE LOD/Nanite not inspectable offline | UE morph/profile state not inspectable offline | 2 source textures; duplicate test textures | 21 source bones | 66,473,271–66,653,823 B each |

The source GLB used for the rigging handoff is the 435,206-triangle asset. The
separate 981,188-triangle GLB is a larger static candidate and was not silently
expanded by skinning. The 5.66M-face PLY is a separate color-point/face source
and is not the file imported into the validated 435k rig handoff.

## What was and was not duplicated

Each inspected GLB contains exactly one mesh, one node, and one primitive. The
rigged GLB has one animation (`idle_validation`), 21 joints, `JOINTS_0` and
`WEIGHTS_0` as VEC4 attributes, and no morph-target arrays. There is no evidence
of hidden duplicate geometry or an armature-evaluated second mesh in the GLB.

The project does contain four separate approximately 66 MB skeletal test
packages and duplicated 4096 texture packages. That is real content duplication,
but the complete `Content/AsylumDemon` folder is only 333,063,279 bytes
(approximately 0.310 GiB). The two 4096 textures are approximately 22.0 MB and
10.9 MB each; they are not pathological enough to explain 4.6 GB.

## First explosion

The first proven multi-gigabyte explosion occurs after Unreal C++ build
preprocessing, in `Intermediate/Build`, not in source preprocessing, rigging,
skinning, export, or Unreal asset serialization. The shared PCH dependency
files for ordinary sources such as `p3Character.cpp` and
`p3IceMountainCharacter.cpp` point to those same PCHs. Their names and usage
are project-wide; they are not Asylum-specific.

## Remaining inspection limits

The editor bridge was unavailable during this offline audit. Therefore UE-side
per-asset LOD count, Nanite enablement, imported build-data residency, skin
weight profiles, collision cooked-data size, and exact runtime skeletal-memory
statistics are marked **NOT INSPECTED**, not guessed. The binary GLB evidence
does prove the source/export-side mesh, joints, attributes, animation, and
morph-target facts listed above.

## Safe fix and validation status

No decimation, re-rigging, re-export, texture replacement, or `.uasset` edit was
warranted. The high-detail source and rigged handoff remain intact. The safe
disk recovery was removal of only the two generated shared-PCH cache files after
confirming no editor/build/compiler process was running. They may be recreated
by a future Unreal build; that is build-cache behavior, not asset growth.

The existing separate UE test copies remain available for a future live-bridge
check. Because no asset data was changed, there is no “after reimport” mesh to
claim: geometry preservation is exact across the validated source-to-rigged GLB
handoff (435,206 triangles; 293,590 rigged vertices; 21 joints; 4 stored
influences per vertex). UE deformation/Nanite/runtime visual proof remains
pending and is deliberately not claimed here.
