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

foreach ($marker in @('### Worker reporting', 'Evidence state steers decisions, not presentation', 'Branch/Worker:', 'Progress: <N>%')) {
    if ($policySource -notmatch [regex]::Escape($marker)) {
        throw "WORKER_REPORT_POLICY_MARKER_MISSING=$marker"
    }
}
if ($policySource -match '(?im)^\s*[-*]\s*PROVEN:') {
    throw 'WORKER_REPORT_POLICY_MUST_NOT_DEFINE_PROVEN_LEDGER'
}

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
} finally {
    Remove-Item Env:POLICY_SYNC_TARGETS -ErrorAction SilentlyContinue
    Remove-Item Env:POLICY_AUDIT_TARGETS -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
exit 0
