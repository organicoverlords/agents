$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$required = @(
  'must inspect its own actual captured pixels/video',
  'Producer review may record `NOT_PROVEN` or `REJECTED`',
  'must never promote its own capture to `PROVEN`',
  'final `PROVEN` remains an independent visual review',
  'exact review image must first exist in ChatGPT Library',
  'opened through the native Files surface'
)
foreach ($needle in $required) { if (-not $rules.Contains($needle)) { throw "visual proof rule missing: $needle" } }
Write-Host 'VISUAL_PROOF_REVIEW_RULE=PASS'
