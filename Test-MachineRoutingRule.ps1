$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
foreach ($required in @(
    'OMEN UE build routing: default C++ validation to the Linux OMEN single-file UBT lane',
    'Do not auto-start the heavyweight full `p3Editor` source build',
    'The HP OMEN Linux node is the preferred execution surface for portable heavy build, test, analysis, render, dependency-hydration',
    'LowVRAM is explicitly pinned to the main Windows PC',
    'Normal filesystem/process/Git/GitHub work uses the machine route',
    'use local `git`/`gh` through MCPv3 and do not require a direct GitHub plugin',
    'A direct GitHub plugin/connector is likewise fallback-only for GitHub operations'
)) {
    if (-not ($agents.Contains($required) -or $rules.Contains($required))) { throw "machine routing invariant missing: $required" }
}
if (($rules -split "`r?`n" | Where-Object { $_ -match '^- Machine-route precedence: prefer MCPv3' }).Count -ne 1) { throw 'expected exactly one MCPv3 route precedence rule' }
Write-Output 'PASS machine routing rule'
