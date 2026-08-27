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
if ($policySource -notmatch [regex]::Escape('**Version 1.18 - 2026-08-27.**')) { throw 'POLICY_RECOVERY_VERSION_MISSING' }

foreach ($marker in @('### Worker reporting', 'only to classify the claim being made', 'Branch/Worker:', 'Progress: <N>%')) {
    if ($policySource -notmatch [regex]::Escape($marker)) {
        throw "WORKER_REPORT_POLICY_MARKER_MISSING=$marker"
    }
}
if ($policySource -match '(?im)^\s*[-*]\s*PROVEN:') {
    throw 'WORKER_REPORT_POLICY_MUST_NOT_DEFINE_PROVEN_LEDGER'
}
if ($policySource -match [regex]::Escape('Evidence state steers decisions, not presentation')) { throw 'POLICY_DECISION_GATING_REGRESSION' }
if ($policySource -match [regex]::Escape('For claims that affect acceptance or the next action')) { throw 'POLICY_NEXT_ACTION_EVIDENCE_GATE_REGRESSION' }
if ($policySource -match [regex]::Escape('recent-title window')) { throw 'POLICY_WORKER_RECENT_MEMORY_BOOTSTRAP_REGRESSION' }
if ($policySource -match [regex]::Escape('An active process_id, BUSY scope, unfinished mutation')) { throw 'POLICY_GLOBAL_COMPLETION_TAIL_REGRESSION' }

foreach ($forbidden in @(
    'A dirty worktree is a reconciliation obligation',
    'Producer backpressure is mandatory',
    'completed or idle PR awaiting integration is fleet debt',
    'Open-PR count is work to reconcile',
    'merge immediately',
    'memory_bank.py recent'
)) {
    if ($policySource -match [regex]::Escape($forbidden)) {
        throw "POLICY_SCOPE_EXPANSION_REGRESSION=$forbidden"
    }
}
foreach ($required in @(
    'MCP0 BUSY is the live ownership authority',
    'busy_claim',
    'busy_release'
)) {
    if ($policySource -notmatch [regex]::Escape($required)) {
        throw "POLICY_BUSY_AUTHORITY_MARKER_MISSING=$required"
    }
}
if ($syncSource -notmatch [regex]::Escape('const MAX_BLOCK_BYTES = 10000;')) { throw 'POLICY_SIZE_CAP_NOT_10000' }
if ($syncSource -notmatch [regex]::Escape('C:/Users/Lauri/Desktop/vault/AGENTS.md')) { throw 'POLICY_VAULT_SYNC_TARGET_MISSING' }
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
