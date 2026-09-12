$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
$requiredRules = @(
  'UNIFIED DISCOVERY IS THE MANDATORY FIRST SEARCH SURFACE',
  'materialized local Git commits and branch refs',
  'local `gh-buffer` cache',
  'MCP process receipts and transport/watchdog events',
  'CI/runner/machine/coordinator observations',
  'worker reports, artifacts, Vault memories/timeline, and live-swarm navigation evidence',
  'Repository grepping is forbidden as a discovery fallback',
  'Evidence clusters returned by `find` are correlation windows only',
  'Worker reports are one evidence class only and never outrank runtime receipts/logs',
  'missing exact identity may be returned as `reference_only`',
  'Bootstrap scope is deliberately small'
)
foreach ($needle in $requiredRules) {
  if (-not $rules.Contains($needle)) { throw "unified discovery rule missing: $needle" }
}
$requiredAgents = @(
  'Those discovery classes belong to `stack_atlas.py find`',
  'use one `stack_atlas.py find <natural-language-query>` discovery pass',
  'Repository-content grep/recursive scans are not a discovery fallback'
)
foreach ($needle in $requiredAgents) {
  if (-not $agents.Contains($needle)) { throw "unified discovery agent guidance missing: $needle" }
}
Write-Host 'UNIFIED_DISCOVERY_RULE=PASS'
