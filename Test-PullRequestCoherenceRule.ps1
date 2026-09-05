Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- A pull request is a coherent merge/review boundary' })
if ($line.Count -ne 1) { throw "expected exactly one PR-coherence rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'not a progress checkpoint',
    "one actor's contiguous work stream on the same owner/acceptance scenario",
    'compose adjacent changes that are safe and reviewable together before opening or merging a PR',
    'does not require one PR per issue',
    'serialize different agents',
    'delay unrelated ready work merely to pad a PR',
    'real independent boundary'
)) {
    if (-not $rule.Contains($required)) { throw "PR coherence rule missing invariant: $required" }
}
[ordered]@{
    ok = $true
    rule_count = 1
    coherent_pr_boundary = $true
    parallel_agents_preserved = $true
    independent_boundaries_preserved = $true
} | ConvertTo-Json -Compress
