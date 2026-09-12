Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$direct = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Test-DirectReplyGate.ps1'))
$substance = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Test-SlopwallSubstanceRule.ps1'))

foreach ($required in @(
  'unresolved literal `slopwall`',
  'fail-closed pre-final block',
  'inherited objective has been resumed with concrete missing user-relevant substance',
  'memory_bank.py record --kind correction',
  'accepted durable record'
)) {
  if ($rules.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "RULES missing Slopwall pre-final invariant: $required" }
}
foreach ($required in @(
  'pending fail-closed pre-final state',
  'concrete resumed work/result that repairs the inherited objective',
  'accepted `memory_bank.py record --kind correction` result',
  'do not return control with acknowledgement, status, diagnosis, or promises'
)) {
  if ($agents.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "AGENTS missing Slopwall pre-final invariant: $required" }
}
foreach ($required in @('unresolved literal `slopwall`','fail-closed pre-final block','accepted durable record')) {
  if ($direct.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "direct-reply regression coverage missing Slopwall branch: $required" }
}
foreach ($required in @('Slopwall remains pending and the direct-reply pre-final gate must fail closed','pending fail-closed pre-final state')) {
  if ($substance.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "Slopwall substance regression coverage missing pre-final coupling: $required" }
}
[ordered]@{ok=$true; literal_slopwall_fail_closed=$true; corrected_substance_required=$true; accepted_durable_record_required=$true; direct_reply_gate_coupled=$true} | ConvertTo-Json -Compress
