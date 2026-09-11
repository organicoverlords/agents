[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RunnerRoot,

    [ValidateSet('Status','Install','On','Off','Start','Stop','AutostartOn','AutostartOff','Uninstall')]
    [string]$Action = 'Status',

    [string]$TaskName,

    [ValidateSet('On','Off')]
    [string]$Autostart = 'On'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-NormalizedPath([string]$Path) {
    return [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($Path)).TrimEnd('\\')
}

function Get-RunnerIdentity([string]$Root, [string]$ExplicitTaskName) {
    $normalizedRoot = Get-NormalizedPath $Root
    if (-not [string]::IsNullOrWhiteSpace($ExplicitTaskName)) {
        return [pscustomobject]@{ Root = $normalizedRoot; TaskName = $ExplicitTaskName }
    }
    $runnerConfig = Join-Path $normalizedRoot '.runner'
    if (-not (Test-Path -LiteralPath $runnerConfig -PathType Leaf)) {
        throw "GITHUB_RUNNER_IDENTITY_MISSING=root:$normalizedRoot|hint:pass -TaskName when the runner registration is unavailable"
    }
    $config = Get-Content -LiteralPath $runnerConfig -Raw | ConvertFrom-Json
    $agentName = [string]$config.agentName
    if ([string]::IsNullOrWhiteSpace($agentName)) {
        throw "GITHUB_RUNNER_AGENT_NAME_MISSING=$runnerConfig"
    }
    return [pscustomobject]@{ Root = $normalizedRoot; TaskName = "GitHub-Runner-$agentName" }
}

function Assert-RunnerInstallable([string]$Root) {
    foreach ($required in @('.runner','run-helper.cmd.template','bin\\Runner.Listener.exe')) {
        $path = Join-Path $Root $required
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "GITHUB_RUNNER_REQUIRED_PATH_MISSING=root:$Root|required:$required"
        }
    }
    $launcher = Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1'
    if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
        throw "GITHUB_RUNNER_LAUNCHER_MISSING=$launcher"
    }
}

function Get-ExpectedTaskAction([string]$Root) {
    $launcher = Get-NormalizedPath (Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1')
    $powershell = Join-Path ([Environment]::SystemDirectory) 'WindowsPowerShell\\v1.0\\powershell.exe'
    if (-not (Test-Path -LiteralPath $powershell -PathType Leaf)) {
        throw "GITHUB_RUNNER_POWERSHELL_MISSING=$powershell"
    }
    $arguments = '-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -RunnerRoot "{1}"' -f $launcher, $Root
    return [pscustomobject]@{ Execute = $powershell; Arguments = $arguments; Launcher = $launcher }
}

function Test-TaskAutostart($Task) {
    foreach ($trigger in @($Task.Triggers)) {
        if ($null -eq $trigger) { continue }
        if ($trigger.CimClass.CimClassName -eq 'MSFT_TaskLogonTrigger') { return $true }
    }
    return $false
}

function Test-TaskActionValid($Task, [string]$Root) {
    $expected = Get-ExpectedTaskAction $Root
    $actions = @($Task.Actions)
    if ($actions.Count -ne 1) { return $false }
    $actualExecute = Get-NormalizedPath ([string]$actions[0].Execute)
    $expectedExecute = Get-NormalizedPath ([string]$expected.Execute)
    return $actualExecute.Equals($expectedExecute, [StringComparison]::OrdinalIgnoreCase) -and ([string]$actions[0].Arguments -eq [string]$expected.Arguments)
}

function Get-RunnerTaskStatus([string]$Name, [string]$Root) {
    $task = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if (-not $task) {
        return [ordered]@{
            ok = $true
            task = $Name
            runner_root = $Root
            installed = $false
            enabled = $false
            running = $false
            autostart = $false
            action_valid = $false
            restart_count = 0
            intent = 'not_installed'
        }
    }
    $enabled = [string]$task.State -ne 'Disabled'
    $running = [string]$task.State -eq 'Running'
    $restartCount = if ($null -ne $task.Settings.RestartCount) { [int]$task.Settings.RestartCount } else { 0 }
    $actionValid = Test-TaskActionValid $task $Root
    $intent = if (-not $enabled) { 'off' } elseif (-not $actionValid) { 'misconfigured' } elseif ($running) { 'on_running' } else { 'on_stopped' }
    return [ordered]@{
        ok = $true
        task = $Name
        runner_root = $Root
        installed = $true
        enabled = $enabled
        running = $running
        autostart = Test-TaskAutostart $task
        action_valid = $actionValid
        restart_count = $restartCount
        state = [string]$task.State
        intent = $intent
    }
}

function Register-RunnerTask([string]$Name, [string]$Root, [bool]$AutoStartEnabled) {
    Assert-RunnerInstallable $Root
    $existing = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if ($existing -and [string]$existing.State -eq 'Running') {
        throw "GITHUB_RUNNER_TASK_RUNNING_RECONFIGURE_REQUIRES_STOP=$Name"
    }

    $expected = Get-ExpectedTaskAction $Root
    $taskAction = New-ScheduledTaskAction -Execute $expected.Execute -Argument $expected.Arguments -WorkingDirectory $Root
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero)
    $userId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited

    if ($AutoStartEnabled) {
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
        Register-ScheduledTask -TaskName $Name -Action $taskAction -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
    }
    else {
        $definition = New-ScheduledTask -Action $taskAction -Settings $settings -Principal $principal
        Register-ScheduledTask -TaskName $Name -InputObject $definition -Force | Out-Null
    }

    $registered = Get-ScheduledTask -TaskName $Name
    $restartCount = if ($null -ne $registered.Settings.RestartCount) { [int]$registered.Settings.RestartCount } else { 0 }
    if ($restartCount -ne 0) {
        throw "GITHUB_RUNNER_TASK_RESTART_LOOP_PRESENT=task:$Name|restart_count:$restartCount"
    }
    if (-not (Test-TaskActionValid $registered $Root)) {
        throw "GITHUB_RUNNER_TASK_ACTION_MISMATCH=$Name"
    }
}

