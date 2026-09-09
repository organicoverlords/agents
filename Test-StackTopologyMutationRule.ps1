$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
$requiredRules = @(
  'Topology-first rule:',
  'stack_atlas.py inventory',
  'before proposing or applying a mutation',
  'one component `lookup`',
  'never sufficient by itself to establish cross-component topology',
  'derived Atlas output must be reconciled when it contradicts those owners'
)
foreach ($needle in $requiredRules) {
  if (-not $rules.Contains($needle)) { throw "stack topology mutation rule missing: $needle" }
}
$requiredAgents = @(
  'Before any stack/MCP/infra mutation',
  'full canonical component/dependency inventory',
  'before targeted component lookup or mutation',
  'Never infer stack topology from one subsystem file, service, component lookup, or derived projection'
)
foreach ($needle in $requiredAgents) {
  if (-not $agents.Contains($needle)) { throw "stack topology repo-entry rule missing: $needle" }
}
Write-Host 'STACK_TOPOLOGY_MUTATION_RULE=PASS'
