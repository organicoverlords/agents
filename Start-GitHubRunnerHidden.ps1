[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$RunnerRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RunnerRoot).Path
$commandProcessor = $env:ComSpec
if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
    $commandProcessor = Join-Path ([Environment]::SystemDirectory) 'cmd.exe'
}
if (-not (Test-Path -LiteralPath $commandProcessor -PathType Leaf)) {
    throw "GITHUB_RUNNER_COMMAND_PROCESSOR_MISSING=$commandProcessor"
}
$taskKill = Join-Path ([Environment]::SystemDirectory) 'taskkill.exe'
if (-not (Test-Path -LiteralPath $taskKill -PathType Leaf)) {
    throw "GITHUB_RUNNER_TASKKILL_MISSING=$taskKill"
}

function Test-CommandLineContains {
    param(
        [AllowNull()]
        [string]$CommandLine,
        [Parameter(Mandatory)]
        [string]$Needle
    )
    return (-not [string]::IsNullOrWhiteSpace($CommandLine)) -and
        ($CommandLine.IndexOf($Needle, [StringComparison]::OrdinalIgnoreCase) -ge 0)
}

function Get-RunnerListenersForRoot {
    param([Parameter(Mandatory)][string]$Root)
    return @(
        Get-CimInstance Win32_Process -Filter "Name='Runner.Listener.exe'" -ErrorAction SilentlyContinue |
            Where-Object { Test-CommandLineContains -CommandLine $_.CommandLine -Needle $Root }
    )
}

function Get-RunnerWorkersForRoot {
    param([Parameter(Mandatory)][string]$Root)
    return @(
        Get-CimInstance Win32_Process -Filter "Name='Runner.Worker.exe'" -ErrorAction SilentlyContinue |
            Where-Object { Test-CommandLineContains -CommandLine $_.CommandLine -Needle $Root }
    )
}

function Get-CurrentLaunchLongBrokerBackoff {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumSeconds
    )
    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $pattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z WARN BrokerServer\] Back off (?<seconds>[\d,]+) seconds before next retry\.'
    foreach ($log in @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 4)) {
        foreach ($line in @(Get-Content -LiteralPath $log.FullName -Tail 200 -ErrorAction SilentlyContinue)) {
            $match = [regex]::Match($line, $pattern)
            if (-not $match.Success) { continue }
            $observedAt = [datetime]::ParseExact(
                $match.Groups['observed'].Value,
                'yyyy-MM-dd HH:mm:ss',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
            )
            if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }
            $seconds = [int]($match.Groups['seconds'].Value.Replace(',', ''))
            if ($seconds -lt $MinimumSeconds) { continue }
            return [pscustomobject]@{
                ObservedAtUtc = $observedAt
                Seconds = $seconds
                LogPath = $log.FullName
            }
        }
    }
    return $null
}

function Test-ListenerHasLiveLauncher {
    param(
        [Parameter(Mandatory)]$Listener,
        [Parameter(Mandatory)][string]$Root
    )
    $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($Listener.ParentProcessId)" -ErrorAction SilentlyContinue
    if (-not $parent) { return $false }
    $launcher = Get-CimInstance Win32_Process -Filter "ProcessId=$($parent.ParentProcessId)" -ErrorAction SilentlyContinue
    if (-not $launcher) { return $false }
    return (Test-CommandLineContains -CommandLine $launcher.CommandLine -Needle 'Start-GitHubRunnerHidden.ps1') -and
        (Test-CommandLineContains -CommandLine $launcher.CommandLine -Needle $Root)
}

function Remove-OrphanedRunnerListeners {
    param([Parameter(Mandatory)][string]$Root)
    foreach ($listener in @(Get-RunnerListenersForRoot -Root $Root)) {
        $worker = Get-CimInstance Win32_Process -Filter "Name='Runner.Worker.exe' AND ParentProcessId=$($listener.ProcessId)" -ErrorAction SilentlyContinue
        if ($worker) {
            throw "GITHUB_RUNNER_EXISTING_ACTIVE_WORKER=root:$Root|listener_pid:$($listener.ProcessId)|worker_pid:$($worker.ProcessId)"
        }
        if (Test-ListenerHasLiveLauncher -Listener $listener -Root $Root) {
            throw "GITHUB_RUNNER_LAUNCHER_ALREADY_ACTIVE=root:$Root|listener_pid:$($listener.ProcessId)"
        }

        & $taskKill /PID ([string]$listener.ProcessId) /T /F | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "GITHUB_RUNNER_ORPHAN_CLEANUP_FAILED=root:$Root|listener_pid:$($listener.ProcessId)|exit:$LASTEXITCODE"
        }
        Start-Sleep -Milliseconds 200
        if (Get-Process -Id $listener.ProcessId -ErrorAction SilentlyContinue) {
            throw "GITHUB_RUNNER_ORPHAN_SURVIVED=root:$Root|listener_pid:$($listener.ProcessId)"
        }
    }
}

$helperTemplate = Join-Path $root 'run-helper.cmd.template'
$helperCommand = Join-Path $root 'run-helper.cmd'
if (-not (Test-Path -LiteralPath $helperTemplate -PathType Leaf)) {
    throw "GITHUB_RUNNER_HELPER_TEMPLATE_MISSING=$helperTemplate"
}

Get-ChildItem -LiteralPath $root -File | Unblock-File -ErrorAction SilentlyContinue

while ($true) {
    Remove-OrphanedRunnerListeners -Root $root
    Copy-Item -LiteralPath $helperTemplate -Destination $helperCommand -Force

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $commandProcessor
    $startInfo.Arguments = '/d /s /c ""{0}""' -f $helperCommand
    $startInfo.WorkingDirectory = $root
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $false
    $startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $launchStartedUtc = [datetime]::UtcNow
    if (-not $process.Start()) {
        throw "GITHUB_RUNNER_HIDDEN_START_FAILED=$root"
    }

    $brokerBackoffMinimumSeconds = 300
    while (-not $process.WaitForExit(1000)) {
        $backoff = Get-CurrentLaunchLongBrokerBackoff -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumSeconds $brokerBackoffMinimumSeconds
        if ($null -eq $backoff) { continue }
        $workers = @(Get-RunnerWorkersForRoot -Root $root)
        if ($workers.Count -gt 0) { continue }

        Write-Warning "GITHUB_RUNNER_BROKER_BACKOFF_RECOVERY=root:$root|seconds:$($backoff.Seconds)|log:$($backoff.LogPath)|helper_pid:$($process.Id)"
        & $taskKill /PID ([string]$process.Id) /T /F | Out-Null
        if ($LASTEXITCODE -ne 0 -and -not $process.HasExited) {
            throw "GITHUB_RUNNER_BROKER_RECYCLE_FAILED=root:$root|helper_pid:$($process.Id)|exit:$LASTEXITCODE"
        }
        if (-not $process.WaitForExit(10000)) {
            throw "GITHUB_RUNNER_BROKER_RECYCLE_TIMEOUT=root:$root|helper_pid:$($process.Id)"
        }
        break
    }
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE -eq '1' -and $exitCode -eq 7) {
        exit $exitCode
    }

    # This launcher owns a persistent runner. Any helper exit other than the explicit
    # version-deprecated handoff is a recoverable loss of service, including exit 0.
    Write-Warning "GITHUB_RUNNER_HELPER_EXITED=root:$root|exit:$exitCode|restart_seconds:2"
    Start-Sleep -Seconds 2
    continue
}
