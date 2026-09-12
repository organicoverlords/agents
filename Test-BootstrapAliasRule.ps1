$ErrorActionPreference='Stop'
$rules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'AGENTS.md') -Raw
if (-not $rules.Contains('reserved stable bootstrap alias `process_id="bootstrap"`')) { throw 'RULES missing reserved bootstrap alias' }
if (-not $rules.Contains('Never hard-code or persist a runtime process UUID for bootstrap')) { throw 'RULES missing runtime UUID prohibition' }
if (-not $agents.Contains('reserved stable `process_id="bootstrap"`')) { throw 'AGENTS missing reserved bootstrap alias' }

foreach ($required in @(
    'Snapshot-file age, producer status, Task Scheduler state/result, or a successful manual producer run never proves the persistent bootstrap alias is fresh',
    'when certifying a bootstrap producer/scheduler repair, read the stable alias itself',
    'A fresh degraded bootstrap envelope is current evidence of the refresh failure only'
)) { if (-not $rules.Contains($required)) { throw "RULES missing bootstrap freshness invariant: $required" } }
foreach ($required in @(
    'Producer file age, Task Scheduler results, or direct producer success do not certify the alias',
    'any bootstrap producer/scheduler acceptance must read `process_id="bootstrap"` itself'
)) { if (-not $agents.Contains($required)) { throw "AGENTS missing bootstrap freshness invariant: $required" } }
foreach ($required in @(
    'refresh/re-discover only the needed binding',
    'Never tight-loop an unchanged failure',
    'another retry requires changed binding/schema/authorization/route evidence or a natural recovery boundary'
)) { if (-not $rules.Contains($required)) { throw "RULES missing state-aware bootstrap recovery invariant: $required" } }
foreach ($required in @(
    'refresh/re-discover only that binding',
    'Never tight-loop an unchanged failure',
    'another retry requires changed route/binding/authorization evidence or a natural recovery boundary'
)) { if (-not $agents.Contains($required)) { throw "AGENTS missing state-aware bootstrap recovery invariant: $required" } }
foreach ($forbidden in @('make at most one MCPv4 fallback call', 'use the single MCPv4 `start_process` fallback', 'use the next supported usable machine route once')) {
    if ($rules.Contains($forbidden) -or $agents.Contains($forbidden)) { throw "single-attempt bootstrap ceiling remains: $forbidden" }
}
$uuidPattern = 'process_id="[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"'
if ($rules -match $uuidPattern -or $agents -match $uuidPattern) { throw 'runtime UUID hard-coded as bootstrap process id' }
Write-Host 'BOOTSTRAP_ALIAS_RULE=PASS'
