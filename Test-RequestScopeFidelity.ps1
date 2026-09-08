$ErrorActionPreference = 'Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
foreach ($required in @(
    'Scope fidelity is a hard completion rule',
    "The user's current explicit request defines the operation and its completion boundary",
    'Availability of another supported tool call is never by itself a reason to continue',
    'For an ongoing manual/on-demand swarm `go`/`continue`',
    "the inherited scope is the user's established project/product engineering goal",
    'not the currently open issue/PR/branch/worktree',
    'the next highest-value safe supported contribution from canonical open issues or the repo North Star',
    'Fix the blocker itself when that is the highest-value safe action; otherwise switch work rather than wait',
    'No issue, PR, branch, worktree, or objective is a worker-owned lane or assignment',
    'Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive or progress-polling surface',
    'A worker has no issue lane to defend',
    'Manual `go` does not imply timed-fleet supervision or scheduler work',
    'remote publication must be separately explicit'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing request-scope invariant: $required" }
}
foreach ($forbidden in @(
    'If another supported tool call can still be issued',
    'actionable work must continue',
    'continue across sequential safe useful actions until the task-level objective is complete',
    'yield after that operation plus necessary validation or at a decision-ready checkpoint',
    'inside the same established issue/objective',
    'another required same-objective contribution',
    'continue the established issue/objective'
)) {
    if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "shared policy retains stale/churn/issue-lane behavior: $forbidden" }
}
foreach ($required in @(
    'Follow the prompt-local scope-fidelity rule in `RULES.md`',
    'Do not poll unchanged state',
    'follow the `go`/`continue` completion and yield semantics in `RULES.md`'
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing request-scope invariant: $required" }
}
[ordered]@{
    ok = $true
    narrow_explicit_scope_preserved = $true
    manual_swarm_scope_is_project_product_not_issue = $true
    issue_lane_ownership_forbidden = $true
    cross_issue_north_star_continuation = $true
    random_tool_churn_forbidden = $true
    unchanged_polling_forbidden = $true
    remote_memory_publication_explicit = $true
} | ConvertTo-Json -Compress
