Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$owner = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'docs\repos\regression-research\BUSY_COORDINATOR_NORTH_STAR.md'))

foreach ($required in @(
  'BusyCoordinator is exact shared-mutation collision control only',
  '%LOCALAPPDATA%\BusyCoordinator\coordinator-contract.json',
  'BUSY_COORDINATOR_NORTH_STAR.md',
  'never repo-wide metadata',
  'evidence-backed compare-and-swap',
  'age alone',
  'incoming change',
  'collision blocks only that exact mutation'
)) { if (-not $rules.Contains($required)) { throw "global Busy invariant/pointer missing: $required" } }

foreach ($required in @(
  'Git ref mutation claims the exact ref',
  '<repo>:git-ref:refs/heads/<branch>',
  'never repo-wide `git-ref-metadata`',
  'no MCP process start/read/kill/output activity has occurred for at least 60 seconds',
  'still-identical actor/scope/claim timestamp through CAS',
  'Any newer activity, heartbeat, renewal, replacement, or timestamp mismatch cancels recovery',
  'ambiguous/unmapped claims keep ordinary lease/manual-recovery semantics',
  'claimant WIP already subsumes the intended mutation',
  'one structured `incoming change` comment',
  'Hold a claim only while that exact mutation needs exclusivity',
  'If the exact lease is absent/expired',
  'before issue closure, record each note''s resulting commit/PR/runtime evidence or explicit supersession'
)) { if (-not $owner.Contains($required)) { throw "Busy owner missing mechanic: $required" } }

[ordered]@{ok=$true; global_policy_compact=$true; owner='BUSY_COORDINATOR_NORTH_STAR.md'; recovery='evidence-backed-cas'; stale_threshold_seconds=60; age_only_takeover=$false} | ConvertTo-Json -Compress
