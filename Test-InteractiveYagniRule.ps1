Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

foreach ($required in @(
    'WORKER REPORTS ARE FOR WORKER RUNS, NOT ORDINARY CONVERSATION',
    'MANUAL REPORTS ARE MANDATORY BUT MINIMAL',
    'Do not checkpoint routine progress or duplicate commands, process IDs, Busy claims, GitHub/PR chronology, CI output, validation logs, or other telemetry already owned elsewhere',
    'Vault investigation learning is subordinate to request scope',
    'never turn a narrow user request into a separate investigation or remote-publication workflow merely to create memory',
    'A Vault write failure is a durability gap, not a reason to expand the current request or start repair work unless that repair is itself requested',
    'reuse the returned state until there is concrete reason it may have changed'
)) {
    if (-not $text.Contains($required)) { throw "interactive YAGNI invariant missing: $required" }
}
foreach ($obsolete in @(
    'TIMED WORKER REPORTS ARE MANDATORY; ORDINARY INTERACTIVE CHATS ARE NOT WORKERS BY DEFAULT',
    'WHEN A MANUAL REPORT IS ACTUALLY REQUIRED, USE THE CANONICAL FORMAT',
    'preserve one compact assistant-authored record through the canonical `memory_bank.py record` path before closing the interval'
)) {
    if ($text.Contains($obsolete)) { throw "obsolete mandatory overhead still present: $obsolete" }
}
[ordered]@{ok=$true;manual_report_mandatory=$true;manual_report_minimal=$true;memory_scope_bounded=$true;unchanged_polling_forbidden=$true} | ConvertTo-Json -Compress

