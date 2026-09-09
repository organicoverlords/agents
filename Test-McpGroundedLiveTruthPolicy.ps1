Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($required in @(
    '**LIVE/CURRENT WORK TRUTH IS MCP-GROUNDED.**',
    'fresh MCP activity evidence first',
    'local repo/worktree/runtime state',
    'static local state cannot establish liveness by itself',
    'they cannot establish live/current truth by themselves',
    'If MCP activity coverage for the relevant route is unavailable, stale, or insufficient, report `UNKNOWN`'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing live-truth invariant: $required" }
}
foreach ($required in @(
    'For **live/current work truth**',
    'fresh MCP activity evidence is mandatory first',
    'relevant local repo/worktree/runtime state is mandatory supporting evidence',
    'never substitute for MCP-grounded liveness',
    'the live/current proposition is `UNKNOWN`'
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing live-truth invariant: $required" }
}
Write-Output 'PASS live/current work truth is MCP-grounded with required local-state corroboration'
