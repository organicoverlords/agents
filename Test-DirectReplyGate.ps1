Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$owners = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*DIRECT REPLIES ARE RESEARCH-DEEP AND OUTPUT-LEAN\.\*\*' })
if ($owners.Count -ne 1) { throw "expected one direct-reply gate; found $($owners.Count)" }
foreach ($required in @(
  'silent pre-final gate',
  'do not confuse a short answer with shallow work',
  'use proposition-appropriate evidence',
  'refresh materially changeable facts from the current/live owner',
  'Investigation may be as deep as needed',
  'Then compress the user-visible answer',
  'Remove tool chronology, process narration, source inventories, repeated caveats, implementation trivia, and background',
  'one to three compact paragraphs',
  'at most five bullets',
  'This gate is internal',
  'never dump the audit, research process, or hidden work onto the user as ceremony'
)) {
  if (-not $owners[0].Contains($required)) { throw "direct-reply gate missing invariant: $required" }
}
foreach ($required in @('Exact-fact proof is a hard answer gate','LIVE/CURRENT WORK TRUTH IS MCP-GROUNDED.','answer/result first','only necessary evidence')) {
  if ($rules.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "lost truth/relevance invariant: $required" }
}
foreach ($required in @('research-deep/output-lean direct-reply gate','refresh materially changeable facts from proposition-appropriate current/live evidence','compress the final reply to the result','Do not expose tool chronology, evidence inventories, internal audit steps, or research volume')) {
  if ($agents.IndexOf($required,[StringComparison]::OrdinalIgnoreCase) -lt 0) { throw "AGENTS missing direct-reply gate invariant: $required" }
}
[ordered]@{ok=$true;research_depth_decoupled_from_reply_length=$true;live_truth_required_when_changeable=$true;pre_final_compression_required=$true;process_dump_forbidden=$true;user_visible_audit_forbidden=$true} | ConvertTo-Json -Compress
