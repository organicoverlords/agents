# ChatGPT MCP North Star

Status: **AUTHORITATIVE PRODUCT DIRECTION**
Repository: `organicoverlords/chatgpt-mcp-clean`

## Product identity

MCP is **boring authenticated execution transport** between ChatGPT workers and the Windows machine. It exposes a deliberately small process/tool contract through a stable public endpoint while preserving process continuity, evidence, least privilege and independent recovery.

MCP is not the ownership system, scheduler, worker registry, backlog, product authority or orchestration brain. BusyCoordinator owns exact live mutation collisions; GitHub/issues/repos own work truth; MCP only transports supported capabilities and their evidence.

## Current GPT1 serving contract

This section is the human-facing current topology contract. The machine-readable authority is `C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-current-topology.json`, surfaced directly by Stack Atlas/bootstrap as `mcp_current_topology`. Historical recovery records must not override it.

- **Connector URL:** `https://91-159-12-133.sslip.io/mcp`.
- **Serving path:** GPT1/ChatGPT -> local HTTPS Caddy -> `127.0.0.1:3022`. The pinned runtime is `%LOCALAPPDATA%\ChatGPTMcpV4HomeDirectStable` on `chatgpt/home-direct-stable-runtime`, supervised by `McpV4HomeDirect3022`; local Caddy is supervised by `McpV4HomeDirectCaddy`.
- **OAuth:** discovery and authorization use the same local public origin, with `https://91-159-12-133.sslip.io/authorize` and backend owner-auth mode `local-edge`. Authentication repair must not introduce a second network topology.
- **ChatGPT action surface:** exactly three tools: `start_process`, `read_output`, `kill_process`. No fourth image tool exists on this connector.
- **Image/file delivery:** `CHATGPT_LIBRARY_UPLOAD=<absolute path>` is interpreted from process results and carried through a resource link, `structuredContent`, `_meta.chatgpt_library_upload`, and `ui://process/library-upload-v2.html`. This is output metadata/resource behavior, not an additional action.
- **Excluded from the GPT1 connector:** `view_image`, `busy_*`, `open_visual_proof`, `open_visual_proof_run`, `record_visual_proof_review`, and other full/visual-profile actions. Internal code may retain those capabilities for explicit non-GPT1 testing, but `MCP_TOOL_PROFILE=process` must not advertise them.
- **Not in the GPT1 path:** `5-61-91-127.sslip.io`, VPS Caddy, WireGuard, and Tailscale owner authorization. Those may exist as separate historical/recovery infrastructure, but they are not the current GPT1 serving or auth route.
- **Independent control/recovery:** local `clone-a` on `127.0.0.1:3011` remains an independent control route. `mcp-recovery-state.json` is historical rollback/recovery state only and must never be projected as the current GPT1 topology.

Diagnostic invariant: if ChatGPT discovers anything other than the three process actions, or an authorization browser opens `5-61-91-127.sslip.io`, treat the ChatGPT connector binding/metadata as stale or wrong before changing MCP. Recreate/rebind the connector to the canonical URL; do not repair the obsolete route or widen the server tool surface to accommodate stale client state.

## Reproducible local package contract

The supported external-install target is the same **single-Windows-host home-direct shape**, not a second production architecture. A clean clone can run `install.ps1` to install the complete local stack together:

- loopback MCP backend with `MCP_TOOL_PROFILE=process`;
- local Caddy HTTPS edge, pinned to Caddy 2.11.3 and SHA-256 verified before promotion;
- standalone BusyCoordinator beside MCP, never exposed as an MCP action;
- public shared base-rules checkout;
- the PlanOnly interoperability profile;
- per-user autostart/supervision for MCP, Caddy and rules sync.

The package must preserve the GPT1 action contract exactly: `start_process`, `read_output`, and `kill_process`, with no Busy, image, proof or orchestration action added. `CHATGPT_LIBRARY_UPLOAD` remains metadata/resource-widget delivery attached to process results and therefore does not increase the tool count.

