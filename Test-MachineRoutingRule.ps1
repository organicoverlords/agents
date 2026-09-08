$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
foreach ($required in @(
    'Machine routing is cohort-owned, not worker-local.',
    'swarm_route.py route --work-id <stable-task-id>',
    'A route assignment is admission evidence, not execution evidence.',
    'swarm_exec.py --work-id <stable-task-id> --kind <portable|portable-light> --repo-root <repo> -- <command>',
    'do not continue the assigned command locally on Windows',
    'A route receipt alone does not satisfy the execution requirement.',
    'OMEN-first is the routing invariant.',
    'LowVRAM stays pinned to the main Windows PC',
    'Windows becomes the general fallback only when the routing cohort has fresh evidence that OMEN is unavailable or saturated',
    'The VPS remains the persistent edge/coordination node and may take cohort-approved portable-light overflow',
    'the Linux OMEN is the default build, runtime, test, and proof machine',
    'Keep a supervised hot P3 runtime available there for immediate proof use',
    'Normal filesystem/process/Git/GitHub work uses the machine route',
    'use local `git`/`gh` through MCPv3 and do not require a direct GitHub plugin',
    'A direct GitHub plugin/connector is likewise fallback-only for GitHub operations'
)) {
    if (-not ($agents.Contains($required) -or $rules.Contains($required))) { throw "machine routing invariant missing: $required" }
}
if (($rules -split "`r?`n" | Where-Object { $_ -match '^- Machine-route precedence: prefer MCPv3' }).Count -ne 1) { throw 'expected exactly one MCPv3 route precedence rule' }
if ($agents.Contains('Do not auto-start the heavyweight full `p3Editor` source build')) { throw 'stale OMEN anti-hot-runtime rule remains' }
Write-Output 'PASS machine routing rule'
