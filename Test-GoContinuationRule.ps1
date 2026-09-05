Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- On a `go` turn,' })
if ($line.Count -ne 1) { throw "expected exactly one go continuation rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'not permission to block the turn inside a long read',
    'nonblocking or short bounded status reads',
    'Never choose a multi-minute tool wait/read',
    'smallest supported bounded recheck',
    'finite canonical retry-after',
    'use one bounded recheck rather than a watcher',
    'temporary or recoverable capacity state',
    'never a task-level blocker or hard boundary',
    'actual platform/tool/safety limit or an unrecoverable dependency'
)) {
    if (-not $rule.Contains($required)) { throw "go continuation rule missing invariant: $required" }
}
foreach ($obsolete in @(
    'keep observing it with that bounded mechanism until it completes',
    'consume one bounded wait/recheck in the same `go` turn'
)) {
    if ($rule.Contains($obsolete)) { throw "go continuation rule still permits idle blocking wait semantics: $obsolete" }
}
[ordered]@{
    ok = $true
    rule_count = 1
    recoverable_capacity_is_not_hard_boundary = $true
    idle_long_waits_forbidden = $true
} | ConvertTo-Json -Compress
