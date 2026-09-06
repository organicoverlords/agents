Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

foreach ($required in @(
    'TIMED WORKER REPORTS ARE MANDATORY; ORDINARY INTERACTIVE CHATS ARE NOT WORKERS BY DEFAULT',
    'Merely using tools, receiving `go`, editing code, running tests, opening a PR, or doing normal debugging does not create a reporting obligation',
    'Never delay a user-visible answer solely to create, finalize, archive, or repair a manual worker report',
    'WHEN A MANUAL REPORT IS ACTUALLY REQUIRED, USE THE CANONICAL FORMAT',
    'automatic Vault investigation learning for substantive technical debugging/investigation, but this is an optimization rather than a per-turn obligation',
    'Never extend a tool interval or delay a user-visible answer solely to create, sync, repair, or deduplicate a Vault memory',
    'A slow, failed, or unnecessary Vault write is not a completion gate',
    'do not use `gh run watch` or an equivalent long-lived CI watcher as a waiting primitive'
)) {
    if (-not $text.Contains($required)) { throw "interactive YAGNI invariant missing: $required" }
}
foreach ($obsolete in @(
    'WORKER REPORTS ARE MANDATORY FOR BOTH TIMED AND MANUAL/ON-DEMAND WORK',
    'Every substantive worker run or substantive user-driven execution turn (including ordinary manual chats driven by `go`) must leave a durable canonical worker report',
    'preserve one compact assistant-authored record through the canonical `memory_bank.py record` path before closing the interval'
)) {
    if ($text.Contains($obsolete)) { throw "obsolete mandatory overhead still present: $obsolete" }
}
[ordered]@{ok=$true;ordinary_chat_not_worker=$true;manual_report_conditional=$true;memory_nonblocking=$true;gh_watch_forbidden=$true} | ConvertTo-Json -Compress
