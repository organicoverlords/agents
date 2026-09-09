Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- Before sending an MCP `start_process` command,' })
if ($line.Count -ne 1) { throw "expected exactly one start_process command-shape rule; found $($line.Count)" }
foreach ($required in @(
  'For local Python helpers on Windows, prefer the PowerShell call-operator form',
  '& python.exe',
  'make one materially normalized retry',
  'preserve the rejected and successful command shapes as a `tooling` finding',
  'If the user corrected the command-shape failure, apply the answer-first correction rule',
  'do not create a separate Vault write merely for this tooling finding',
  'repeated recurrence is an owned tooling defect',
  'fix the command-producing guidance/helper',
  'Invoke-LiteralScript.ps1',
  'transports arguments through JSON',
  'do not fall back to re-embedding the same payload',
  'add the narrowest available regression check',
  'do not infer a platform-security cause'
)) {
  if ($line[0].IndexOf($required, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "command-shape rule missing invariant: $required" }
}
if ($line[0].Contains('required compact Vault correction when user-corrected')) {
  throw 'command-shape rule retains stale logging-first correction requirement'
}
if ($line[0].Contains('retry an unchanged preflight-rejected command')) {
  if (-not $line[0].Contains('Do not retry an unchanged preflight-rejected command')) { throw 'unchanged retry must remain forbidden' }
}
Write-Output 'PASS command-shape-preflight-rule'
