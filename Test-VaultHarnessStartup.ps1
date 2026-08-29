$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$policy = Get-Content (Join-Path $root 'SHARED-AGENT-POLICY.md') -Raw
$sync = Get-Content (Join-Path $root 'sync-agent-policy.mjs') -Raw
$hook = Get-Content (Join-Path $root 'vault-session-start.ps1') -Raw
$required = @(
  'python C:\Users\Lauri\Desktop\vault\tools\memory_bank.py bootstrap',
  'fresh_session_startup',
  'harness-local memory/seeds are evidence only',
  'retry that exact command once'
)
foreach ($item in $required) {
  if (-not $policy.Contains($item)) { throw "missing shared Vault startup invariant: $item" }
}
if (-not $sync.Contains('C:/Users/Lauri/.claude/CLAUDE.md')) { throw 'Claude is not a shared-policy sync target' }
foreach ($item in @("Invoke-VaultBootstrap", "fresh_session_startup", "hookEventName = 'SessionStart'", "do not turn memory recovery into the task")) {
  if (-not $hook.Contains($item)) { throw "missing hook contract: $item" }
}
$installer = Get-Content (Join-Path $root 'install-vault-harness.ps1') -Raw
foreach ($item in @('.claude\CLAUDE.md', '.commandcode\settings.json', 'VAULT-HARNESS-ADAPTER:BEGIN', 'vault-session-start.ps1')) {
  if (-not $installer.Contains($item)) { throw "missing installer contract: $item" }
}
$installer = Get-Content (Join-Path $root 'install-vault-harness.ps1') -Raw
if (-not $sync.Contains('.replace(/\r\n?/g, "\n")')) { throw 'sync does not normalize CRLF source text' }
if (-not $installer.Contains('[StringComparison]::OrdinalIgnoreCase')) { throw 'installer lacks stable-hook self-copy guard' }

$temp = Join-Path ([IO.Path]::GetTempPath()) ("vault-harness-crlf-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
  Copy-Item (Join-Path $root 'sync-agent-policy.mjs') (Join-Path $temp 'sync-agent-policy.mjs')
  $policyText = (Get-Content (Join-Path $root 'SHARED-AGENT-POLICY.md') -Raw) -replace "`r?`n", "`r`n"
  [IO.File]::WriteAllText((Join-Path $temp 'SHARED-AGENT-POLICY.md'), $policyText, (New-Object Text.UTF8Encoding($false)))
  $target = Join-Path $temp 'AGENTS.md'
  [IO.File]::WriteAllText($target, "# temp`r`n", (New-Object Text.UTF8Encoding($false)))
  $oldTargets = $env:POLICY_SYNC_TARGETS
  try {
    $env:POLICY_SYNC_TARGETS = $target
    & node (Join-Path $temp 'sync-agent-policy.mjs') --apply | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "CRLF sync apply failed: $LASTEXITCODE" }
  } finally {
    $env:POLICY_SYNC_TARGETS = $oldTargets
  }
  $generated = [IO.File]::ReadAllText($target)
  if ($generated.Contains("`r`r`n")) { throw 'CRLF source produced doubled carriage returns' }
} finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'VAULT_HARNESS_STARTUP_POLICY=PASS'
