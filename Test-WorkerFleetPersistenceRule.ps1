Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$workerContractPath = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\fresh-worker-generation-launch.md'
$worker = [IO.File]::ReadAllText($workerContractPath)

$lines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*THE CANONICAL FIVE TIMED WORKERS PER SUBSCRIPTION PARTITION STAY ENABLED\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one canonical worker persistence invariant; found $($lines.Count)" }
foreach ($required in @(
  'Never pause, disable, delete, retire, reschedule, rename, replace, or recreate them as ordinary task handling',
  'worker contract owns sibling-recovery mechanics',
  'never administer self or cross partitions',
  'worker_recovery_guard.py',
  'preserving prompt/title/schedule/timezone/stagger'
)) { if (-not $lines[0].Contains($required)) { throw "global worker invariant missing: $required" } }

$schedulerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one scheduler authority invariant; found $($schedulerLines.Count)" }
foreach ($required in @('Do not create non-fleet scheduled tasks','unless the user explicitly changes that topology','fresh-worker-generation-launch.md','manual/on-demand execution remains outside scheduler slots')) {
  if (-not $schedulerLines[0].Contains($required)) { throw "global scheduler invariant missing: $required" }
}

foreach ($required in @(
  'Exactly five canonical recurring workers per ChatGPT subscription partition stay enabled',
  'two scheduler partitions, `S1` and `S2`',
  'A worker must never administer itself',
  'recurring-worker recovery never crosses subscription partitions',
  'targeted idempotent `is_enabled=true` write',
  'preserving prompt/title/schedule/timezone/stagger',
  'Do not preflight with a broad scheduler read',
  'Never create verifier, spare, overlap, replacement, or temporary sixth workers',
  'never create an eleventh recurring worker globally'
)) { if (-not $worker.Contains($required)) { throw "worker owner contract missing mechanic: $required" } }

[ordered]@{ok=$true; global_policy_compact=$true; mechanics_owner='fresh-worker-generation-launch.md'; no_self_admin=$true; no_cross_partition_admin=$true; nonfleet_task_creation_forbidden=$true} | ConvertTo-Json -Compress
