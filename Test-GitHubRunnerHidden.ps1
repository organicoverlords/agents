Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'Start-GitHubRunnerHidden.ps1'
$text = [IO.File]::ReadAllText($launcher)
if (-not $text.Contains('$startInfo.CreateNoWindow = $false')) { throw 'GITHUB_RUNNER_HIDDEN_CONSOLE_INHERITANCE_DISABLED' }
if ($text.Contains('$startInfo.CreateNoWindow = $true')) { throw 'GITHUB_RUNNER_DESCENDANT_CONSOLE_DETACHMENT_REINTRODUCED' }
if (-not $text.Contains('cmd/listener/worker descendants inherit the same hidden')) { throw 'GITHUB_RUNNER_DESCENDANT_HIDDEN_CONSOLE_CONTRACT_MISSING' }
$tailStart = $text.IndexOf('    $exitCode = $process.ExitCode', [StringComparison]::Ordinal)
if ($tailStart -lt 0) { throw 'GITHUB_RUNNER_PERSISTENCE_TAIL_MISSING' }
$tail = $text.Substring($tailStart)

foreach ($required in @(
    '$process.Dispose()',
    "if (`$env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE -eq '1' -and `$exitCode -eq 7)",
    'GITHUB_RUNNER_HELPER_EXITED=root:$root|exit:$exitCode|restart_seconds:2',
    'Start-Sleep -Seconds 2',
    'continue'
)) {
    if (-not $tail.Contains($required)) { throw "GITHUB_RUNNER_PERSISTENCE_CONTRACT_MISSING=$required" }
}
if ($tail -match '(?m)^\s*if \(\$exitCode -eq 1\)') { throw 'GITHUB_RUNNER_PERSISTENCE_EXIT1_ONLY_RETRY_REMAINS' }
if ($tail -match '(?m)^\s*exit 0\s*$') { throw 'GITHUB_RUNNER_PERSISTENCE_CLEAN_EXIT_STOPS_SUPERVISION' }

function New-FakeRunnerRoot([int]$ExitCode) {
    $root = Join-Path $env:TEMP ('github-runner-launcher-test-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $counter = Join-Path $root 'hits.txt'
    $template = Join-Path $root 'run-helper.cmd.template'
    $content = "@echo off`r`necho hit>>`"$counter`"`r`nexit /b $ExitCode`r`n"
    [IO.File]::WriteAllText($template, $content, [Text.ASCIIEncoding]::new())
    return $root
}

$retryRoot = New-FakeRunnerRoot 0
$retryProcess = $null
try {
    $retryProcess = Start-Process powershell.exe -ArgumentList @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$launcher,'-RunnerRoot',$retryRoot) -WindowStyle Hidden -PassThru
    $deadline = [DateTime]::UtcNow.AddSeconds(7)
    do {
        Start-Sleep -Milliseconds 200
        $hits = if (Test-Path (Join-Path $retryRoot 'hits.txt')) { @(Get-Content (Join-Path $retryRoot 'hits.txt')).Count } else { 0 }
    } while ($hits -lt 2 -and [DateTime]::UtcNow -lt $deadline -and -not $retryProcess.HasExited)
    if ($hits -lt 2) { throw "GITHUB_RUNNER_PERSISTENCE_EXIT0_NOT_RETRIED=hits:$hits exited:$($retryProcess.HasExited)" }
}
finally {
    if ($retryProcess -and -not $retryProcess.HasExited) { & "$env:SystemRoot\System32\taskkill.exe" /PID ([string]$retryProcess.Id) /T /F | Out-Null }
    Remove-Item -LiteralPath $retryRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$deprecatedRoot = New-FakeRunnerRoot 7
$deprecatedProcess = $null
$previous = $env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE
try {
    $env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE = '1'
    $deprecatedProcess = Start-Process powershell.exe -ArgumentList @('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$launcher,'-RunnerRoot',$deprecatedRoot) -WindowStyle Hidden -PassThru
    if (-not $deprecatedProcess.WaitForExit(5000)) { throw 'GITHUB_RUNNER_DEPRECATED_HANDOFF_DID_NOT_EXIT' }
    if ($deprecatedProcess.ExitCode -ne 7) { throw "GITHUB_RUNNER_DEPRECATED_HANDOFF_EXIT=$($deprecatedProcess.ExitCode)" }
}
finally {
    if ($null -eq $previous) { Remove-Item Env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE -ErrorAction SilentlyContinue } else { $env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE = $previous }
    if ($deprecatedProcess -and -not $deprecatedProcess.HasExited) { & "$env:SystemRoot\System32\taskkill.exe" /PID ([string]$deprecatedProcess.Id) /T /F | Out-Null }
    Remove-Item -LiteralPath $deprecatedRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'PASS GitHub runner launcher retries clean helper exits and preserves deprecated-version handoff'
