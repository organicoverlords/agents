# P3 proof phases and compatible batching

This is the operating contract for reducing repeated builds and renders without weakening visual acceptance. It applies to source changes, Unreal runtime checks, animation proof, and placement proof.

## Phases

| Phase | Work | Reuse boundary | Output |
| --- | --- | --- | --- |
| 0. Triage | Read changed files, manifests, hashes, affected module, claim list, and existing evidence | No build or render | Candidate claim matrix |
| 1. Build cohort | Exact-head contract validation remains per PR; compatible merge-ready C++ heads that passed it share one full Editor integration build | A changed PR head reruns that PR contract gate; a changed cohort membership/tree starts a new shared integration build | Per-head gate receipts plus one cohort build receipt |
| 2. Runtime bundle | Start one worker-owned normal-runtime session for claims sharing map, asset package, runtime mode, camera contract, and compatible setup | Any changed map, package, runtime mode, camera, or setup starts a new session | Ordered frames/clips with scenario IDs |
| 3. Visual review | Open and watch the actual frame sequence or clip; verify the intended pipeline asset, behavior, readability, and defects | A reviewer decision is per claim, even when evidence is shared | `PROVEN`, `NOT_PROVEN`, or `REJECTED` per claim |
| 4. Receipt/publication | Write one hash-bound receipt per claim, pointing to the shared build/runtime artifact and review result | Never copy a result across a changed input | Durable ledger/PR evidence |

GitHub Actions keeps at most one useful integration cohort active. Bursty contract-gate completions are coalesced behind it to the newest pending cohort trigger rather than cancelling a useful active build. Before the cheap planner decides readiness, a workflow-run cohort gets one bounded 30-second coalescing window on `p3-secondary`; the cohort then replans from current `main`, so heads that finish their cheap gates during the burst can share the same build. When a compatible cohort is ready, the planner also advances the canonical machine-pressure recovery state using `P3BuildAdmission.ps1`, `P3BuildProgress.ps1`, and `P3BuildQueueRetry.ps1` from that same selected `main` SHA. For non-editor ambient pressure, recovery reset uses the same bounded two-sample sustained-hard-paging definition as a new pressure refusal, so one noisy combined sample can throttle work but cannot erase an otherwise clean recovery window. Editor-associated combined hard paging remains an immediate first-sample refusal and may reset recovery without waiting for the ambient-pressure confirmation sample. A blocked, newly observed, or still-held pressure state keeps `ready=false` on `p3-secondary`, so `p3-build` is not scheduled merely to rediscover known contention; only canonical `RECOVERY_STABLE` admission may release the scarce job, and the build wrapper independently rechecks pressure before UBT. The cohort revalidates the selected `main` base and every selected PR head immediately before the full build and again before shared acceptance; a moved base, closed/draft PR, or superseded head makes that cohort stale without promoting its result. Build exit `124` remains retryable machine/resource contention: selected heads remain `pending`, not failed, and a later coalesced trigger may try again after machine state changes.

## Handoff stage is the first unmet gate

Do not reduce handoff state to a percentage such as `90%`. The last 10% can contain editor serialization, normal-runtime behavior, visual review, or merge reconciliation, each with different resource and invalidation costs. A worker that stops before landing records the **first unmet gate** in the existing PR body:

```text
P3_HANDOFF_STAGE=AUTHORING
P3_HANDOFF_NEXT=run the exact production-world authoring command and require its save receipt
P3_HANDOFF_BUNDLE=v2-production-world|editor-authoring
P3_HANDOFF_BLOCKER=RESOURCE_CONTENTION:#456
```

Allowed stages, from closest to landing to earliest, are `MERGE`, `VISUAL_REVIEW`, `RUNTIME`, `AUTHORING`, `BUILD`, and `SOURCE`. `P3_HANDOFF_BUNDLE` is a compatibility hint for batching; it is not ownership. `P3_HANDOFF_BLOCKER` names the current concrete route/resource blocker or `NONE`. `P3_HANDOFF_NEXT` must be an executable next action, not "finish proof".

