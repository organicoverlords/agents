$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $root 'Start-DesktopCommanderFallbackHidden.ps1'
$text = Get-Content -LiteralPath $launcher -Raw
foreach ($needle in @(
    '$startInfo.UseShellExecute = $false',
    '$startInfo.CreateNoWindow = $true',
    '$startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden',
    '@wonderwhy-er/desktop-commander@latest remote',
    '[switch]$ReadyProbe',
    '[switch]$TreeCleanupProbe',
    'JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE',
    '[DesktopCommanderProcessJob]::Assign',
    '[switch]$AllowInteractiveAuthorization',
    'DESKTOP_COMMANDER_PERSISTED_SESSION_REQUIRED',
    'EXPECTED_ACCOUNT_REQUIRED',
    'ACCOUNT_MISMATCH',
    'DESKTOP_COMMANDER_AUTH_ACCOUNT_REJECTED'
)) {
    if ($text.IndexOf($needle, [StringComparison]::Ordinal) -lt 0) {
        throw "DESKTOP_COMMANDER_HIDDEN_CONTRACT_MISSING=$needle"
    }
}

$output = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -Probe
if ($LASTEXITCODE -ne 0) {
    throw "DESKTOP_COMMANDER_HIDDEN_PROBE_EXIT=$LASTEXITCODE output=$output"
}
$result = $output | ConvertFrom-Json
if ($result.status -ne 'PASS') {
    throw "DESKTOP_COMMANDER_HIDDEN_PROBE_FAILED=$output"
}
if (@($result.visible_processes).Count -ne 0) {
    throw "DESKTOP_COMMANDER_HIDDEN_PROBE_VISIBLE=$output"
}
Write-Output "PASS DesktopCommanderFallback hidden probe processes=$($result.observed_process_count)"
$treeProbeOut = Join-Path ([IO.Path]::GetTempPath()) ("desktop-commander-tree-probe-" + [Guid]::NewGuid().ToString('N') + '.out')
$treeProbeErr = $treeProbeOut + '.err'
$treeProbe = $null
$treeChildPid = $null
try {
    $treeProbe = Start-Process powershell.exe -ArgumentList @(
        '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden',
        '-File', ('"' + $launcher + '"'), '-TreeCleanupProbe'
    ) -RedirectStandardOutput $treeProbeOut -RedirectStandardError $treeProbeErr -WindowStyle Hidden -PassThru

    $deadline = (Get-Date).AddSeconds(10)
    $probePayload = $null
    do {
        Start-Sleep -Milliseconds 100
        if (Test-Path -LiteralPath $treeProbeOut) {
            $rawContent = Get-Content -LiteralPath $treeProbeOut -Raw -ErrorAction SilentlyContinue
            $raw = if ($null -eq $rawContent) { '' } else { ([string]$rawContent).Trim() }
            if ($raw) {
                try { $probePayload = $raw | ConvertFrom-Json } catch {}
            }
        }
    } while (-not $probePayload -and (Get-Date) -lt $deadline -and -not $treeProbe.HasExited)

    if (-not $probePayload -or $probePayload.status -ne 'RUNNING') {
        $errText = if (Test-Path $treeProbeErr) { Get-Content -Raw $treeProbeErr } else { '' }
        throw "DESKTOP_COMMANDER_TREE_PROBE_START_FAILED out=$raw err=$errText exit=$($treeProbe.ExitCode)"
    }
    $treeChildPid = [int]$probePayload.child_pid
    if (-not (Get-Process -Id $treeChildPid -ErrorAction SilentlyContinue)) {
        throw "DESKTOP_COMMANDER_TREE_PROBE_CHILD_MISSING=$treeChildPid"
    }

    Stop-Process -Id $treeProbe.Id -Force
    $treeProbe.WaitForExit(5000) | Out-Null
    $childDeadline = (Get-Date).AddSeconds(5)
    do {
        Start-Sleep -Milliseconds 100
        $childAlive = Get-Process -Id $treeChildPid -ErrorAction SilentlyContinue
    } while ($childAlive -and (Get-Date) -lt $childDeadline)
    if ($childAlive) {
        throw "DESKTOP_COMMANDER_TREE_CLEANUP_FAILED child_pid=$treeChildPid"
    }
}
finally {
    if ($treeProbe -and -not $treeProbe.HasExited) { Stop-Process -Id $treeProbe.Id -Force -ErrorAction SilentlyContinue }
    if ($treeChildPid) { Stop-Process -Id $treeChildPid -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $treeProbeOut,$treeProbeErr -Force -ErrorAction SilentlyContinue
}
Write-Output "PASS DesktopCommanderFallback forced wrapper termination cleans child tree"


$originalProfile = $env:USERPROFILE
$tempProfile = Join-Path ([IO.Path]::GetTempPath()) ("desktop-commander-fallback-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempProfile -Force | Out-Null
try {
    $env:USERPROFILE = $tempProfile

    $notReadyOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -ReadyProbe 2>$null
    if ($LASTEXITCODE -ne 2) {
        throw "DESKTOP_COMMANDER_READY_PROBE_MISSING_SESSION_EXIT=$LASTEXITCODE output=$notReadyOutput"
    }
    $notReady = $notReadyOutput | ConvertFrom-Json
    if ($notReady.status -ne 'AUTHORIZATION_REQUIRED' -or $notReady.ready) {
        throw "DESKTOP_COMMANDER_READY_PROBE_MISSING_SESSION_BAD=$notReadyOutput"
    }

    $savedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $launchFailure = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher 2>&1
        $launchExit = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $savedErrorActionPreference
    }
    if ($launchExit -eq 0 -or ($launchFailure -join "`n") -notmatch 'DESKTOP_COMMANDER_PERSISTED_SESSION_REQUIRED') {
        throw "DESKTOP_COMMANDER_UNATTENDED_FAIL_CLOSED_MISSING output=$($launchFailure -join ' | ') exit=$launchExit"
    }

    $configDir = Join-Path $tempProfile '.desktop-commander-device'
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    $payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('{"email":"expected@example.com"}')).TrimEnd('=').Replace('+','-').Replace('/','_')
    $matchingToken = "e30.$payload.sig"
    [pscustomobject]@{
        deviceId = 'test-device'
        session = [pscustomobject]@{ access_token = $matchingToken; refresh_token = 'test-refresh' }
    } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $configDir 'device.json') -Encoding UTF8

    $missingExpectedOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -ReadyProbe 2>$null
    if ($LASTEXITCODE -ne 2 -or (($missingExpectedOutput | ConvertFrom-Json).status -ne 'EXPECTED_ACCOUNT_REQUIRED')) {
        throw "DESKTOP_COMMANDER_EXPECTED_ACCOUNT_FAIL_CLOSED_BAD=$missingExpectedOutput exit=$LASTEXITCODE"
    }

    Set-Content -LiteralPath (Join-Path $configDir 'expected-account.txt') -Value 'expected@example.com' -NoNewline -Encoding UTF8
    $readyOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -ReadyProbe
    if ($LASTEXITCODE -ne 0) {
        throw "DESKTOP_COMMANDER_READY_PROBE_AUTHORIZED_EXIT=$LASTEXITCODE output=$readyOutput"
    }
    $ready = $readyOutput | ConvertFrom-Json
    if ($ready.status -ne 'READY' -or -not $ready.ready -or -not $ready.has_refresh_token -or -not $ready.account_matches_expected) {
        throw "DESKTOP_COMMANDER_READY_PROBE_AUTHORIZED_BAD=$readyOutput"
    }

    $badPayload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('{"email":"wrong@example.com"}')).TrimEnd('=').Replace('+','-').Replace('/','_')
    $badToken = "e30.$badPayload.sig"
    [pscustomobject]@{
        deviceId = 'test-device'
        session = [pscustomobject]@{ access_token = $badToken; refresh_token = 'test-refresh' }
    } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $configDir 'device.json') -Encoding UTF8
    $mismatchOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -ReadyProbe 2>$null
    if ($LASTEXITCODE -ne 2) {
        throw "DESKTOP_COMMANDER_ACCOUNT_MISMATCH_EXIT=$LASTEXITCODE output=$mismatchOutput"
    }
    $mismatch = $mismatchOutput | ConvertFrom-Json
    if ($mismatch.status -ne 'ACCOUNT_MISMATCH' -or $mismatch.ready -or $mismatch.account_matches_expected) {
        throw "DESKTOP_COMMANDER_ACCOUNT_MISMATCH_NOT_REJECTED=$mismatchOutput"
    }
}
finally {
    $env:USERPROFILE = $originalProfile
    Remove-Item -LiteralPath $tempProfile -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "PASS DesktopCommanderFallback authorization readiness is noninteractive and fail-closed"
