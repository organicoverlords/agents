Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($doc in @($rules, $agents)) {
  if ($doc -notmatch '(?m)^Shared contract version:\s*[1-9][0-9]*\s*$') { throw 'shared contract version header is missing' }
}
foreach ($required in @(
  'Do not ask the user for permission or merely narrate the workaround',
  'Repeated recurrence makes the owner repair load-bearing work, not optional cleanup'
)) {
  if (-not $rules.Contains($required)) { throw "RULES missing routine-trap invariant: $required" }
}
foreach ($required in @(
  'Busy mutation idempotency is per semantic mutation',
  'never reuse one `--operation-id` across different claim, release, heartbeat, or recovery operations/scopes',
  'Do not leave a known recurring trap as a prose-only worker note',
  'add the narrowest executable recurrence check in the same run without asking the user'
)) {
  if (-not $agents.Contains($required)) { throw "AGENTS missing routine-trap invariant: $required" }
}
Write-Output 'PASS routine-trap-closure-rule'
