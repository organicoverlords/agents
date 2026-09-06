Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$goLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- `go` means continue' })
if ($goLines.Count -ne 1) { throw "expected exactly one go objective-continuation rule; found $($goLines.Count)" }
$goRule = $goLines[0]
foreach ($required in @(
    'a useful but small local result is not a yield boundary',
    'If the current avenue produces no user-meaningful progress, pivot to another safe supported action instead of final-answering',
    'Orientation, status inspection, bookkeeping, evidence preservation, a report/commit/PR, or an incidental tiny correction do not count as task-level completion',
    'Elapsed time, tool-call count, artifact count, and local subtask completion are never standalone stop conditions'
)) {
    if (-not $goRule.Contains($required)) { throw "go objective-continuation rule missing invariant: $required" }
}

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

$runtimeLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- The shared-production cutover gate is scope-specific,' })
if ($runtimeLines.Count -ne 1) { throw "expected exactly one scoped live-runtime authorization rule; found $($runtimeLines.Count)" }
$runtimeRule = $runtimeLines[0]
foreach ($required in @(
    'not a blanket live-runtime approval gate',
    '`go`/`continue` authorizes already-scoped ordinary engineering execution',
    'owned/isolated editor, runtime, build, test, render, or proof process',
    'does not change a currently serving shared production/control-plane path',
    'does not destructively overwrite user/foreign state',
    'existing repo-owned safety and exact-collision checks',
    'Do not invent a separate user-approval boundary merely because an operation is live',
    'launches Unreal',
    'captures proof'
)) {
    if (-not $runtimeRule.Contains($required)) { throw "scoped live-runtime authorization rule missing invariant: $required" }
}
if ($runtimeRule.Contains('authorizes a live shared-production/control-plane cutover')) {
    throw 'scoped live-runtime rule accidentally authorizes shared production cutover'
}


$goLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- `go` means continue the current task' })
if ($goLine.Count -ne 1) { throw "expected exactly one primary go rule; found $($goLine.Count)" }
$goRule = $goLine[0]
foreach ($required in @(
    'Never invent or infer an internal `tool window`, `tool budget`, `turn budget`',
    'If another supported tool call can still be issued',
    'an actual platform/tool limit has not been established',
    'actually rejects, disables, or prevents further needed execution',
    'no approved route or independent safe useful work remains'
)) {
    if (-not $goRule.Contains($required)) { throw "primary go rule missing anti-slopwall invariant: $required" }
}

[ordered]@{
    ok = $true
    rule_count = 1
    recoverable_capacity_is_not_hard_boundary = $true
    idle_long_waits_forbidden = $true
    ordinary_live_runtime_needs_no_extra_approval = $true
    meaningful_progress_required_before_voluntary_yield = $true
} | ConvertTo-Json -Compress
