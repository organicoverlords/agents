Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$agentsPath = Join-Path $PSScriptRoot 'AGENTS.md'
$text = [IO.File]::ReadAllText($rulesPath)
$agentsText = [IO.File]::ReadAllText($agentsPath)
$bootstrap = @($text -split "`r?`n" | Where-Object { $_ -match '^- On a fresh chat that materially needs machine state, \*\*route eligibility precedes bootstrap\*\*' })
if ($bootstrap.Count -ne 1) { throw "expected exactly one fresh-chat bootstrap rule; found $($bootstrap.Count)" }
foreach ($required in @(
    'route eligibility precedes bootstrap',
    'MCPv4 `read_output`',
    '231b7e74-4cc8-43d0-9702-fd6dfa2215b3',
    'max_chars=32000',
    'wait_ms=0',
    'skip that MCPv4 bootstrap read',
    'stack_atlas.py bootstrap-glance',
    'If no usable route can obtain bootstrap'
)) {
    if (-not $bootstrap[0].Contains($required)) { throw "fresh-chat bootstrap rule missing invariant: $required" }
}
$orientation = @($text -split "`r?`n" | Where-Object { $_ -match '^- After a fresh-chat bootstrap snapshot is obtained' })
if ($orientation.Count -ne 1) { throw "expected exactly one follow-up orientation rule; found $($orientation.Count)" }
foreach ($required in @(
    'do not automatically rerun bootstrap for every follow-up or subtask',
    'If bootstrap could not be obtained because no usable route existed',
    'do not manufacture a bootstrap prerequisite later in the task',
    'A bounded local request such as reading, writing, or updating a specific Vault artifact does not by itself authorize or require GitHub',
    'one known/targeted issue/PR identity when needed',
    'Never turn task orientation into broad fanout or recurring refresh ceremony'
)) {
    if (-not $orientation[0].Contains($required)) { throw "work identity/orientation rule missing invariant: $required" }
}
$issueLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- The GitHub issue is the shared work/convergence record' })
if ($issueLine.Count -ne 1) { throw "expected exactly one issue convergence rule; found $($issueLine.Count)" }
foreach ($required in @('not a priority queue or admission gate','parallel contributions are allowed when exact mutation scopes are disjoint')) {
    if (-not $issueLine[0].Contains($required)) { throw "issue convergence rule missing invariant: $required" }
}
$identityLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- The issue/task is a \*\*shared convergence identity\*\*' })
if ($identityLine.Count -ne 1) { throw "expected exactly one shared work identity rule; found $($identityLine.Count)" }
foreach ($required in @(
    'not a worker assignment, lane, reservation, or ownership boundary',
    'Workers may enter, leave, review, integrate, or return to an issue as value and exact-collision safety dictate',
    'select the highest-value ready canonical contribution from the relevant repo issues / North Star',
    'do not bind worker identity or continuation to one issue or execution surface'
)) {
    if (-not $identityLine[0].Contains($required)) { throw "shared work identity rule missing invariant: $required" }
}
if ($text.Contains('On every fresh chat, the first machine action is MCPv4 `read_output`')) { throw 'fresh-chat routing regressed to circular MCPv4-first bootstrap' }
if ($text.Contains('mandatory fresh-chat bootstrap')) { throw 'fresh-chat bootstrap incorrectly remains universally mandatory' }
if ($bootstrap[0].Contains('process_id="bootstrap"') -or $bootstrap[0].Contains('Never hard-code or persist a runtime process UUID for bootstrap')) { throw 'fresh-chat bootstrap rule reverted to obsolete alias semantics' }
$issueFirstLine = @($text -split "`r?`n" | Where-Object { $_ -match '^- \*\*Material swarm work is issue-first, not issue-everything\.\*\*' })
if ($issueFirstLine.Count -ne 1) { throw "expected exactly one material issue-first rule; found $($issueFirstLine.Count)" }
foreach ($required in @(
    'material, actionable idea, problem, fix, plan, regression, blocker, or improvement',
    'smallest decision-relevant duplicate/owner check',
    'create or reuse one canonical GitHub issue before deeper implementation work when no durable owner exists',
    'One coherent outcome gets one issue',
    'observations, hypotheses, measurements, sub-findings, and implementation notes stay inside that issue unless they become independently actionable outcomes',
    'Do not turn this into broad GitHub enumeration, startup ceremony, or issue spam',
    'initial shaping through diagnosis/design, patch/PR, validation, integration, and live proof or explicit disproval/supersession'
)) { if (-not $issueFirstLine[0].Contains($required)) { throw "issue-first rule missing invariant: $required" } }
foreach ($required in @(
    'Material work gets a durable owner early',
    'This is not issue-per-observation',
    'idea/problem through design/diagnosis, patch/PR, validation, integration, and live proof or explicit disproval/supersession'
)) { if (-not $agentsText.Contains($required)) { throw "AGENTS issue lifecycle missing invariant: $required" } }
if ($text.Contains('The issue/task is the work identity.')) { throw 'legacy issue-as-worker-lane identity remains' }
[ordered]@{
    ok = $true
    bounded_local_work_avoids_issue_ritual = $true
    issue_is_shared_convergence_not_assignment = $true
    targeted_issue_identity_when_needed = $true
    material_swarm_work_issue_first = $true
    issue_spam_forbidden = $true
    lifecycle_reaches_live_proof = $true
    cross_issue_north_star_selection = $true
    disjoint_contributions_remain_parallel = $true
    bootstrap_uses_persistent_process_id = $true
} | ConvertTo-Json -Compress
