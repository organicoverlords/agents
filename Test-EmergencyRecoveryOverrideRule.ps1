Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$agentsPath = Join-Path $PSScriptRoot 'AGENTS.md'
$emergencyPath = Join-Path $PSScriptRoot 'EMERGENCY_RECOVERY.md'
$rules = [IO.File]::ReadAllText($rulesPath)
$agents = [IO.File]::ReadAllText($agentsPath)
if (-not (Test-Path -LiteralPath $emergencyPath)) { throw 'missing dormant emergency recovery contract' }
$emergency = [IO.File]::ReadAllText($emergencyPath)
$pointer = @($rules -split "`r?`n" | Where-Object { $_ -match 'Emergency recovery is a dormant break-glass contract' })
if ($pointer.Count -ne 1) { throw "expected exactly one emergency recovery pointer; found $($pointer.Count)" }
foreach ($required in @('Do not read or apply','during ordinary work','Read it only when','active production/control-plane outage','recovery deadlock','minimum scope and duration','standing authorization','does not override platform security/safety controls')) {
    if (-not $pointer[0].Contains($required)) { throw "emergency pointer missing: $required" }
}
foreach ($forbidden in @('## Emergency trigger','## Anti-deadlock rule','## Minimum evidence before acting','## Coordination and locks','## Control-plane recovery','## Exit and reconciliation')) {
    if ($rules.Contains($forbidden)) { throw "full emergency procedure leaked into always-loaded RULES: $forbidden" }
}
foreach ($required in @(
    'This contract is dormant. Do not load, consult, or apply it during normal operation.',
    '## Emergency trigger',
    'explicitly invokes emergency or break-glass recovery',
    '## Recovery priority',
    'standing user authorization for the minimum live production/control-plane change',
    'A local gate returning BLOCK solely because global observation is incomplete',
    '## Anti-deadlock rule',
    'No recovery prerequisite may require evidence, approval, telemetry, coordination, or control exclusively from the same subsystem',
    'Unknown unrelated global state is not a reason to block a narrowly evidenced emergency repair.',
    '## Coordination and locks',
    'If the coordination service itself is degraded and cannot provide a claim',
    '## Control-plane recovery',
    'Prefer, in order: reversible reroute/failover',
    '## Boundaries that are not suspended',
    'does not override platform security or safety controls',
    '## Exit and reconciliation',
    'When this contract is active and conflicts with another local shared operational rule'
)) {
    if (-not $emergency.Contains($required)) { throw "emergency contract missing: $required" }
}
$versionPattern = '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$'
$rulesMatch = [regex]::Match($rules, $versionPattern)
$agentsMatch = [regex]::Match($agents, $versionPattern)
if (-not $rulesMatch.Success -or -not $agentsMatch.Success) { throw 'shared contract version missing' }
if ($rulesMatch.Groups[1].Value -ne $agentsMatch.Groups[1].Value) { throw 'shared contract versions are incoherent' }
[ordered]@{ok=$true; dormant=$true; trigger_pointer=$true; anti_deadlock=$true; local_recovery_priority=$true; external_security_boundaries_preserved=$true} | ConvertTo-Json -Compress
