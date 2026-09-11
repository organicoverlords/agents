$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$p3Proof = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'docs\repos\p3\docs\P3_PROOF_PHASES_AND_BATCHING.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
$required = @(
  'VISUAL ACCEPTANCE IS PIXEL-GATED; METRICS NEVER SUBSTITUTE',
  'VISION ACCESS IS NATIVE/DURABLE-FIRST AND FAIL-CLOSED FOR THE VISUAL CLAIM, NOT FOR THE WHOLE TASK',
  'Durable Library reopen is canonical retrieval, not a transport detour',
  'A ZIP/archive is never visual-review transport',
  'actual native inspection of rendered pixels or video frames',
  'RETAINED VISUAL PROOF GETS DURABLE IDENTITY AT PRODUCER COMPLETION; CHAT TRANSFER IS ON-DEMAND',
  'session expiry must be recoverable from durable proof/media identity',
  '12-VIEW REVIEW REUSES CANONICAL ORIGINALS; ARCHIVES AND REVIEWER COMPOSITES ARE NOT TRANSPORT',
  'reopen the persistent originals by durable identity when available',
  'otherwise transfer the individual originals directly in a bounded sequence of `upload_local_file` calls',
  'Do not ZIP them, do not create a reviewer-authored contact sheet',
  'ALREADY-EXPOSED MEDIA IS REUSED IN PLACE; PRESENTATION IS NOT A NEW TRANSPORT'
)
foreach ($needle in $required) { if (-not $rules.Contains($needle)) { throw "visual proof rule missing: $needle" } }
$requiredRouting = @(
  'Pixel-inspect visual outputs before handoff',
  'Give retained visual proof durable identity at completion; expose it to chat only when needed',
  'Session expiry is a retrieval event, not a reason to regenerate or redesign transport',
  'Review 12-view proof from canonical originals, never archive transport',
  'reopen its durable Library identity',
  'do not ZIP them and do not invent a reviewer-authored contact sheet',
  'Reuse already-exposed media directly'
)
foreach ($needle in $requiredRouting) { if (-not $agents.Contains($needle)) { throw "visual routing rule missing: $needle" } }
$forbidden = @('Drive/Library detours','one transient ZIP carrying the exact original media plus a compact manifest','Multi-file payloads use one transient ZIP','transient ZIP+manifest')
foreach ($needle in $forbidden) { if ($rules.Contains($needle) -or $agents.Contains($needle)) { throw "obsolete review transport returned: $needle" } }
if (-not $p3Proof.Contains('Google Drive') -or -not $p3Proof.Contains('ChatGPT Library')) { throw 'P3 proof documentation lost canonical durable Library consumer route' }
Write-Host 'VISUAL_PROOF_REVIEW_RULE=PASS'
