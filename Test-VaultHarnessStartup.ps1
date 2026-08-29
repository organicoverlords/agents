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
Write-Output 'VAULT_HARNESS_STARTUP_POLICY=PASS'
