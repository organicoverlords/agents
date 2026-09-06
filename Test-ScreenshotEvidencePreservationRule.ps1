Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$line = @($text -split "`r?`n" | Where-Object { $_ -match '^- When the user explicitly asks to preserve a screenshot or screenshot-described incident in Vault/history,' })
if ($line.Count -ne 1) { throw "expected exactly one screenshot evidence preservation rule; found $($line.Count)" }
foreach ($required in @(
  'default to **text + reference**, not byte transfer',
  'existing conversation attachment path, file ID, or other already-available reference',
  'Do **not** copy, materialize, base64-encode, chunk, re-encode, OCR, re-hash, repeatedly reread',
  'shuttle screenshot/image bytes merely to archive them',
  'user explicitly requests byte-level preservation/chain-of-custody',
  'fall back immediately to text + existing reference',
  'do not retry through alternate screenshot-transfer encodings',
  'recursive evidence-preservation work'
)) {
  if (-not $line[0].Contains($required)) { throw "screenshot evidence preservation rule missing invariant: $required" }
}
[ordered]@{ok=$true; text_reference_default=$true; byte_shuttling_forbidden=$true; recursive_retries_forbidden=$true} | ConvertTo-Json -Compress
