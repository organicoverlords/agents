Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$line = @($rules -split "`r?`n" | Where-Object { $_ -like '*stack_atlas.py live-swarm*' })
if ($line.Count -ne 1) { throw "expected exactly one live-swarm rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'mandatory fresh-chat bootstrap snapshot is the shared swarm starting point',
    'only as a refresh',
    'already-held bootstrap/live-swarm snapshot is stale or insufficient',
    'Do not turn it into per-turn, per-tool, or lane-selection ceremony',
    'This surface is observation only',
    'Reuse a fresh result and never poll it as a keepalive'
)) {
    if (-not $rule.Contains($required)) { throw "live-swarm rule missing invariant: $required" }
}
if ($rule.Contains('whenever current swarm/worktree/lease/timing context can materially change')) {
    throw 'live-swarm rule still requires broad whenever-use ceremony'
}
Write-Output 'PASS live-swarm is a stale-snapshot refresh, not routine per-turn ceremony'
