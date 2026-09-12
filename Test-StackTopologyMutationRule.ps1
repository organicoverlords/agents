$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
$requiredRules = @(
  'evidence-sufficiency mutation gate, not an inventory ritual',
  "Reuse the fresh bootstrap's bounded topology/recovery/current-route orientation first",
  'stack_atlas.py find <natural-language-query>',
  'stack_atlas.py inventory',
  'inventory is a completeness fallback, not the default first lookup',
  'Named live/repo/runtime sources remain authoritative for current state'
)
foreach ($needle in $requiredRules) {
  if (-not $rules.Contains($needle)) { throw "stack topology mutation rule missing: $needle" }
}
$requiredAgents = @(
  'Before any stack/MCP/infra mutation',
  "reuse the fresh bootstrap's bounded current topology/recovery orientation",
  'stack_atlas.py find <natural-language-query>',
  'Load full Stack Atlas inventory only when bootstrap plus targeted discovery still cannot bound the cross-component dependency/blast radius',
  'Never infer stack topology from one subsystem file, service, search hit, component lookup, or derived projection'
)
foreach ($needle in $requiredAgents) {
  if (-not $agents.Contains($needle)) { throw "stack topology repo-entry rule missing: $needle" }
}
if ($rules.Contains('Topology-first rule:')) { throw 'obsolete inventory-first topology rule remains in RULES.md' }
Write-Host 'STACK_TOPOLOGY_MUTATION_RULE=PASS'
