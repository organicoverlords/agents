Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$workerContractPath = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\fresh-worker-generation-launch.md'
$worker = [IO.File]::ReadAllText($workerContractPath)

$lines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*Recurring-fleet topology and liveness are separate dimensions\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one recurring-fleet topology invariant; found $($lines.Count)" }
foreach ($required in @(
  'two independent canonical recurring partitions',
  '`S1` and `S2`',
  'at most five recurring workers per partition',
  'scheduler/fleet-watch result describes recurrence/recovery evidence, not current swarm liveness'
)) { if (-not $lines[0].Contains($required)) { throw "global worker invariant missing: $required" } }

foreach ($required in @(
  'hard maximum of five recurring workers per subscription partition',
  '`S1` and `S2` are both canonical recurring partitions',
  'five enabled in one partition does not consume slots in the other',
  'probe that exact ChatGPT automation live and reconcile `is_enabled` plus `last_run_time`'
)) { if (-not $rules.Contains($required)) { throw "shared fleet topology statement missing: $required" } }

$schedulerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one scheduler authority invariant; found $($schedulerLines.Count)" }
foreach ($required in @('Do not create non-fleet scheduled tasks','unless the user explicitly changes that topology','fresh-worker-generation-launch.md','manual/on-demand execution remains outside scheduler slots')) {
  if (-not $schedulerLines[0].Contains($required)) { throw "global scheduler invariant missing: $required" }
}

foreach ($required in @(
  'Each recurring subscription partition has a hard maximum of five workers',
  '`S1` and `S2` are both canonical recurring partitions',
  'scheduler-write authority',
  'A recurring worker must never administer itself or any sibling',
  'targeted `is_enabled=true` recovery',
  'preserve prompt/title/schedule/timezone/stagger',
  'Do not preflight with a broad scheduler read',
  'Never create verifier, spare, overlap, replacement, or temporary sixth recurring workers inside either canonical partition'
)) { if (-not $worker.Contains($required)) { throw "worker owner contract missing mechanic: $required" } }

[ordered]@{ok=$true; global_policy_compact=$true; mechanics_owner='fresh-worker-generation-launch.md'; canonical_partitions=@('S1','S2'); recurring_partition_max=5; recurring_total_max=10; no_self_or_sibling_admin=$true; live_scheduler_probe_required=$true; nonfleet_task_creation_forbidden=$true} | ConvertTo-Json -Compress
