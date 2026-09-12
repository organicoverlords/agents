$ErrorActionPreference='Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($doc in @($rules, $agents)) {
    if ($doc -notmatch '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$') { throw 'shared contract version missing' }
}
$requiredRules = @(
    'Task memory is conditional drill-down evidence, not a first-line search surface or startup tax',
    'do not stop at that placeholder when the returned bounded local lineage can recover the object',
    'origin/memory/live',
    'stack_atlas.py find',
    'memory_bank.py context <query>',
    'memory_bank.py timeline <query>',
    'evidence-sufficiency mutation gate, not an inventory ritual',
    'Task memory `context`/`timeline` is second-stage drill-down only when `find` surfaces a relevant memory/history thread',
    'inventory is a completeness fallback, not the default first lookup',
    'do not require that component to certify its own repair'
)
foreach ($needle in $requiredRules) {
    if ($rules.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "RULES.md missing conditional-memory/search gate: $needle" }
}
$requiredAgents = @(
    'use one unified `stack_atlas.py find` pass',
    'Task-scoped memory is conditional drill-down evidence, not startup ceremony',
    'resolve it with `stack_atlas.py find <mem-id>`',
    'origin/memory/live',
    'Task memory/timeline is drill-down only after a relevant historical thread is surfaced',
    'Use full Atlas inventory only when bootstrap plus targeted discovery still leaves the dependency/blast radius materially unknown',
    'use an independent supported evidence source rather than making the broken component certify its own repair'
)
foreach ($needle in $requiredAgents) {
    if ($agents.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "AGENTS.md missing conditional-memory/search gate: $needle" }
}
foreach ($forbidden in @(
    'Every substantive worker task starts with task-scoped memory context',
    'Task memory is part of work startup, not optional archaeology',
    'run both the task-scoped memory `context` and `timeline` reads',
    'Topology-first rule:'
)) {
    if ($rules.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or $agents.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0) { throw "shared policy retains obsolete lookup ceremony: $forbidden" }
}
Write-Output 'WORKER_MEMORY_CONTEXT_RULE_PASS'
