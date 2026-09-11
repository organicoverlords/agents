[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'ReadyPullRequestConvergence.json'),
    [string]$StatePath = (Join-Path $env:LOCALAPPDATA 'ReadyPullRequestConvergence\state.json'),
    [string]$LogPath = (Join-Path $env:LOCALAPPDATA 'ReadyPullRequestConvergence\events.jsonl'),
    [string]$SnapshotPath = '',
    [switch]$NoMutate,
    [string]$NowUtc = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$env:GH_HTTP_TIMEOUT = '10'

function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline=$true)]$InputObject)
    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [System.Collections.IDictionary]) {
        $out = @{}
        foreach ($key in $InputObject.Keys) { $out[[string]$key] = ConvertTo-Hashtable $InputObject[$key] }
        return $out
    }
    if ($InputObject -is [pscustomobject]) {
        $out = @{}
        foreach ($property in $InputObject.PSObject.Properties) { $out[$property.Name] = ConvertTo-Hashtable $property.Value }
        return $out
    }
    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        return @($InputObject | ForEach-Object { ConvertTo-Hashtable $_ })
    }
    return $InputObject
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonAtomic {
    param([string]$Path, $Value)
    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $tmp = "$Path.tmp-$PID-$([guid]::NewGuid().ToString('N'))"
    $Value | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $tmp -Encoding UTF8
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

function Write-Event {
    param([hashtable]$Event)
    if ($NoMutate -or $SnapshotPath) { return }
    $dir = Split-Path -Parent $LogPath
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    ($Event | ConvertTo-Json -Depth 20 -Compress) | Add-Content -LiteralPath $LogPath -Encoding UTF8
}

function Get-Now {
    if ($NowUtc) { return [DateTimeOffset]::Parse($NowUtc).ToUniversalTime() }
    return [DateTimeOffset]::UtcNow
}

function Get-Fingerprint {
    param($Pr)
    $shape = [ordered]@{
        number = $Pr.number
        head = $Pr.headRefOid
        draft = $Pr.isDraft
        mergeable = $Pr.mergeable
        merge_state = $Pr.mergeStateStatus
        checks = @($Pr.statusCheckRollup)
        labels = @($Pr.labels)
    } | ConvertTo-Json -Depth 20 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($shape)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-LabelNames {
    param($Pr)
    $names = @()
    foreach ($label in @($Pr.labels)) {
        if ($label -is [string]) { $names += $label }
        elseif ($null -ne $label -and $null -ne $label.name) { $names += [string]$label.name }
    }
    return @($names)
}

function Find-StatusContext {
    param($Pr, [string]$Context)
    foreach ($item in @($Pr.statusCheckRollup)) {
        if ([string]$item.__typename -eq 'StatusContext' -and [string]$item.context -eq $Context) { return $item }
    }
    return $null
}

function Test-RequiredChecks {
    param($Pr, $RepoConfig)
    $details = @()
    foreach ($required in @($RepoConfig.required_checks)) {
        $match = $null
        if ([string]$required.type -eq 'check') {
            foreach ($item in @($Pr.statusCheckRollup)) {
                if ([string]$item.__typename -ne 'CheckRun') { continue }
                if ([string]$item.name -ne [string]$required.name) { continue }
                if ($required.PSObject.Properties.Name -contains 'workflow' -and [string]$required.workflow) {
                    if ([string]$item.workflowName -ne [string]$required.workflow) { continue }
                }
                $match = $item
            }
            if ($null -eq $match) {
                return [pscustomobject]@{ ok=$false; state='MISSING'; detail="missing required check '$($required.name)'" }
            }
            if ([string]$match.status -ne 'COMPLETED') {
                return [pscustomobject]@{ ok=$false; state='PENDING'; detail="required check '$($required.name)' is $($match.status)" }
            }
            if (@('SUCCESS','NEUTRAL','SKIPPED') -notcontains [string]$match.conclusion) {
                return [pscustomobject]@{ ok=$false; state='FAILED'; detail="required check '$($required.name)' concluded $($match.conclusion)" }
            }
            $details += "$($required.name)=SUCCESS"
            continue
        }
        if ([string]$required.type -eq 'status') {
            $match = Find-StatusContext -Pr $Pr -Context ([string]$required.context)
            if ($null -eq $match) {
                return [pscustomobject]@{ ok=$false; state='MISSING'; detail="missing required status '$($required.context)'" }
            }
            if ([string]$match.state -ne 'SUCCESS') {
                $state = if ([string]$match.state -eq 'PENDING') { 'PENDING' } else { 'FAILED' }
                return [pscustomobject]@{ ok=$false; state=$state; detail="required status '$($required.context)' is $($match.state)" }
            }
            $details += "$($required.context)=SUCCESS"
            continue
        }
        throw "Unsupported required check type '$($required.type)'"
    }
    return [pscustomobject]@{ ok=$true; state='SUCCESS'; detail=($details -join ', ') }
}

function Get-Readiness {
    param($Pr, $RepoConfig)
    $context = [string]$RepoConfig.required_readiness_context
    if (-not $context) { return [pscustomobject]@{ ok=$true; explicit=$false; detail='not required' } }
    $status = Find-StatusContext -Pr $Pr -Context $context
    if ($null -eq $status) { return [pscustomobject]@{ ok=$false; explicit=$false; detail="missing '$context' status" } }
    if ([string]$status.state -eq 'SUCCESS') { return [pscustomobject]@{ ok=$true; explicit=$true; detail="$context=SUCCESS" } }
    return [pscustomobject]@{ ok=$false; explicit=$true; detail="$context=$($status.state)" }
}

function Get-PrDecision {
    param($Pr, $RepoConfig, [DateTimeOffset]$ActivatedAt, [DateTimeOffset]$Now, $Config)
    $fingerprint = Get-Fingerprint -Pr $Pr
    $readiness = Get-Readiness -Pr $Pr -RepoConfig $RepoConfig
    $createdAt = [DateTimeOffset]::Parse([string]$Pr.createdAt).ToUniversalTime()
    $grace = [TimeSpan]::FromMinutes([double]$Config.existing_pr_grace_minutes)
    $newEnough = $createdAt -ge $ActivatedAt.Subtract($grace)
    $labels = Get-LabelNames -Pr $Pr
    $priority = $false
    foreach ($label in @($Config.priority_labels)) {
        if ($labels -contains [string]$label) { $priority = $true; break }
    }

    if ([bool]$Pr.isDraft) {
        return [pscustomobject]@{ action='SKIP_DRAFT'; terminal=$false; detail='draft PR'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    $activationStatus = Find-StatusContext -Pr $Pr -Context 'agent/convergence-ready'
    $explicitActivation = ($null -ne $activationStatus -and [string]$activationStatus.state -eq 'SUCCESS') -or $priority
    if (-not $newEnough -and -not $explicitActivation) {
        return [pscustomobject]@{ action='LEGACY_OBSERVE_ONLY'; terminal=$false; detail='predates convergence activation and has no explicit readiness/priority activation'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$false }
    }
    if ([string]$Pr.mergeable -eq 'CONFLICTING' -or [string]$Pr.mergeStateStatus -eq 'DIRTY') {
        return [pscustomobject]@{ action='BLOCKED_CONFLICT'; terminal=$false; detail='head conflicts with base'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if ([string]$Pr.mergeable -eq 'UNKNOWN') {
        return [pscustomobject]@{ action='WAIT_MERGEABILITY'; terminal=$false; detail='GitHub mergeability is not resolved yet'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if ([string]$Pr.mergeStateStatus -eq 'BEHIND' -and [bool]$RepoConfig.allow_update_branch) {
        return [pscustomobject]@{ action='UPDATE_BRANCH'; terminal=$false; detail='base advanced; safe GitHub update-branch requested'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if ([string]$Pr.mergeStateStatus -eq 'BLOCKED') {
        return [pscustomobject]@{ action='BLOCKED_REPO_GATE'; terminal=$false; detail='GitHub reports a repository merge gate'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }

    if ([string]$RepoConfig.mode -eq 'p3_guard') {
        if ([string]$Pr.mergeable -ne 'MERGEABLE') {
            return [pscustomobject]@{ action='WAIT_MERGEABILITY'; terminal=$false; detail="mergeable=$($Pr.mergeable)"; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
        }
        return [pscustomobject]@{ action='RUN_P3_GUARD'; terminal=$false; detail='delegate exact-head proof and merge to P3 guard'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }

    $required = Test-RequiredChecks -Pr $Pr -RepoConfig $RepoConfig
    if (-not $required.ok) {
        $action = switch ([string]$required.state) {
            'PENDING' { 'WAIT_REQUIRED_CHECK' }
            'MISSING' { 'WAIT_REQUIRED_CHECK' }
            default { 'BLOCKED_REQUIRED_CHECK' }
        }
        return [pscustomobject]@{ action=$action; terminal=$false; detail=$required.detail; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if (-not $readiness.ok) {
        return [pscustomobject]@{ action='WAIT_READINESS'; terminal=$false; detail=$readiness.detail; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if ([string]$Pr.mergeable -ne 'MERGEABLE') {
        return [pscustomobject]@{ action='WAIT_MERGEABILITY'; terminal=$false; detail="mergeable=$($Pr.mergeable)"; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    if (@('CLEAN','UNSTABLE','HAS_HOOKS') -notcontains [string]$Pr.mergeStateStatus) {
        return [pscustomobject]@{ action='WAIT_MERGE_STATE'; terminal=$false; detail="mergeStateStatus=$($Pr.mergeStateStatus)"; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
    }
    return [pscustomobject]@{ action='MERGE'; terminal=$true; detail='exact head is ready for automatic integration'; fingerprint=$fingerprint; priority=$priority; explicit_readiness=$readiness.explicit }
}

function Get-RepoPullRequests {
    param($RepoConfig, $Snapshot)
    if ($null -ne $Snapshot) {
        $property = $Snapshot.PSObject.Properties[[string]$RepoConfig.repo]
        if ($null -eq $property) { return @() }
        return @($property.Value)
    }
    $json = & gh pr list --repo ([string]$RepoConfig.repo) --state open --limit 50 --json number,title,isDraft,mergeable,mergeStateStatus,headRefOid,baseRefName,statusCheckRollup,labels,createdAt,updatedAt,url 2>&1
    if ($LASTEXITCODE -ne 0) { throw "gh pr list failed for $($RepoConfig.repo): $($json -join "`n")" }
    return @((($json -join "`n") | ConvertFrom-Json))
}

function Invoke-GithubMerge {
    param([string]$Repo, $Pr)
    $output = & gh pr merge ([int]$Pr.number) --repo $Repo --merge --match-head-commit ([string]$Pr.headRefOid) --delete-branch 2>&1
    return [pscustomobject]@{ ok=($LASTEXITCODE -eq 0); output=($output -join "`n") }
}

function Invoke-GithubUpdateBranch {
    param([string]$Repo, $Pr)
    $endpoint = "repos/$Repo/pulls/$($Pr.number)/update-branch"
    $output = & gh api --method PUT $endpoint -f "expected_head_sha=$($Pr.headRefOid)" 2>&1
    return [pscustomobject]@{ ok=($LASTEXITCODE -eq 0); output=($output -join "`n") }
}

function Invoke-P3Guard {
    param($RepoConfig, $Pr)
    $root = [string]$RepoConfig.local_path
    $guard = Join-Path $root ([string]$RepoConfig.guard)
    if (-not (Test-Path -LiteralPath $guard -PathType Leaf)) {
        return [pscustomobject]@{ ok=$false; output="P3 guard missing: $guard" }
    }
    Push-Location $root
    try {
        $output = & $guard -Repository ([string]$RepoConfig.repo) -PullRequest ([int]$Pr.number) -Execute 2>&1
        return [pscustomobject]@{ ok=($LASTEXITCODE -eq 0); output=($output -join "`n") }
    } finally {
        Pop-Location
    }
}

function Add-BlockerComment {
    param([string]$Repo, $Pr, [string]$Detail)
    $body = "Automatic convergence is blocked for exact head ``$($Pr.headRefOid.Substring(0,12))``: $Detail. This is a terminal gate, not a passive review queue; update the existing PR/head rather than opening overlapping replacement work."
    $output = & gh pr comment ([int]$Pr.number) --repo $Repo --body $body 2>&1
    return [pscustomobject]@{ ok=($LASTEXITCODE -eq 0); output=($output -join "`n") }
}

$config = Read-JsonFile -Path $ConfigPath
if ($null -eq $config -or [int]$config.schema_version -ne 1) { throw "Invalid convergence config: $ConfigPath" }
$snapshot = if ($SnapshotPath) { Read-JsonFile -Path $SnapshotPath } else { $null }
$now = Get-Now
$stateObject = Read-JsonFile -Path $StatePath
if ($null -eq $stateObject) {
    $state = @{
        schema_version = 1
        activated_at = $now.ToString('o')
        prs = @{}
    }
} else {
    $state = ConvertTo-Hashtable $stateObject
    if (-not $state.ContainsKey('prs') -or $null -eq $state.prs) { $state.prs = @{} }
}
$activatedAt = [DateTimeOffset]::Parse([string]$state.activated_at).ToUniversalTime()

$results = @()
$seen = @{}
foreach ($repoConfig in @($config.repos)) {
    $repo = [string]$repoConfig.repo
    $prs = Get-RepoPullRequests -RepoConfig $repoConfig -Snapshot $snapshot
    foreach ($pr in @($prs)) {
        $key = "$repo#$($pr.number)"
        $seen[$key] = $true
        $decision = Get-PrDecision -Pr $pr -RepoConfig $repoConfig -ActivatedAt $activatedAt -Now $now -Config $config
        $existing = if ($state.prs.ContainsKey($key)) { $state.prs[$key] } else { $null }
        $firstSeen = if ($null -ne $existing -and $existing.ContainsKey('first_seen_at')) {
            [DateTimeOffset]::Parse([string]$existing.first_seen_at).ToUniversalTime()
        } else { $now }
        $entry = @{
            first_seen_at = $firstSeen.ToString('o')
            last_seen_at = $now.ToString('o')
            fingerprint = [string]$decision.fingerprint
            last_action = [string]$decision.action
            head = [string]$pr.headRefOid
            detail = [string]$decision.detail
            escalated_fingerprint = if ($null -ne $existing -and $existing.ContainsKey('escalated_fingerprint')) { [string]$existing.escalated_fingerprint } else { '' }
        }

        $performed = 'NONE'
        $outcome = ''
        $shouldAct = -not $NoMutate -and -not $SnapshotPath

        if ([string]$decision.action -eq 'MERGE' -and $shouldAct) {
            $merge = Invoke-GithubMerge -Repo $repo -Pr $pr
            $performed = if ($merge.ok) { 'MERGED' } else { 'MERGE_FAILED' }
            $outcome = $merge.output
        } elseif ([string]$decision.action -eq 'UPDATE_BRANCH' -and $shouldAct) {
            $update = Invoke-GithubUpdateBranch -Repo $repo -Pr $pr
            $performed = if ($update.ok) { 'BRANCH_UPDATED' } else { 'UPDATE_BRANCH_FAILED' }
            $outcome = $update.output
        } elseif ([string]$decision.action -eq 'RUN_P3_GUARD') {
            $changed = $null -eq $existing -or [string]$existing.fingerprint -ne [string]$decision.fingerprint
            if ($shouldAct -and $changed) {
                $guardResult = Invoke-P3Guard -RepoConfig $repoConfig -Pr $pr
                $performed = if ($guardResult.ok) { 'P3_GUARD_MERGED' } else { 'P3_GUARD_BLOCKED' }
                $outcome = $guardResult.output
            }
        }

        $blockedActions = @('BLOCKED_CONFLICT','BLOCKED_REPO_GATE','BLOCKED_REQUIRED_CHECK','WAIT_READINESS','WAIT_REQUIRED_CHECK')
        if ($blockedActions -contains [string]$decision.action) {
            $ageMinutes = ($now - $firstSeen).TotalMinutes
            $threshold = if ([bool]$decision.priority) {
                [double]$config.priority_escalation_minutes
            } elseif ([string]$decision.action -eq 'WAIT_REQUIRED_CHECK') {
                [double]$config.pending_required_check_escalation_minutes
            } elseif ([string]$decision.action -eq 'WAIT_READINESS') {
                [double]$config.missing_readiness_escalation_minutes
            } else {
                [double]$config.blocking_escalation_minutes
            }
            if ($ageMinutes -ge $threshold -and [string]$entry.escalated_fingerprint -ne [string]$decision.fingerprint) {
                if ($shouldAct) {
                    $comment = Add-BlockerComment -Repo $repo -Pr $pr -Detail ([string]$decision.detail)
                    if ($comment.ok) {
                        $entry.escalated_fingerprint = [string]$decision.fingerprint
                        if ($performed -eq 'NONE') { $performed = 'ESCALATED' }
                    } else {
                        if ($performed -eq 'NONE') { $performed = 'ESCALATION_FAILED' }
                        $outcome = $comment.output
                    }
                }
            }
        }

        $state.prs[$key] = $entry
        $result = [ordered]@{
            repo = $repo
            pr = [int]$pr.number
            head = [string]$pr.headRefOid
            decision = [string]$decision.action
            detail = [string]$decision.detail
            performed = $performed
        }
        if ($outcome) { $result['outcome'] = $outcome }
        $results += [pscustomobject]$result
        Write-Event -Event @{
            at = $now.ToString('o')
            repo = $repo
            pr = [int]$pr.number
            head = [string]$pr.headRefOid
            decision = [string]$decision.action
            performed = $performed
            detail = [string]$decision.detail
        }
    }
}

foreach ($key in @($state.prs.Keys)) {
    if (-not $seen.ContainsKey($key)) { $state.prs.Remove($key) }
}
$state.last_run_at = $now.ToString('o')
if (-not $NoMutate -and -not $SnapshotPath) { Write-JsonAtomic -Path $StatePath -Value $state }

$summary = [ordered]@{
    ok = $true
    activated_at = $state.activated_at
    observed_prs = $results.Count
    merged = @($results | Where-Object { $_.performed -in @('MERGED','P3_GUARD_MERGED') }).Count
    branch_updates = @($results | Where-Object { $_.performed -eq 'BRANCH_UPDATED' }).Count
    escalations = @($results | Where-Object { $_.performed -eq 'ESCALATED' }).Count
    results = $results
}
$summary | ConvertTo-Json -Depth 20 -Compress
