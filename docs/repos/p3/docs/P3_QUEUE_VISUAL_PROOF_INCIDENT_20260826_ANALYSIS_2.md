# Incident analysis 2 (independent): enforce convergence and reuse valid proof

- Incident key: `p3-queue-visual-proof-2026-08-26`
- Analysis: 2 of 2; independent second-pass record
- Source traversed: the complete available raw session snapshot at `C:\Users\Lauri\Documents\Codex\2026-08-26\p3-incident-raw-20260826-033241.jsonl`
- Snapshot SHA-256: `A9AC58528240501CE47C6E730A25B5FAD35709CB5AAE56CA47ABA69CB49AB462`
- Related implementation: PR #566, branch `chatgpt/issue533-queue-admission-20260826`

This analysis was written independently after raw-source acquisition and traversal. It is not an edit or correction of Analysis 1.

## Reconstructed sequence

The incident had two coupled tracks:

1. A generic-looking capture was treated as if it answered a request for the actual Android pipeline asset. After correction, the real `angular_android_blade_herald` asset was found and inspected, but its visual/runtime result still failed the acceptance bar.
2. The repository had a large open-PR queue. Existing classification and sweep code could describe duplicate/superseded work, but it did not hard-stop new non-emergency work at the observed budget or make runtime/visual `NOT_PROVEN` a universal merge blocker.

The direct evidence is consistent with a control-plane gap, not a mysterious runner stall: the queue was flooded, the relevant placement stream remained unproven, and PR #554 was merged despite its explicit unproven statement. PR #565 was then opened as another placement continuation.

## Root causes and contributing defects

### Root cause A: proof was not claim-bound

The proof path did not require a mapping from claim to the exact asset, runtime path, frame/clip, and reviewer decision. A capture could therefore exist without proving the requested asset or quality. The new policy closes the human-review gap, but the receipt and gate must also carry the claim mapping.

### Root cause B: queue signals were advisory

The lifecycle code could return a backpressure signal, but the normal admission path did not enforce it before a new lane was created. The merge path also lacked a universal queue check and did not independently reject explicit `NOT_PROVEN`/`REJECTED` runtime or visual statements.

### Contributing defect C: Windows encoding assumptions

The new queue check initially failed on a trusted-main bootstrap mismatch (`github-admit` was not yet on `main`), then on a UTF-8 BOM in the GitHub event file, and then on a BOM written by Windows PowerShell into the temporary snapshot. These were observed CI failures, not queue-state conclusions. PR #566 now uses the trusted `admit` command, reads the event with `utf-8-sig`, and writes the snapshot with explicit UTF-8 without BOM.

## Corrective design

PR #566 adds live read-only admission against the current open-PR list, excludes the current PR from its own workstream collision test, requires a queue check in lifecycle classification/merge evaluation, and rejects explicit unproven or rejected visual/runtime claims. A direct live admission check for PR #565 returned `BACKPRESSURE_CONVERGE` at the observed queue size versus budget 8. That result means converge/retire existing work; it is not permission to discard unique changes.

The companion contract, [P3_PROOF_PHASES_AND_BATCHING.md](P3_PROOF_PHASES_AND_BATCHING.md), makes evidence reuse explicit:

- static/source checks first;
- one exact-head build for a compatible cohort;
- one worker-owned runtime session for a compatible claim bundle;
- one short clip may cover several simultaneously visible claims only when the claim matrix says so and a reviewer watches the actual clip;
- one hash-bound receipt can reference that clip for each proven claim;
- changed head, asset, map, engine/config, camera, or behavior invalidates reuse.

## Decision table

| Claim or action | Result from this incident | Required treatment |
| --- | --- | --- |
| Generic/dummy image proves the Android pipeline asset | `REJECTED` | Find and inspect the actual pipeline asset |
| File/capture exists | Supporting evidence only | Never promote to visual `PROVEN` alone |
| Actual asset frames show motion but deformation/integration is unclear | `NOT_PROVEN` | Capture normal-runtime proof and review it |
| Open-PR count exceeds budget | `BACKPRESSURE_CONVERGE` | Stop new non-emergency lanes and converge existing work |
| Unique PR is merely old, dirty, or blocked | Not a retirement reason | Preserve/reconcile; no blind closure |
| Same exact runtime/head/map/asset/camera, several visible claims in one 2-second clip | Potentially `PROVEN` per claim | Reviewer must watch and mark each claim separately |

## Remaining acceptance gap

No current document changes the visual status of PR #565. Until a canonical normal-runtime frame or clip of the actual placement/asset is reviewed, that player-visible claim remains `NOT_PROVEN`.
