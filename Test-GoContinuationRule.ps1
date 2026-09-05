Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- On a `go` turn,' })
if ($line.Count -ne 1) { throw "expected exactly one go continuation rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'temporary or recoverable capacity state',
    'never a task-level blocker or hard boundary',
    'finite canonical retry-after',
    'same `go` turn',
    'rather than final-answering solely because of the contention',
    'actual platform/tool/safety limit or an unrecoverable dependency'
)) {
    if (-not $rule.Contains($required)) { throw "go continuation rule missing invariant: $required" }
}
$obsolete = 'Report a task-level blocker only after disjoint useful work and required bounded waiting/rechecks are exhausted'
if ($rule.Contains($obsolete)) { throw 'go continuation rule still permits recoverable contention to become a blocker after useful work is exhausted' }
[ordered]@{
    ok = $true
    rule_count = 1
    recoverable_capacity_is_not_hard_boundary = $true
    same_turn_bounded_recheck = $true
} | ConvertTo-Json -Compress
