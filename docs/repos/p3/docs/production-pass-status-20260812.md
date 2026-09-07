# p3 production pass status — 2026-08-12

This is the current evidence index for the p3 production pass. It records what is
proven, what remains pending, and where the authoritative receipts live. A
runtime PASS below is limited to the exact MCP PIE checks listed; static source
checks are not promoted to runtime proof.

## Current repository

| Item | Value |
|---|---|
| Project | C:/Users/Lauri/Documents/Unreal Projects/p3 |
| Branch | agent/showroom-spawn-and-effects |
| HEAD at documentation update | dec49d1abc93fd8a8bfc950473ee068168902ae1 |
| Remote | https://github.com/organicoverlords/p3.git |
| Worktree | Dirty; unrelated generated/showroom and asset changes intentionally remain unstaged |

## Runtime character pass

The serialized PIE check used the live UE_MCP bridge on the current p3 editor,
then stopped only the PIE session started by this pass.

| Gate | Result | Evidence |
|---|---|---|
| Direct Fennec selection | PASS | MCP input Six after Asylum; pawn mesh /Game/Playable/Fennec/fennec_playable, material /Game/Playable/Fennec/M_FennecPlayable, actor scale (1,1,1), relative yaw 0. |
| Direct Asylum selection | PASS | MCP input Seven after Fennec; same pawn retained the input contract; mesh /Game/AsylumDemon/SK_AsylumDemon_435k, material /Game/AsylumDemon/M_AsylumDemonPlayable, actor scale (1,1,1), relative yaw -90 degrees. |
| Asylum size sanity | PASS | Live skeletal bounds extents approximately (51.79,44.45,44.64); no million-meter scale observed. |
| Macaw flight pose | PASS | MCP SpaceBar accepted; runtime mode MOVE_FLYING; visible WingPose; sampled bone 6 and bone 13 rotations were non-neutral. |
| Multiple Macaw bombs | PASS | Two immediate MCP LMB actions produced two simultaneous actors tagged MacawBomb. |
| Character cleanup | PASS | Agent-owned PIE stopped; pie_active=false; world restored to /Game/Showroom/Maps/ALL_ASSETS_Lineup. |

Runtime receipt: Saved/CharacterDurableFixReceipt.json. Captures:
Saved/QuickPassAsylum.png and Saved/QuickPassMacaw.png.

These checks prove binding and state transitions, not final visual quality. The
Asylum screenshot still needs an owner pixel review before a visual-quality PASS.

## Mountain

| Gate | Result | Evidence / blocker |
|---|---|---|
| Canonical body/source cleanup | STATIC PASS | docs/mountain-runtime-lighting-receipt.md and scripts/validate_mountain_identity.py. |
| Canonical cloud ownership | STATIC PASS | Source now uses the three Playable cloud paths only; asset moves/deletions were performed through Unreal APIs. |
| Key-5 runtime identity/weather/mount | PENDING | Requires one fresh MCP PIE pass with BodyFaceFixed, all three cloud components, timer weather, LMB lightning, H cycle, and E mount. |
| User-facing visual quality | PENDING/FAIL historically | Existing captures showed wrong/underexposed presentation; no current post-cleanup visual PASS is claimed. |

## Showroom

The durable authority documents are docs/showroom-presentation-authority.md and
docs/showroom-lighting-authority.md.

| Surface | Result |
|---|---|
| Floor material/collision intent | STATIC/PENDING LIVE |
| HISM grass/WPO path | STATIC/PENDING LIVE |
| Lighting writer ownership | STATIC PASS; live appearance pending |
| 184 plaque/board/post ring contract | STATIC/PENDING LIVE completeness |
| Fresh floor/grass/sign visual quality | FAIL historically; fresh live recheck required |

The dirty map and uasset changes are deliberately not included in this
documentation-only commit. They require a separate serialized MCP mutation
receipt and visual review.

## Asylum import/deformation

The size audit proves the approximately 4.6 GB figure was generated build PCH
data, not the skeletal mesh package. See docs/asylum-demon-size-audit.md and
docs/asylum-demon-live-mcp-inspection.md.

| Gate | Result |
|---|---|
| High-detail source preserved | PASS |
| Unreal test-copy LOD/Nanite/collision inventory | PASS_OFFLINE/LIVE_INSPECTED |
| Textured runtime binding | PASS_BINDING; pixel-quality review pending |
| Deformation torture/PIE gameplay proof | PENDING |
| Full import/Nanite/IK/retarget gate | PENDING |

## Policy closure

Every lane must leave either a receipt containing owner, world, exact evidence,
cleanup, and slot release, or an explicit CLEANUP_PENDING / RELEASE_PENDING
record. User-owned PIE is preserved; agent-owned PIE is stopped after the lane.
MCP is authoritative for live state and gameplay input.
