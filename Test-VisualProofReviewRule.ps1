$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$p3Proof = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'docs\repos\p3\docs\P3_PROOF_PHASES_AND_BATCHING.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
$required = @(
  'VISION TRANSPORT IS PLUGIN-ONLY AND FAIL-CLOSED FOR THE VISUAL CLAIM, NOT FOR THE WHOLE TASK',
  '`MCPVisual.upload_local_file` / the exposed dedicated `upload_local_file` tool',
  'Base64 and alternate byte-smuggling routes are absolutely prohibited for vision',
  '`start_process`/`read_output` upload metadata bridges',
  'Drive/Library detours',
  'actual native inspection of the rendered pixels or video frames',
  'VISUAL PROOF PACKAGING HAPPENS AT PRODUCER COMPLETION, NOT LATER',
  'first asset render, explicit multi-asset batch completion, or live/editor/PIE/live-coding capture completion',
  'one transient ZIP carrying the exact original media plus a compact manifest',
  'silently fall back to N individual uploads if packaging fails',
  '12-VIEW PROOF TRANSFERS ARE ASSET-BATCHED AND ORIGINAL-FIDELITY',
  'Transfer it once through `MCPVisual.upload_local_file` / the exposed dedicated `upload_local_file` tool',
  'inspect all twelve panels thoroughly with native vision in that exposure',
  'Do **not** substitute thumbnails, reduced per-view preview derivatives, or a recomposed lower-resolution contact sheet',
  'If no original producer sheet exists but a complete standardized 12-view set already exists as canonical individual images',
  'do not create a reviewer-authored contact sheet',
  'Package the exact standardized images once using the transient ZIP+manifest rule below',
  'A combined/recomposed sheet is allowed only when it is itself the owning renderer/grid builder''s canonical standardized output or an explicit acceptance artifact',
  'Never alter background, exposure, lighting, crop, scale/resolution, tone/color, or panel layout merely to make review transport convenient',
  'If a prior verdict was made only from reduced derivatives while the original full sheet existed, treat that verdict as provisional',
  'must inspect its own captured pixels/video',
  'Producer review may record `NOT_PROVEN` or `REJECTED`',
  'must never promote its own capture to `PROVEN`',
  'final `PROVEN` remains an independent visual review',
  'Rerender the affected claim rather than relabeling a rejected artifact'
)
foreach ($needle in $required) { if (-not $rules.Contains($needle)) { throw "visual proof rule missing: $needle" } }
$requiredRouting = @(
  'Package retained visual proof at completion',
  'first asset-render completion, explicit asset-batch completion, or live/editor/PIE/live-coding capture completion',
  'Multi-file payloads use one transient ZIP with exact originals plus existing labels, relative paths, byte counts, and SHA-256 manifest',
  'Route a 12-view review as one original-fidelity media transfer',
  'transfer that exact sheet once over the approved `MCPVisual.upload_local_file` / `upload_local_file` route and inspect every panel in that exposure',
  'Never substitute thumbnails, reduced per-view previews, or a recomposed lower-resolution contact sheet',
  'If no original producer sheet exists but the complete standardized 12-view set already exists as canonical individual images',
  'do not invent a reviewer-authored contact sheet',
  'package those exact originals once in the transient ZIP+manifest form and inspect the declared originals after transfer',
  'A combined/recomposed sheet is valid only when it is the owning renderer/grid builder''s canonical standardized output or an explicit acceptance artifact',
  'Never change background, exposure, lighting, crop, scale/resolution, tone/color, or panel layout merely for review convenience',
  'Any verdict made only from reduced derivatives while the original existed is provisional until the original full sheet is reviewed'
)
foreach ($needle in $requiredRouting) { if (-not $agents.Contains($needle)) { throw "visual routing rule missing: $needle" } }
$forbiddenRoutes = @(
  'must first exist in ChatGPT Library',
  'opened through the native Files surface',
  ('Google Drive' + ' -> ChatGPT Library'),
  ('record the Library consumer gate as unmet' + ' rather than substituting another transport'),
  'every worker/project defaults to the existing MCP process-result metadata bridge'
)
foreach ($forbidden in $forbiddenRoutes) {
  if ($rules.Contains($forbidden) -or $p3Proof.Contains($forbidden)) { throw "visual proof policy has transport-specific acceptance dependency: $forbidden" }
}
Write-Host 'VISUAL_PROOF_REVIEW_RULE=PASS'