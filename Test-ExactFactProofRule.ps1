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
    'Never answer a historical-status question from a current snapshot',
    'Evidence retrieval precedes clarification',
    'Do not ask the user to supply identifiers, filenames, process IDs, issue/PR numbers, timestamps, historical keywords, or other evidence locators',
    'Ask at most one targeted clarifying question only when two or more materially different propositions remain',
    'Tool/source uncertainty is not user ambiguity',
    'Never turn factual verification into an interrogation loop',
    'Contradictory evidence is a hard reconciliation gate',
    'Evidence authority is proposition-specific, not a global source ranking',
    'event time versus observation time',
    'A stale source cannot disprove a fresher source about the same current state',
    'a current source cannot erase a historical event proved for an earlier interval',
    'If the contradiction cannot be resolved from authoritative evidence, answer `UNKNOWN` or explicitly `CONFLICT`',
    'never manufacture one truth from unresolved disagreement',
    'Entailment strength must never increase in the answer',
    'direct `OBSERVED`, logically `ENTAILED`',
    'An inference, hypothesis, likely explanation, correlation, or temporal ordering must not be worded as observed/proven fact',
    'Never convert sequence into causality, replacement into downtime, process disappearance into a kill by a particular actor',
    'answer `UNKNOWN` for that stronger proposition even when weaker adjacent facts are known',
    'Observation-channel failure is not target-state evidence',
    'establishes `OBSERVATION_FAILED` for that measurement attempt',
    'It does not establish that the target service/process/file/event is down, exited, missing, absent, unchanged, or never happened',
    'Do not convert `read_output` disconnect into process exit',
    'an empty search into nonexistence',
    'if no independent proof is available, answer `UNKNOWN` and distinguish the failed observation channel from the target state',
    'Repeating the same failed probe does not strengthen the target-state claim',
    'Quantifiers determine the required proof coverage',
    'A single authoritative witness inside the requested domain/interval is sufficient to prove an existential positive',
    'a negative existential (`never`, `none`, `did not happen at any point`), a universal (`all`/`every`), or an exact count requires coverage of the entire relevant domain/interval',
    'Partial enumeration may support only `at least N`',
    'If exhaustive coverage needed by the quantifier is unavailable, answer `UNKNOWN`',
    'Never use a short current sample to answer `ever/never`'
)) {
    if ($rules.IndexOf($required, [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "RULES missing exact-fact proof invariant: $required" }
}

foreach ($required in @(
    'Apply the `RULES.md` exact-fact proof gate before status or factual claims',
    'tool choice follows the proposition that must be proved',
    'never substitute current liveness for historical continuity',
    'never substitute process existence for route usability',
    'never substitute test/merge state for deployed runtime behavior',
    'report `UNKNOWN` rather than answering a nearby easier question',
    'Apply **evidence-before-clarification** to factual work',
    'Resolve evidence locators from the conversation and available tools rather than asking the user to repeat discoverable facts',
    'Ask no more than one targeted clarification',
    'A clear proposition with unavailable proof yields `UNKNOWN`',
    'Apply the shared **contradiction-reconciliation gate** whenever relevant evidence disagrees',
    'Derived snapshots accelerate retrieval but never gain authority over their origin',
    'Do not hide a contradiction by citing only one side',
    'report `UNKNOWN`/`CONFLICT` with the scoped competing facts',
    'Preserve **entailment strength** in factual answers',
    'Do not promote `INFERRED` conclusions to `OBSERVED`/`ENTAILED` facts',
    'For stronger yes/no propositions that remain unproved, answer `UNKNOWN` first',
    'Keep **observation-channel state separate from target state**',
    'Tool/transport/query failure is `OBSERVATION_FAILED`, not evidence that the target is dead/missing/absent',
    'Never use repeated identical probe failures as accumulating proof',
    'Preserve **quantifier coverage**',
    'One authoritative witness proves an existential positive (`ever`, `at least one`)',
    'Universal/negative/exact-total claims (`all`, `every`, `none`, `never`, `exactly N`, `how many`) require exhaustive relevant coverage',
    'Incomplete coverage yields `UNKNOWN` for the total/universal/negative claim'
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
