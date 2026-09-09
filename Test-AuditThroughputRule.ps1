Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)

$pollLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive' })
if ($pollLine.Count -ne 1) { throw "expected exactly one anti-polling rule; found $($pollLine.Count)" }
foreach ($required in @(
    'Query external or shared state only when its answer can change the next action or validate the requested result',
    'reuse the returned state until there is concrete reason it may have changed',
    'do not issue repeated unchanged checks',
    'smallest bounded read needed to collect its result'
)) {
    if (-not $pollLine[0].Contains($required)) { throw "anti-polling rule missing invariant: $required" }
}

$foreignLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*FOREIGN IN-FLIGHT WORK IS OPAQUE\.\*\*' })
if ($foreignLine.Count -ne 1) { throw "expected exactly one foreign-work opacity rule; found $($foreignLine.Count)" }
foreach ($required in @(
    'do not inspect that work''s child process tree, UBT/compiler action counts, log tail, resource usage, or intermediate progress',
    'do not narrate `still running`, `healthy`, `N/M actions`, or equivalent progress',
    'submit once and let that owner serialize',
    'do not pre-watch capacity or wait for the incumbent to exit before submitting',
    'external swarm workers must not duplicate it'
)) {
    if (-not $foreignLine[0].Contains($required)) { throw "foreign-work opacity rule missing invariant: $required" }
}

$ownedLongLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- For owned long-running builds, CI watches, renders, tests, and similar processes,' })
if ($ownedLongLine.Count -ne 1) { throw "expected exactly one owned long-running rule; found $($ownedLongLine.Count)" }
if ($text.Contains('observable owner/progress')) { throw 'scope rule must not invite progress observation of serialized blockers' }
foreach ($required in @(
    'External agent reads are for terminal-result collection or one anomaly diagnosis, not progress observation',
    'do not tail logs, inspect process trees, count compiler/actions, or sample resource usage merely to report that owned work is advancing',
    'let the owning wrapper supervise ordinary progress internally'
)) {
    if (-not $ownedLongLine[0].Contains($required)) { throw "owned long-running rule missing invariant: $required" }
}

$latencyLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- Classify latency by operation semantics' })
if ($latencyLine.Count -ne 1) { throw "expected exactly one latency-classification rule; found $($latencyLine.Count)" }
foreach ($required in @(
    'requested wait/poll windows',
    'actual child-command runtime',
    'unexplained tool, transport, or backend delay',
    'Never repair infrastructure from aggregate duration alone'
)) {
    if (-not $latencyLine[0].Contains($required)) { throw "latency rule missing invariant: $required" }
}

$outputLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- Keep audit/research discovery output bounded:' })
if ($outputLine.Count -ne 1) { throw "expected exactly one bounded audit-output rule; found $($outputLine.Count)" }
foreach ($required in @(
    'targeted queries or aggregate summaries',
    'transport or receipt retention ceilings',
    'bounded/truncated output',
    'treat it as incomplete evidence',
    'narrow the query or fetch the specific continuation needed',
    'do not silently promote bounded output to complete evidence'
)) {
    if (-not $outputLine[0].Contains($required)) { throw "bounded audit-output rule missing invariant: $required" }
}

[ordered]@{
    ok = $true
    unchanged_polling_forbidden = $true
    foreign_build_progress_observation_forbidden = $true
    canonical_queue_submit_once = $true
    owned_progress_sampling_forbidden = $true
    wait_aware_latency = $true
    bounded_output_is_incomplete = $true
} | ConvertTo-Json -Compress
