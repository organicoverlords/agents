Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

$markerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- `slopwall` is a user correction marker\.' })
if ($markerLines.Count -ne 1) { throw "expected exactly one slopwall rule; found $($markerLines.Count)" }
$marker = $markerLines[0]
foreach ($required in @(
    'Correction handling is answer-first',
    'treat the immediately preceding assistant reply/action as failed against the inherited objective',
    'recover the exact requested result and the missing user-relevant substance',
    'A slopwall is not defined by length: it is substance displacement',
    'filler, meta-commentary, procedural narration, templated structure, promises, weak proxy evidence, premature closure, wrong-objective work, or control-plane/tool drift',
    'The correction is not satisfied by shortening, apologizing, restating the complaint, explaining the failure, or promising a new style',
    'The next user-visible reply must lead with the corrected result',
    'every paragraph kept must materially advance the requested result, evidence, decision, or necessary next action',
    'For an execution request, take a concrete safe execution step before explanatory prose when possible',
    'Never make correction logging a prerequisite to returning the corrected answer',
    'never invent mandatory Slopwall ceremony that delays the inherited task'
)) {
    if (-not $marker.Contains($required)) { throw "slopwall rule missing invariant: $required" }
}

$outputLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*For direct replies to the user only:\*\*' })
if ($outputLines.Count -ne 1) { throw "expected exactly one direct user reply contract; found $($outputLines.Count)" }
$outputRule = $outputLines[0]
foreach ($required in @(
    'answer/result first',
    'only necessary evidence',
    'one next action only if the user actually owns it',
    'does not constrain worker reports, issue/PR records, handoffs, durable artifacts, or other work records'
)) {
    if (-not $outputRule.Contains($required)) { throw "direct user reply contract missing invariant: $required" }
}

$correctionLines = @($agents -split "`r?`n" | Where-Object { $_ -match '^- \*\*User corrections are answer-first, not logging-first\.\*\*' })
if ($correctionLines.Count -ne 1) { throw "expected exactly one durable user-correction owner; found $($correctionLines.Count)" }
$correctionRule = $correctionLines[0]
foreach ($required in @(
    'Obtain proposition-appropriate evidence and give or execute the corrected result before retrospective explanation or durability work',
    'The literal signals `slopwall` and `asshole` do not change this ordering',
    'A compact `memory_bank.py record --kind correction` entry is optional secondary durability only',
    'it must not create an extra tool round trip, delay the corrected answer, broaden scope, or replace the inherited task'
)) {
    if (-not $correctionRule.Contains($required)) { throw "durable correction owner missing invariant: $required" }
}

[ordered]@{
    ok = $true
    slopwall_substance_definition_present = $true
    inherited_task_preserved = $true
    corrected_result_first = $true
    no_logging_or_incident_prerequisite = $true
    no_length_only_fix = $true
} | ConvertTo-Json -Compress
