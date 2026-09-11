Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$controller = Join-Path $PSScriptRoot 'Manage-GitHubRunner.ps1'
$text = [IO.File]::ReadAllText($controller)
foreach ($required in @(
    "[ValidateSet('Status','Install','On','Off','Start','Stop','AutostartOn','AutostartOff','Uninstall')]",
    "GITHUB_RUNNER_TASK_RESTART_LOOP_PRESENT",
    "GITHUB_RUNNER_TASK_ACTION_MISMATCH",
    "GITHUB_RUNNER_REQUIRED_PATH_MISSING",
    "Disable-ScheduledTask -TaskName `$taskName",
    "New-ScheduledTaskTrigger -AtLogOn",
    "New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero)"
)) {
    if (-not $text.Contains($required)) { throw "GITHUB_RUNNER_CONTROL_CONTRACT_MISSING=$required" }
}
if ($text.Contains('-RestartCount')) { throw 'GITHUB_RUNNER_CONTROL_RESTART_LOOP_REINTRODUCED' }

$root = Join-Path $env:TEMP ('github-runner-control-test-' + [guid]::NewGuid().ToString('N'))
$taskName = 'GitHub-Runner-Control-Test-' + [guid]::NewGuid().ToString('N')
try {
    New-Item -ItemType Directory -Path (Join-Path $root 'bin') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $root '.runner'), '{"agentName":"CONTROL-TEST"}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $root 'run-helper.cmd.template'), '@echo off`r`nexit /b 7`r`n', [Text.ASCIIEncoding]::new())
    [IO.File]::WriteAllBytes((Join-Path $root 'bin\Runner.Listener.exe'), [byte[]](0))

    $installed = & $controller -RunnerRoot $root -TaskName $taskName -Action Install -Autostart Off | ConvertFrom-Json
    if (-not $installed.installed -or -not $installed.enabled -or $installed.autostart -or -not $installed.action_valid) { throw "GITHUB_RUNNER_CONTROL_INSTALL_BAD=$($installed | ConvertTo-Json -Compress)" }
    if ([int]$installed.restart_count -ne 0) { throw "GITHUB_RUNNER_CONTROL_INSTALL_RESTART_COUNT=$($installed.restart_count)" }
    $xml = Export-ScheduledTask -TaskName $taskName
    if ($xml -match '<RestartOnFailure>') { throw 'GITHUB_RUNNER_CONTROL_TASK_XML_RESTART_LOOP_PRESENT' }

    $autoOn = & $controller -RunnerRoot $root -TaskName $taskName -Action AutostartOn | ConvertFrom-Json
    if (-not $autoOn.autostart) { throw 'GITHUB_RUNNER_CONTROL_AUTOSTART_ON_FAILED' }

    $autoOff = & $controller -RunnerRoot $root -TaskName $taskName -Action AutostartOff | ConvertFrom-Json
    if ($autoOff.autostart) { throw 'GITHUB_RUNNER_CONTROL_AUTOSTART_OFF_FAILED' }

    $off = & $controller -RunnerRoot $root -TaskName $taskName -Action Off | ConvertFrom-Json
    if ($off.enabled -or $off.intent -ne 'off') { throw "GITHUB_RUNNER_CONTROL_OFF_FAILED=$($off | ConvertTo-Json -Compress)" }

    $status = & $controller -RunnerRoot $root -TaskName $taskName -Action Status | ConvertFrom-Json
    if ($status.enabled -or -not $status.installed -or -not $status.action_valid) { throw "GITHUB_RUNNER_CONTROL_STATUS_BAD=$($status | ConvertTo-Json -Compress)" }

    $removed = & $controller -RunnerRoot $root -TaskName $taskName -Action Uninstall | ConvertFrom-Json
    if ($removed.installed) { throw 'GITHUB_RUNNER_CONTROL_UNINSTALL_FAILED' }
}
finally {
    Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'PASS explicit GitHub runner task control is toggleable, autostart-aware, and has no scheduler restart loop'