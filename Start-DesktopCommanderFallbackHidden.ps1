[CmdletBinding()]
param(
    [switch]$Probe,
    [switch]$ReadyProbe,
    [switch]$AllowInteractiveAuthorization
)

$ErrorActionPreference = 'Stop'

function Get-DesktopCommanderAuthorizationState {
    $configPath = Join-Path $env:USERPROFILE '.desktop-commander-device\device.json'
    $state = [ordered]@{
        status = 'AUTHORIZATION_REQUIRED'
        ready = $false
        config_path = $configPath
        has_device_id = $false
        has_session = $false
        has_access_token = $false
        has_refresh_token = $false
    }
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return [pscustomobject]$state
    }
    try {
        $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    }
    catch {
        $state.status = 'INVALID_PERSISTED_CONFIG'
        return [pscustomobject]$state
    }
    $state.has_device_id = -not [string]::IsNullOrWhiteSpace([string]$config.deviceId)
    $state.has_session = $null -ne $config.session
    $state.has_access_token = $state.has_session -and -not [string]::IsNullOrWhiteSpace([string]$config.session.access_token)
    $state.has_refresh_token = $state.has_session -and -not [string]::IsNullOrWhiteSpace([string]$config.session.refresh_token)
    $state.ready = $state.has_device_id -and $state.has_access_token -and $state.has_refresh_token
    if ($state.ready) { $state.status = 'READY' }
    return [pscustomobject]$state
}

if ($ReadyProbe) {
    $authorization = Get-DesktopCommanderAuthorizationState
    $authorization | ConvertTo-Json -Compress
    if ($authorization.ready) { exit 0 }
    exit 2
}
$commandProcessor = $env:ComSpec
if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
    $commandProcessor = Join-Path ([Environment]::SystemDirectory) 'cmd.exe'
}
if (-not (Test-Path -LiteralPath $commandProcessor -PathType Leaf)) {
    throw "DESKTOP_COMMANDER_COMMAND_PROCESSOR_MISSING=$commandProcessor"
}

function Start-HiddenChild {
    param(
        [Parameter(Mandatory)][string]$FileName,
        [Parameter(Mandatory)][string]$Arguments
    )
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FileName
    $startInfo.Arguments = $Arguments
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw "DESKTOP_COMMANDER_HIDDEN_START_FAILED=$FileName"
    }
    return $process
}

function Get-DescendantProcessIds {
    param([Parameter(Mandatory)][int]$ParentPid)
    $result = [System.Collections.Generic.List[int]]::new()
    $queue = [System.Collections.Generic.Queue[int]]::new()
    $queue.Enqueue($ParentPid)
    while ($queue.Count -gt 0) {
        $parent = $queue.Dequeue()
        foreach ($child in @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$parent" -ErrorAction SilentlyContinue)) {
            $childPid = [int]$child.ProcessId
            if (-not $result.Contains($childPid)) {
                $result.Add($childPid)
                $queue.Enqueue($childPid)
            }
        }
    }
    return @($result)
}

if ($Probe) {
    $probeProcess = Start-HiddenChild -FileName $commandProcessor -Arguments '/d /s /c "ping -n 4 127.0.0.1 >nul"'
    Start-Sleep -Milliseconds 300
    $ids = @($probeProcess.Id) + @(Get-DescendantProcessIds -ParentPid $probeProcess.Id)
    $visible = @()
    foreach ($processId in $ids) {
        $live = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($live -and $live.MainWindowHandle -ne 0) {
            $visible += [pscustomobject]@{ pid = $processId; name = $live.ProcessName; handle = $live.MainWindowHandle }
        }
    }
    $probeProcess.WaitForExit()
    [pscustomobject]@{
        status = if ($visible.Count -eq 0) { 'PASS' } else { 'FAIL' }
        root_pid = $probeProcess.Id
        observed_process_count = $ids.Count
        visible_processes = $visible
    } | ConvertTo-Json -Compress
    if ($visible.Count -ne 0) { exit 1 }
    exit $probeProcess.ExitCode
}

$authorization = Get-DesktopCommanderAuthorizationState
if (-not $authorization.ready -and -not $AllowInteractiveAuthorization) {
    throw "DESKTOP_COMMANDER_PERSISTED_SESSION_REQUIRED=$($authorization.config_path) status=$($authorization.status)"
}

$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$escapedNpx = $npx.Replace('"', '""')
$child = Start-HiddenChild -FileName $commandProcessor -Arguments ('/d /s /c ""{0}" --yes @wonderwhy-er/desktop-commander@latest remote"' -f $escapedNpx)
$child.WaitForExit()
exit $child.ExitCode
