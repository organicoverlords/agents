Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$lines = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*THE CANONICAL FIVE TIMED WORKERS STAY ENABLED\.\*\*' })
if ($lines.Count -ne 1) { throw "expected exactly one canonical worker persistence rule; found $($lines.Count)" }
$rule = $lines[0]
foreach ($required in @(
  'Never pause, disable, delete, retire, reschedule, rename, or replace any of the five canonical recurring workers unless the user explicitly instructs that exact fleet mutation',
  'Debugging shell/Git/GitHub/build/resource churn never authorizes scheduler mutation',
  'restore `is_enabled=true`',
  'do not leave the fleet below five while waiting for a causal explanation'
)) { if (-not $rule.Contains($required)) { throw "worker persistence rule missing invariant: $required" } }
[ordered]@{ok=$true; canonical_five_persist=$true; debug_churn_not_scheduler_authority=$true; unexpected_disable_restored=$true} | ConvertTo-Json -Compress
