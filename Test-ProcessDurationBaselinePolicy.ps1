Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($required in @(
    '%LOCALAPPDATA%\VaultProcessDurationBaselines\process-duration-baselines.json',
    'must not use a canonical Git checkout as their default output',
    'explicit artifact intent and an isolated mutation surface')) {
    if (-not $rules.Contains($required)) { throw "RULES missing runtime-state invariant: $required" }
}
if ($rules.Contains('vault\02 Evidence\process-duration-baselines.json')) {
    throw 'RULES still points duration refresh at tracked Vault evidence'
}
if (-not $agents.Contains('Canonical serving/main checkouts are not runtime-state sinks')) {
    throw 'AGENTS missing canonical-checkout runtime-state invariant'
}
Write-Output 'PASS process duration baseline runtime-state policy'
