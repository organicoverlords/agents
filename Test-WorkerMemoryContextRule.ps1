$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

foreach ($doc in @($rules, $agents)) {
    if ($doc -notmatch '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$') { throw 'shared contract version missing' }
}

$requiredRules = @(
    'Task memory is conditional evidence, not a universal startup tax',
    'specific historical fact, prior decision, correction, failed approach, owner/path fact, or compatibility constraint that is materially unknown and can change the next action',
    'Task category alone',
    'does not trigger a memory lookup',
    'If the current conversation, already-held task context, current repo/runtime evidence, or a known prior checkpoint already contains the needed history, reuse it',
    'memory_bank.py context <query>',
    'Ordinary owner-known isolated work and recovery work with the relevant prior failure already established proceed without a memory round trip',
    'reuse it and do not query memory again',
    'memory_bank.py timeline <query>',
    'Stack/MCP/infra retains its separate evidence-sufficiency mutation gate',
    'Stack/MCP/infra understanding is an evidence-sufficiency mutation gate, not a subsystem-only lookup ritual',
    'Topology-first rule',
    'Use already-held current task evidence first',
    'do not require both memory reads merely because the target is stack/MCP/infra',
    'only then use targeted `find`/`lookup` for touched components',
    'Do not require memory plus Atlas when the required evidence fields are already established directly',
    'do not require that component to provide the evidence needed to authorize its own repair',
    'Understanding only one local file/service remains insufficient when the mutation can affect broader stack resources'
)
foreach ($needle in $requiredRules) {
    if ($rules.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "RULES.md missing conditional-memory/stack gate: $needle" }
}

$requiredAgents = @(
    'Task-scoped memory is conditional evidence, not startup ceremony',
    'specific historical unknown',
    'Task category alone',
    'does not trigger memory',
    'Reuse the current conversation/task context, current repo/runtime evidence, and known checkpoints first',
    'if they already establish the needed history, proceed without a memory round trip',
    'memory_bank.py context <query>',
    'never make memory/timeline a per-tool or per-subtask ritual',
    'memory_bank.py timeline <query>',
    'Stack/MCP/infra work retains the evidence-sufficiency gate below',
    'No partial-understanding stack mutation, but no fixed ceremony',
    'Task memory/timeline is conditional on a material historical unknown',
    'Stack Atlas is conditional on an ownership/topology/dependency unknown or contradiction',
    'Never run both merely because the target is stack/MCP/infra',
    'use an independent supported evidence source rather than making the broken component certify its own repair',
    'Understanding one local file/service is not sufficient stack understanding when broader resources are in the blast radius'
)
foreach ($needle in $requiredAgents) {
    if ($agents.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "AGENTS.md missing conditional-memory/stack gate: $needle" }
}

foreach ($forbidden in @(
    'Every substantive worker task starts with task-scoped memory context',
    'even when the task appears new',
    'Task memory is part of work startup, not optional archaeology',
    'Use `python C:\Users\Lauri\Desktop\vault\tools\memory_bank.py context <query>` once before substantive work only when the task is materially historical/repeated/recurring/cross-project/migration/recovery',
    'Before structural or architectural work, use the task memory/timeline result plus relevant branch/commit history',
    'Before substantive work, run `python C:\Users\Lauri\Desktop\vault\tools\memory_bank.py context <query>` once only when historical/repeated/recurring/cross-project/migration/recovery context may materially change the approach',
    'run both the task-scoped memory `context` and `timeline` reads',
    'targeted task memory/timeline plus Stack Atlas/named live sources must establish'
)) {
    if ($rules.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or $agents.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0) { throw "shared policy retains universal memory ceremony: $forbidden" }
}

Write-Output 'WORKER_MEMORY_CONTEXT_RULE_PASS'
