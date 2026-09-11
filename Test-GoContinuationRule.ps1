Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$agentsPath = Join-Path $PSScriptRoot 'AGENTS.md'
$text = [IO.File]::ReadAllText($rulesPath)
$agentsText = [IO.File]::ReadAllText($agentsPath)
$lines = $text -split "`r?`n"
$requestLine = @($lines | Where-Object { $_ -match '^- Request fidelity constrains relevance and blast radius; it is not a completion or yield rule\.' })
$yieldAuditLine = @($lines | Where-Object { $_ -match '^- \*\*MANUAL GO IS NOT A TIMEBOX\.\*\*' })
$pollLine = @($lines | Where-Object { $_ -match '^- Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive' })
$identityLine = @($lines | Where-Object { $_ -match '^- The issue/task is a \*\*shared convergence identity\*\*' })
$wipLine = @($lines | Where-Object { $_ -match '^- Existing coherent WIP wins by default' })
$blockerLine = @($lines | Where-Object { $_ -match '^- A constrained tool, build, CI job, lane, checkout, worktree, or exact Busy scope blocks only that exact action;' })
$manualLine = @($lines | Where-Object { $_ -match '^- For manual/on-demand chats, especially `go`/`continue`,' })
$rebootLine = @($lines | Where-Object { $_ -match '^- \*\*MACHINE REBOOT/RESTART IS EXPLICIT-ONLY\.\*\*' })
foreach ($pair in @(@('request-fidelity',$requestLine),@('yield-audit',$yieldAuditLine),@('poll',$pollLine),@('identity',$identityLine),@('wip',$wipLine),@('blocker',$blockerLine),@('manual',$manualLine),@('reboot',$rebootLine))) {
    if ($pair[1].Count -ne 1) { throw "expected exactly one $($pair[0]) rule; found $($pair[1].Count)" }
}
foreach ($required in @(
    'rather than treating the currently open issue/PR/branch/worktree, repository, project, or any inferred "scope" as a lane or stop boundary',
    'the highest-value safe supported work that materially advances the same user goal',
    'Absence of ready work inside any chosen issue/repo/project/scope is never a stop condition by itself',
    'broaden by relevance to the user goal before concluding execution is blocked'
)) { if (-not $requestLine[0].Contains($required)) { throw "request-fidelity rule missing invariant: $required" } }
foreach ($required in @(
    'Before sending a final answer in any manual/on-demand `go`/`continue` turn',
    'Elapsed wall time, number of tool calls, amount of work already done',
    'an open/clean/mergeable PR',
    'an exact-scope Busy collision',
    'Scope exhaustion, `no ready in scope`, no ready issue/North-Star work, or a decision-ready blocker are never stop evidence',
    'A final answer is allowed only when live evidence supports one of',
    'If the audit cannot name one of those conditions and its live evidence, do not final-answer',
    'If the user corrects a failed `go`/`continue` turn because the assistant yielded, apologized, explained, or reported status instead of advancing the established goal',
    'Apology, status recap, incident narration, rule-reading, or explaining the prior failure is not progress and cannot satisfy the yield audit'
)) { if (-not $yieldAuditLine[0].Contains($required)) { throw "yield audit rule missing invariant: $required" } }
foreach ($required in @(
    'Immediately before final-answering a manual `go`/`continue` turn, apply the `RULES.md` pre-final yield audit',
    'if no permitted stop condition is supported by live evidence, continue execution',
    'Never treat elapsed wall time, tool-call count, work already completed, handoff/PR state, or an exact-scope collision as stop evidence',
    'A user correction that a manual `go` was answered with apology, explanation, or status instead of execution resumes that same continuation immediately',
    'never count apology/status/incident narration as progress or as satisfaction of the yield audit'
)) { if (-not $agentsText.Contains($required)) { throw "AGENTS missing manual-go yield audit invariant: $required" } }

foreach ($required in @(
    'prefer local branch/commit/worktree evidence before remote GitHub when it can answer the question',
    'query remote issue/PR state only when the remote fact itself is decision-relevant',
    'Fresh chat/session status alone is not a reason to query GitHub'
)) { if (-not $agentsText.Contains($required)) { throw "AGENTS WIP lookup rule missing invariant: $required" } }

