[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$RunnerRoot,
    [ValidateSet('Status','Install','Uninstall')]
    [string]$Action = 'Status',
    [string]$HookStoreRoot = (Join-Path $env:LOCALAPPDATA 'GitHubRunnerHooks')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-NormalizedPath([string]$Path) {
    return [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($Path)).TrimEnd('\')
}

function Test-SameOrChild([string]$Path, [string]$Root) {
    $p = Get-NormalizedPath $Path
    $r = Get-NormalizedPath $Root
    return $p.Equals($r, [StringComparison]::OrdinalIgnoreCase) -or $p.StartsWith($r + '\', [StringComparison]::OrdinalIgnoreCase)
}

function Get-FileSha256([string]$Path) {
    $stream = [IO.File]::OpenRead($Path)
    try {
        $sha = [Security.Cryptography.SHA256]::Create()
        try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','').ToLowerInvariant() }
        finally { $sha.Dispose() }
    }
    finally { $stream.Dispose() }
}

function Get-RunnerName([string]$Root) {
    $config = Join-Path $Root '.runner'
    if (-not (Test-Path -LiteralPath $config -PathType Leaf)) { throw "GITHUB_RUNNER_CONFIG_MISSING=$config" }
    $data = [IO.File]::ReadAllText($config) | ConvertFrom-Json
    $name = [string]$data.agentName
    if ([string]::IsNullOrWhiteSpace($name)) { throw "GITHUB_RUNNER_NAME_MISSING=$config" }
    return $name
}

function Get-ConfiguredHook([string]$Root) {
    $envPath = Join-Path $Root '.env'
    if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) { return $null }
    $value = $null
    foreach ($line in [IO.File]::ReadAllLines($envPath)) {
        if ($line -match '^ACTIONS_RUNNER_HOOK_JOB_COMPLETED=(.*)$') { $value = $Matches[1].Trim() }
    }
    return $value
}

function Set-ConfiguredHook([string]$Root, [string]$HookPath) {
    $envPath = Join-Path $Root '.env'
    $lines = if (Test-Path -LiteralPath $envPath -PathType Leaf) { [IO.File]::ReadAllLines($envPath) } else { @() }
    $output = [Collections.Generic.List[string]]::new()
    $written = $false
    foreach ($line in $lines) {
        if ($line -match '^ACTIONS_RUNNER_HOOK_JOB_COMPLETED=') {
            if (-not $written) { $output.Add("ACTIONS_RUNNER_HOOK_JOB_COMPLETED=$HookPath"); $written = $true }
            continue
        }
        $output.Add($line)
    }
    if (-not $written) { $output.Add("ACTIONS_RUNNER_HOOK_JOB_COMPLETED=$HookPath") }
    $tmp = $envPath + '.tmp'
    [IO.File]::WriteAllLines($tmp, $output, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $tmp -Destination $envPath -Force
}

function Clear-ConfiguredHook([string]$Root) {
    $envPath = Join-Path $Root '.env'
    if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) { return }
    $output = @([IO.File]::ReadAllLines($envPath) | Where-Object { $_ -notmatch '^ACTIONS_RUNNER_HOOK_JOB_COMPLETED=' })
    [IO.File]::WriteAllLines($envPath, $output, [Text.UTF8Encoding]::new($false))
}

function Get-HookStatus([string]$Root, [string]$StoreRoot) {
    $configuredPath = Get-ConfiguredHook $Root
    if ([string]::IsNullOrWhiteSpace($configuredPath)) {
        return [ordered]@{
            configured = $false
            valid = $false
            hook_path = $null
            runner_root = $Root
            env_path = (Join-Path $Root '.env')
            restart_required_after_change = $true
        }
    }

    $path = Get-NormalizedPath $configuredPath
    $store = Get-NormalizedPath $StoreRoot
    $outsideRunner = -not (Test-SameOrChild $path $Root)
    $insideStore = Test-SameOrChild $path $store
    $hookDirectory = Split-Path -Parent $path
    $expectedHash = Split-Path -Leaf $hookDirectory
    $rootFile = Join-Path $hookDirectory 'runner-root.txt'
    $rootMatches = (Test-Path -LiteralPath $rootFile -PathType Leaf) -and ((Get-NormalizedPath ([IO.File]::ReadAllText($rootFile).Trim())).Equals($Root, [StringComparison]::OrdinalIgnoreCase))
    $hookExists = Test-Path -LiteralPath $path -PathType Leaf
    $hashMatches = $false
    if ($hookExists -and $expectedHash -match '^[0-9a-f]{64}$') {
        try { $hashMatches = (Get-FileSha256 $path) -eq $expectedHash } catch { $hashMatches = $false }
    }
    $valid = $outsideRunner -and $insideStore -and $rootMatches -and $hookExists -and $hashMatches -and ([IO.Path]::GetExtension($path) -eq '.ps1')
    return [ordered]@{
        configured = $true
        valid = $valid
        hook_path = $path
        runner_root = $Root
        env_path = (Join-Path $Root '.env')
        restart_required_after_change = $true
    }
}

$root = Get-NormalizedPath (Resolve-Path -LiteralPath $RunnerRoot).Path
$storeRoot = Get-NormalizedPath $HookStoreRoot
if (Test-SameOrChild $storeRoot $root) { throw "GITHUB_RUNNER_HOOK_STORE_INSIDE_RUNNER_ROOT=$storeRoot" }

switch ($Action) {
    'Status' {
        Get-HookStatus -Root $root -StoreRoot $storeRoot | ConvertTo-Json -Compress
        break
    }
    'Install' {
        $source = Join-Path $PSScriptRoot 'Invoke-GitHubRunnerJobCleanup.ps1'
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "GITHUB_RUNNER_JOB_CLEANUP_SOURCE_MISSING=$source" }
        $name = Get-RunnerName $root
        $hash = Get-FileSha256 $source
        $safeName = [regex]::Replace($name, '[^A-Za-z0-9._-]+', '_')
        $directory = Join-Path (Join-Path $storeRoot $safeName) $hash
        if (Test-SameOrChild $directory $root) { throw "GITHUB_RUNNER_JOB_CLEANUP_HOOK_INSIDE_RUNNER_ROOT=$directory" }
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        $hook = Join-Path $directory 'Invoke-GitHubRunnerJobCleanup.ps1'
        Copy-Item -LiteralPath $source -Destination $hook -Force
        [IO.File]::WriteAllText((Join-Path $directory 'runner-root.txt'), $root + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
        [ordered]@{ schema='github-runner-job-cleanup-hook.v1'; source_sha256=$hash; runner_root=$root; installed_at=[DateTimeOffset]::UtcNow.ToString('o') } |
            ConvertTo-Json -Compress | Set-Content -LiteralPath (Join-Path $directory 'manifest.json') -Encoding UTF8
        Set-ConfiguredHook -Root $root -HookPath $hook
        $status = Get-HookStatus -Root $root -StoreRoot $storeRoot
        if (-not $status.valid) { throw "GITHUB_RUNNER_JOB_CLEANUP_INSTALL_INVALID=$hook" }
        $status | ConvertTo-Json -Compress
        break
    }
    'Uninstall' {
        Clear-ConfiguredHook -Root $root
        Get-HookStatus -Root $root -StoreRoot $storeRoot | ConvertTo-Json -Compress
        break
    }
}
