$ErrorActionPreference = 'Stop'
$docPath = Join-Path $PSScriptRoot 'docs\repos\chatgpt-mcp-clean\LOCAL_HOME_DIRECT_UPDATE_RESTORE_RUNBOOK.md'
$northStarPath = Join-Path $PSScriptRoot 'docs\repos\chatgpt-mcp-clean\NORTH_STAR.md'
if (-not (Test-Path -LiteralPath $docPath -PathType Leaf)) { throw 'missing local home-direct MCP update/restore runbook' }
$doc = [IO.File]::ReadAllText($docPath)
$required = @(
  'https://91-159-12-133.sslip.io/mcp',
  'local HTTPS Caddy -> `127.0.0.1:3022`',
  'clone-a on `127.0.0.1:3011`',
  'Never use the serving MCP route to destroy the control plane carrying that route',
  'HTTP 200 health alone is not proof of independent control',
  'Do not redesign topology during recovery',
  'Do not edit or build candidate source in `%LOCALAPPDATA%\ChatGPTMcpV4HomeDirectStable` while it is serving',
  'active_requests == 0',
  'live_process_count == 0',
  'node scripts/verify-process-contract.mjs',
  'node scripts/test-read-window.mjs',
  'node scripts/test-owner-auth-origin.mjs',
  'test-home-direct-caddy-supervisor.ps1',
  'Authenticated client-visible `tools/list`',
  'start_process -> read_output',
  'Never "restore" by routing GPT1 through VPS/WireGuard/reverse SSH/Tailscale'
)
foreach ($needle in $required) {
  if (-not $doc.Contains($needle)) { throw "local MCP runbook missing invariant: $needle" }
}
foreach ($forbidden in @(
  'VPS Caddy -> WireGuard 10.203.0.2:3011 is the production path',
  '5-61-91-127.sslip.io/mcp` is the connector',
  'kill_process the MCP backend to promote'
)) {
  if ($doc.Contains($forbidden)) { throw "local MCP runbook contains forbidden legacy/destructive instruction: $forbidden" }
}
$northStar = [IO.File]::ReadAllText($northStarPath)
if (-not $northStar.Contains('LOCAL_HOME_DIRECT_UPDATE_RESTORE_RUNBOOK.md')) { throw 'MCP North Star does not link the local update/restore runbook' }
Write-Output 'PASS local-home-direct MCP update/restore runbook guard'