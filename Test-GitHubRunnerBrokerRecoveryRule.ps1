$ErrorActionPreference = 'Stop'
$wrapper = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1'))

foreach ($required in @(
    'function Get-RunnerWorkersForRoot',
    'function Get-CurrentLaunchLongBrokerBackoff',
    'function Get-CurrentLaunchRepeatedSessionConflict',
    'function Get-CurrentLaunchRepeatedCancellationStorm',
    '$brokerBackoffMinimumSeconds = 300',
    '$sessionConflictMinimumCount = 3',
    '$sessionConflictMinimumSpanSeconds = 45',
    '$sessionConflictMaximumAgeSeconds = 60',
    '$cancellationStormMinimumCount = 12',
    '$cancellationStormMinimumSpanSeconds = 5',
    '$cancellationStormMaximumAgeSeconds = 15',
    '$brokerSessionReleaseSeconds = 210',
    'if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }',
    'if ($workers.Count -gt 0) { continue }',
    'GITHUB_RUNNER_BROKER_BACKOFF_RECOVERY=',
    'GITHUB_RUNNER_SESSION_CONFLICT_RECOVERY=',
    'GITHUB_RUNNER_CANCELLATION_STORM_RECOVERY=',
    'GITHUB_RUNNER_BROKER_SESSION_RELEASE_WAIT=',
    'Start-Sleep -Seconds $brokerSessionReleaseSeconds',
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
$sessionPatternLine = @($wrapper -split "`r?`n" | Where-Object { $_ -match '^\s*\$sessionConflictPattern\s*=' })
if ($sessionPatternLine.Count -ne 1) { throw 'expected exactly one session conflict regex' }
$sessionPatternMatch = [regex]::Match($sessionPatternLine[0], "^\s*\`$sessionConflictPattern\s*=\s*'(?<pattern>.*)'\s*$")
if (-not $sessionPatternMatch.Success) { throw 'could not extract session conflict regex literal' }
$sessionSample = '[2026-09-08 22:05:51Z ERR  Terminal] WRITE ERROR: A session for this runner already exists.'
if (-not [regex]::Match($sessionSample, $sessionPatternMatch.Groups['pattern'].Value).Success) {
    throw 'session conflict regex does not match the real runner terminal log shape'
}
$cancellationPatternLine = @($wrapper -split "`r?`n" | Where-Object { $_ -match '^\s*\$cancellationPattern\s*=' })
if ($cancellationPatternLine.Count -ne 1) { throw 'expected exactly one cancellation storm regex' }
$cancellationPatternMatch = [regex]::Match($cancellationPatternLine[0], "^\s*\`$cancellationPattern\s*=\s*'(?<pattern>.*)'\s*$")
if (-not $cancellationPatternMatch.Success) { throw 'could not extract cancellation storm regex literal' }
$cancellationSample = '[2026-09-08 23:55:57Z INFO JobDispatcher] Job cancellation request 48cd0226-f84d-529b-bfd9-27e5cba8cb14 received, cancellation timeout 5 minutes.'
$cancellationSampleMatch = [regex]::Match($cancellationSample, $cancellationPatternMatch.Groups['pattern'].Value)
if (-not $cancellationSampleMatch.Success -or $cancellationSampleMatch.Groups['job'].Value -ne '48cd0226-f84d-529b-bfd9-27e5cba8cb14') {
    throw 'cancellation storm regex does not match the observed RR-KONE-02 runner log shape'
}
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseInput($wrapper, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count -gt 0) { throw "runner launcher parse failed: $($parseErrors[0].Message)" }
$detector = $ast.Find({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq 'Get-CurrentLaunchRepeatedSessionConflict'
}, $true)
if (-not $detector) { throw 'session conflict detector AST missing' }
Invoke-Expression $detector.Extent.Text
$cancellationDetector = $ast.Find({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq 'Get-CurrentLaunchRepeatedCancellationStorm'
}, $true)
if (-not $cancellationDetector) { throw 'cancellation storm detector AST missing' }
Invoke-Expression $cancellationDetector.Extent.Text

$fixtureRoot = Join-Path $env:TEMP ('github-runner-session-conflict-test-' + [guid]::NewGuid().ToString('N'))
$diagRoot = Join-Path $fixtureRoot '_diag'
New-Item -ItemType Directory -Path $diagRoot -Force | Out-Null
$logPath = Join-Path $diagRoot 'Runner_fixture.log'
function Write-SessionConflictFixture([datetime[]]$Times) {
    $lines = @($Times | ForEach-Object {
        '[{0}Z ERR  Terminal] WRITE ERROR: A session for this runner already exists.' -f $_.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
    })
    [IO.File]::WriteAllLines($logPath, $lines, [Text.UTF8Encoding]::new($false))
    (Get-Item -LiteralPath $logPath).LastWriteTimeUtc = [datetime]::UtcNow
}
try {
    $now = [datetime]::UtcNow
    Write-SessionConflictFixture @($now.AddSeconds(-55), $now.AddSeconds(-25), $now.AddSeconds(-1))
    $current = Get-CurrentLaunchRepeatedSessionConflict -Root $fixtureRoot -LaunchStartedUtc $now.AddSeconds(-60) -MinimumCount 3 -MinimumSpanSeconds 45 -MaximumAgeSeconds 60
    if (-not $current -or $current.Count -ne 3 -or $current.SpanSeconds -lt 45) {
        throw 'repeated current-launch session conflict was not detected'
    }

    Write-SessionConflictFixture @($now.AddSeconds(-1))
    $transient = Get-CurrentLaunchRepeatedSessionConflict -Root $fixtureRoot -LaunchStartedUtc $now.AddSeconds(-60) -MinimumCount 3 -MinimumSpanSeconds 45 -MaximumAgeSeconds 60
    if ($transient) { throw 'single transient session conflict must not trigger recovery' }

    Write-SessionConflictFixture @($now.AddSeconds(-180), $now.AddSeconds(-150), $now.AddSeconds(-120))
    $stale = Get-CurrentLaunchRepeatedSessionConflict -Root $fixtureRoot -LaunchStartedUtc $now.AddSeconds(-200) -MinimumCount 3 -MinimumSpanSeconds 45 -MaximumAgeSeconds 60
    if ($stale) { throw 'stale session conflict history must not trigger recovery' }

    Write-SessionConflictFixture @($now.AddSeconds(-80), $now.AddSeconds(-30), $now.AddSeconds(-1))
    $preLaunch = Get-CurrentLaunchRepeatedSessionConflict -Root $fixtureRoot -LaunchStartedUtc $now.AddSeconds(-40) -MinimumCount 3 -MinimumSpanSeconds 20 -MaximumAgeSeconds 60
    if ($preLaunch) { throw 'pre-launch session conflict must not count toward current launch recovery' }
}
finally {
    Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
}


$cancellationFixtureRoot = Join-Path $env:TEMP ('github-runner-cancellation-storm-test-' + [guid]::NewGuid().ToString('N'))
$cancellationDiagRoot = Join-Path $cancellationFixtureRoot '_diag'
New-Item -ItemType Directory -Path $cancellationDiagRoot -Force | Out-Null
$cancellationLogPath = Join-Path $cancellationDiagRoot 'Runner_fixture.log'
function Write-CancellationFixture([datetime[]]$Times, [string]$JobId = '48cd0226-f84d-529b-bfd9-27e5cba8cb14') {
    $lines = @($Times | ForEach-Object {
        '[{0}Z INFO JobDispatcher] Job cancellation request {1} received, cancellation timeout 5 minutes.' -f $_.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture), $JobId
    })
    [IO.File]::WriteAllLines($cancellationLogPath, $lines, [Text.UTF8Encoding]::new($false))
    (Get-Item -LiteralPath $cancellationLogPath).LastWriteTimeUtc = [datetime]::UtcNow
}
try {
    $now = [datetime]::UtcNow
    $stormTimes = @()
    foreach ($offset in @(-9,-9,-8,-7,-7,-6,-5,-4,-4,-3,-2,-1)) { $stormTimes += $now.AddSeconds($offset) }
    Write-CancellationFixture $stormTimes
    $storm = Get-CurrentLaunchRepeatedCancellationStorm -Root $cancellationFixtureRoot -LaunchStartedUtc $now.AddSeconds(-20) -MinimumCount 12 -MinimumSpanSeconds 5 -MaximumAgeSeconds 15
    if (-not $storm -or $storm.Count -ne 12 -or $storm.SpanSeconds -lt 5 -or $storm.JobId -ne '48cd0226-f84d-529b-bfd9-27e5cba8cb14') {
        throw 'repeated current-launch same-job cancellation storm was not detected'
    }

    Write-CancellationFixture @($now.AddSeconds(-4), $now.AddSeconds(-2), $now.AddSeconds(-1))
    $sparse = Get-CurrentLaunchRepeatedCancellationStorm -Root $cancellationFixtureRoot -LaunchStartedUtc $now.AddSeconds(-20) -MinimumCount 12 -MinimumSpanSeconds 5 -MaximumAgeSeconds 15
    if ($sparse) { throw 'sparse cancellation requests must not trigger recovery' }

    $staleTimes = @()
    foreach ($offset in @(-40,-39,-38,-37,-36,-35,-34,-33,-32,-31,-30,-29)) { $staleTimes += $now.AddSeconds($offset) }
    Write-CancellationFixture $staleTimes
    $staleCancellation = Get-CurrentLaunchRepeatedCancellationStorm -Root $cancellationFixtureRoot -LaunchStartedUtc $now.AddSeconds(-60) -MinimumCount 12 -MinimumSpanSeconds 5 -MaximumAgeSeconds 15
    if ($staleCancellation) { throw 'stale cancellation storm history must not trigger recovery' }

    $mixed = @()
    foreach ($offset in @(-9,-8,-7,-6,-5,-4)) { $mixed += $now.AddSeconds($offset) }
    Write-CancellationFixture $mixed '48cd0226-f84d-529b-bfd9-27e5cba8cb14'
    $other = @($mixed | ForEach-Object { '[{0}Z INFO JobDispatcher] Job cancellation request aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee received, cancellation timeout 5 minutes.' -f $_.ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture) })
    Add-Content -LiteralPath $cancellationLogPath -Value $other
    (Get-Item -LiteralPath $cancellationLogPath).LastWriteTimeUtc = [datetime]::UtcNow
    $mixedJobs = Get-CurrentLaunchRepeatedCancellationStorm -Root $cancellationFixtureRoot -LaunchStartedUtc $now.AddSeconds(-20) -MinimumCount 12 -MinimumSpanSeconds 5 -MaximumAgeSeconds 15
    if ($mixedJobs) { throw 'different job cancellation ids must not be combined into a storm' }
}
finally {
    Remove-Item -LiteralPath $cancellationFixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
}

if ($wrapper.Contains('taskkill /IM Runner.Listener.exe')) {
    throw 'runner broker recovery must stay scoped to the owned helper tree'
}

Write-Output 'PASS GitHub runner broker recovery rule'
