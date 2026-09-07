Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$lines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*THE CANONICAL FIVE TIMED WORKERS PER SUBSCRIPTION PARTITION STAY ENABLED\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one canonical worker persistence rule; found $($lines.Count)" }
$rule = $lines[0]
foreach ($required in @(
  'Never pause, disable, delete, retire, reschedule, rename, replace, or recreate any canonical recurring worker as ordinary task handling',
  'A recurring worker never administers itself',
  'same ChatGPT subscription partition',
  'local worker/report cadence evidence identifies as suspect',
  'targeted idempotent is_enabled=true write for that exact same-partition sibling only',
  'worker_recovery_guard.py --actor-worker-id <own-automation-id> --target-worker-id <sibling-automation-id>',
  'require `authorized: true`',
  'never cross subscription partitions',
  'Preserve prompt/title/schedule/timezone/stagger',
  'never use a broad scheduler read as routine liveness or fleet-health evidence',
  'S2 carrying control while S1 is capacity-limited'
)) { if (-not $rule.Contains($required)) { throw "worker persistence rule missing invariant: $required" } }

$fleetLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- The recurring scheduler fleet is partitioned by ChatGPT subscription\.' })
if ($fleetLines.Count -ne 1) { throw "expected exactly one recurring partition topology rule; found $($fleetLines.Count)" }
$fleetRule = $fleetLines[0]
foreach ($required in @(
  'two canonical partitions, `S1` and `S2`',
  'five timed scheduler automations each (10 recurring workers total)',
  'Manual/on-demand worker chats',
  'do not count against either five-slot recurring partition',
  'total active swarm work may exceed 10'
)) { if (-not $fleetRule.Contains($required)) { throw "fleet topology rule missing invariant: $required" } }

$schedulerLines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one deny-by-default scheduler authority rule; found $($schedulerLines.Count)" }
$schedulerRule = $schedulerLines[0]
foreach ($required in @(
  'outside the 10 canonical recurring workers',
  'five in `S1`, five in `S2`',
  'The only ordinary recurring-worker scheduler write is bounded sibling recovery after local report/start evidence identifies the exact suspect',
  'set only that existing same-partition canonical sibling to is_enabled=true',
  'only after `worker_recovery_guard.py` returns `authorized: true` for that exact actor/target pair',
  'Manual/on-demand execution is a separate non-scheduler population',
  'Do not read/list the scheduler first merely to discover fleet state',
  'Never administer self, cross subscription partitions, create a replacement/non-fleet automation, or change prompt/title/schedule/timezone/stagger'
)) { if (-not $schedulerRule.Contains($required)) { throw "scheduler authority rule missing invariant: $required" } }

[ordered]@{ok=$true; subscription_partitions=2; recurring_workers_per_partition=5; canonical_recurring_total=10; manual_population_separate=$true; no_cross_partition_admin=$true; local_evidence_first_recovery=$true; no_self_admin=$true; nonfleet_task_creation_forbidden=$true; no_broad_scheduler_discovery=$true; targeted_sibling_recovery_only=$true} | ConvertTo-Json -Compress
