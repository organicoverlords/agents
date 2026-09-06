$ErrorActionPreference = 'Stop'
$rulesPath = Join-Path $PSScriptRoot 'RULES.md'
$text = Get-Content -LiteralPath $rulesPath -Raw
$required = 'OpenAI/ChatGPT platform security controls, reroutes, blocks, and equivalent platform-side security events are outside local MCP engineering telemetry and incident tracking.'
if (-not $text.Contains($required)) {
    throw 'RULES.md must explicitly keep platform security events outside local MCP telemetry and incident tracking.'
}
if ($text.Contains('treat the report itself as required evidence capture')) {
    throw 'RULES.md must not require platform security-event evidence capture.'
}
if ($text.Contains('mcp-security-routing-events.jsonl')) {
    throw 'RULES.md must not route platform security events into the old MCP security-routing event log.'
}
foreach ($requiredRecovery in @(
    'MCP recovery state has one canonical discoverable pointer',
    'Recovery-target selection is not a health verdict',
    'Never create a candidate/proven promotion label',
    'Conditions use `True`/`False`/`Unknown`'
)) {
    if (-not $text.Contains($requiredRecovery)) { throw "MCP recovery-state invariant missing: $requiredRecovery" }
}
if (-not $text.Contains('Never attempt to disable, evade, or bypass platform security controls.')) {
    throw 'RULES.md must preserve the no-bypass boundary.'
}
Write-Output 'PASS platform-security-tracking-rule'

