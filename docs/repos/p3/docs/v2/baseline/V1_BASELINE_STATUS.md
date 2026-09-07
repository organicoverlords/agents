# V2-00C — V1 Baseline Status

Issue: #18  
PR: #39  
Purpose: evidence only; no V1 repair authority.

## Current target

- Repository: `organicoverlords/p3`
- Source ref: `main`
- Exact current-main target at this refresh: `bdc133936e7dd65f795fc153be1e7baa434f7539`
- Evidence branch: `evidence/v2-00c-v1-baseline-20260818`

Current truth must be re-resolved again immediately before any actual build/gate/PIE capture. Historical SHAs are provenance only and are never relabeled as execution on a newer head.

## Scope / reconciliation proof

PR #39 remains an evidence-only two-file lane:

- `docs/v2/baseline/V1_BASELINE_STATUS.md`
- `evidence/v2/v1-baseline/index.json`

At this GPT-5 refresh, current `main` advanced from the prior recorded target `ccc17c9daef7ce600c519cd3460e49cbb65ab7b8` to `bdc133936e7dd65f795fc153be1e7baa434f7539`. GitHub compare reports five newer main commits. Those commits belong to the separate bounded-agent/real-canary control effort; #51 is actively BUSY and is not touched by this lane. No build, gate, or PIE receipt for `bdc1339...` is inferred from those commits.

This refresh does not claim the evidence branch itself has been forward-integrated to `bdc1339...`; it records the exact source target that the next real baseline capture must use. The branch remains a compact evidence carrier only.

## V2-00B / #43 upstream evidence

Canonical PR #43 remains the sole owner of the `l3/user-path` verifier. Its current head observed during this pass is `ed90ee6b03f8481461e614b9d6770a04cd414369`. Accepted owned-PIE runtime evidence remains from source head `0b10d8835ad9e71287002241c16a77001a9d446f`:

- `RUNTIME_ACCEPTANCE=PASS`
- normal MCP `W` movement: `929.527 cm`
- temporal capture: `PASS`
- receipt validation: `PASS`
- PIE cleanup: `PASS`
- final PIE state: `isPlaying=false`
- local verification tests: `41/41 PASS`

That accepted #43 evidence is upstream evidence only. It is not relabeled as an exact-current-main V2-00C run, and #18 does not duplicate the verifier.

## Current #18 evidence state

- UE5.8 editor build on exact current main: `PENDING=NO_EXACT_CURRENT_MAIN_BUILD_RECEIPT`
- `scripts/ci/control/Test-MainIntegrationGate.ps1` on exact current main: `PENDING=NO_EXACT_CURRENT_MAIN_GATE_EXECUTION_RECEIPT`
- owned PIE baseline capture on exact current main: `PENDING=NO_EXACT_CURRENT_MAIN_OWNED_PIE_RECEIPT`
- upstream canonical #43 owned-PIE evidence: `PASS` at `0b10d883...`, preserved as upstream evidence only
- baseline acceptance: `PENDING`

No GitHub-only source/ancestry result is promoted to build or runtime acceptance.

## Historical coordination note

This file is an evidence snapshot from V2-00C. Its old branch-protection, receipt,
acceptance, and sequencing state has no authority to gate current implementation or
merging. Current work uses current `main`, current code/runtime evidence, and current
mutation/safety constraints.

## Exact next action

On the exact then-current `main`, using only a currently authorized unattended route and never user-owned PIE:

1. run the normal UE5.8 `p3Editor` build;
2. run `scripts/ci/control/Test-MainIntegrationGate.ps1`;
3. perform one minimal owned-PIE `forward/W` baseline check through the canonical #43 verifier path;
4. record actual map/world, possessed Pawn, before/after state, temporal capture, cleanup/release, and exact receipts;
5. update only these evidence files and record the result truthfully.

A failed V1 behavior is valid baseline evidence when recorded honestly. #18 has no authority to repair it.

## Safety

This lane owns only `docs/v2/baseline/**` and `evidence/v2/v1-baseline/**`. No V1 source/config/production-content, verifier, workflow, routing, policy, #51 control surface, or user-owned Unreal/PIE state is changed here.

`DISPOSITION=ACTIVE`  
`ACCEPTANCE=PENDING`  
`PROVENANCE=GPT-5`
