Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$lines = $text -split "`r?`n"
$scopeLine = @($lines | Where-Object { $_ -match '^- Scope fidelity is a hard completion rule\.' })
$pollLine = @($lines | Where-Object { $_ -match '^- Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive' })
$identityLine = @($lines | Where-Object { $_ -match '^- The issue/task is a \*\*shared convergence identity\*\*' })
$wipLine = @($lines | Where-Object { $_ -match '^- Existing coherent WIP wins by default' })
$blockerLine = @($lines | Where-Object { $_ -match '^- A constrained tool, build, CI job, lane, checkout, worktree, or exact Busy scope blocks only that exact action;' })
$manualLine = @($lines | Where-Object { $_ -match '^- For manual/on-demand chats, especially `go`/`continue`,' })
$shortIntentLine = @($lines | Where-Object { $_ -match '^- In an already-established manual/on-demand execution scope, treat a very short ambiguous follow-up' })
foreach ($pair in @(@('scope',$scopeLine),@('poll',$pollLine),@('identity',$identityLine),@('wip',$wipLine),@('blocker',$blockerLine),@('manual',$manualLine),@('shortIntent',$shortIntentLine))) {
    if ($pair[1].Count -ne 1) { throw "expected exactly one $($pair[0]) rule; found $($pair[1].Count)" }
}
foreach ($required in @(
    'the inherited scope is the user''s established project/product engineering goal',
    'not the currently open issue/PR/branch/worktree',
    'the next highest-value safe supported contribution from canonical open issues or the repo North Star',
    'Fix the blocker itself when that is the highest-value safe action; otherwise switch work rather than wait',
    'no ready canonical issue/North-Star contribution and no safe supported blocker repair/preparation remains'
)) { if (-not $scopeLine[0].Contains($required)) { throw "scope rule missing invariant: $required" } }
foreach ($required in @(
    'shared convergence identity',
    'not a worker assignment, lane, reservation, or ownership boundary',
    'Workers may enter, leave, review, integrate, or return to an issue as value and exact-collision safety dictate',
    'select the highest-value ready canonical contribution from the relevant repo issues / North Star',
    'do not bind worker identity or continuation to one issue or execution surface'
)) { if (-not $identityLine[0].Contains($required)) { throw "identity rule missing invariant: $required" } }

foreach ($required in @(
    'No issue, PR, branch, worktree, or objective is a worker-owned lane or assignment',
    'Busy owns only exact mutation collision',
    'select the next highest-value ready canonical contribution from the owning repo''s open issues / North Star',
    'do not idle or yield merely to stay attached to one issue'
)) { if (-not $wipLine[0].Contains($required)) { throw "WIP rule missing invariant: $required" } }
foreach ($required in @(
    'must not monopolize the turn',
    'another ready canonical issue/North-Star contribution',
    'do not babysit an owned or foreign watcher'
)) { if (-not $pollLine[0].Contains($required)) { throw "anti-poll rule missing invariant: $required" } }
foreach ($required in @(
    'it never reserves the surrounding issue/objective for the claimant',
    'select another ready canonical contribution from open issues / North Star, even when it belongs to a different issue',
    'A short remaining Busy lease, retry-after, CI wait, or build slot is not a reason to skip available useful work',
    'Do not create duplicate mutations or unrelated activity merely to stay busy'
)) { if (-not $blockerLine[0].Contains($required)) { throw "blocker rule missing invariant: $required" } }
foreach ($required in @(
    'A worker has no issue lane to defend',
    'move to a different ready issue/North-Star contribution',
    'do not wait on that contribution merely to preserve narrative continuity'
)) { if (-not $manualLine[0].Contains($required)) { throw "manual rule missing invariant: $required" } }
foreach ($required in @(
    'very short ambiguous follow-up or obvious one/few-key typo as continuation intent by default',
    'Bias terse inputs such as `o` toward `go`/`continue`',
    '`no`, `n`, and likely adjacent-key `no` typos such as `np` or `ni` mean no/stop/not-go in context',
    'Content-bearing short messages keep their ordinary meaning'
)) { if (-not $shortIntentLine[0].Contains($required)) { throw "short-intent rule missing invariant: $required" } }
foreach ($forbidden in @(
    'inside the same established issue/objective',
    'another required same-objective contribution',
    'another ready non-conflicting contribution already required by the established issue/objective',
    'continue the established issue/objective'
)) { if ($text.Contains($forbidden)) { throw "shared rules still encode issue-lane ownership: $forbidden" } }
[ordered]@{
    ok = $true
    issue_is_shared_convergence_not_assignment = $true
    issue_lane_ownership_forbidden = $true
    busy_is_exact_mutation_only = $true
    cross_issue_north_star_fallback_required = $true
    blocker_repair_or_switch_required = $true
    polling_yield_forbidden = $true
    unrelated_busywork_forbidden = $true
    terse_typo_continuation_bias_required = $true
    no_typo_exception_required = $true
} | ConvertTo-Json -Compress
