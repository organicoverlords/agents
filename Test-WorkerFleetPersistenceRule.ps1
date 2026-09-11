Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$workerContractPath = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\fresh-worker-generation-launch.md'
$worker = [IO.File]::ReadAllText($workerContractPath)

$lines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*Recurring-fleet topology and liveness are separate dimensions\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one recurring-fleet topology invariant; found $($lines.Count)" }
foreach ($required in @(
  'single canonical active `S2` recurring fleet',
  'paused `S1` partition',
  'global five-worker cap',
  'scheduler/fleet-watch result describes recurrence/recovery evidence, not current swarm liveness'
)) { if (-not $lines[0].Contains($required)) { throw "global worker invariant missing: $required" } }

foreach ($required in @(
  'The current canonical active recurring fleet is `S2`; `S1` is a known paused partition and does not count as active recurring membership.',
  'The supported swarm is the canonical active `S2` recurring fleet with at most five timed workers; `S1` is paused, plus the separate manual/on-demand ChatGPT worker population.'
)) { if (-not $rules.Contains($required)) { throw "shared fleet topology statement missing: $required" } }

$schedulerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*SCHEDULER AUTHORITY IS DENY-BY-DEFAULT\.\*\*' })
if ($schedulerLines.Count -ne 1) { throw "expected exactly one scheduler authority invariant; found $($schedulerLines.Count)" }
foreach ($required in @('Do not create non-fleet scheduled tasks','unless the user explicitly changes that topology','fresh-worker-generation-launch.md','manual/on-demand execution remains outside scheduler slots')) {
  if (-not $schedulerLines[0].Contains($required)) { throw "global scheduler invariant missing: $required" }
}

foreach ($required in @(
  'The recurring fleet has a global hard maximum of five workers',
  'current canonical active recurring fleet is `S2`',
  '`S1` is a paused partition',
  'A recurring worker must never administer itself or any sibling',
  'targeted `is_enabled=true` recovery',
  'preserve prompt/title/schedule/timezone/stagger',
  'Do not preflight with a broad scheduler read',
  'Never create verifier, spare, overlap, replacement, or temporary sixth recurring workers globally'
)) { if (-not $worker.Contains($required)) { throw "worker owner contract missing mechanic: $required" } }

[ordered]@{ok=$true; global_policy_compact=$true; mechanics_owner='fresh-worker-generation-launch.md'; active_partition='S2'; paused_partition='S1'; global_recurring_max=5; no_self_or_sibling_admin=$true; nonfleet_task_creation_forbidden=$true} | ConvertTo-Json -Compress
