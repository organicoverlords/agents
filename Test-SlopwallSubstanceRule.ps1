Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

$markerLines = @($rules -split "`r?`n" | Where-Object { $_ -match '^- `slopwall` is a user correction marker\.' })
if ($markerLines.Count -ne 1) { throw "expected exactly one compact slopwall correction marker; found $($markerLines.Count)" }
$marker = $markerLines[0]
foreach ($required in @(
    'Apply the correction and continue the inherited task',
    'durable correction handling is defined in `AGENTS.md`'
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

$correctionLines = @($agents -split "`r?`n" | Where-Object { $_ -match '^- User-corrected assistant missteps are mandatory local Vault learning\.' })
if ($correctionLines.Count -ne 1) { throw "expected exactly one durable user-correction owner; found $($correctionLines.Count)" }
$correctionRule = $correctionLines[0]
foreach ($required in @(
    'The literal user signal `slopwall` always qualifies as a correction incident',
    'record it before returning control',
    'continue the inherited task with the missing substance',
    'Do not turn the reply into response-style discussion'
)) {
    if (-not $correctionRule.Contains($required)) { throw "durable slopwall correction owner missing invariant: $required" }
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
