[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$RunnerRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RunnerRoot).Path
$helperTemplate = Join-Path $root 'run-helper.cmd.template'
$helperCommand = Join-Path $root 'run-helper.cmd'
if (-not (Test-Path -LiteralPath $helperTemplate -PathType Leaf)) {
    throw "GITHUB_RUNNER_HELPER_TEMPLATE_MISSING=$helperTemplate"
}

Get-ChildItem -LiteralPath $root -File | Unblock-File -ErrorAction SilentlyContinue

while ($true) {
    Copy-Item -LiteralPath $helperTemplate -Destination $helperCommand -Force

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $env:ComSpec
    $startInfo.Arguments = '/d /s /c ""{0}""' -f $helperCommand
    $startInfo.WorkingDirectory = $root
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

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
