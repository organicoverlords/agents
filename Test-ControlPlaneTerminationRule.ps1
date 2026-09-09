$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

$rulesRequired = @(
  'MCP and Remote Desktop Commander are protected control-plane infrastructure',
  'does not authorize `kill_process`, `Stop-Process`, `taskkill`',
  'positively identify the exact target and process-tree/service/task blast radius',
  'independent usable control/recovery route',
  'ambiguity is a preserve/fail-closed result',
  'Never use broad name/port/process cleanup as MCP/Commander recovery'
)
foreach ($needle in $rulesRequired) {
  if (-not $rules.Contains($needle)) { throw "RULES.md missing protected-control-plane invariant: $needle" }
}

$agentsRequired = @(
  'Apply the `RULES.md` protected-control-plane termination rule',
  'Observation failure is route evidence only; it is never a kill signal',
  'preserve fallback/recovery paths',
  'If the target may contain protected infrastructure and that mapping is not positively known, do not terminate it'
)
foreach ($needle in $agentsRequired) {
  if (-not $agents.Contains($needle)) { throw "AGENTS.md missing protected-control-plane execution guidance: $needle" }
}

[ordered]@{ok=$true; protected_control_plane_termination_guard=$true} | ConvertTo-Json -Compress