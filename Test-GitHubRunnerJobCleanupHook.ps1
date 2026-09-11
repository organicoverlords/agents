Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$manager = Join-Path $PSScriptRoot 'Manage-GitHubRunnerJobCleanup.ps1'
$text = [IO.File]::ReadAllText($manager)
foreach ($required in @(
    "[ValidateSet('Status','Install','Uninstall')]",
    'ACTIONS_RUNNER_HOOK_JOB_COMPLETED=',
    'Invoke-GitHubRunnerJobCleanup.ps1',
    'restart_required_after_change',
    'GitHubRunnerHooks',
    'runner-root.txt',
    'Get-FileSha256'
)) {
    if (-not $text.Contains($required)) { throw "RUNNER_JOB_CLEANUP_MANAGER_CONTRACT_MISSING=$required" }
}
foreach ($forbidden in @('ScheduledTask','Manage-GitHubRunner.ps1','Start-ScheduledTask','Register-ScheduledTask')) {
    if ($text.Contains($forbidden)) { throw "RUNNER_JOB_CLEANUP_MANAGER_SCHEDULER_COUPLING=$forbidden" }
}

$base = Join-Path $env:TEMP ('github-runner-job-cleanup-manager-' + [guid]::NewGuid().ToString('N'))
$root = Join-Path $base 'runner'
$store = Join-Path $base 'hook-store'
try {
    New-Item -ItemType Directory -Path $root,$store -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $root '.runner'), '{"agentName":"FILE-OWNED-RUNNER"}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $root '.env'), "PRESERVE_ME=1`r`nACTIONS_RUNNER_HOOK_JOB_COMPLETED=C:\old\hook.ps1`r`nACTIONS_RUNNER_HOOK_JOB_COMPLETED=C:\duplicate\hook.ps1`r`n", [Text.UTF8Encoding]::new($false))

    $installed = & $manager -RunnerRoot $root -HookStoreRoot $store -Action Install | ConvertFrom-Json
    if (-not $installed.configured -or -not $installed.valid) { throw "RUNNER_JOB_CLEANUP_MANAGER_INSTALL_BAD=$($installed | ConvertTo-Json -Compress)" }
    if (-not $installed.restart_required_after_change) { throw 'RUNNER_JOB_CLEANUP_MANAGER_RESTART_SEMANTIC_MISSING' }
    if (-not (Test-Path -LiteralPath $installed.hook_path -PathType Leaf)) { throw 'RUNNER_JOB_CLEANUP_MANAGER_HOOK_MISSING' }
    if ($installed.hook_path.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw 'RUNNER_JOB_CLEANUP_MANAGER_HOOK_INSIDE_RUNNER' }
    $envLines = @([IO.File]::ReadAllLines((Join-Path $root '.env')))
    if ($envLines -notcontains 'PRESERVE_ME=1') { throw 'RUNNER_JOB_CLEANUP_MANAGER_ENV_LOST_UNRELATED_KEY' }
    if (@($envLines | Where-Object { $_ -match '^ACTIONS_RUNNER_HOOK_JOB_COMPLETED=' }).Count -ne 1) { throw 'RUNNER_JOB_CLEANUP_MANAGER_ENV_DUPLICATE_KEY' }

    Add-Content -LiteralPath $installed.hook_path -Value '# tamper-test'
    $tampered = & $manager -RunnerRoot $root -HookStoreRoot $store -Action Status | ConvertFrom-Json
    if ($tampered.valid) { throw 'RUNNER_JOB_CLEANUP_MANAGER_TAMPER_ACCEPTED' }

    $repaired = & $manager -RunnerRoot $root -HookStoreRoot $store -Action Install | ConvertFrom-Json
    if (-not $repaired.valid) { throw 'RUNNER_JOB_CLEANUP_MANAGER_REPAIR_FAILED' }

    $removed = & $manager -RunnerRoot $root -HookStoreRoot $store -Action Uninstall | ConvertFrom-Json
    if ($removed.configured -or $removed.valid) { throw 'RUNNER_JOB_CLEANUP_MANAGER_UNINSTALL_BAD' }
    $after = @([IO.File]::ReadAllLines((Join-Path $root '.env')))
    if ($after -notcontains 'PRESERVE_ME=1') { throw 'RUNNER_JOB_CLEANUP_MANAGER_UNINSTALL_LOST_UNRELATED_KEY' }
    if (@($after | Where-Object { $_ -match '^ACTIONS_RUNNER_HOOK_JOB_COMPLETED=' }).Count -ne 0) { throw 'RUNNER_JOB_CLEANUP_MANAGER_UNINSTALL_KEY_RETAINED' }
}
finally {
    Remove-Item -LiteralPath $base -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'PASS GitHub runner job-cleanup hook is file-owned, content-addressed, and scheduler-independent'
