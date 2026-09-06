Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = [IO.File]::ReadAllText($rulesPath)
$lines = @($text -split "`r?`n" | Where-Object { $_ -match '^- `slopwall` is a response-quality failure:' })
if ($lines.Count -ne 1) { throw "expected exactly one slopwall substance rule; found $($lines.Count)" }
$rule = $lines[0]
foreach ($required in @(
    'too little user-relevant substance',
    'Length is not the definition',
    'a one-line acknowledgement can be a slopwall',
    'a long answer is not one when its detail is necessary and substantive',
    'silently integrate that correction into response/action selection',
    'return to the inherited task with new substance',
    'do not make `slopwall` the topic by defining it, apologizing, paraphrasing the correction',
    'lead with the answer and default to one short paragraph',
    'diagnosis/status/policy/reporting is not a substitute for performing the bounded requested work'
)) {
    if (-not $rule.Contains($required)) { throw "slopwall substance rule missing invariant: $required" }
}
foreach ($forbidden in @(
    'slopwall means a long answer',
    'slopwall means too many words',
    'always keep answers short'
)) {
    if ($rule.Contains($forbidden)) { throw "slopwall rule contains length-only heuristic: $forbidden" }
}

[ordered]@{
    ok = $true
    substance_not_length = $true
    short_regurgitation_can_fail = $true
    correction_resumes_inherited_task = $true
    execution_not_replaced_by_meta = $true
} | ConvertTo-Json -Compress
