$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $root 'Start-DesktopCommanderFallbackHidden.ps1'
$text = Get-Content -LiteralPath $launcher -Raw
foreach ($needle in @(
    '$startInfo.UseShellExecute = $false',
    '$startInfo.CreateNoWindow = $true',
    '$startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden',
    '@wonderwhy-er/desktop-commander@latest remote'
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