The install is agentless-compatible by default. `-WithAgentEntrypoints` may add supported Codex/OpenCode pointer files, but no private GigStack code or agent implementation is required for the base package. PlanOnly is distributed as an agent-neutral permission/profile contract.

The installer owns only the Windows host. It does not provision a VPS, WireGuard, reverse SSH, Tailscale owner authorization, DNS, or router configuration. For Internet-facing ChatGPT use, the operator's own DNS/router must deliver public HTTPS to the local Caddy listener; that external edge prerequisite must never be disguised as a packaged remote dependency.

Acceptance for this package is install-plan immutability, frozen three-tool contract verification, local-edge OAuth behavior, pinned Caddy integrity/config validation, Busy contract validation, doctor checks, and reversible uninstall.

## Finished-product outcome

A finished MCP service is something workers can normally forget exists:

- the public endpoint remains reachable across ordinary backend replacement, paging pressure, service restart and bounded network-path failure;
- the worker-visible tool schema and semantics stay small, pinned, backwards-compatible where promised and testable independently of the public edge;
- a running process can be started, read and terminated through its owning route without a replacement backend losing or directly killing foreign process state;
- completed output has durable bounded receipts with enough identity, hashes, byte/character counts, request/caller/process linkage and completeness metadata to audit the execution claim without exposing raw output in aggregate views;
- authentication/OAuth/resource metadata and public routing are least-privilege and stable across replacement; transport recovery never silently weakens the security boundary;
- primary and recovery paths have explicit roles. A fallback can restore service without becoming an accidental second production architecture;
- failures are localized and diagnosable: client/edge/backend/process/receipt/ownership failures are not conflated, and an unchanged failed recovery is not retried indefinitely;
- backend generations can be canaried off-path, promoted or rolled back while preserving unique work and without requiring the user to supervise routine recovery;
- long-running real use demonstrates bounded socket/resource growth and stable behavior; "health endpoint is green" alone is not production proof.

The user should not need to know which backend generation, tunnel, port, supervisor or recovery lane served a normal tool call.

## Durable milestones

1. **Serving contract and exact semantics.** Keep the minimal worker contract healthy and regression-tested: process lifecycle, output paging/retention, safety preflight, caller isolation, receipt/control handoff and Busy separation.
2. **Safe replacement and recovery.** Prove candidate generation -> off-path semantic canary -> bounded promotion -> independent rollback while preserving live processes, OAuth identity and receipts. Recovery actions must be executable and scoped below LLM interpretation where invariants are mechanical.
3. **Edge/security stability.** Keep one declared production path plus explicit recovery paths; reduce unexplained security reroutes, preserve exact routing evidence, and never churn backend/OAuth state when evidence shows the failure is upstream of the backend.
4. **Long-run boring operation.** Survive real multi-worker load, idle/reuse cycles, Windows paging/memory pressure, network interruption and repeated backend maintenance without process loss, unbounded resource growth or user-visible intervention.
5. **Finished transport.** Current known failure families have replayable coverage, production status is observable without becoming a second control plane, replacement/recovery is routine, and MCP changes can be made without destabilizing unrelated worker behavior.

## Current priority

Preserve the currently serving contract while closing the remaining evidence gaps around security reroute elimination/reduction, replacement safety and long-run stability. Do not create new transport layers, supervisors or routing schemes unless a reproduced failure cannot be solved through an existing owner.

## Roadmap continuity and issue-wall recovery

Workers own MCP issue continuity. When an active recovery/stability issue is satisfied, stale or exhausted, reconcile the North Star against current source, exact live topology, receipts/telemetry, known-good/recovery contracts and observed failure evidence. Close or supersede obsolete incident paths and create the smallest new issue only for a real uncovered transport/reliability/security acceptance gap. The user is not required to maintain the MCP issue wall.

Do not rewrite the North Star from transient topology state. Current user direction may change product goals; live runtime evidence changes current facts; incidents seed bounded repair work beneath this durable product boundary.
