$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

foreach ($doc in @($rules, $agents)) {
    if ($doc -notmatch '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$') { throw 'shared contract version missing' }
}

$requiredRules = @(
    'Task memory is conditional evidence, not a universal startup tax',
    'memory_bank.py context <query>',
    'Ordinary owner-known isolated work with current repo/runtime evidence does not require a memory lookup',
    'never rerun it per subtask/tool',
    'memory_bank.py timeline <query>',
    'Stack/MCP/infra retains its separate hard understanding gate',
    'Stack/MCP/infra understanding is an evidence-sufficiency mutation gate, not a fixed lookup ritual',
    'Use already-held current task evidence first',
    'do not require both memory reads merely because the target is stack/MCP/infra',
    'Use targeted Stack Atlas `find`/`lookup` only when ownership/topology/dependency facts are unknown, stale, or contradictory',
    'Do not require memory plus Atlas when the required evidence fields are already established directly',
    'do not require that component to provide the evidence needed to authorize its own repair',
    'Understanding only one local file/service remains insufficient when the mutation can affect broader stack resources'
)
foreach ($needle in $requiredRules) {
    if (-not $rules.Contains($needle)) { throw "RULES.md missing conditional-memory/stack gate: $needle" }
}

$requiredAgents = @(
    'Task-scoped memory is conditional evidence, not startup ceremony',
    'memory_bank.py context <query>',
    'Ordinary owner-known isolated work with current repo/runtime evidence goes directly to the owner without a memory round trip',
    'never make memory/timeline a per-tool or per-subtask ritual',
    'memory_bank.py timeline <query>',
    'Stack/MCP/infra work retains the hard understanding gate below',
    'No partial-understanding stack mutation, but no fixed ceremony',
    'Task memory/timeline is conditional on a material historical unknown',
    'Stack Atlas is conditional on an ownership/topology/dependency unknown or contradiction',
    'Never run both merely because the target is stack/MCP/infra',
    'use an independent supported evidence source rather than making the broken component certify its own repair',
    'Understanding one local file/service is not sufficient stack understanding when broader resources are in the blast radius'
)
foreach ($needle in $requiredAgents) {
    if (-not $agents.Contains($needle)) { throw "AGENTS.md missing conditional-memory/stack gate: $needle" }
}

foreach ($forbidden in @(
    'Every substantive worker task starts with task-scoped memory context',
    'even when the task appears new',
    'Task memory is part of work startup, not optional archaeology',
    'run both the task-scoped memory `context` and `timeline` reads',
    'targeted task memory/timeline plus Stack Atlas/named live sources must establish'
)) {
    if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "shared policy retains universal memory ceremony: $forbidden" }
}

Write-Output 'WORKER_MEMORY_CONTEXT_RULE_PASS'
