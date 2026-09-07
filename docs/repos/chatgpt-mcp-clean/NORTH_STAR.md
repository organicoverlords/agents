# ChatGPT MCP North Star

Status: **AUTHORITATIVE PRODUCT DIRECTION**
Repository: `organicoverlords/chatgpt-mcp-clean`

## Product identity

MCP is **boring authenticated execution transport** between ChatGPT workers and the Windows machine. It exposes a deliberately small process/tool contract through a stable public endpoint while preserving process continuity, evidence, least privilege and independent recovery.

MCP is not the ownership system, scheduler, worker registry, backlog, product authority or orchestration brain. BusyCoordinator owns exact live mutation collisions; GitHub/issues/repos own work truth; MCP only transports supported capabilities and their evidence.

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
