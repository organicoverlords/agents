$ErrorActionPreference = 'Stop'
$wrapper = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1'))

foreach ($required in @(
    'function Get-RunnerWorkersForRoot',
    'function Get-CurrentLaunchLongBrokerBackoff',
    '$brokerBackoffMinimumSeconds = 300',
    'if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }',
    'if ($workers.Count -gt 0) { continue }',
    'GITHUB_RUNNER_BROKER_BACKOFF_RECOVERY=',
    '$taskKill /PID ([string]$process.Id) /T /F',
    'GITHUB_RUNNER_BROKER_RECYCLE_FAILED=',
    'GITHUB_RUNNER_BROKER_RECYCLE_TIMEOUT='
)) {
    if (-not $wrapper.Contains($required)) { throw "runner broker recovery invariant missing: $required" }
}

$patternLine = @($wrapper -split "`r?`n" | Where-Object { $_ -match '^\s*\$pattern\s*=' })
if ($patternLine.Count -ne 1) { throw 'expected exactly one broker backoff regex' }
$patternMatch = [regex]::Match($patternLine[0], "^\s*\`$pattern\s*=\s*'(?<pattern>.*)'\s*$")
if (-not $patternMatch.Success) { throw 'could not extract broker backoff regex literal' }
$sample = '[2026-09-08 03:17:42Z WARN BrokerServer] Back off 12,261 seconds before next retry. 4 attempt left.'
$sampleMatch = [regex]::Match($sample, $patternMatch.Groups['pattern'].Value)
if (-not $sampleMatch.Success) { throw 'broker backoff regex does not match a real runner log shape' }
if ([int]($sampleMatch.Groups['seconds'].Value.Replace(',', '')) -ne 12261) { throw 'broker backoff seconds parse changed' }
if ($wrapper.Contains('taskkill /IM Runner.Listener.exe')) {
    throw 'runner broker recovery must stay scoped to the owned helper tree'
}

Write-Output 'PASS GitHub runner broker recovery rule'
