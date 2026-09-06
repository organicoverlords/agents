$ErrorActionPreference = 'Stop'
$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = Get-Content -LiteralPath $rulesPath -Raw
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- For regression recovery,' })
if ($line.Count -ne 1) { throw "expected exactly one regression-recovery rule" }
foreach ($required in @('restore that verified working behavior and topology before layering speculative fixes','Preserve rollback evidence, unique work, and active child processes','a source SHA alone is insufficient when serving topology differs','use the existing production-change gate and only minimal proven replacement compatibility','no MCP request in flight','stop MCP/edge mutation unless new MCP-local evidence appears')) {
    if (-not $line[0].Contains($required)) { throw "regression-recovery rule missing invariant: $required" }
}
Write-Output 'PASS mcp-regression-recovery-rule'
