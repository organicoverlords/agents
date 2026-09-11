$ErrorActionPreference = 'Stop'
$rules = Get-Content (Join-Path $PSScriptRoot 'RULES.md') -Raw
$required = @(
  'currently engaged workers',
  'default 60 seconds',
  'Never substitute `recent_callers`',
  'report `unknown` or an explicitly scoped observed lower bound',
  'MCPv4, MCPv3, and Remote Desktop Commander',
  '`MCPv4-observed` engaged-worker count',
  'Route health/availability is reported separately from worker activity',
  'two independent canonical recurring partitions',
  '`S1` and `S2`',
  'at most five recurring workers per partition',
  'never infer fleet membership from caller id',
  'manual/on-demand population',
  'scheduler/fleet-watch result describes recurrence/recovery evidence, not current swarm liveness'
)
foreach ($token in $required) {
  if (-not $rules.Contains($token)) { throw "swarm status truth rule missing: $token" }
}
Write-Output 'PASS swarm status requires truth-scoped liveness, route coverage, and dual S1/S2 identity evidence'