foreach ($required in @(
    'shared convergence identity',
    'not a worker assignment, lane, reservation, or ownership boundary',
    'Workers may enter, leave, review, integrate, or return to an issue as value and exact-collision safety dictate',
    'select the highest-value ready canonical contribution from the relevant repo issues / North Star',
    'do not bind worker identity or continuation to one issue or execution surface'
)) { if (-not $identityLine[0].Contains($required)) { throw "identity rule missing invariant: $required" } }

foreach ($required in @(
    'On a fresh entry, inspect the local target repo branch/HEAD/dirty state and already-provided task/WIP references first',
    'Query remote issue/PR/current-plan state only when whether matching WIP exists or materially changed is a real decision-relevant unknown',
    'do not query GitHub merely because the chat is fresh',
    'do not fetch issue + PR + branch state as a bundle when one source is sufficient',
    'No issue, PR, branch, worktree, or objective is a worker-owned lane or assignment',
    'Busy owns only exact mutation collision',
    'select the next highest-value ready canonical contribution from the owning repo''s open issues / North Star',
    'do not idle or yield merely to stay attached to one issue'
)) { if (-not $wipLine[0].Contains($required)) { throw "WIP rule missing invariant: $required" } }
foreach ($required in @(
    'must not monopolize the turn',
    'another ready canonical issue/North-Star contribution',
    'do not babysit an owned or foreign watcher'
)) { if (-not $pollLine[0].Contains($required)) { throw "anti-poll rule missing invariant: $required" } }
foreach ($required in @(
    'it never reserves the surrounding issue/objective for the claimant',
    'select another ready canonical contribution from open issues / North Star, even when it belongs to a different issue',
    'A short remaining Busy lease, retry-after, CI wait, or build slot is not a reason to skip available useful work',
    'Do not create duplicate mutations or unrelated activity merely to stay busy'
)) { if (-not $blockerLine[0].Contains($required)) { throw "blocker rule missing invariant: $required" } }
foreach ($required in @(
    'A worker has no issue lane to defend',
    'move to a different ready issue/North-Star contribution',
    'do not wait on that contribution merely to preserve narrative continuity'
)) { if (-not $manualLine[0].Contains($required)) { throw "manual rule missing invariant: $required" } }
foreach ($required in @(
    '`go`, `continue`, debugging permission, issue/Busy ownership, generic `fix`, update installation, or a reboot-required state never authorizes rebooting or restarting a machine',
    'requires explicit user wording that unambiguously authorizes restarting that specific machine now',
    'if the current machine routes depend on an interactive login or otherwise cannot recover unattended, that is a restart safety constraint, not implied authorization',
    'must not be promoted into proof that reboot is the correct diagnostic or repair action'
)) { if (-not $rebootLine[0].Contains($required)) { throw "reboot authorization rule missing invariant: $required" } }
foreach ($forbidden in @(
    'on a fresh entry do one bounded reconciliation of the targeted issue/PR/branch/dirty state',
    'no ready canonical issue/North-Star contribution and no safe supported blocker repair/preparation remains',
    'A decision-ready blocker is a valid yield only when no ready in-scope contribution remains',
    'Yield for the failure only when no approved route, no safe blocker repair, and no ready canonical contribution can advance',
    'inside the same established issue/objective',
    'another required same-objective contribution',
    'another ready non-conflicting contribution already required by the established issue/objective',
    'continue the established issue/objective'
)) { if ($text.Contains($forbidden)) { throw "shared rules still encode issue-lane ownership: $forbidden" } }
[ordered]@{
    ok = $true
    issue_is_shared_convergence_not_assignment = $true
    issue_lane_ownership_forbidden = $true
    busy_is_exact_mutation_only = $true
    cross_issue_north_star_fallback_required = $true
    blocker_repair_or_switch_required = $true
    polling_yield_forbidden = $true
    unrelated_busywork_forbidden = $true
    manual_go_pre_final_yield_audit_required = $true
    elapsed_time_never_stop_evidence = $true
    scope_exhaustion_stop_forbidden = $true
    generic_go_never_authorizes_reboot = $true
    explicit_machine_restart_required = $true
} | ConvertTo-Json -Compress
