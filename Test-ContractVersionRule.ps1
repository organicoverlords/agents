Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SharedContractVersion {
    param([Parameter(Mandatory=$true)][string]$Path)
    $text = [IO.File]::ReadAllText($Path)
    $matches = [regex]::Matches($text, '(?m)^Shared contract version:\s*([1-9][0-9]*)\s*$')
    if ($matches.Count -ne 1) { throw "expected exactly one shared contract version in $Path; found $($matches.Count)" }
    return [int]$matches[0].Groups[1].Value
}

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$agentsPath = Join-Path $PSScriptRoot 'AGENTS.md'
$rulesVersion = Get-SharedContractVersion $rulesPath
$agentsVersion = Get-SharedContractVersion $agentsPath
if ($rulesVersion -ne $agentsVersion) { throw "shared contract version mismatch: RULES=$rulesVersion AGENTS=$agentsVersion" }

$agents = [IO.File]::ReadAllText($agentsPath)
foreach ($required in @(
    'same monotonic `Shared contract version: N`',
    'Any shared-contract change to either file increments both version headers in the same patch',
    'bootstrap must report that exact coherent version'
)) { if (-not $agents.Contains($required)) { throw "contract version maintenance rule missing: $required" } }

[ordered]@{ok=$true; shared_contract_version=$rulesVersion; coherent=$true} | ConvertTo-Json -Compress
