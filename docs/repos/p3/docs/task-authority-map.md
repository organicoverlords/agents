# p3 task authority map

`TASK_AUTHORITY_MAP_V1`

This file maps task classes to the **current files/runtime surfaces that own the
answer**. It deliberately does not copy current ports, PIDs, tuning numbers,
asset counts, provider models, or other values that can drift.

When a listed owner changes, read the changed owner. Do not preserve an old value
from this map, a handoff, or memory.

## Unreal editor / PIE / viewport

- Project/plugin topology: `p3.uproject` and current `Config/`.
- Canonical agent/session rules: `organicoverlords/agents` `AGENTS.md`; current session/runtime evidence remains local/live.
- Dynamic UE_MCP_Bridge endpoint: `Saved/UE_MCP_Bridge/port.json` on the live
  project; never use a remembered port.
- Runtime/editor/visual truth: the current owned editor/PIE path and current
  runtime evidence.

## Unreal agent-control path and bridge roles

For **new typed editor-tool work**, the primary control path is Unreal Engine 5.8
native MCP Tool Search / Toolset Registry through the repo-owned
`scripts/v2/verification/p3_native_mcp_client.py`. Resolve its endpoint from the
current editor/project configuration and bind it to the exact owned editor PID;
do not preserve a remembered port or treat a listener alone as project ownership.
The canonical task-level verification surface remains
`scripts/v2/verification/Invoke-P3Verification.ps1` / `p3_verification.py`; native
MCP is a transport/tool surface behind that owner, not a second verifier.

The other enabled bridges are retained secondary surfaces with bounded roles:

- `UE_MCP_Bridge` remains the current project-specific runtime/user-path/visual
  compatibility bridge. Existing verification and capture paths still depend on
  capabilities such as normal gameplay input, runtime observation, scene capture,
  and privileged Python escape-hatch calls. Its dynamic `port.json` is only
  endpoint metadata; `scripts/v2/verification/p3_bridge_guard.py` must prove the
  live loopback editor process and canonical runtime verification must prove the
  project/session identity. Do not migrate or delete this bridge ahead of those
  dependencies.
- `UnrealMCPBridge` is a legacy project-index/Blueprint graph surface, not a
  general default control path. Its only demonstrated repo consumer outside
  project enablement is the read-only #1621 benchmark; no product/runtime path
  currently uses it. Its unique project-index value is being measured before any
  default-disable decision. Do not route new general editor automation through
  its fixed-port TCP transport.

Tool Search reduces discovery payload, not privilege. Keep native MCP loopback
only and use the current Toolset Registry allow/block settings when narrowing
exposure. A secondary bridge becomes removable only after its unique current
consumer/proof role has migrated and the replacement has fresh acceptance.

## Playable character orientation and animation authority

- Native variant/orientation behavior: `Source/p3/p3Character.cpp` and
  `Source/p3/p3Character.h`.
- Humanoid runtime animation guard: `Source/p3/p3HumanoidRuntimeAnimationGuard.*`.
- Macaw orientation regression guard: `scripts/validate_macaw_orientation.py`.
- Shared playable-orientation guard when present: `scripts/validate_playable_orientation.py`.

Do not copy yaw, scale, animation, or asset-path values out of those owners into
`AGENTS.md`. A task touching them must inspect the current owner and run the
applicable current guard.

## Grapple

- Runtime contract and current defaults: `Source/p3/p3Character.h` and
  `Source/p3/p3Character.cpp`.
- The source owns current hook asset, scale, launch/pull tuning, cable behavior,
  collision sweep, visibility, attachment, and release behavior.

Do not use a number or asset path from an old handoff/AGENTS snapshot. Inspect the
current source and prove the real gameplay path.

## Showroom / automatic asset ring

- Current implementation owner: `Content/Python/init_unreal.py` and the current
  showroom ring module it registers.
- Current accepted count/state is runtime/receipt evidence, not policy prose.

Never copy a current actor/sign count into global agent policy.

## Build / Unreal execution surface

- Canonical execution-surface rules: `organicoverlords/agents` `AGENTS.md`.
- Current build/worker implementation: current `.github/workflows/`, current
  scripts, and the exact target branch/HEAD.
- Canonical delegated-worker and handoff rules: `organicoverlords/agents` `AGENTS.md`.

## V2 / product-foundation work

Use canonical `organicoverlords/agents` `AGENTS.md` for agent rules, then inspect `docs/v2/P3_V2_NORTH_STAR.md`, the current lane registry, execution packet, issue, path ownership, code, and runtime evidence. Those artifacts provide navigation/provenance, not permission. A prerequisite
exists only when current causal code/runtime/safety evidence proves it for the exact
work; never infer readiness from receipts, dependency metadata, or status labels.

## Historical feature documents

Dated feature notes, frozen handoffs, screenshots, and old receipts remain useful
for lineage and regression diagnosis. They are not execution authority unless a
current owner above explicitly points to one for a specific proof requirement.
