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
foreach ($required in @('the Linux OMEN is the default build, runtime, test, and proof machine','Keep a supervised hot P3 runtime available there for immediate proof use','Normal filesystem/process/Git/GitHub work uses the machine route','stack_atlas.py live-swarm','use local `git`/`gh` through MCPv4 and do not require a direct GitHub plugin','`DEGRADED` is fallback-worthy exactly like unavailability')) {
    if (-not ($agents.Contains($required) -or $rules.Contains($required))) { throw "execution routing invariant missing: $required" }
}
foreach ($required in @(
    'route eligibility precedes bootstrap',
    'do not call a route merely to obtain permission to decide whether that same route is usable',
    'skip that MCPv4 bootstrap read and use the next supported usable machine route',
    'If no usable route can obtain bootstrap',
    'prefer MCPv4 only while it is **usable for the requested operation**',
    'known-lightweight local operation that is normally sub-second remains above 5 seconds on one bounded confirmation',
    '`DEGRADED` is fallback-worthy exactly like unavailability',
    'do not keep work on MCPv4 merely because the service is alive',
    'Start-DesktopCommanderFallbackHidden.ps1 -ReadyProbe',
    '`READY` permits a connection attempt but does not itself prove route usability',
    'Missing/invalid persisted authorization is `UNAVAILABLE` for unattended recovery',
    'never poll it as a recovery loop'
)) { if (-not $rules.Contains($required)) { throw "degraded-route invariant missing: $required" } }
foreach ($required in @(
    'Fresh chats that materially need machine state follow the `RULES.md` **route-before-bootstrap** rule once',
    'Do not make MCPv4 bootstrap a prerequisite for deciding whether MCPv4 itself is usable',
    'Machine-route choice follows **operation usability**, not service existence',
    'A live listener or HTTP 200 does not pin work to MCPv4',
    '`-ReadyProbe` proves only persisted authorization readiness',
    'never trigger browser authorization during unattended fallback'
)) { if (-not $agents.Contains($required)) { throw "AGENTS degraded-route invariant missing: $required" } }
foreach ($forbidden in @(
    'When MCPv4 is genuinely unavailable, fall back',
    'before choosing machine routes or reporting machine state',
    'the first machine action is MCPv4 `read_output`',
    'a healthy route is a usable route'
)) { if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "stale route-liveness substitution remains: $forbidden" } }
if (($rules -split "`r?`n" | Where-Object { $_ -match '^- Machine-route precedence: prefer MCPv4' }).Count -ne 1) { throw 'expected exactly one MCPv4 route precedence rule' }
Write-Output 'PASS machine routing owner-bound rule'
