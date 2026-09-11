[CmdletBinding()]
param(
    [string]$TaskName = 'ReadyPullRequestConvergence',
    [int]$IntervalMinutes = 1
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($IntervalMinutes -lt 1) { throw 'IntervalMinutes must be at least 1' }
$repo = $PSScriptRoot
$script = Join-Path $repo 'Invoke-ReadyPullRequestConvergence.ps1'
$config = Join-Path $repo 'ReadyPullRequestConvergence.json'
if (-not (Test-Path -LiteralPath $script -PathType Leaf)) { throw "Missing convergence script: $script" }
if (-not (Test-Path -LiteralPath $config -PathType Leaf)) { throw "Missing convergence config: $config" }
$powershell = (Get-Command powershell.exe -ErrorAction Stop).Source
$args = '-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -ConfigPath "{1}"' -f $script,$config
$action = New-ScheduledTaskAction -Execute $powershell -Argument $args -WorkingDirectory $repo
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(30)) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Seconds 50)
$userId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
$task = Get-ScheduledTask -TaskName $TaskName
[ordered]@{
    ok = $true
    task = $task.TaskName
    state = [string]$task.State
    interval_minutes = $IntervalMinutes
    execution_limit_seconds = 50
    multiple_instances = 'IgnoreNew'
    execute = $powershell
    script = $script
    config = $config
    logon_type = 'Interactive'
    run_level = 'Limited'
} | ConvertTo-Json -Compress
