Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

$agent = @($agents -split "`r?`n" | Where-Object { $_ -match '^- \*\*User corrections are answer-first; literal `slopwall` additionally requires a bounded durable learning loop\.\*\*' })
if ($agent.Count -ne 1) { throw "expected one correction owner; found $($agent.Count)" }
foreach ($required in @(
  'For ordinary corrections',
  'give or execute the corrected result before retrospective explanation or optional durability work',
  'Literal `slopwall` is the durability exception, not a task-priority exception',
  'persist one compact `memory_bank.py record --kind correction` entry',
  'The Slopwall record is mandatory',
  'The literal signal `asshole` remains a lightweight correction marker and does not by itself require durable logging'
)) {
  if (-not $agent[0].Contains($required)) { throw "correction owner missing invariant: $required" }
}
if ($rules -notmatch '(?m)^- `slopwall` is a \*\*mandatory correction-and-learning incident\*\*') {
  throw 'RULES does not classify literal slopwall as a mandatory learning incident'
}
[ordered]@{
  ok = $true
  ordinary_corrections_answer_first = $true
  slopwall_requires_durable_learning = $true
  asshole_remains_lightweight = $true
} | ConvertTo-Json -Compress
