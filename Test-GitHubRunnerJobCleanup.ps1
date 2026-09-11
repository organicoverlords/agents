Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$hook = Join-Path $PSScriptRoot 'Invoke-GitHubRunnerJobCleanup.ps1'
$text = [IO.File]::ReadAllText($hook)
foreach ($required in @(
    'ACTIONS_RUNNER_HOOK_JOB_COMPLETED',
    'runner-root.txt',
    '[IO.FileAttributes]::ReparsePoint',
    'workspace_outside_owned_shape',
    'runner_temp_outside_owned_shape',
    '[ValidateRange(0,120)]',
    '[int]$TimeoutSeconds = 15',
    '[int]$MaxItems = 100000'
)) {
    if ($required -eq 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED') { continue }
    if (-not $text.Contains($required)) { throw "RUNNER_JOB_CLEANUP_CONTRACT_MISSING=$required" }
}

$root = Join-Path $env:TEMP ('github-runner-job-cleanup-test-' + [guid]::NewGuid().ToString('N'))
$outside = Join-Path $env:TEMP ('github-runner-job-cleanup-outside-' + [guid]::NewGuid().ToString('N'))
try {
    $workspace = Join-Path $root '_work\repo\repo'
    $warm = Join-Path $root '_work\repo\.ci-cache'
    $temp = Join-Path $root '_work\_temp'
    New-Item -ItemType Directory -Path $workspace,$warm,$temp,$outside -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $workspace 'job.bin'), 'job')
    [IO.File]::WriteAllText((Join-Path $warm 'warm.bin'), 'warm')
    [IO.File]::WriteAllText((Join-Path $temp 'temp.bin'), 'temp')
    [IO.File]::WriteAllText((Join-Path $outside 'keep.bin'), 'keep')

    $result = & $hook -RunnerRoot $root -Workspace $workspace -RunnerTemp $temp | ConvertFrom-Json
    if ($result.status -ne 'ok' -or [int]$result.removed_items -lt 2) { throw "RUNNER_JOB_CLEANUP_VALID_BAD=$($result | ConvertTo-Json -Compress)" }
    if (Test-Path -LiteralPath $workspace) { throw 'RUNNER_JOB_CLEANUP_WORKSPACE_RETAINED' }
    if (-not (Test-Path -LiteralPath (Join-Path $warm 'warm.bin'))) { throw 'RUNNER_JOB_CLEANUP_WARM_CACHE_REMOVED' }
    if (-not (Test-Path -LiteralPath $temp -PathType Container) -or @(Get-ChildItem -LiteralPath $temp -Force).Count -ne 0) { throw 'RUNNER_JOB_CLEANUP_TEMP_NOT_EMPTIED' }
    if (-not (Test-Path -LiteralPath (Join-Path $outside 'keep.bin'))) { throw 'RUNNER_JOB_CLEANUP_OUTSIDE_REMOVED' }

    $bad = & $hook -RunnerRoot $root -Workspace $outside -RunnerTemp $outside | ConvertFrom-Json
    if ($bad.skipped -notcontains 'workspace_outside_owned_shape' -or $bad.skipped -notcontains 'runner_temp_outside_owned_shape') { throw "RUNNER_JOB_CLEANUP_OUTSIDE_NOT_BLOCKED=$($bad | ConvertTo-Json -Compress)" }
    if (-not (Test-Path -LiteralPath (Join-Path $outside 'keep.bin'))) { throw 'RUNNER_JOB_CLEANUP_OUTSIDE_MUTATED' }

    $boundedWorkspace = Join-Path $root '_work\bounded\bounded'
    New-Item -ItemType Directory -Path $boundedWorkspace -Force | Out-Null
    1..5 | ForEach-Object { [IO.File]::WriteAllText((Join-Path $boundedWorkspace ("$_.bin")), 'x') }
    $bounded = & $hook -RunnerRoot $root -Workspace $boundedWorkspace -RunnerTemp '' -MaxItems 1 | ConvertFrom-Json
    if (-not $bounded.item_bound_reached -or [int]$bounded.removed_items -ne 1) { throw "RUNNER_JOB_CLEANUP_BOUND_BAD=$($bounded | ConvertTo-Json -Compress)" }

    $timeoutWorkspace = Join-Path $root '_work\timeout\timeout'
    New-Item -ItemType Directory -Path $timeoutWorkspace -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $timeoutWorkspace 'keep.bin'), 'x')
    $timed = & $hook -RunnerRoot $root -Workspace $timeoutWorkspace -RunnerTemp '' -TimeoutSeconds 0 | ConvertFrom-Json
    if (-not $timed.timed_out -or $timed.status -ne 'timeout' -or [int]$timed.removed_items -ne 0) { throw "RUNNER_JOB_CLEANUP_TIMEOUT_BAD=$($timed | ConvertTo-Json -Compress)" }
    if (-not (Test-Path -LiteralPath (Join-Path $timeoutWorkspace 'keep.bin'))) { throw 'RUNNER_JOB_CLEANUP_TIMEOUT_MUTATED' }

    $reparseParent = Join-Path $root '_work\linked\linked-parent'
    New-Item -ItemType Directory -Path $reparseParent -Force | Out-Null
    $reparseWorkspace = Join-Path $reparseParent 'linked-parent'
    New-Item -ItemType Junction -Path $reparseWorkspace -Target $outside | Out-Null
    $rootLink = & $hook -RunnerRoot $root -Workspace $reparseWorkspace -RunnerTemp '' | ConvertFrom-Json
    if ($rootLink.skipped -notcontains 'workspace_reparse_root') { throw "RUNNER_JOB_CLEANUP_REPARSE_ROOT_NOT_SKIPPED=$($rootLink | ConvertTo-Json -Compress)" }
    if (-not (Test-Path -LiteralPath (Join-Path $outside 'keep.bin'))) { throw 'RUNNER_JOB_CLEANUP_REPARSE_ROOT_TARGET_MUTATED' }

    $nestedWorkspace = Join-Path $root '_work\nested\nested'
    New-Item -ItemType Directory -Path $nestedWorkspace -Force | Out-Null
    $nestedLink = Join-Path $nestedWorkspace 'outside-link'
    New-Item -ItemType Junction -Path $nestedLink -Target $outside | Out-Null
    [IO.File]::WriteAllText((Join-Path $nestedWorkspace 'job.bin'), 'job')
    $nested = & $hook -RunnerRoot $root -Workspace $nestedWorkspace -RunnerTemp '' | ConvertFrom-Json
    if ($nested.status -ne 'ok' -or (Test-Path -LiteralPath $nestedWorkspace)) { throw "RUNNER_JOB_CLEANUP_NESTED_REPARSE_BAD=$($nested | ConvertTo-Json -Compress)" }
    if (-not (Test-Path -LiteralPath (Join-Path $outside 'keep.bin'))) { throw 'RUNNER_JOB_CLEANUP_NESTED_REPARSE_TARGET_MUTATED' }
}
finally {
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $outside -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'PASS GitHub runner post-job cleanup is provenance-contained, warm-cache preserving, and bounded'