$identity = Get-RunnerIdentity -Root $RunnerRoot -ExplicitTaskName $TaskName
$root = $identity.Root
$taskName = $identity.TaskName

switch ($Action) {
    'Status' {
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'Install' {
        Register-RunnerTask -Name $taskName -Root $root -AutoStartEnabled ($Autostart -eq 'On')
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'On' {
        Assert-RunnerInstallable $root
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if (-not (Test-TaskActionValid $task $root)) { throw "GITHUB_RUNNER_TASK_ACTION_MISMATCH=$taskName" }
        $restartCount = if ($null -ne $task.Settings.RestartCount) { [int]$task.Settings.RestartCount } else { 0 }
        if ($restartCount -ne 0) { throw "GITHUB_RUNNER_TASK_RESTART_LOOP_PRESENT=task:$taskName|restart_count:$restartCount|hint:run Install to normalize" }
        Enable-ScheduledTask -TaskName $taskName | Out-Null
        Start-ScheduledTask -TaskName $taskName
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'Off' {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if ([string]$task.State -eq 'Running') { Stop-ScheduledTask -TaskName $taskName }
        Disable-ScheduledTask -TaskName $taskName | Out-Null
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'Start' {
        Assert-RunnerInstallable $root
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if ([string]$task.State -eq 'Disabled') { throw "GITHUB_RUNNER_TASK_DISABLED=$taskName|hint:use -Action On" }
        if (-not (Test-TaskActionValid $task $root)) { throw "GITHUB_RUNNER_TASK_ACTION_MISMATCH=$taskName" }
        $restartCount = if ($null -ne $task.Settings.RestartCount) { [int]$task.Settings.RestartCount } else { 0 }
        if ($restartCount -ne 0) { throw "GITHUB_RUNNER_TASK_RESTART_LOOP_PRESENT=task:$taskName|restart_count:$restartCount|hint:run Install to normalize" }
        Start-ScheduledTask -TaskName $taskName
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'Stop' {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if ([string]$task.State -eq 'Running') { Stop-ScheduledTask -TaskName $taskName }
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'AutostartOn' {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if ([string]$task.State -eq 'Running') { throw "GITHUB_RUNNER_TASK_RUNNING_AUTOSTART_CHANGE_REQUIRES_STOP=$taskName" }
        $wasDisabled = [string]$task.State -eq 'Disabled'
        Register-RunnerTask -Name $taskName -Root $root -AutoStartEnabled $true
        if ($wasDisabled) { Disable-ScheduledTask -TaskName $taskName | Out-Null }
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'AutostartOff' {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        if ([string]$task.State -eq 'Running') { throw "GITHUB_RUNNER_TASK_RUNNING_AUTOSTART_CHANGE_REQUIRES_STOP=$taskName" }
        $wasDisabled = [string]$task.State -eq 'Disabled'
        Register-RunnerTask -Name $taskName -Root $root -AutoStartEnabled $false
        if ($wasDisabled) { Disable-ScheduledTask -TaskName $taskName | Out-Null }
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
    'Uninstall' {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task -and [string]$task.State -eq 'Running') { Stop-ScheduledTask -TaskName $taskName }
        if ($task) { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false }
        Get-RunnerTaskStatus $taskName $root | ConvertTo-Json -Compress
        break
    }
}