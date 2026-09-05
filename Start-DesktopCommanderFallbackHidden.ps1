[CmdletBinding()]
param(
    [switch]$Probe
)

$ErrorActionPreference = 'Stop'
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

$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$escapedNpx = $npx.Replace('"', '""')
$child = Start-HiddenChild -FileName $commandProcessor -Arguments ('/d /s /c ""{0}" --yes @wonderwhy-er/desktop-commander@latest remote"' -f $escapedNpx)
$child.WaitForExit()
exit $child.ExitCode
