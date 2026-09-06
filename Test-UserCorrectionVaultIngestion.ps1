Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- User-corrected assistant missteps are mandatory local Vault learning\.' })
if ($line.Count -ne 1) { throw "expected exactly one user-correction Vault ingestion rule; found $($line.Count)" }
foreach ($required in @(
  'memory_bank.py record --kind correction',
  'verbatim correction',
  'rejected behavior/design',
  'bounded local durability action only',
  'do not start a new investigation, GitHub/CI work, remote publication, or adjacent cleanup',
  'Do not wait for the user to separately ask for memory ingestion'
)) {
  if (-not $line[0].Contains($required)) { throw "user-correction ingestion rule missing invariant: $required" }
}
[ordered]@{ok=$true; user_correction_auto_ingested=$true; local_only=$true; scope_expansion_forbidden=$true} | ConvertTo-Json -Compress
