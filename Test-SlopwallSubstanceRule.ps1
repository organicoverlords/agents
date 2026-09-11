Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

$markerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- `slopwall` is a user correction marker\.' })
if ($markerLines.Count -ne 1) { throw "expected exactly one compact slopwall correction marker; found $($markerLines.Count)" }
$marker = $markerLines[0]
foreach ($required in @(
    'Correction handling is answer-first',
    'give/execute the corrected result before any retrospective explanation, learning record, or process commentary',
    'Never make correction logging a prerequisite to returning the corrected answer'
)) {
    if (-not $marker.Contains($required)) { throw "slopwall marker missing invariant: $required" }
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

if ($rules -match '(?m)^- `slopwall` is a response-quality failure:') {
    throw 'obsolete inline slopwall response-style mini-contract returned to RULES.md'
}

[ordered]@{
    ok = $true
    compact_marker_in_rules = $true
    durable_correction_owner_in_agents = $true
    direct_user_reply_contract_present = $true
    obsolete_inline_response_contract_absent = $true
} | ConvertTo-Json -Compress
