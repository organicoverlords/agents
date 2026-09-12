Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$owners = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*ELI5 means give the concise core in normal understandable language, not dumb the subject down\.\*\*' })
if ($owners.Count -ne 1) { throw "expected one ELI5 reply owner; found $($owners.Count)" }
foreach ($required in @(
  'lead with the essential answer and only the context needed to understand it',
  'Keep the real technical/factual distinctions that matter',
  'replace unnecessary jargon with normal words',
  'Prefer a few compact paragraphs',
  'use a short list only when it genuinely makes the core easier to scan',
  'do not turn the answer into a long bullet wall or listicle',
  'Do not default to cars, houses, restaurants, toys, or other metaphors/analogies',
  'Never infantilize the explanation',
  'oversimplify away important constraints'
)) {
  if (-not $owners[0].Contains($required)) { throw "ELI5 rule missing invariant: $required" }
}
[ordered]@{ ok=$true; concise_core=$true; normal_language=$true; no_dumbing_down=$true; no_bullet_wall=$true; analogy_not_default=$true } | ConvertTo-Json -Compress
