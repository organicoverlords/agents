$ErrorActionPreference = 'Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw

foreach ($required in @(
    'Exact-fact proof is a hard answer gate',
    'reduce the user''s question to the exact proposition',
    'subject, time window, scope, and polarity',
    'Evidence that proves an adjacent proposition must not be promoted into an answer',
    'A current-health snapshot proves only current health, not continuity',
    'A running process does not prove an authenticated or usable route',
    'Passing tests or a merged PR does not prove deployment or live improvement',
    'Absence of a matching record does not prove an event did not happen',
    'If direct evidence for the exact proposition is unavailable, answer `UNKNOWN`',
    'Historical or continuity claims require interval or lifecycle evidence spanning the relevant window',
    'Causal claims require evidence of the mechanism or transition, not merely temporal correlation',
    'Negative claims require coverage evidence that the authoritative source would have recorded the event',
    'Answer the exact fact before explanation or retrospective commentary',
    'Verify **proposition-appropriate evidence** before status claims',
    'historical, continuity, outage, restart, or “at any point” claims require lifecycle/interval evidence covering the requested window',
    'Never answer a historical-status question from a current snapshot'
)) {
    if ($rules.IndexOf($required, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "RULES missing exact-fact proof invariant: $required" }
}

foreach ($required in @(
    'Apply the `RULES.md` exact-fact proof gate before status or factual claims',
    'tool choice follows the proposition that must be proved',
    'never substitute current liveness for historical continuity',
    'never substitute process existence for route usability',
    'never substitute test/merge state for deployed runtime behavior',
    'report `UNKNOWN` rather than answering a nearby easier question'
)) {
    if ($agents.IndexOf($required, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "AGENTS missing exact-fact proof invariant: $required" }
}

foreach ($forbidden in @(
    'current health implies continuity',
    'process exists, therefore route is usable',
    'tests passed, therefore runtime is improved'
)) {
    if ($rules.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or $agents.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase) -ge 0) { throw "shared policy contains forbidden fact substitution: $forbidden" }
}

[ordered]@{
    ok = $true
    exact_proposition_required = $true
    adjacent_evidence_substitution_forbidden = $true
    continuity_requires_interval_evidence = $true
    causality_requires_mechanism_evidence = $true
    negatives_require_coverage_evidence = $true
    unknown_is_required_when_unproved = $true
} | ConvertTo-Json -Compress
