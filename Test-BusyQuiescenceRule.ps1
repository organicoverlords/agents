Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- At designated-orchestrator coordination checkpoints' })
if ($line.Count -ne 1) { throw "expected exactly one orchestrator Busy quiescence rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'before treating an exact Busy collision as active',
    'live MCP/runtime evidence',
    'no live child process',
    'at least 60 seconds',
    'actor/scope/claim timestamp',
    'BusyCoordinator CAS `recover`',
    'timestamp mismatch cancels recovery',
    'Unmapped or ambiguous claims keep ordinary lease/manual-recovery semantics',
    'Claim age alone is never stale proof',
    'MCP must remain transport/evidence rather than owning Busy lifecycle',
    'bounded demand-driven reconciliation, not a daemon, queue, scheduler, or second ownership store'
)) {
    if (-not $rule.Contains($required)) { throw "Busy quiescence rule missing invariant: $required" }
}
[ordered]@{
    ok = $true
    rule_count = 1
    owner = 'designated-orchestrator/shared-policy'
    mcp_role = 'transport-evidence-only'
    stale_threshold_seconds = 60
    recovery = 'exact-timestamp-cas'
    age_only_takeover = $false
    background_daemon = $false
} | ConvertTo-Json -Compress
