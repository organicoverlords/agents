Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)

$goLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- On a `go` turn,' })
if ($goLine.Count -ne 1) { throw "expected exactly one go continuation rule; found $($goLine.Count)" }
foreach ($required in @(
    'finite canonical retry-after',
    'Honor the emitted interval',
    'do not re-probe the same unchanged condition before that retry-after elapses',
    'new discriminating evidence materially changes the state'
)) {
    if (-not $goLine[0].Contains($required)) { throw "go retry rule missing invariant: $required" }
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
    retry_hint_respected = $true
    wait_aware_latency = $true
    bounded_output_is_incomplete = $true
} | ConvertTo-Json -Compress
