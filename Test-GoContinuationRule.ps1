Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$scopeLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- Scope fidelity is a hard completion rule\.' })
if ($scopeLine.Count -ne 1) { throw "expected exactly one scope-fidelity rule; found $($scopeLine.Count)" }
$pollLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive' })
if ($pollLine.Count -ne 1) { throw "expected exactly one anti-polling rule; found $($pollLine.Count)" }
foreach ($required in @(
    'The user''s current explicit request defines the operation and its completion boundary',
    'Availability of another supported tool call is never by itself a reason to continue',
    '`go`/`continue` in a manual/on-demand execution chat means resume the already-established unresolved engineering objective',
    'carry the next coherent contribution through its normal completion path',
    'publication/integration or merge when that is already the established completion path and its gates pass',
    'Do not yield merely because a plan is clear, a commit exists, a PR is open',
    'A healthy finite serialized blocker with observable owner/progress',
    'is not an immediate yield boundary',
    'use one bounded defer/recheck chosen from recent duration/progress evidence',
    'continue the required step if it clears',
    'Manual `go` does not imply timed-fleet supervision or scheduler work',
    'Timed recurring workers keep their separate utilization contract'
)) {
    if (-not $scopeLine[0].Contains($required)) { throw "scope-fidelity rule missing invariant: $required" }
}
foreach ($required in @(
    'Query external or shared state only when its answer can change the next action or validate the requested result',
    'reuse the returned state until there is concrete reason it may have changed',
    'do not issue repeated unchanged checks',
    'smallest bounded read needed to collect its result',
    'a pending CI/build/process gate must not monopolize the turn through a blocking watcher',
    'Take one bounded/nonblocking snapshot',
    'advance that ready contribution',
    're-check the gate only when its result can change the next action',
    'do not babysit its output',
    'A single bounded defer/recheck explicitly required by the scope-fidelity rule is not keepalive polling',
    'do not turn it into a recurring watch loop',
    'If no alternative ready contribution exists',
    'use the scope-fidelity rule''s one bounded defer/recheck rather than a blocking watcher or repeated polling'
)) {
    if (-not $pollLine[0].Contains($required)) { throw "anti-polling rule missing invariant: $required" }
}
foreach ($obsolete in @(
    'If another supported tool call can still be issued',
    'actionable work must continue',
    'continue across sequential safe useful actions until the task-level objective is complete',
    'keep observing it with that bounded mechanism until it completes',
    'consume one bounded wait/recheck in the same `go` turn',
    'next required action truly depends on a blocked result',
    'decision-ready checkpoint is a valid yield boundary'
)) {
    if ($text.Contains($obsolete)) { throw "shared rules retain churn incentive: $obsolete" }
}
[ordered]@{
    ok = $true
    prompt_scope_is_completion_boundary = $true
    tool_exhaustion_forbidden = $true
    unchanged_polling_forbidden = $true
    blocking_watcher_monopoly_forbidden = $true
    manual_go_lands_coherent_contribution = $true
    manual_go_not_scheduler_supervision = $true
    timed_worker_contract_separate = $true
} | ConvertTo-Json -Compress
