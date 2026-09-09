$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$p3Proof = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'docs\repos\p3\docs\P3_PROOF_PHASES_AND_BATCHING.md') -Raw
$required = @(
  'Visual proof review is **native-image/video-first, with explicit lossless MCP file transfer as the default retrieval route whenever that tool surface is exposed**',
  'every worker/project defaults to `upload_local_file`',
  'Use `download_chatgpt_file` for ChatGPT/Library -> local exact-byte delivery',
  'report byte count plus SHA-256',
  'do not recompress or transcode media/artifacts as stored content',
  '`start_process`/`read_output` are process tools only',
  'legacy `CHATGPT_LIBRARY_UPLOAD=<absolute path>` process-result metadata bridge is transition fallback only',
  'Do not prefer',
  'Drive/Library',
  'actual inspection of the rendered pixels or video frames',
  'paths, storage surfaces, transport metadata, hashes, or pixel gates alone are not acceptance',
  'must inspect its own captured pixels/video',
  'Producer review may record `NOT_PROVEN` or `REJECTED`',
  'must never promote its own capture to `PROVEN`',
  'final `PROVEN` remains an independent visual review',
  'Rerender the affected claim rather than relabeling a rejected artifact'
)
foreach ($needle in $required) { if (-not $rules.Contains($needle)) { throw "visual proof rule missing: $needle" } }
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