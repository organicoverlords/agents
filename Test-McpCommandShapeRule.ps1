Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- Keep MCPv3 start_process payloads short' })
if ($line.Count -ne 1) { throw "expected exactly one MCP command-shape rule" }
foreach ($required in @('single-purpose','repo-owned wrapper/script','sequence of short calls','security-routing thresholds')) { if (-not $line[0].Contains($required)) { throw "missing invariant: $required" } }
'PASS MCP command-shape rule'
