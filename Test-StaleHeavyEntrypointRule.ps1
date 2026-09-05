Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$agentsPath = Join-Path $PSScriptRoot 'AGENTS.md'
$text = [IO.File]::ReadAllText($agentsPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match 'A heavy wrapper is not current safety authority' })
if ($line.Count -ne 1) { throw "expected exactly one stale-heavy-entrypoint rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'filename is canonical',
    'current supported heavy entrypoint',
    'already-existing refreshed execution surface',
    'target another project/worktree root',
    'preserved target',
    'stale branch-local copy',
    'current safety ownership cannot be established',
    'fail closed',
    'never refresh, overwrite, or clean foreign/dirty target state'
)) {
    if ($rule -notlike "*$required*") { throw "stale-heavy-entrypoint rule missing invariant: $required" }
}
[ordered]@{ ok = $true; rule_count = 1; stale_copy_fails_closed = $true; dirty_target_preserved = $true } | ConvertTo-Json -Compress