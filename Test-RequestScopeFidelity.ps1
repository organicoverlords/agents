$ErrorActionPreference = 'Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
foreach ($required in @(
    'Scope fidelity is a hard completion rule',
    "The user's current explicit request defines the operation and its completion boundary",
    'Availability of another supported tool call is never by itself a reason to continue',
    '`go`/`continue` in a manual/on-demand execution chat means resume the already-established unresolved engineering objective',
    'carry the next coherent contribution through its normal completion path',
    'publication/integration or merge when that is already the established completion path and its gates pass',
    'Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive or progress-polling surface',
    'a prompt-local plan, status update, open PR, partial validation result, or decision-ready checkpoint is not a yield boundary',
    'Manual `go` does not imply timed-fleet supervision or scheduler work',
    'remote publication must be separately explicit'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing request-scope invariant: $required" }
}
foreach ($forbidden in @(
    'If another supported tool call can still be issued',
    'actionable work must continue',
    'continue across sequential safe useful actions until the task-level objective is complete',
    'yield after that operation plus necessary validation or at a decision-ready checkpoint'
)) {
    if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "shared policy retains stale/churn behavior: $forbidden" }
}
foreach ($required in @(
    'Follow the prompt-local scope-fidelity rule in `RULES.md`',
    'Do not poll unchanged state',
    'follow the `go`/`continue` completion and yield semantics in `RULES.md`'
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing request-scope invariant: $required" }
}
[ordered]@{
    ok = $true
    manual_go_continuation = $true
    manual_go_lands_coherent_contribution = $true
    tool_exhaustion_forbidden = $true
    unchanged_polling_forbidden = $true
    remote_memory_publication_explicit = $true
} | ConvertTo-Json -Compress
