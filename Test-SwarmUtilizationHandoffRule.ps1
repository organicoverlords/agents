Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))


foreach ($required in @(
    'workers can enter without user dispatch',
    'Checkpoint current coherent WIP',
    'another already-required non-overlapping contribution',
    'Query the blocked state again only when its answer can change the next action',
    'prefer an immutable commit for coherent WIP',
    'The collision blocks only that exact mutation'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing non-idle swarm invariant: $required" }
}

foreach ($required in @(
    'existing implementation/PRs/checkpoints',
    'multiple real non-overlapping contribution boundaries',
    'existing WIP, and immutable checkpoints',
    'branch plus immutable commit when available',
    'validation already performed',
    'next integration action',
    'Do not sit on CI, review, a Busy claim, a build slot, or another worker',
    'return to the in-flight result only when it can change the next action'
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing swarm checkpoint/handoff invariant: $required" }
}

foreach ($forbidden in @(
    'otherwise yield at a decision-ready blocker',
    'or yield at a decision-ready blocker'
)) {
    if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "blocking-idle wording remains: $forbidden" }
}

[ordered]@{
    ok = $true
    no_idle_on_local_contention = $true
    swarm_issue_parallel_boundaries = $true
    immutable_git_checkpoints = $true
    explicit_handoff_contract = $true
    ci_polling_not_work = $true
} | ConvertTo-Json -Compress
