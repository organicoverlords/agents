$ErrorActionPreference = 'Stop'
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$routingPath = 'C:\Users\Lauri\Desktop\vault\04 Operating Contracts\swarm-routing-cohort.md'
$routing = [IO.File]::ReadAllText($routingPath)
foreach ($required in @(
    'Machine routing is cohort-owned, not worker-local.',
    'swarm-routing-cohort.md',
    'reuse its assignment',
    'admission rather than execution evidence',
    'swarm_exec.py',
    'OMEN-first is the routing invariant.',
    'never independently reroute or duplicate the workload across machines'
)) { if (-not $rules.Contains($required)) { throw "global routing invariant missing: $required" } }
foreach ($required in @(
    'swarm_route.py route --work-id <stable-task-id>',
    'swarm_exec.py --work-id <stable-task-id>',
    'LowVRAM',
    'Windows is the general fallback only after the cohort has fresh evidence that OMEN is unavailable or saturated',
    'portable-light',
    'p3-vps-light',
    'A valid assignment is sticky for its `work-id`',
    'Release the assignment when the work leaves that machine',
    'machine admission only'
)) { if (-not $routing.Contains($required)) { throw "routing owner contract missing mechanic: $required" } }
foreach ($required in @('the Linux OMEN is the default build, runtime, test, and proof machine','Keep a supervised hot P3 runtime available there for immediate proof use','Normal filesystem/process/Git/GitHub work uses the machine route','stack_atlas.py live-swarm','use local `git`/`gh` through MCPv4 and do not require a direct GitHub plugin','When MCPv4 is genuinely unavailable, fall back in order to MCPv3')) {
    if (-not ($agents.Contains($required) -or $rules.Contains($required))) { throw "execution routing invariant missing: $required" }
}
if (($rules -split "`r?`n" | Where-Object { $_ -match '^- Machine-route precedence: prefer MCPv4' }).Count -ne 1) { throw 'expected exactly one MCPv4 route precedence rule' }
Write-Output 'PASS machine routing owner-bound rule'
