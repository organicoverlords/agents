$ErrorActionPreference = 'Stop'
$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = Get-Content -LiteralPath $rulesPath -Raw
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- For regression recovery,' })
if ($line.Count -ne 1) { throw "expected exactly one regression-recovery invariant" }
foreach ($required in @('exact last verified working boundary','historical labels are evidence only','restore the verified behavior/topology before speculative fixes','mcp-recovery-state.json','production-change gate')) {
    if (-not $line[0].Contains($required)) { throw "global regression-recovery invariant missing: $required" }
}
if ($text.Contains('vault-memory-bootstrap-user-known-pretty-good-20260906-031536')) { throw 'incident-specific rollback tag leaked into global RULES' }

$ownerPath = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\mcp-recovery-state.json'
$state = Get-Content -LiteralPath $ownerPath -Raw | ConvertFrom-Json
if (-not $state.recovery_target.policy.restore_first_on_regression) { throw 'MCP owner lost restore-first invariant' }
$ownerText = Get-Content -LiteralPath $ownerPath -Raw
foreach ($required in @('Preserve the current runtime, dist, serving identity, and rollback evidence','a source SHA alone is not sufficient when topology differs','minimal compatibility required by the proven replacement mechanism','no MCP request in flight','stop MCP/edge mutation unless new MCP-local evidence appears','Restoration must preserve unique work and active child processes')) {
    if (-not $ownerText.Contains($required)) { throw "MCP owner contract missing mechanic: $required" }
}
Write-Output 'PASS mcp-regression-recovery owner-bound rule'
