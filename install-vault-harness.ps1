$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$stableRoot = 'C:\Users\Lauri\.agents'
$stableHook = Join-Path $stableRoot 'vault-session-start.ps1'
$sourceHook = Join-Path $root 'vault-session-start.ps1'
$sync = Join-Path $root 'sync-agent-policy.mjs'
$targets = @(
  'C:\Users\Lauri\.codex\AGENTS.md',
  'C:\Users\Lauri\.claude\CLAUDE.md',
  'C:\Users\Lauri\.config\opencode\AGENTS.md',
  'C:\Users\Lauri\.traycer\agent-selection-guide.md'
)

$oldTargets = $env:POLICY_SYNC_TARGETS
try {
  $env:POLICY_SYNC_TARGETS = [string]::Join([IO.Path]::PathSeparator, $targets)
  & node $sync --apply
  if ($LASTEXITCODE -ne 0) { throw "shared policy sync failed: $LASTEXITCODE" }
} finally {
  $env:POLICY_SYNC_TARGETS = $oldTargets
}

if (-not (Test-Path -LiteralPath $stableRoot -PathType Container)) {
  throw "stable agent root missing: $stableRoot"
}
if (-not [string]::Equals([IO.Path]::GetFullPath($sourceHook), [IO.Path]::GetFullPath($stableHook), [StringComparison]::OrdinalIgnoreCase)) {
  Copy-Item -LiteralPath $sourceHook -Destination $stableHook -Force
}

function Backup-Once([string]$path) {
  $backup = "$path.vault-harness-pre-20260829"
  if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $path -Destination $backup }
}

function Ensure-SessionStartHook([string]$settingsPath) {
  if (-not (Test-Path -LiteralPath $settingsPath -PathType Leaf)) { throw "settings missing: $settingsPath" }
  Backup-Once $settingsPath
  $json = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
  if (-not $json.hooks) { $json | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) }
  if (-not $json.hooks.SessionStart) { $json.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() }
  $command = 'powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Users\Lauri\.agents\vault-session-start.ps1"'
  $exists = @($json.hooks.SessionStart) | Where-Object {
    @($_.hooks) | Where-Object { $_.type -eq 'command' -and $_.command -eq $command }
  }
  if (-not $exists) {
    $entry = [pscustomobject]@{ hooks = @([pscustomobject]@{ type='command'; command=$command; timeout=8 }) }
    $json.hooks.SessionStart = @($entry) + @($json.hooks.SessionStart)
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $settingsPath -Encoding utf8
  }
}

Ensure-SessionStartHook 'C:\Users\Lauri\.claude\settings.json'
Ensure-SessionStartHook 'C:\Users\Lauri\.commandcode\settings.json'

$claude = 'C:\Users\Lauri\.claude\CLAUDE.md'
Backup-Once $claude
$rawBytes = [IO.File]::ReadAllBytes($claude)
$hasBom = $rawBytes.Length -ge 3 -and $rawBytes[0] -eq 239 -and $rawBytes[1] -eq 187 -and $rawBytes[2] -eq 191
$text = Get-Content -LiteralPath $claude -Raw
$eol = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
$text = [regex]::Replace($text, '(?ms)^Bootstrap once per session, before the first mutation:.*?\r?\n\r?\n', '')
$text = [regex]::Replace($text, '(?ms)^BUSY lifecycle, route recovery and proof rules.*?\r?\n\r?\n', '')
$begin = '<!-- VAULT-HARNESS-ADAPTER:BEGIN -->'
$end = '<!-- VAULT-HARNESS-ADAPTER:END -->'
$adapter = @(
  $begin,
  '## Claude Vault adapter',
  '`SessionStart` runs `C:\Users\Lauri\.agents\vault-session-start.ps1` and injects the Vault bootstrap result. If that hook is unavailable, execute the bootstrap command in the generated shared policy directly. ChatGPT Files/Library seeds and GitHub issue-title BUSY are not continuity or ownership fallbacks.',
  $end
) -join $eol
if ($text.Contains($begin) -and $text.Contains($end)) {
  $text = [regex]::Replace($text, '(?s)<!-- VAULT-HARNESS-ADAPTER:BEGIN -->.*?<!-- VAULT-HARNESS-ADAPTER:END -->', $adapter)
} else {
  $sharedEnd = '<!-- SHARED-AGENT-POLICY:END -->'
  $at = $text.IndexOf($sharedEnd)
  if ($at -lt 0) { throw 'Claude shared-policy block missing after sync' }
  $at += $sharedEnd.Length
  $text = $text.Insert($at, "$eol$eol$adapter")
}
$encoding = New-Object System.Text.UTF8Encoding($hasBom)
[IO.File]::WriteAllText($claude, $text, $encoding)

Write-Output 'VAULT_HARNESS_INSTALL=PASS'
