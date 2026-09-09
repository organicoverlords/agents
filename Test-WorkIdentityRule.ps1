Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$bootstrap = @($text -split "`r?`n" | Where-Object { $_ -match '^- On every fresh chat, the first machine action is' })
if ($bootstrap.Count -ne 1) { throw "expected exactly one fresh-chat bootstrap rule; found $($bootstrap.Count)" }
foreach ($required in @(
    'MCPv4 `read_output`',
    '231b7e74-4cc8-43d0-9702-fd6dfa2215b3',
    'max_chars=32000',
    'wait_ms=0',
    'fall back once',
    'stack_atlas.py bootstrap-glance'
)) {
    if (-not $bootstrap[0].Contains($required)) { throw "fresh-chat bootstrap rule missing invariant: $required" }
}
$orientation = @($text -split "`r?`n" | Where-Object { $_ -match '^- After the mandatory fresh-chat bootstrap' })
if ($orientation.Count -ne 1) { throw "expected exactly one follow-up orientation rule; found $($orientation.Count)" }
foreach ($required in @(
    'do not automatically rerun bootstrap for every follow-up or subtask',
    'A bounded local request such as reading, writing, or updating a specific Vault artifact does not by itself authorize or require GitHub',
    'one known/targeted issue/PR identity when needed',
    'Never turn task orientation into broad fanout or recurring refresh ceremony'
)) {
    if (-not $orientation[0].Contains($required)) { throw "work identity/orientation rule missing invariant: $required" }
}
$issueLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- The GitHub issue is the shared work/convergence record' })
if ($issueLine.Count -ne 1) { throw "expected exactly one issue convergence rule; found $($issueLine.Count)" }
foreach ($required in @('not a priority queue or admission gate','parallel contributions are allowed when exact mutation scopes are disjoint')) {
    if (-not $issueLine[0].Contains($required)) { throw "issue convergence rule missing invariant: $required" }
}
$identityLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- The issue/task is a \*\*shared convergence identity\*\*' })
if ($identityLine.Count -ne 1) { throw "expected exactly one shared work identity rule; found $($identityLine.Count)" }
foreach ($required in @(
    'not a worker assignment, lane, reservation, or ownership boundary',
    'Workers may enter, leave, review, integrate, or return to an issue as value and exact-collision safety dictate',
    'select the highest-value ready canonical contribution from the relevant repo issues / North Star',
    'do not bind worker identity or continuation to one issue or execution surface'
)) {
    if (-not $identityLine[0].Contains($required)) { throw "shared work identity rule missing invariant: $required" }
}
if ($bootstrap[0].Contains('process_id="bootstrap"') -or $bootstrap[0].Contains('Never hard-code or persist a runtime process UUID for bootstrap')) { throw 'fresh-chat bootstrap rule reverted to obsolete alias semantics' }
if ($text.Contains('The issue/task is the work identity.')) { throw 'legacy issue-as-worker-lane identity remains' }
[ordered]@{
    ok = $true
    bounded_local_work_avoids_issue_ritual = $true
    issue_is_shared_convergence_not_assignment = $true
    targeted_issue_identity_when_needed = $true
    cross_issue_north_star_selection = $true
    disjoint_contributions_remain_parallel = $true
    bootstrap_uses_persistent_process_id = $true
} | ConvertTo-Json -Compress
