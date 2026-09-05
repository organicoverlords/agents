Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match 'Heavy build, runtime, render, and GPU-generation work is single-flight' })
if ($line.Count -ne 1) { throw "expected exactly one heavy single-flight rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'exact input identity',
    'canonical heavy entrypoint',
    'Concurrent duplicate requests join the same in-flight execution',
    'still-valid verified PASS result',
    "same-flight followers receive that flight's result",
    'failed flight may be retried only by a later fresh request after the failed flight ends',
    'identity and artifact verification repo-owned',
    'do not create a global scheduler or queue'
)) {
    if ($rule -notlike "*$required*") { throw "single-flight rule missing invariant: $required" }
}
if ($text -match 'SHARED-AGENT-POLICY\.md') { throw 'canonical RULES must not depend on retired SHARED-AGENT-POLICY.md' }
[ordered]@{ ok = $true; rule_count = 1; retired_policy_reference = $false } | ConvertTo-Json -Compress