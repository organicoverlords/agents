Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))

foreach ($required in @(
    'materially historical, repeated/recurring, cross-project integration, migration, recovery, replacement, or user-reported recurrence work',
    'reconcile prior attempts once before the first new implementation or expensive proof',
    'Derive the lookup from the current task and known repo/subsystem',
    'do not make the user supply old project names, issue numbers, transport names, or historical keywords',
    'current issue/WIP and relevant owning-repo branch/commit history',
    'bounded task-scoped Vault Timeline/lesson context',
    'Historical evidence is a prior, not current truth',
    'Routine small isolated edits do not trigger broad history archaeology'
)) {
    if (-not $text.Contains($required)) { throw "prior-attempt reconciliation invariant missing: $required" }
}

foreach ($forbidden in @(
    'scan all Vault history before every task',
    'ask the user for the old project name',
    'history is current truth'
)) {
    if ($text.Contains($forbidden)) { throw "unsafe prior-attempt rule present: $forbidden" }
}

[ordered]@{
    ok=$true
    task_derived=$true
    prior_attempts_before_new_implementation=$true
    current_truth_still_required=$true
    routine_small_fix_fast_path=$true
} | ConvertTo-Json -Compress
