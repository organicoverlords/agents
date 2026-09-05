[CmdletBinding()]
param(
    [switch]$Check,
    [string]$CanonicalRoot = (Join-Path $env:USERPROFILE '.agents'),
    [string]$CodexAgentsPath = (Join-Path $env:USERPROFILE '.codex\AGENTS.md'),
    [string]$OpenCodeAgentsPath = (Join-Path $env:USERPROFILE '.config\opencode\AGENTS.md')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $CanonicalRoot 'RULES.md'
$agentsPath = Join-Path $CanonicalRoot 'AGENTS.md'
foreach ($required in @($rulesPath, $agentsPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "canonical agent file missing: $required"
    }
}

$expected = @"
# Agent rules

Canonical rules: $rulesPath
Shared work contract: $agentsPath

Read both canonical files directly. This file is pointer-only and contains no local policy.
"@
$expected = $expected.Replace("`r`n", "`n").TrimEnd() + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$targets = @($CodexAgentsPath, $OpenCodeAgentsPath)

function Read-NormalizedText([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
}

$mismatches = @()
foreach ($target in $targets) {
    $actual = Read-NormalizedText $target
    if ($actual -ne $expected) {
        $mismatches += $target
        if (-not $Check) {
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            [IO.File]::WriteAllText($target, $expected, $utf8NoBom)
        }
    }
}

if ($Check -and $mismatches.Count -gt 0) {
    throw "agent entrypoint mismatch: $($mismatches -join ', ')"
}

$result = [ordered]@{
    ok = $true
    mode = $(if ($Check) { 'check' } else { 'install' })
    canonical_rules = $rulesPath
    canonical_agents = $agentsPath
    targets = $targets
    changed = $(if ($Check) { @() } else { $mismatches })
}
$result | ConvertTo-Json -Compress