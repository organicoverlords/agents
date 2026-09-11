[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[^/]+/[^/]+$')][string]$Repository,
    [Parameter(Mandatory)][int]$PullRequest,
    [switch]$Superseded,
    [string]$SupersededReason = 'Superseded by newer canonical work.',
    [switch]$NoExecute,
    [string]$FixturePath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Get-Plan($pr,[string]$Repo,[bool]$IsSuperseded) {
    if ([string]$pr.state -ne 'OPEN') { return @{outcome='already_terminal';action='none'} }
    if ($IsSuperseded) { return @{outcome='closed_superseded';action='close'} }
    if ([bool]$pr.isDraft) { return @{outcome='draft_not_integrated';action='none'} }
    if ([string]$pr.mergeable -eq 'CONFLICTING' -or [string]$pr.mergeStateStatus -eq 'DIRTY') { return @{outcome='rebase_required';action='none'} }
    $pending=@(); $failed=@()
    foreach ($check in @($pr.statusCheckRollup)) {
        if ([string]$check.status -ne 'COMPLETED') { $pending += [string]$check.name; continue }
        if ([string]$check.conclusion -in @('FAILURE','CANCELLED','TIMED_OUT','ACTION_REQUIRED','STARTUP_FAILURE')) { $failed += [string]$check.name }
    }
    if ($failed.Count -gt 0) { return @{outcome='repair_required';action='none';failed_checks=$failed} }
    if ([string]$pr.reviewDecision -eq 'CHANGES_REQUESTED') { return @{outcome='changes_requested';action='none'} }
    if ($Repo.Equals('organicoverlords/p3',[StringComparison]::OrdinalIgnoreCase)) { return @{outcome='p3_merge_guard_required';action='p3_guard'} }
    if ($pending.Count -gt 0 -or [string]$pr.reviewDecision -eq 'REVIEW_REQUIRED') {
        if ($null -ne $pr.autoMergeRequest) { return @{outcome='auto_merge_pending';action='none';pending_checks=$pending} }
        return @{outcome='auto_merge_enabled';action='auto_merge';pending_checks=$pending}
    }
    if ([string]$pr.mergeable -eq 'UNKNOWN') { return @{outcome='mergeability_unknown';action='none'} }
    return @{outcome='merged';action='merge'}
}
if (-not [string]::IsNullOrWhiteSpace($FixturePath)) {
    if (-not $NoExecute) { throw 'FIXTURE_DATA_REQUIRES_NOEXECUTE' }
    $pr = Get-Content -LiteralPath $FixturePath -Raw | ConvertFrom-Json
} else {
    $raw = & gh pr view $PullRequest --repo $Repository --json state,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,headRefOid,autoMergeRequest,url
    if ($LASTEXITCODE -ne 0) { throw "GITHUB_PR_READ_FAILED=$Repository#$PullRequest" }
    $pr = $raw | ConvertFrom-Json
}
$plan = Get-Plan $pr $Repository ([bool]$Superseded)
$result = [ordered]@{ok=$true;repository=$Repository;pull_request=$PullRequest;outcome=$plan.outcome;action=$plan.action;url=[string]$pr.url}
if ($plan.ContainsKey('failed_checks')) { $result.failed_checks=$plan.failed_checks }
if ($plan.ContainsKey('pending_checks')) { $result.pending_checks=$plan.pending_checks }
if ($NoExecute) { $result | ConvertTo-Json -Compress -Depth 5; exit 0 }
switch ($plan.action) {
    'none' { $result.ok=($plan.outcome -in @('already_terminal','auto_merge_pending')); $result|ConvertTo-Json -Compress -Depth 5; if (-not $result.ok) { exit 20 }; exit 0 }
    'p3_guard' { $result.command="scripts/ci/control/Invoke-P3PrMergeGuard.ps1 -Repository organicoverlords/p3 -PullRequest $PullRequest -Execute"; $result.ok=$false; $result|ConvertTo-Json -Compress; exit 24 }
    'close' { & gh pr close $PullRequest --repo $Repository --comment $SupersededReason; if ($LASTEXITCODE -ne 0) { throw 'PR_CLOSE_FAILED' }; $result|ConvertTo-Json -Compress; exit 0 }
    'auto_merge' { & gh pr merge $PullRequest --repo $Repository --auto --squash --match-head-commit ([string]$pr.headRefOid); if ($LASTEXITCODE -ne 0) { throw 'PR_AUTO_MERGE_ENABLE_FAILED' }; $result|ConvertTo-Json -Compress -Depth 5; exit 0 }
    'merge' { & gh pr merge $PullRequest --repo $Repository --squash --match-head-commit ([string]$pr.headRefOid); if ($LASTEXITCODE -ne 0) { throw 'PR_MERGE_FAILED' }; $result|ConvertTo-Json -Compress; exit 0 }
    default { throw "UNKNOWN_PR_CONVERGENCE_ACTION=$($plan.action)" }
}