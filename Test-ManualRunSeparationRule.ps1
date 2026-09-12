$ErrorActionPreference = 'Stop'
$rules = Get-Content (Join-Path $PSScriptRoot 'RULES.md') -Raw
$required = @(
  'Ordinary answers, clarifications, acknowledgements, correction-only handling, and incidental small cleanup/read calls are not manual/on-demand worker runs',
  'run_mode: continuation',
  'the correction itself is not a new worker run',
  'current/live status, acceptance state, or actual runtime/connector behavior',
  'duration is never an exemption for this class',
  'they do not create extra worker reports',
  'one report per command or tool call'
)
foreach ($needle in $required) {
  if (-not $rules.Contains($needle)) { throw "missing manual-run separation rule: $needle" }
}
if ($rules -match 'Each substantive manual/on-demand execution turn writes') {
  throw 'obsolete per-turn manual-report wording still present'
}
Write-Output 'PASS manual run separation rule'
