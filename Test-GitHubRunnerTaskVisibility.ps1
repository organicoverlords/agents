[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1'
$tasks = @(
    'GitHub-Runner-LOWVRAM3D-KONE-02',
    'GitHub-Runner-LOWVRAM3D-KONE-03',
    'GitHub-Runner-LOWVRAM3D-KONE-04',
    'GitHub-Runner-P3-KONE-01',
    'GitHub-Runner-P3-KONE-02',
    'GitHub-Runner-TINY3D-KONE-02',
    'GitHub-Runner-TINY3D-KONE-03',
    'LowVRAM3D-GitHub-Runner',
    'Tiny3D-GitHub-Runner'
)

if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
    throw "RUNNER_HIDDEN_LAUNCHER_MISSING=$launcher"
}

$launcherText = [IO.File]::ReadAllText($launcher)
foreach ($marker in @('CreateNoWindow = $true', 'UseShellExecute = $false')) {
    if (-not $launcherText.Contains($marker)) {
        throw "RUNNER_HIDDEN_LAUNCHER_MARKER_MISSING=$marker"
    }
}

foreach ($taskName in $tasks) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
    $action = $task.Actions[0]
    $executeName = [IO.Path]::GetFileName($action.Execute)
    if ($executeName -in @('powershell.exe', 'pwsh.exe')) {
        if ($action.Arguments -notmatch '(?i)-WindowStyle\s+Hidden') {
            throw "RUNNER_TASK_WINDOW_STYLE_NOT_HIDDEN=$taskName"
        }
        if ($action.Arguments -notmatch [regex]::Escape($launcher)) {
            throw "RUNNER_TASK_HIDDEN_LAUNCHER_MISSING=$taskName"
        }
        continue
    }
    if ($executeName -ne 'cmd.exe') {
        throw "RUNNER_TASK_UNSUPPORTED_EXECUTABLE=$taskName execute=$($action.Execute)"
    }
    $runCommand = Join-Path $action.WorkingDirectory 'run.cmd'
    $runText = [IO.File]::ReadAllText($runCommand)
    if ($runText -notmatch '(?i)-WindowStyle\s+Hidden' -or $runText -notmatch [regex]::Escape($launcher)) {
        throw "RUNNER_TASK_CMD_WRAPPER_NOT_HIDDEN=$taskName path=$runCommand"
    }
}

Write-Host "RUNNER_TASKS_HIDDEN=PASS count=$($tasks.Count)"
