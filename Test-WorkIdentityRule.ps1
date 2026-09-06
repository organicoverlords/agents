Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$orientation = @($text -split "`r?`n" | Where-Object { $_ -match '^- After the mandatory fresh-chat `bootstrap-glance`' })
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
if ($issueLine.Count -ne 1) { throw "expected exactly one issue work-identity rule; found $($issueLine.Count)" }
foreach ($required in @('not a priority queue or admission gate','parallel contributions are allowed when exact mutation scopes are disjoint')) {
    if (-not $issueLine[0].Contains($required)) { throw "issue identity rule missing invariant: $required" }
}
[ordered]@{
    ok = $true
    bounded_local_work_avoids_issue_ritual = $true
    targeted_issue_identity_when_needed = $true
    disjoint_contributions_remain_parallel = $true
} | ConvertTo-Json -Compress
