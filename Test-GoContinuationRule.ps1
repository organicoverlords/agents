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
    '`go` means continue the already-established scope',
    'returning control to the user is valid',
    'Timed recurring workers keep their separate utilization contract'
)) {
    if (-not $scopeLine[0].Contains($required)) { throw "scope-fidelity rule missing invariant: $required" }
}
foreach ($required in @(
    'Query external or shared state only when its answer can change the next action or validate the requested result',
    'reuse the returned state until there is concrete reason it may have changed',
    'do not issue repeated unchanged checks',
    'smallest bounded read needed to collect its result'
)) {
    if (-not $pollLine[0].Contains($required)) { throw "anti-polling rule missing invariant: $required" }
}
foreach ($obsolete in @(
    'If another supported tool call can still be issued',
    'actionable work must continue',
    'continue across sequential safe useful actions until the task-level objective is complete',
    'keep observing it with that bounded mechanism until it completes',
    'consume one bounded wait/recheck in the same `go` turn'
)) {
    if ($text.Contains($obsolete)) { throw "shared rules retain churn incentive: $obsolete" }
}
[ordered]@{
    ok = $true
    prompt_scope_is_completion_boundary = $true
    tool_exhaustion_forbidden = $true
    unchanged_polling_forbidden = $true
    timed_worker_contract_separate = $true
} | ConvertTo-Json -Compress
