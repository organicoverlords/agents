Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$lines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*THE CANONICAL FIVE TIMED WORKERS STAY ENABLED\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one canonical worker persistence rule; found $($lines.Count)" }
$rule = $lines[0]
foreach ($required in @(
  'Never pause, disable, delete, retire, reschedule, rename, replace, or recreate any of the five canonical recurring workers as ordinary task handling',
  'A recurring worker never administers itself',
  'local worker/report cadence evidence identifies as suspect',
  'targeted idempotent is_enabled=true write for that exact sibling only',
  'preserve prompt/title/schedule/timezone/stagger',
  'never use a broad scheduler read as routine liveness or fleet-health evidence'
)) { if (-not $rule.Contains($required)) { throw "worker persistence rule missing invariant: $required" } }

$schedulerLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one deny-by-default scheduler authority rule; found $($schedulerLines.Count)" }
$schedulerRule = $schedulerLines[0]
foreach ($required in @(
  'Never create any new timed, recurring, condition-watch, reminder, monitor, notification, or scheduled automation/task outside the five canonical recurring workers',
  'The only recurring-worker scheduler write is bounded sibling recovery after local report/start evidence identifies the exact suspect',
  'set only that existing canonical sibling to is_enabled=true',
  'Do not read/list the scheduler first merely to discover fleet state',
  'Never administer self, create a replacement/non-fleet automation, or change prompt/title/schedule/timezone/stagger'
)) { if (-not $schedulerRule.Contains($required)) { throw "scheduler authority rule missing invariant: $required" } }

[ordered]@{ok=$true; canonical_five_persist=$true; local_evidence_first_recovery=$true; no_self_admin=$true; nonfleet_task_creation_forbidden=$true; no_broad_scheduler_discovery=$true; targeted_sibling_recovery_only=$true} | ConvertTo-Json -Compress
