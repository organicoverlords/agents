Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

foreach ($required in @(
    'workers can enter without user dispatch',
    'No issue, PR, branch, worktree, or objective is a worker-owned lane or assignment',
    'select the next highest-value ready canonical contribution from the owning repo''s open issues / North Star',
    'A worker has no issue lane to defend',
    'move to a different ready issue/North-Star contribution',
    'repair the blocking owner when that is the best safe supported contribution',
    'select another ready canonical contribution from open issues / North Star, even when it belongs to a different issue',
    'Query the blocked state again only when its answer can change the next action',
    'Historical/WIP evidence narrows duplication, not solution search',
    'bounded external research on public documentation/web sources',
    'run isolated experiments/prototypes',
    'do not treat existing WIP, a prior lesson, or a currently passing path as proof that the design is optimal',
    'expected information/value toward the user objective',
    'churn metrics, repeated builds/tests, PR/commit count, worker activity, and report volume are not progress',
    'converge it through the existing owner and acceptance path'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing non-idle swarm invariant: $required" }
}

foreach ($required in @(
    'existing implementation/PRs/checkpoints',
    'multiple real non-overlapping contribution boundaries',
    'existing implementation/PRs/checkpoints',
    'At a meaningful checkpoint/handoff, record branch plus immutable commit when available',
    'branch plus immutable commit when available',
    'validation already performed',
    'next integration action',
    'Do not sit on CI, review, a Busy claim, a build slot, or another worker',
    'return to the in-flight result only when it can change the next action'
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing swarm checkpoint/handoff invariant: $required" }
}

foreach ($forbidden in @(
    'inside the same established issue/objective',
    'another required same-objective contribution',
    'another already-required non-overlapping contribution',
    'otherwise yield at a decision-ready blocker',
    'or yield at a decision-ready blocker'
)) {
    if ($rules.Contains($forbidden)) { throw "issue-lane/blocking-idle wording remains in RULES: $forbidden" }
}

[ordered]@{
    ok = $true
    no_issue_lane_ownership = $true
    cross_issue_north_star_fallback = $true
    blocker_repair_or_switch = $true
    no_idle_on_local_contention = $true
    immutable_git_checkpoints = $true
    explicit_handoff_contract = $true
    ci_polling_not_work = $true
    exploration_not_suppressed = $true
    churn_not_progress = $true
} | ConvertTo-Json -Compress
