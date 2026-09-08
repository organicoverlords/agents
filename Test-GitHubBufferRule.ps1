Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- GitHub read acceleration is local-first and Rust-backed\.' })
if ($line.Count -ne 1) { throw "expected exactly one gh-buffer adoption rule; found $($line.Count)" }
$rule = $line[0]
foreach ($required in @(
    'noninteractive tools that issue repeated safe read-only GitHub CLI lookups',
    'Rust `ghbuf exec -- <command>`',
    'cache/coalesce only provably read-only calls',
    'Do not globally shadow or replace interactive `gh`',
    'interactive or mutating commands keep real GitHub CLI semantics',
    'ghbuf exec-readonly -- <command>',
    'authenticated loopback tunnel',
    'explicit `--repo`/`GH_REPO`',
    'ambiguous or mutating commands fail closed',
    'GitHub/repo state remains authoritative',
    'never work, liveness, ownership, progress, or permission',
    'does not authorize repeated polling'
)) {
    if (-not $rule.Contains($required)) { throw "gh-buffer rule missing invariant: $required" }
}
Write-Output 'PASS GitHub buffer rule'
