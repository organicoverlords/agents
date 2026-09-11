[CmdletBinding()]
param(
    [string]$RunnerRoot,
    [string]$Workspace = $env:GITHUB_WORKSPACE,
    [string]$RunnerTemp = $env:RUNNER_TEMP,
    [ValidateRange(0,120)]
    [int]$TimeoutSeconds = 15,
    [ValidateRange(1,500000)]
    [int]$MaxItems = 100000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-Path([string]$Path) {
    return [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($Path)).TrimEnd('\\')
}

function Is-SameOrChild([string]$Path, [string]$Root) {
    $p = Normalize-Path $Path
    $r = Normalize-Path $Root
    return $p.Equals($r, [StringComparison]::OrdinalIgnoreCase) -or $p.StartsWith($r + '\', [StringComparison]::OrdinalIgnoreCase)
}

if ([string]::IsNullOrWhiteSpace($RunnerRoot)) {
    $rootFile = Join-Path $PSScriptRoot 'runner-root.txt'
    if (-not (Test-Path -LiteralPath $rootFile -PathType Leaf)) {
        [ordered]@{ ok=$true; status='blocked'; reason='runner_root_missing'; removed_items=0; errors=@() } | ConvertTo-Json -Compress
        exit 0
    }
    $RunnerRoot = [IO.File]::ReadAllText($rootFile).Trim()
}

$root = Normalize-Path $RunnerRoot
$workRoot = Normalize-Path (Join-Path $root '_work')
$tempRoot = Normalize-Path (Join-Path $workRoot '_temp')
$errors = [Collections.Generic.List[string]]::new()
$skipped = [Collections.Generic.List[string]]::new()
$removed = 0
$budgetExhausted = $false
$timedOut = $false
$clock = [Diagnostics.Stopwatch]::StartNew()

function Test-Budget {
    if ($script:removed -ge $MaxItems) { $script:budgetExhausted = $true; return $false }
    if ($clock.Elapsed.TotalSeconds -ge $TimeoutSeconds) { $script:timedOut = $true; return $false }
    return $true
}

function Remove-BoundedNode([string]$Path, [bool]$RemoveRoot) {
    if (-not (Test-Budget)) { return }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return }
    try {
        $isReparse = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
        if ($isReparse) {
            if ($item.PSIsContainer) { [IO.Directory]::Delete($item.FullName, $false) }
            else { [IO.File]::Delete($item.FullName) }
            $script:removed++
            return
        }
        if ($item.PSIsContainer) {
            foreach ($child in @(Get-ChildItem -LiteralPath $item.FullName -Force -ErrorAction Stop)) {
                if (-not (Test-Budget)) { return }
                Remove-BoundedNode -Path $child.FullName -RemoveRoot $true
                if ($script:budgetExhausted -or $script:timedOut) { return }
            }
            if ($RemoveRoot -and (Test-Budget)) {
                Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
                $script:removed++
            }
        }
        elseif (Test-Budget) {
            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
            $script:removed++
        }
    }
    catch {
        $errors.Add(($item.FullName + ':' + $_.Exception.GetType().Name))
    }
}

if (-not (Test-Path -LiteralPath $workRoot -PathType Container)) {
    [ordered]@{ ok=$true; status='blocked'; reason='work_root_missing'; runner_root=$root; removed_items=0; errors=@() } | ConvertTo-Json -Compress
    exit 0
}

if (-not [string]::IsNullOrWhiteSpace($Workspace)) {
    $workspacePath = Normalize-Path $Workspace
    $workspaceParent = Split-Path -Parent $workspacePath
    $workspaceLeaf = Split-Path -Leaf $workspacePath
    $parentLeaf = Split-Path -Leaf $workspaceParent
    $workspaceShapeValid = Is-SameOrChild $workspacePath $workRoot -and -not $workspacePath.Equals($workRoot, [StringComparison]::OrdinalIgnoreCase) -and $workspaceLeaf -eq $parentLeaf
    if ($workspaceShapeValid -and (Test-Path -LiteralPath $workspacePath)) {
        $workspaceItem = Get-Item -LiteralPath $workspacePath -Force
        if (($workspaceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            $skipped.Add('workspace_reparse_root')
        }
        else {
            Remove-BoundedNode -Path $workspacePath -RemoveRoot $true
        }
    }
    elseif (-not $workspaceShapeValid) {
        $skipped.Add('workspace_outside_owned_shape')
    }
}

if (-not [string]::IsNullOrWhiteSpace($RunnerTemp)) {
    $runnerTempPath = Normalize-Path $RunnerTemp
    if ($runnerTempPath.Equals($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $runnerTempPath -PathType Container)) {
        $tempItem = Get-Item -LiteralPath $runnerTempPath -Force
        if (($tempItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            $skipped.Add('runner_temp_reparse_root')
        }
        else {
            Remove-BoundedNode -Path $runnerTempPath -RemoveRoot $false
        }
    }
    elseif (-not $runnerTempPath.Equals($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        $skipped.Add('runner_temp_outside_owned_shape')
    }
}

$status = if ($timedOut) { 'timeout' } elseif ($budgetExhausted) { 'item_bound' } elseif ($errors.Count) { 'partial' } else { 'ok' }
[ordered]@{
    ok = $true
    status = $status
    runner_root = $root
    removed_items = $removed
    timeout_seconds = $TimeoutSeconds
    max_items = $MaxItems
    timed_out = $timedOut
    item_bound_reached = $budgetExhausted
    skipped = @($skipped)
    errors = @($errors)
} | ConvertTo-Json -Compress
exit 0
