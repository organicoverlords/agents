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
    '[switch]$AllowInteractiveAuthorization',
    'DESKTOP_COMMANDER_PERSISTED_SESSION_REQUIRED'
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
    [pscustomobject]@{
        deviceId = 'test-device'
        session = [pscustomobject]@{ access_token = 'test-access'; refresh_token = 'test-refresh' }
    } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $configDir 'device.json') -Encoding UTF8

    $readyOutput = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -ReadyProbe
    if ($LASTEXITCODE -ne 0) {
        throw "DESKTOP_COMMANDER_READY_PROBE_AUTHORIZED_EXIT=$LASTEXITCODE output=$readyOutput"
    }
    $ready = $readyOutput | ConvertFrom-Json
    if ($ready.status -ne 'READY' -or -not $ready.ready -or -not $ready.has_refresh_token) {
        throw "DESKTOP_COMMANDER_READY_PROBE_AUTHORIZED_BAD=$readyOutput"
    }
}
finally {
    $env:USERPROFILE = $originalProfile
    Remove-Item -LiteralPath $tempProfile -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "PASS DesktopCommanderFallback authorization readiness is noninteractive and fail-closed"
