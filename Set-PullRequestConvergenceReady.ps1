[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Repository,
    [Parameter(Mandatory=$true)][int]$PullRequest,
    [string]$Evidence = 'repo-owned/local validation satisfied',
    [string]$Context = 'agent/convergence-ready'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$prJson = & gh pr view $PullRequest --repo $Repository --json number,isDraft,headRefOid,state,url 2>&1
if ($LASTEXITCODE -ne 0) { throw "Cannot read PR $Repository#$PullRequest`: $($prJson -join "`n")" }
$pr = ($prJson -join "`n") | ConvertFrom-Json
if ([string]$pr.state -ne 'OPEN') { throw "PR $Repository#$PullRequest is not open" }
if ([bool]$pr.isDraft) { throw "PR $Repository#$PullRequest is still draft" }
$description = "Exact-head proof satisfied: $Evidence"
if ($description.Length -gt 140) { $description = $description.Substring(0,140) }
$output = & gh api --method POST "repos/$Repository/statuses/$($pr.headRefOid)" -f state=success -f "context=$Context" -f "description=$description" -f "target_url=$($pr.url)" 2>&1
if ($LASTEXITCODE -ne 0) { throw "Failed to publish readiness status: $($output -join "`n")" }
[ordered]@{
    ok = $true
    repository = $Repository
    pull_request = $PullRequest
    head = [string]$pr.headRefOid
    context = $Context
    state = 'success'
    evidence = $Evidence
} | ConvertTo-Json -Compress
