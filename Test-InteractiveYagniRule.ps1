Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

foreach ($required in @(
    'WORKER REPORTS ARE MANDATORY FOR BOTH TIMED AND MANUAL/ON-DEMAND WORK',
    'MANUAL REPORTS ARE MANDATORY BUT MINIMAL',
    'Do not checkpoint routine progress or duplicate commands, process IDs, Busy claims, GitHub/PR chronology, CI output, validation logs, or other telemetry already owned elsewhere',
    'automatic Vault investigation learning for substantive technical debugging/investigation, but this is an optimization rather than a per-turn obligation',
    'Never extend a tool interval or delay a user-visible answer solely to create, sync, repair, or deduplicate a Vault memory',
    'A slow, failed, or unnecessary Vault write is not a completion gate',
    'do not use `gh run watch` or an equivalent long-lived CI watcher as a waiting primitive'
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
[ordered]@{ok=$true;manual_report_mandatory=$true;manual_report_minimal=$true;memory_nonblocking=$true;gh_watch_forbidden=$true} | ConvertTo-Json -Compress
