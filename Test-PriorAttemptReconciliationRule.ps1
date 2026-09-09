Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

foreach ($required in @(
    'Prior-attempt reconciliation is question-driven, not category-driven',
    'concrete unresolved historical question can change the next implementation/proof',
    'Start with the current conversation/task context and already-held WIP/checkpoints',
    'if they already establish the relevant prior attempt or correction, proceed without another lookup',
    'local repo/branch/commit evidence before remote GitHub when sufficient',
    'bounded task-scoped Vault memory/timeline only when repository/current-task evidence cannot answer the historical question',
    'Do not automatically query current issue/WIP, branch/commit history, and Vault merely because work is repeated, recovery, migration, replacement, or user-reported recurrence',
    'do not make the user supply old project names, issue numbers, transport names, or historical keywords',
    'Historical evidence is a prior, not current truth',
    'recurrence where the relevant prior failure is already known do not trigger history archaeology'
)) {
    if (-not $text.Contains($required)) { throw "prior-attempt reconciliation invariant missing: $required" }
}

foreach ($forbidden in @(
    'reconcile prior attempts once before the first new implementation or expensive proof',
    'materially historical, repeated/recurring, cross-project integration, migration, recovery, replacement, or user-reported recurrence work',
    'Reconcile the current issue/WIP and relevant owning-repo branch/commit history, then use bounded task-scoped Vault Timeline/lesson context',
    'scan all Vault history before every task',
    'ask the user for the old project name',
    'history is current truth'
)) {
    if ($text.Contains($forbidden)) { throw "unsafe prior-attempt rule present: $forbidden" }
}

[ordered]@{
    ok=$true
    task_derived=$true
    history_only_for_material_unknown=$true
    current_truth_still_required=$true
    routine_small_fix_fast_path=$true
} | ConvertTo-Json -Compress
