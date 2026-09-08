Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- User-corrected assistant missteps are mandatory local Vault learning\.' })
if ($line.Count -ne 1) { throw "expected exactly one user-correction Vault ingestion rule; found $($line.Count)" }
foreach ($required in @(
  'memory_bank.py record --kind correction',
  'verbatim correction',
  'rejected behavior/design',
  'bounded local durability action only',
  'do not start a new investigation, GitHub/CI work, remote publication, or adjacent cleanup',
  'Do not wait for the user to separately ask for memory ingestion',
  'The literal user signal `slopwall` always qualifies as a correction incident',
  'record it before returning control',
  'continue the inherited task with the missing substance',
  'The literal user signal `asshole`',
  'lightweight correction event',
  'tag `asshole`',
  'add `regression` only when recurrence is evidenced',
  'smaller than `slopwall`'
)) {
  if (-not $line[0].Contains($required)) { throw "user-correction ingestion rule missing invariant: $required" }
}
if ($rules -notmatch '(?m)^- `slopwall` is a response-quality failure:') { throw 'canonical RULES.md slopwall definition missing' }
if ($rules -notmatch '(?m)^- `asshole`, when the user uses it as a direct correction') { throw 'canonical RULES.md asshole correction definition missing' }
[ordered]@{ok=$true; correction_ingestion_rule_present=$true; literal_slopwall_trigger_present=$true; canonical_slopwall_definition_present=$true; asshole_trigger_present=$true; canonical_asshole_definition_present=$true; local_only=$true; scope_expansion_forbidden=$true} | ConvertTo-Json -Compress
