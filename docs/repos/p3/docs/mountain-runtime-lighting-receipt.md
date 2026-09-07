# Mountain runtime identity and lighting receipt

Offline receipt captured 2026-08-12 from the shared `p3` worktree. This file
documents historical source checks only; it is not runtime proof and has no
current authority to permit or prohibit map edits, asset edits, builds, or PIE.

## Canonical identity

| Check | Source anchor | Expected behavior |
| --- | --- | --- |
| Sole body object path | `Source/p3/p3IceMountainCharacter.cpp:39` | Only `BodyFaceFixed/.../SM_IceMountain_BodyFaceFixed.SM_IceMountain_BodyFaceFixed` is canonical. |
| Cloud object paths | `p3IceMountainCharacter.cpp:29-33` | `cloud_00`, `cloud_01`, and `cloud_02` load only from `/Game/Playable/IceMountain/<cloud>/StaticMeshes/<cloud>.<cloud>`. There is no Showroom fallback. |
| Body lookup | `p3IceMountainCharacter.cpp:45-51` | `FindPlayableBody()` loads only `CanonicalBodyPath`; no alternate body or inner-shell fallback. |
| BeginPlay reassertion | `p3IceMountainCharacter.cpp:244-248` | Every Mountain pawn reassigns the canonical body before use. |
| Canonicalization | `p3IceMountainCharacter.cpp:352-376` | Missing canonical asset hides/clears the body; valid assets receive canonical mesh, -90° yaw, measured location/scale, visibility, and ticking. |
| Runtime reuse | `Source/p3/p3Character.cpp:560-654` | Key 5 scans only `PlayableIceMountain` pawns, rejects failed canonicalization, destroys stale/duplicate pawns, and keeps at most one reusable actor. |
| Spawn gate | `p3Character.cpp:656-683` | New pawn receives identity/mount tags and must pass `EnsureCanonicalBody()` before possession. |
| Enum route | `p3Character.cpp:716-725` | Any enum Ice Mountain request routes to the canonical key-5 selector; the retired skeletal path is not loadable. |
| Key binding | `p3Character.cpp:1818` | `5` invokes `SelectIceMountainVariant`. |

## Mount bridge checks

`Source/p3/p3IceMountainCharacter.cpp:641-705` is the Mountain-side bridge.
It temporarily removes the Mountain's own `RideableMount` tag before calling
the shared `FindNearestMount()`, restores it, restores the hidden pawn's
transform on failure, possesses the original pawn, calls shared `MountActor()`,
and re-possesses/re-hides correctly if attachment fails. The ordinary shared
bindings remain at `p3Character.cpp:1803`, `1894-1904`, and `2011+`.

## Lighting ownership checks

| Check | Source anchor | Expected behavior |
| --- | --- | --- |
| Opt-in directional light | `p3IceMountainCharacter.cpp:571-596` | H/BeginPlay writes only a directional light tagged `MountainTimeOfDay`. |
| Opt-in sky light | `p3IceMountainCharacter.cpp:598-609` | H/BeginPlay writes only a sky light tagged `MountainTimeOfDay`. |
| H binding | `p3IceMountainCharacter.cpp:730` | H still cycles Morning → Bright Day → Rain → Evening → Night. |
| Showroom authority | `Content/Python/TuneShowroomLighting.py` | Sole named-showroom baseline writer, guarded to `ALL_ASSETS_Lineup`. |
| Repair isolation | `Content/Python/RepairShowroomVisuals.py` | Floor/material/grass repair only; no light writes. |
| Deprecated writer | `Content/Python/TuneShowroomSkylight.py` | No-op compatibility script; no map save or mutation. |

## Useful live checks after a coordinated build/restart

1. In the active world, inspect all `Ap3IceMountainCharacter` actors and confirm
   exactly one `PlayableIceMountain` runtime actor after key 5; confirm its
   Body component resolves to the canonical BodyFaceFixed object path and all
   three cloud components resolve to the exact Playable-owned cloud paths.
2. Press key 5 twice and confirm the count remains one, no legacy/inner-shell
   body is visible, and the body relative yaw is -90°.
3. Press E with a valid tagged rideable target and confirm the shared mount
   contract succeeds; repeat with no target and confirm the original pawn
   transform/possession are restored.
4. Confirm untagged showroom lights retain their baseline after key 5 and H.
   If H is intended to drive showroom lighting, add `MountainTimeOfDay` only to
   the inspected approved `SHOWROOM_Sun` and `SHOWROOM_SkyLight` actors during
   an ownership-approved live map pass. Do not tag `SHOWROOM_FillLight`.
5. Capture the live receipt with world path, owner, actor labels, exact body
   asset path, tags, transform/rotation, possession result, and cleanup state.

## Static receipt

The following checks passed before this receipt was written:

```text
python scripts/validate_mountain_identity.py                 PASS
python scripts/validate_icemountain_vfx.py                   PASS
python scripts/validate_time_of_day.py                       PASS
python scripts/validate_mountain_mount_contract.py           PASS
python scripts/validate_lighting_authority.py                PASS
python -m py_compile validators and edited Python scripts      PASS
git diff --check                                               PASS
```

No Fennec files are referenced or changed by these Mountain/lighting patches.
