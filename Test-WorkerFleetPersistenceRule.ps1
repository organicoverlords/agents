Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$lines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*THE CANONICAL FIVE TIMED WORKERS STAY ENABLED\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one canonical worker persistence rule; found $($lines.Count)" }
$rule = $lines[0]
foreach ($required in @(
  'Never pause, disable, delete, retire, reschedule, rename, replace, or recreate any of the five canonical recurring workers as ordinary task handling',
  'Debugging shell/Git/GitHub/build/resource churn never authorizes scheduler mutation',
  're-enable a disabled canonical worker that is not doing its job',
  'clear/recover a canonical worker proven to be running without required tools',
  'Preserve its existing prompt/title/schedule/timezone/stagger and do not create another task',
  'do not leave the fleet below five while waiting for a causal explanation'
)) { if (-not $rule.Contains($required)) { throw "worker persistence rule missing invariant: $required" } }

$schedulerLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one deny-by-default scheduler authority rule; found $($schedulerLines.Count)" }
$schedulerRule = $schedulerLines[0]
foreach ($required in @(
  'Never create any new timed, recurring, condition-watch, reminder, monitor, notification, or scheduled automation/task outside the five canonical recurring workers',
  'execute that work in the current manual/on-demand chat instead',
  'unless the user explicitly revokes this standing scheduler prohibition',
  're-enable a disabled canonical worker that is not doing its job',
  'clear/recover a canonical worker proven to be running without required tools',
  'Never create a replacement/non-fleet automation'
)) { if (-not $schedulerRule.Contains($required)) { throw "scheduler authority rule missing invariant: $required" } }

[ordered]@{ok=$true; canonical_five_persist=$true; debug_churn_not_scheduler_authority=$true; unexpected_disable_restored=$true; nonfleet_task_creation_forbidden=$true; monitoring_stays_manual=$true; fleet_recovery_only=$true} | ConvertTo-Json -Compress
