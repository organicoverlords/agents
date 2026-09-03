[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$syncPath = Join-Path $root 'sync-agent-policy.mjs'
$auditPath = Join-Path $root 'audit-repo-sections.mjs'
$syncSource = Get-Content -Raw -LiteralPath $syncPath
$auditSource = Get-Content -Raw -LiteralPath $auditPath
$policyPath = Join-Path $root 'SHARED-AGENT-POLICY.md'
$policySource = Get-Content -Raw -LiteralPath $policyPath
$customInstructionsPath = Join-Path $root 'chatgpt-custom-instructions.md'
$customInstructionsSource = Get-Content -Raw -LiteralPath $customInstructionsPath
if ($customInstructionsSource -notmatch [regex]::Escape('MCP0 is retired and must not be used')) { throw 'CUSTOM_INSTRUCTIONS_MCP0_RETIREMENT_MISSING' }
foreach ($forbidden in @('load the seed', 'before you answer anything at all', 'MCP0 connector', 'chatgpt-memory-seed.md')) {
    if ($customInstructionsSource -match [regex]::Escape($forbidden)) { throw "CUSTOM_INSTRUCTIONS_STALE_BOOTSTRAP=$forbidden" }
}
foreach ($required in @('Use the current conversation and ChatGPT Memory for continuity', 'Vault is optional searchable history', 'verify the smallest relevant live surface', 'Match process to risk', 'normally plugin2 when available', 'Commander and', 'GitHub are permitted fallbacks', 'do not use either ahead of a working plugin2 route')) {
    if ($customInstructionsSource -notmatch [regex]::Escape($required)) { throw "CUSTOM_INSTRUCTIONS_REQUIRED_RULE_MISSING=$required" }
}
function Invoke-GitQuiet([string[]]$GitArgs) {
    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & git @GitArgs *> $null
        $rc = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($rc -ne 0) { throw "POLICY_TEST_GIT_FAILED=$rc args=$($GitArgs -join ' ')" }
}

$skillRoot = Join-Path $root 'skills'
foreach ($skill in Get-ChildItem -LiteralPath $skillRoot -Recurse -Filter 'SKILL.md' -File) {
    $bytes = [IO.File]::ReadAllBytes($skill.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        throw "SKILL_UTF8_BOM_FORBIDDEN=$($skill.FullName)"
    }
    $skillSource = [IO.File]::ReadAllText($skill.FullName)
    $frontmatter = [regex]::Match($skillSource, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $frontmatter.Success) { throw "SKILL_FRONTMATTER_MISSING=$($skill.FullName)" }
    $body = $frontmatter.Groups['body'].Value
    if ($body -notmatch '(?m)^name:\s*\S') { throw "SKILL_NAME_MISSING=$($skill.FullName)" }
    if ($body -notmatch '(?m)^description:\s*\S') { throw "SKILL_DESCRIPTION_MISSING=$($skill.FullName)" }
}
if ($policySource -notmatch '(?m)^\*\*Version \d+\.\d+ - \d{4}-\d{2}-\d{2}\.\*\*') { throw 'POLICY_VERSION_HEADER_MISSING' }
foreach ($required in @(
    '### Route failure is local',
    'scheduled task prompt is current instruction for that run',
    'Do not centralize routine resilience',
    'Prefer production `MCPv3` via VPS',
    'MCPv3 start_process` is Windows PowerShell 5.1',
    'NativeCommandError',
    '$LASTEXITCODE',
    'Never hand-build JSON with report text',
    'ConvertTo-Json',
    'preserve the finding in the project issue/PR',
    'Checkpoints are context, never queue/priority state',
    '### Coordination and BUSY',
    'Every claim actor must identify its harness',
    'task/session suffix',
    'standalone coordinator defined by current live repo/runtime state is collision/ownership authority only',
    'records are coordination bookkeeping, never backlog',
    'Dirty/behind state is not a blocker or proof of current behavior',
    'before opening a fix lane',
    'verify current live/default acceptance still fails',
    'never hard-code or redirect output into a human/shared checkout',
    'Never update it silently; disclose every change in the same reply',
    'Project-specific machinery belongs in the narrowest repo, skill, adapter, automation prompt, or test that owns it'
)) {
    if ($policySource -notmatch [regex]::Escape($required)) { throw "POLICY_REQUIRED_INVARIANT_MISSING=$required" }
}
foreach ($forbidden in @(
    '### Never stop',
    '### Worker reporting',
    'Progress: <N>%',
    'current multi-plugin reliability trial',
    '`plugin5`',
    'A player-visible claim needs a rendered frame',
    'MUST NOT be merged, closed, or ticked',
    'Prompts, schedules, names, receipts and handoffs describe the past',
    'No roles, no reserved work',
    'fleet owner/coordinator owns fleet health',
    'recent-title window',
    'An active process_id, BUSY scope, unfinished mutation',
    'A dirty worktree is a reconciliation obligation',
    'do not substitute origin/main or isolate merely because main is dirty/behind',
    'Producer backpressure is mandatory',
    'completed or idle PR awaiting integration is fleet debt',
    'Open-PR count is work to reconcile',
    'merge immediately',
    'MCP0 BUSY is the single live ownership authority',
    'memory_bank.py recent'
)) {
    if ($policySource -match [regex]::Escape($forbidden)) { throw "POLICY_ACCRETION_REGRESSION=$forbidden" }
}
if ($syncSource -notmatch [regex]::Escape('const MAX_BLOCK_BYTES = 8000;')) { throw 'POLICY_SIZE_CAP_NOT_8000' }
if ($syncSource -notmatch [regex]::Escape('C:/Users/Lauri/Desktop/vault/AGENTS.md')) { throw 'POLICY_VAULT_SYNC_TARGET_MISSING' }
if ($syncSource -match [regex]::Escape('C:/Users/Lauri/Desktop/lowvram3d-studio-p0a-worktree/AGENTS.md')) { throw 'POLICY_DEAD_P0A_SYNC_TARGET_PRESENT' }
if ($syncSource -match [regex]::Escape('C:/Users/Lauri/Desktop/TinyLab/AGENTS.md')) { throw 'POLICY_ARCHIVED_TINYLAB_SYNC_TARGET_PRESENT' }
foreach ($marker in @('check-remotes', 'REMOTE_DRIFTED', 'REMOTE_MISSING', 'REMOTE_UNAVAILABLE', 'git-backed origin defaults match the source')) {
    if ($syncSource -notmatch [regex]::Escape($marker)) { throw "POLICY_REMOTE_SYNC_GUARD_MISSING=$marker" }
}
foreach ($marker in @('DIRTY_TARGET_REFUSED', 'dirtyRefused', 'planned')) {
    if ($syncSource -notmatch [regex]::Escape($marker)) { throw "POLICY_DIRTY_TARGET_GUARD_MISSING=$marker" }
}
if ($syncSource -match [regex]::Escape('C:/Users/Lauri/Desktop/regression-research/AGENTS.md')) { throw 'POLICY_STALE_REGRESSION_RESEARCH_TARGET' }
foreach ($marker in @('POLICY_SYNC_TARGETS', 'process.argv.includes("--apply")')) {
    if ($syncSource -notmatch [regex]::Escape($marker)) {
        throw "POLICY_SYNC_SAFETY_MARKER_MISSING=$marker"
    }
}
if ($syncSource -match 'replace\(/\\n\{3,\}/g') {
    throw 'POLICY_SYNC_GLOBAL_WHITESPACE_REWRITE_FORBIDDEN'
}
if ($auditSource -notmatch [regex]::Escape('POLICY_AUDIT_TARGETS')) {
    throw 'POLICY_AUDIT_TARGET_OVERRIDE_MISSING'
}
if ($auditSource -notmatch 'if\s*\(findings\)\s*process\.exit\(1\)') {
    throw 'POLICY_AUDIT_MUST_FAIL_ON_FINDINGS'
}

$tmp = Join-Path $env:TEMP ('policy_tool_safety_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $target = Join-Path $tmp 'AGENTS.md'
    $before = "# Probe`r`n`r`nPREFIX`r`n`r`n`r`n<!-- SHARED-AGENT-POLICY:BEGIN -->`r`nold`r`n<!-- SHARED-AGENT-POLICY:END -->`r`n`r`n`r`nSUFFIX  `r`n"
    [IO.File]::WriteAllText($target, $before, [Text.UTF8Encoding]::new($false))
    $env:POLICY_SYNC_TARGETS = $target

    & node $syncPath *> $null
    if ($LASTEXITCODE -eq 0) { throw 'POLICY_SYNC_DEFAULT_MUST_REPORT_DRIFT' }
    $afterCheck = [IO.File]::ReadAllText($target)
    if ($afterCheck -cne $before) { throw 'POLICY_SYNC_DEFAULT_MUTATED_TARGET' }

    & node $syncPath --apply *> $null
    if ($LASTEXITCODE -ne 0) { throw "POLICY_SYNC_APPLY_FAILED=$LASTEXITCODE" }
    $afterApply = [IO.File]::ReadAllText($target)
    $begin = '<!-- SHARED-AGENT-POLICY:BEGIN -->'
    $end = '<!-- SHARED-AGENT-POLICY:END -->'
    $beforePrefix = $before.Substring(0, $before.IndexOf($begin))
    $afterPrefix = $afterApply.Substring(0, $afterApply.IndexOf($begin))
    $beforeSuffix = $before.Substring($before.IndexOf($end) + $end.Length)
    $afterSuffix = $afterApply.Substring($afterApply.IndexOf($end) + $end.Length)
    if ($afterPrefix -cne $beforePrefix -or $afterSuffix -cne $beforeSuffix) {
        throw 'POLICY_SYNC_CHANGED_BYTES_OUTSIDE_GENERATED_BLOCK'
    }

    & node $syncPath *> $null
    if ($LASTEXITCODE -ne 0) { throw "POLICY_SYNC_POST_APPLY_CHECK_FAILED=$LASTEXITCODE" }

    $env:POLICY_AUDIT_TARGETS = $target
    Add-Content -LiteralPath $target -Value 'BUSY duplicate outside generated block'
    & node $auditPath *> $null
    if ($LASTEXITCODE -eq 0) { throw 'POLICY_AUDIT_FINDING_DID_NOT_FAIL' }

    # Regression: local apply must not masquerade as durable propagation. A stale origin/default
    # must fail --check-remotes until the generated block is committed and pushed.
    $remoteRepo = Join-Path $tmp 'remote-check-work'
    $bareRepo = Join-Path $tmp 'remote-check-origin.git'
    New-Item -ItemType Directory -Path $remoteRepo | Out-Null
    Invoke-GitQuiet @('-C',$remoteRepo,'init','-b','main')
    Invoke-GitQuiet @('-C',$remoteRepo,'config','user.email','policy-test@example.invalid')
    Invoke-GitQuiet @('-C',$remoteRepo,'config','user.name','Policy Test')
    $remoteTarget = Join-Path $remoteRepo 'AGENTS.md'
    [IO.File]::WriteAllText($remoteTarget, "# Probe`n`n<!-- SHARED-AGENT-POLICY:BEGIN -->`nold`n<!-- SHARED-AGENT-POLICY:END -->`n", [Text.UTF8Encoding]::new($false))
    Invoke-GitQuiet @('-C',$remoteRepo,'add','AGENTS.md')
    Invoke-GitQuiet @('-C',$remoteRepo,'commit','-m','old policy')
    Invoke-GitQuiet @('init','--bare',$bareRepo)
    Invoke-GitQuiet @('-C',$remoteRepo,'remote','add','origin',$bareRepo)
    Invoke-GitQuiet @('-C',$remoteRepo,'push','-u','origin','main')
    $env:POLICY_SYNC_TARGETS = $remoteTarget
    & node $syncPath --apply *> $null
    if ($LASTEXITCODE -ne 0) { throw "POLICY_REMOTE_TEST_LOCAL_APPLY_FAILED=$LASTEXITCODE" }
    $remoteDrift = & node $syncPath --check-remotes 2>&1
    if ($LASTEXITCODE -eq 0) { throw 'POLICY_REMOTE_DRIFT_WAS_NOT_DETECTED' }
    if (($remoteDrift -join "`n") -notmatch 'REMOTE_DRIFTED') { throw 'POLICY_REMOTE_DRIFT_WRONG_FAILURE' }
    Invoke-GitQuiet @('-C',$remoteRepo,'add','AGENTS.md')
    Invoke-GitQuiet @('-C',$remoteRepo,'commit','-m','current policy')
    Invoke-GitQuiet @('-C',$remoteRepo,'push','origin','main')
    $remoteClean = & node $syncPath --check-remotes 2>&1
    if ($LASTEXITCODE -ne 0) { throw "POLICY_REMOTE_SYNC_DID_NOT_CLEAR=$LASTEXITCODE $($remoteClean -join ' ')" }
    Write-Host 'POLICY_REMOTE_PROPAGATION_GUARD=PASS'

    # Regression: unrelated dirty work must not block syncing a clean AGENTS target.
    [IO.File]::WriteAllText($remoteTarget, "# Probe`n`n<!-- SHARED-AGENT-POLICY:BEGIN -->`nold`n<!-- SHARED-AGENT-POLICY:END -->`n", [Text.UTF8Encoding]::new($false))
    Invoke-GitQuiet @('-C',$remoteRepo,'add','AGENTS.md')
    Invoke-GitQuiet @('-C',$remoteRepo,'commit','-m','stale policy for dirty-neighbor test')
    [IO.File]::WriteAllText((Join-Path $remoteRepo 'LOCAL-WORK.txt'), 'preserve me', [Text.UTF8Encoding]::new($false))
    $neighborApply = & node $syncPath --apply 2>&1
    if ($LASTEXITCODE -ne 0) { throw "POLICY_UNRELATED_DIRTY_BLOCKED_APPLY=$LASTEXITCODE $($neighborApply -join ' ')" }
    if (-not (Test-Path (Join-Path $remoteRepo 'LOCAL-WORK.txt'))) { throw 'POLICY_UNRELATED_DIRTY_WORK_LOST' }
    Write-Host 'POLICY_UNRELATED_DIRTY_ALLOWED=PASS'

    # Regression: apply must still refuse when the AGENTS target itself is dirty.
    [IO.File]::WriteAllText($remoteTarget, "# Local edit`n`n<!-- SHARED-AGENT-POLICY:BEGIN -->`nold`n<!-- SHARED-AGENT-POLICY:END -->`n", [Text.UTF8Encoding]::new($false))
    $dirtyTargetBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $remoteTarget).Hash
    $dirtyApply = & node $syncPath --apply 2>&1
    if ($LASTEXITCODE -eq 0) { throw 'POLICY_DIRTY_TARGET_WAS_MUTATED' }
    $dirtyTargetAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $remoteTarget).Hash
    if ($dirtyTargetAfter -ne $dirtyTargetBefore) { throw 'POLICY_DIRTY_TARGET_HASH_CHANGED' }
    if (($dirtyApply -join "`n") -notmatch 'DIRTY_TARGET_REFUSED') { throw 'POLICY_DIRTY_TARGET_WRONG_FAILURE' }
    Write-Host 'POLICY_DIRTY_TARGET_REFUSAL=PASS'

    Write-Host 'POLICY_SYNC_DEFAULT_READ_ONLY=PASS'
    Write-Host 'POLICY_SYNC_OUTSIDE_BYTES_PRESERVED=PASS'
    Write-Host 'POLICY_AUDIT_FAIL_CLOSED=PASS'

    $guardDir = Join-Path $tmp 'size-guard'
    New-Item -ItemType Directory -Path $guardDir | Out-Null
    $guardSync = Join-Path $guardDir 'sync-agent-policy.mjs'
    $guardPolicy = Join-Path $guardDir 'SHARED-AGENT-POLICY.md'
    Copy-Item -LiteralPath $syncPath -Destination $guardSync
    [IO.File]::WriteAllText($guardPolicy, ('X' * 11000), [Text.UTF8Encoding]::new($false))
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $guardOutput = & node $guardSync 2>&1 | Out-String
    $guardExitCode = $LASTEXITCODE
    $ErrorActionPreference = $oldErrorActionPreference
    if ($guardExitCode -eq 0) { throw 'POLICY_SIZE_GUARD_ACCEPTED_OVERSIZE' }
    if ($guardOutput -notmatch 'POLICY_BLOCK_TOO_LARGE_BYTES=') { throw 'POLICY_SIZE_GUARD_WRONG_FAILURE' }
    Write-Host 'POLICY_SIZE_GUARD=PASS'
} finally {
    Remove-Item Env:POLICY_SYNC_TARGETS -ErrorAction SilentlyContinue
    Remove-Item Env:POLICY_AUDIT_TARGETS -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
exit 0
