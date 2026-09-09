Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

$agentLine = @($agents -split "`r?`n" | Where-Object { $_ -match '^- \*\*User corrections are answer-first, not logging-first\.\*\*' })
if ($agentLine.Count -ne 1) { throw "expected exactly one answer-first user-correction rule; found $($agentLine.Count)" }
foreach ($required in @(
  'immediately reduce the corrected request to the exact proposition/action',
  'give or execute the corrected result before retrospective explanation or durability work',
  'Never perform `memory_bank.py record`, Vault writes, issue updates, incident analysis, or similar learning/coordination work merely as a prerequisite to answering the correction',
  'The literal signals `slopwall` and `asshole` do not change this ordering',
  'If direct proof is unavailable, report `UNKNOWN`',
  'optional secondary durability only',
  'it must not create an extra tool round trip, delay the corrected answer, broaden scope, or replace the inherited task'
)) {
  if (-not $agentLine[0].Contains($required)) { throw "answer-first correction rule missing invariant: $required" }
}
foreach ($required in @(
  '`slopwall` is a user correction marker. **Correction handling is answer-first:**',
  'give/execute the corrected result before any retrospective explanation, learning record, or process commentary',
  'Never make correction logging a prerequisite to returning the corrected answer',
  'Treat the user''s corrected proposition/request as the immediate objective',
  'Prove or execute that objective first',
  'Do not lead with self-analysis, apology, incident narrative, or a description of why the prior answer failed',
  'it must never block, precede, or replace the corrected result'
)) {
  if ($rules.IndexOf($required, [StringComparison]::Ordinal) -lt 0) { throw "RULES answer-first correction invariant missing: $required" }
}
foreach ($forbidden in @(
  'mandatory local Vault learning',
  'record one compact `memory_bank.py record --kind correction` entry before returning control',
  'record it before returning control',
  'save one compact Vault correction containing the verbatim user signal'
)) {
  if ($agents.Contains($forbidden) -or $rules.Contains($forbidden)) { throw "stale logging-first correction behavior remains: $forbidden" }
}
[ordered]@{
  ok = $true
  corrected_result_precedes_retrospective = $true
  correction_logging_not_prerequisite = $true
  unknown_required_when_unproved = $true
  slopwall_answer_first = $true
  asshole_answer_first = $true
} | ConvertTo-Json -Compress
