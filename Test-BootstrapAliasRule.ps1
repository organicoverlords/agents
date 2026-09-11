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
$uuidPattern = 'process_id="[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"'
if ($rules -match $uuidPattern -or $agents -match $uuidPattern) { throw 'runtime UUID hard-coded as bootstrap process id' }
Write-Host 'BOOTSTRAP_ALIAS_RULE=PASS'
