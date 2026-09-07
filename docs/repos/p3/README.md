# p3

## Project timeline

Canonical history: [CHANGELOG.md](CHANGELOG.md)

Unreal Engine 5.8 project containing the playable Seal, Panda, Titan Robot,
showroom, mounts, and agent-driven editor tooling.
## Setup

1. Install Unreal Engine 5.8 and Git LFS.
2. Clone with LFS smudge disabled; hydrate only required assets through scripts/ci/control/Invoke-P3NarrowLfsHydration.ps1 (local cache first).
3. Generate project files from `p3.uproject` if needed.
4. Build the `p3Editor` target, then open `p3.uproject`.

Durable final LFS publication is explicit: `scripts/ci/control/Invoke-P3FinalLfsPublish.ps1 -Path Content/...` plans and writes a receipt by default; add `-Execute` only for reviewed final assets. It validates exact local object hashes/sizes and uploads only those object IDs while leaving persistent LFS guards unchanged. Generated proof/media is rejected. When the reviewed branch itself must be published while the emergency LFS push guard remains active, add `-PushBranch <current-branch> -CompareRef origin/main`; the publisher first proves that the branch LFS delta exactly matches the approved object set, then skips only the Git LFS pre-push action for that one ref update.

## Agent authority

Canonical shared agent rules live only in `organicoverlords/agents` (`RULES.md` plus `AGENTS.md`). Local `AGENTS.md` and the agent pointer files contain no copied shared policy. P3-specific product direction and operating routes remain repo-owned: `docs/v2/P3_V2_NORTH_STAR.md`, `docs/SINGLE_MACHINE_SWARM.md`, `docs/P3_PROOF_PHASES_AND_BATCHING.md`, current scripts/help/tests, and current runtime evidence.

## CI workflow contract

Pull-request work is admitted by the current workflows that actually exist on
`main`. The integration cohort in
`.github/workflows/p3-cpp-integration-cohort.yml` listens for the completed
`p3 PR contract gate` workflow.
Do not add a `workflow_run` dependency on a deleted or renamed workflow: GitHub
rejects that configuration at startup and surfaces it as an `(Unknown event)` /
`startup_failure` run rather than executing jobs. When a workflow is renamed or
removed, update every `workflow_run.workflows` consumer in the same change and
verify the referenced workflow names against current `main`.

This private repository currently has no GitHub branch-protection/ruleset enforcement, so `gh pr merge --auto` is not a CI gate and may merge immediately. Use `scripts/ci/control/Invoke-P3PrMergeGuard.ps1 -PullRequest <number>` as the repo-owned merge boundary: it is plan-only by default and verifies the exact current PR head and current `main`; every P3 gate emitted for that head must be terminal `SUCCESS`, and a C++ PR also needs the current `p3 integration-cohort/<main-sha>` status to be `SUCCESS`. Add `-Execute` only to perform the already-ready merge; the guard rechecks live evidence, uses GitHub head-SHA matching, and verifies the merge parent afterward. Pending, missing expected, failed, or stale-base evidence blocks only that merge decision; it does not block unrelated useful work.

Shared execution/coordination invariants come from `organicoverlords/agents`; P3-specific build, editor, runtime, handoff, and proof semantics come from the current repo-owned documents, scripts, help, and tests named above.

The main showroom map is `/Game/Showroom/Maps/ALL_ASSETS_Lineup`.

For P3 Unreal/process/proof work, use the current repo-owned launch/capture scripts and proof contract; shared `AGENTS.md` supplies cross-repo behavior, not P3 command semantics.

## Friend Lane War playtest

On each Windows PC, from the repo root run:

```powershell
.\scripts\launch_lane_war_human_1v1.ps1
```

Before connecting, confirm both launchers print the same `P3_V2_PLAYTEST_BUILD_ID`. On the host choose **HOST LAN MATCH** and wait for **HOST READY** in the Lane War HUD; on the second PC choose **JOIN LAN MATCH** while both PCs are on the same local network. If the match does not appear, allow Unreal Editor through Windows Firewall on **Private networks**, confirm both PCs use a **Private** network profile, and retry **JOIN LAN MATCH**. The launcher prints the current in-match acceptance checklist for combat, economy, terrain, construction, movement, characters, and match resolution.
