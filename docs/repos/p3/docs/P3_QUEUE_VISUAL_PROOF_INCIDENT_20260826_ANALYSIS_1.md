# Incident analysis 1 (immutable): P3 queue and visual-proof divergence

- Incident key: `p3-queue-visual-proof-2026-08-26`
- Analysis: 1 of 2; immutable first-pass record
- Scope: the stalled GitHub Actions lane, the rejected visual captures, and the open-PR flood
- First-pass time: 2026-08-26
- Raw source snapshot: `C:\Users\Lauri\Documents\Codex\2026-08-26\p3-incident-raw-20260826-033241.jsonl`
- Snapshot SHA-256: `A9AC58528240501CE47C6E730A25B5FAD35709CB5AAE56CA47ABA69CB49AB462`
- Provenance note: the source session was still live when copied. The hash covers the captured snapshot, not later session growth.

This document is append-only. It records the first analysis from the available incident evidence; the independent second analysis is in the companion file with the same incident key.

## Trigger and impact

The user-visible failure was not simply a slow build. Work stopped advancing while pull requests accumulated, and visual acceptance was being represented by captures that did not show the requested Android asset from the pipeline. The user repeatedly rejected generic or dummy-looking proof and asked for the actual latest animated asset to be found and inspected.

Impact:

- queue throughput degraded as many open PRs remained active, draft, dirty, or blocked;
- a player-visible meadow-placement change was carried forward without rendered runtime proof;
- reviewer time was spent recapturing and rechecking invalid evidence instead of reusing a governed artifact;
- a merge path could accept a PR whose own body explicitly said runtime/visual acceptance was `NOT_PROVEN`.

## Evidence observed

1. The requested asset was eventually located at `C:\Users\Lauri\Desktop\lowvram3d-repo\out\character_angular_android_blade_herald_20260824\humanoid_rig_v2`, with clips including `idle`, `walk_loop`, `breathe`, `sit`, and `dance_loop`.
2. The inspected animation frames showed the intended Android pipeline asset and visible dance motion, but also lower-body overlap/deformation concerns. The runtime integration and clean visual acceptance remained `NOT_PROVEN`.
3. The shared policy was amended so a worker must inspect/watch the actual rendered proof and verify the intended asset and behavior before calling it acceptable.
4. The queue was observed at roughly 41 open PRs, mostly drafts or blocked, while the existing lifecycle machinery produced no merge/retirement decision for this situation.
5. PR #554 was merged even though its body explicitly retained `NOT_PROVEN` for player-visible placement/render acceptance. PR #565 then continued the placement stream with the same missing visual proof.

## First causal assessment

The initial failure was an evidence-type mismatch: file existence, capture existence, metadata, and focused tests were allowed to stand in for normal-runtime visual proof. The queue failure was a control-plane mismatch: lifecycle classification emitted useful signals, but admission and merge enforcement did not make those signals a hard, current gate.

The two failures reinforced each other. Because invalid proof was not rejected early, more PRs and more repeated captures accumulated. Because the queue was not applying backpressure, additional work increased the number of artifacts that needed review.

## Containment recorded

- Do not accept generic mannequin/dummy imagery as proof of the Android pipeline asset.
- Keep player-visible acceptance `NOT_PROVEN` until a normal-runtime frame or clip is found, opened, and reviewed.
- Preserve unique PR commits; do not close or delete lanes merely to reduce the count.
- Add a queue-admission gate and fail-closed merge checks in PR #566.
- Separate cheap source/build checks from runtime rendering and visual review so a valid artifact can be reused.

## Unresolved at this first pass

The exact canonical runtime proof for PR #565 was still missing. The queue-fix PR was open and its new workflow was still being corrected on Windows; no claim is made here that the protection was already deployed to `main`. The connected Library/vault route was unavailable in this environment, so this repo mirror and the local memory note are the durable records.
