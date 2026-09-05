$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$required = @(
  'bounded payload bound to the exact captured run',
  'actual inspection of rendered pixels or video frames',
  'paths, storage surfaces, transport metadata, hashes, or pixel gates alone are not acceptance',
  'must inspect its own captured pixels/video',
  'Producer review may record `NOT_PROVEN` or `REJECTED`',
  'must never promote its own capture to `PROVEN`',
  'final `PROVEN` remains an independent visual review',
  'rerender the affected claim rather than relabeling the rejected artifact'
)
foreach ($needle in $required) { if (-not $rules.Contains($needle)) { throw "visual proof rule missing: $needle" } }
foreach ($forbidden in @('must first exist in ChatGPT Library','opened through the native Files surface')) { if ($rules.Contains($forbidden)) { throw "visual proof rule has transport-specific acceptance dependency: $forbidden" } }
Write-Host 'VISUAL_PROOF_REVIEW_RULE=PASS'
