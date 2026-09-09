Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($required in @(
  'Busy stale/orphan reclaim is routine',
  'busy-python.cmd recover <old-actor> <scope> --expected-claim-timestamp <timestamp> --operation-id <unique-id>',
  'claim_changed',
  'claim the same scope under the current actor with a new operation ID and continue',
  'Never rediscover this procedure during live work',
  'Debug owner-first, not search-first',
  'one hypothesis and one discriminating check',
  'Do not fan out into wrapper/runbook/task/filesystem archaeology',
  'does not justify inventing a parallel recovery path'
)) {
  if (-not $agents.Contains($required)) { throw "AGENTS missing Busy/debugging invariant: $required" }
}
Write-Output 'PASS busy-reclaim-debugging-rule'