These PR-local markers are handoff evidence only. They do not create a queue, select work, admit lanes, reserve capacity, or make independent workers wait.

For content/world changes, failed or unrun serialization is `AUTHORING`, even when source tests and a full editor build passed. Only after the exact packages are saved and the authoring receipt exists can the handoff advance to `RUNTIME` or `VISUAL_REVIEW`. This prevents a source-complete but unsaved world change from masquerading as "just needs a screenshot."
`Invoke-P3UnattendedEditor.ps1` also preflights the machine-wide Turnkey `Build.bat -Mode=ValidatePlatforms` route. If another validator already occupies it, the launcher exits 124 with `P3_UNATTENDED_ROUTE_BLOCKED phase=turnkey-validateplatforms` before spawning Unreal. That is requeueable resource contention, not a failed authoring/runtime claim.

## When one 2-second clip can cover many checks

Yes, when the checks are simultaneously visible and the clip has a deterministic scenario contract. A useful 2-second bundle can include a baseline, action start, mid-action, and settle frame and may cover, for example, spawn location, possession, animation selection, weapon visibility, and HUD state if all five are visible in the same normal-runtime view.

The receipt must list each claim separately and identify the exact frame/time window that proves it. The worker must watch the clip rather than only verify that a file was emitted. One clip cannot prove hidden state, long-duration behavior, load/streaming completion, replication over time, audio quality, or a result that is outside the camera. Those claims need a longer or separate artifact.

For gameplay VFX, review the actual clip against production VFX fundamentals before accepting presentation quality: the effect must read clearly at gameplay distance; timing must show anticipation/arrival, the primary impact beat, and dissipation/settle; the primary gameplay signal must dominate secondary decoration; the claimed ground/target interaction must actually be visible; and framing must keep the relevant action on screen. A nonblank frame, glow, color change, or unrelated animation is not a substitute for these beats.

## Rebuild and rerender rules

- Do not rebuild when only the claim list or receipt text changes and the exact build artifact remains valid.
- Do not rerender when the exact runtime session and inputs are unchanged; reuse the reviewed artifact by hash.
- Rebuild when source/head, engine/toolchain, target, configuration, or build inputs change.
- Rerun runtime when map/package, runtime mode, camera contract, asset, behavior, or setup changes.
- If a reviewer rejects the clip for wrong asset, bad framing, ambiguity, or visible defects, keep the artifact for diagnosis but do not relabel it; rerender only the affected bundle after fixing the cause.
- Never use batching to hide a failed claim. A shared artifact may reduce work, but it does not turn an unclear claim into `PROVEN`.

Shared C++ integration cohorts stop at compile, focused automation, and shared runtime acceptance. They do not auto-promote visual claims or synthesize screenshots/video. A PR whose lifecycle requires visual proof remains blocked until a worker-owned offscreen runtime is captured through `scripts/Invoke-P3VisualProofCapture.ps1` and the actual artifact is reviewed; motion claims require a playable MP4/clip rather than still-only evidence. This keeps build/runtime batching cheap without weakening player-visible acceptance.
## Minimal claim matrix

```text
bundle_id: android-placement-v2-<exact-head>
build: <build-receipt-hash>
runtime: <map>|<mode>|<camera-contract>|<asset-package>
artifact: <clip-or-frame-hash>
claims:
  - id: spawn_location
    window: 0.00-0.70s
    visible: true
  - id: animation_selection
    window: 0.35-1.60s
    visible: true
  - id: deformation_quality
    window: 0.35-1.60s
    visible: true
review: watched_by_worker=<actor>; result=<PROVEN|NOT_PROVEN|REJECTED>
```

The matrix is a planning and receipt contract, not proof by itself. The artifact must exist, be opened, and be inspected before any claim is promoted.

## Current incident application

The Android pipeline capture from this incident is a good example of why the phases matter: the correct asset was found and motion was visible, but deformation/integration quality was not cleanly proven. Reusing that capture for every visual claim would be invalid. PR #565 therefore remains `NOT_PROVEN` until an exact normal-runtime proof is reviewed.
