Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- At the start of every distinct technical work item' })
if ($line.Count -ne 1) { throw "expected exactly one issue-intake rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'create the issue only when genuinely new',
    'not already covered by the objective or acceptance criteria of an open current issue or parent convergence issue',
    'adjacent discovery in the same owner/acceptance scenario continues that work identity',
    'rather than opening a child issue merely for bookkeeping',
    'does not serialize disjoint contributions inside the issue'
)) {
    if (-not $rule.Contains($required)) { throw "work identity rule missing invariant: $required" }
}
[ordered]@{
    ok = $true
    rule_count = 1
    parent_acceptance_reuses_identity = $true
    disjoint_contributions_remain_parallel = $true
} | ConvertTo-Json -Compress
