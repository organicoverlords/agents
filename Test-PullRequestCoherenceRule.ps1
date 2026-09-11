Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- A pull request is a coherent merge/review boundary' })
if ($line.Count -ne 1) { throw "expected exactly one PR-coherence rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'not a progress checkpoint',
    "one actor's contiguous work stream on the same owner/acceptance scenario",
    'compose adjacent changes that are safe and reviewable together before opening or merging a PR',
    'does not require one PR per issue',
    'serialize different agents',
    'delay unrelated ready work merely to pad a PR',
    'real independent boundary'
)) {
    if (-not $rule.Contains($required)) { throw "PR coherence rule missing invariant: $required" }
}

$agentsText = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$queueRules = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*No passive integration queue\.\*\*' })
$queueAgents = @($agentsText -split "`r?`n" | Where-Object { $_ -match '^- \*\*No passive integration queue\.\*\*' })
if ($queueRules.Count -ne 1) { throw "expected exactly one no-passive-integration-queue rule in RULES.md; found $($queueRules.Count)" }
if ($queueAgents.Count -ne 1) { throw "expected exactly one no-passive-integration-queue rule in AGENTS.md; found $($queueAgents.Count)" }
foreach ($required in @(
    'immediate integration action',
    'Optional or queued CI',
    'no batching window or review holding period',
    'next entrant touching the same owner/objective must reconcile that PR',
    'stale or conflicting',
    'important or high-impact regression fixes remain load-bearing',
    'open PR alone is never completion or a passive handoff',
    'Set-PullRequestConvergenceReady.ps1',
    'agent/convergence-ready',
    'ReadyPullRequestConvergence'
)) {
    if (-not $queueRules[0].Contains($required)) { throw "RULES no-passive-integration-queue rule missing invariant: $required" }
}
foreach ($required in @(
    'Merge immediately through the repo''s supported path',
    'repair/rebase that still-valid PR before creating overlapping follow-on changes',
    'important or high-impact regression remains load-bearing',
    'open PR alone is not a handoff, completion state, or reason to start a parallel replacement',
    'Set-PullRequestConvergenceReady.ps1',
    'ReadyPullRequestConvergence',
    'Do not publish readiness before the required proof is actually satisfied'
)) {
    if (-not $queueAgents[0].Contains($required)) { throw "AGENTS no-passive-integration-queue rule missing invariant: $required" }
}
$no_passive_integration_queue = $true
[ordered]@{
    ok = $true
    rule_count = 1
    coherent_pr_boundary = $true
    parallel_agents_preserved = $true
    independent_boundaries_preserved = $true
    no_passive_integration_queue = $no_passive_integration_queue
} | ConvertTo-Json -Compress
