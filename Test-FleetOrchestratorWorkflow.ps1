[CmdletBinding()]
param(
    [string]$AgentsRoot = 'C:\Users\Lauri\.agents'
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

function Require-Match {
    param([string]$Text, [string]$Pattern, [string]$Scenario)
    if ($Text -notmatch $Pattern) { $failures.Add($Scenario) }
}

$customPath = Join-Path $AgentsRoot 'chatgpt-custom-instructions.md'
$memoryPath = Join-Path $AgentsRoot 'chatgpt-memory-seed.md'
$skillPath = Join-Path $AgentsRoot 'skills\orchestrate-fleet\SKILL.md'
$interfacePath = Join-Path $AgentsRoot 'skills\orchestrate-fleet\agents\openai.yaml'

$custom = if (Test-Path -LiteralPath $customPath) {
    Get-Content -LiteralPath $customPath -Raw
} else {
    $failures.Add('worker default instructions exist')
    ''
}

if ($custom -match '(?im)^Paste into Settings') {
    $failures.Add('day-to-day workflow requires no pasted startup note')
}
Require-Match $custom '(?is)explicit.*\$orchestrate-fleet' 'fleet orchestration starts only through the explicit skill'
Require-Match $custom '(?is)worker.*own.*BUSY' 'ordinary workers own their GitHub and MCP BUSY lifecycle'
Require-Match $custom '(?is)stale.*block.*continue' 'every worker clears stale blockers and keeps going'

$memory = if (Test-Path -LiteralPath $memoryPath) {
    Get-Content -LiteralPath $memoryPath -Raw
} else {
    $failures.Add('ChatGPT web memory source exists')
    ''
}

if (-not (Test-Path -LiteralPath $skillPath)) {
    $failures.Add('orchestrate-fleet skill exists')
    $skill = ''
} else {
    $skill = Get-Content -LiteralPath $skillPath -Raw
}

if (-not (Test-Path -LiteralPath $interfacePath)) {
    $failures.Add('skill interface exists')
    $interface = ''
} else {
    $interface = Get-Content -LiteralPath $interfacePath -Raw
}

Require-Match $interface 'allow_implicit_invocation:\s*false' 'orchestrator skill is explicit-only'
Require-Match $skill '(?is)saved memory.*live.*MCP' 'skill delegates durable workflow to ChatGPT memory and live MCP state'
if (($skill -split '\s+').Count -gt 160) {
    $failures.Add('explicit orchestrator skill stays small')
}
Require-Match $memory '(?is)five timed.*chat' 'ChatGPT memory covers all five timed chats'
Require-Match $memory '(?is)worker.*claim.*BUSY.*release' 'ChatGPT memory says each worker owns BUSY'
Require-Match $memory '(?is)stale.*block.*continue' 'ChatGPT memory says every worker self-recovers stale blockers'
Require-Match $memory '(?is)issues?.*pull requests?.*NORTH_STAR.*MCP.*machine' 'ChatGPT memory holds the full fleet orientation contract'
Require-Match $memory '(?is)report.*then.*take' 'ChatGPT memory says the orchestrator reports, then takes work'

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL: $_" }
    Write-Host "RESULT=FAIL count=$($failures.Count)"
    exit 1
}

Write-Host 'RESULT=PASS scenarios=12'
