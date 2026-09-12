Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
$owners = @($rules -split "`r?`n" | Where-Object { $_ -match '^- \*\*LIBRARY `/Inbox` IS THE LAST-RESORT DURABILITY FALLBACK, NOT AN MCP-SPECIFIC ARCHIVE\.\*\*' })
if ($owners.Count -ne 1) { throw "expected one Library Inbox fallback owner; found $($owners.Count)" }
foreach ($required in @(
  'normal canonical durable/reporting route whenever it is usable',
  'GitHub, MCPv4, MCPVisual, Remote Desktop Commander, user-manual PowerShell',
  'handoff_state: TOOLCHAIN_RECOVERY_PENDING',
  '/Inbox` is recovery state, never final archive authority',
  'never repurpose or mutate a scheduled worker merely to carry or reconcile another actor''s report',
  'verify durable landing, then delete only reconciled entries',
  '/Inbox` must be empty whenever all entries have been reconciled',
  'never patch individual automation prompts for it'
)) {
  if (-not $owners[0].Contains($required)) { throw "Library Inbox fallback missing invariant: $required" }
}
$rv = [regex]::Match($rules, 'Shared contract version: (\d+)').Groups[1].Value
$av = [regex]::Match($agents, 'Shared contract version: (\d+)').Groups[1].Value
if ($rv -ne $av) { throw "shared contract version mismatch RULES=$rv AGENTS=$av" }
[ordered]@{ok=$true;toolchain_generic=$true;library_is_last_resort=$true;scheduled_worker_repurpose_forbidden=$true;inbox_drain_required=$true;contract_version=$rv} | ConvertTo-Json -Compress