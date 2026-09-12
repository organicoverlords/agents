Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$owners = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*ELI5 means simplify the actual explanation, not automatically replace it with an analogy\.\*\*' })
if ($owners.Count -ne 1) { throw "expected one ELI5 reply owner; found $($owners.Count)" }
foreach ($required in @(
  'preserve the real subject and causal/factual structure',
  'reducing jargon',
  'Do not default to cars, houses, restaurants, toys, or other metaphors/analogies',
  'Use an analogy only when the user explicitly asks for one or when it materially clarifies a difficult point',
  'keep it brief and secondary to the direct explanation',
  'Never let the analogy become the explanation itself'
)) {
  if (-not $owners[0].Contains($required)) { throw "ELI5 rule missing invariant: $required" }
}
[ordered]@{ ok=$true; simplify_not_metaphorize=$true; analogy_not_default=$true; direct_explanation_primary=$true } | ConvertTo-Json -Compress
