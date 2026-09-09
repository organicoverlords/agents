$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

foreach ($doc in @($rules, $agents)) {
    if ($doc -notmatch '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$') { throw 'shared contract version missing' }
}

$requiredRules = @(
    'Task memory is part of work startup, not optional archaeology',
    'memory_bank.py context <query>',
    'even when the task appears new',
    'memory_bank.py timeline <query>',
    'This work-context read is distinct from bootstrap/live-swarm orientation',
    'Stack/MCP/infra understanding is a hard mutation gate',
    'run both the task-scoped memory `context` and `timeline` reads',
    'owner, entrypoint, dependents/resources, relevant current topology, recovery/rollback path, and relevant historical commits/incidents/lessons',
    'A worker that understands only the local component must not touch the stack'
)
foreach ($needle in $requiredRules) {
    if (-not $rules.Contains($needle)) { throw "RULES.md missing worker memory/stack gate: $needle" }
}

$requiredAgents = @(
    'Every substantive worker task starts with task-scoped memory context',
    'memory_bank.py context <query>',
    'even when the task appears new',
    'memory_bank.py timeline <query>',
    'worker work-context, not bootstrap expansion',
    'No partial-understanding stack mutation',
    'component owner, entrypoint, dependents/resources, current topology, recovery/rollback path, and relevant historical commits/incidents/lessons',
    'Understanding one local file/service is not sufficient stack understanding'
)
foreach ($needle in $requiredAgents) {
    if (-not $agents.Contains($needle)) { throw "AGENTS.md missing worker memory/stack gate: $needle" }
}

if ($rules -match 'memory_bank\.py (recent|recent-titles).*Before the first substantive') {
    throw 'worker startup regressed to broad/recent memory instead of task-scoped context'
}

Write-Output 'WORKER_MEMORY_CONTEXT_RULE_PASS'
