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
    if (-not $process.Start()) {
        throw "GITHUB_RUNNER_HIDDEN_START_FAILED=$root"
    }
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    if ($exitCode -eq 1) {
        continue
    }
    if ($env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE -eq '1' -and $exitCode -eq 7) {
        exit $exitCode
    }
    exit 0
}
