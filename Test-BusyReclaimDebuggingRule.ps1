Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

foreach ($required in @(
  'Busy stale/orphan reclaim is a deterministic collision-recovery primitive, not a research task',
  'BUSY_COORDINATOR_NORTH_STAR.md',
  'no MCP process start/read/kill/output activity has occurred for at least 60 seconds',
  'busy-python.cmd recover <existing-actor> <exact-scope> --expected-claim-timestamp <timestamp> --operation-id <unique-recovery-id>',
  'The `recover` actor argument is the expected old owner, not the new/current actor',
  'After successful recovery, `claim` the same exact scope under the current actor with a distinct operation ID and continue',
  'Debug deterministic owner paths before searching broadly',
  'form one falsifiable hypothesis, and run one discriminating check',
  'Do not fan out across scheduled tasks, alternate wrappers, runbooks, filesystem-wide searches, or adjacent repositories',
  'A failed low-level call is not evidence that a different wrapper must exist and is not permission to invent a parallel recovery path'
)) {
  if (-not $agents.Contains($required)) { throw "AGENTS missing Busy/debugging invariant: $required" }
}

Write-Output 'PASS busy-reclaim-debugging-rule'
