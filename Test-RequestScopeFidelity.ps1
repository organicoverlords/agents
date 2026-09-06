$ErrorActionPreference = 'Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
foreach ($required in @(
    'Scope fidelity is a hard completion rule',
    "The user's current explicit request defines the operation and its completion boundary",
    'Availability of another supported tool call is never by itself a reason to continue',
    '`go` means continue the already-established scope',
    'Never use GitHub, CI, Vault, Busy, build/runtime state, or tool reads as a keepalive or progress-polling surface',
    'prompt-local completion or a decision-ready checkpoint is a valid yield boundary',
    'remote publication must be separately explicit'
)) {
    if (-not $rules.Contains($required)) { throw "RULES missing request-scope invariant: $required" }
}
foreach ($forbidden in @(
    'If another supported tool call can still be issued',
    'actionable work must continue',
    'continue across sequential safe useful actions until the task-level objective is complete'
)) {
    if ($rules.Contains($forbidden)) { throw "RULES retains churn incentive: $forbidden" }
}
foreach ($required in @(
    'Follow the prompt-local scope-fidelity rule in `RULES.md`',
    'Do not poll unchanged state',
    "the user's requested operation is the completion boundary"
)) {
    if (-not $agents.Contains($required)) { throw "AGENTS missing request-scope invariant: $required" }
}
[ordered]@{
    ok = $true
    prompt_local_completion = $true
    tool_exhaustion_forbidden = $true
    unchanged_polling_forbidden = $true
    remote_memory_publication_explicit = $true
} | ConvertTo-Json -Compress
