Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

$owners = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*Shared behavior correction is analysis-before-claim and proof-gated\.\*\*' })
if ($owners.Count -ne 1) { throw "expected one durable behavior-correction owner; found $($owners.Count)" }
foreach ($required in @(
  'first perform bounded rule/owner analysis before promising change',
  '`RULE_GAP`',
  '`RULE_VIOLATION`',
  'duplicating or paraphrasing the rule is not recurrence prevention',
  'repair the narrowest canonical enforcement, guard, test, or mechanism',
  'never claim that swarm behavior is corrected, fixed, changed, or will behave differently going forward until',
  'the durable canonical change has landed',
  'proposition-appropriate proof shows the changed contract/enforcement is available to the swarm',
  'the correction is not yet durable'
)) {
  if (-not $owners[0].Contains($required)) { throw "durable behavior-correction rule missing invariant: $required" }
}
if (-not $rules.Contains('Repository grepping is forbidden as a discovery fallback')) {
  throw 'durable correction regression guard lost the canonical no-grep discovery boundary'
}
if (-not $rules.Contains('do not use `rg`, `git grep`, recursive repo/Vault file walks, or broad source scans to discover whether work/evidence exists')) {
  throw 'durable correction regression guard lost the explicit forbidden discovery mechanisms'
}
[ordered]@{
  ok = $true
  rule_analysis_required = $true
  violation_requires_enforcement_repair = $true
  proof_before_behavior_claim = $true
  unified_discovery_no_grep_preserved = $true
} | ConvertTo-Json -Compress
