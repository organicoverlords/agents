Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$script = Join-Path $root 'Invoke-ReadyPullRequestConvergence.ps1'
$temporary = Join-Path ([IO.Path]::GetTempPath()) ("ready-pr-convergence-test-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
    $configPath = Join-Path $temporary 'config.json'
    $snapshotPath = Join-Path $temporary 'snapshot.json'
    $statePath = Join-Path $temporary 'state.json'
    @'
{
  "schema_version": 1,
  "existing_pr_grace_minutes": 5,
  "missing_readiness_escalation_minutes": 10,
  "pending_required_check_escalation_minutes": 15,
  "blocking_escalation_minutes": 5,
  "priority_escalation_minutes": 2,
  "priority_labels": ["important"],
  "repos": [
    {"repo":"o/ready","mode":"github","required_readiness_context":"agent/convergence-ready","required_checks":[],"allow_update_branch":true},
    {"repo":"o/check","mode":"github","required_readiness_context":"","required_checks":[{"type":"check","name":"verify","workflow":"ci"}],"allow_update_branch":true},
    {"repo":"o/p3","mode":"p3_guard","required_readiness_context":"","required_checks":[],"allow_update_branch":false,"local_path":"C:\\nope","guard":"guard.ps1"}
  ]
}
'@ | Set-Content -LiteralPath $configPath -Encoding UTF8
    @'
{
  "o/ready": [
    {"number":1,"title":"ready","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"CLEAN","headRefOid":"1111111111111111111111111111111111111111","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/1","labels":[],"statusCheckRollup":[{"__typename":"StatusContext","context":"agent/convergence-ready","state":"SUCCESS"}]},
    {"number":2,"title":"needs readiness","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"CLEAN","headRefOid":"2222222222222222222222222222222222222222","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/2","labels":[],"statusCheckRollup":[]},
    {"number":3,"title":"conflict","isDraft":false,"mergeable":"CONFLICTING","mergeStateStatus":"DIRTY","headRefOid":"3333333333333333333333333333333333333333","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/3","labels":[],"statusCheckRollup":[{"__typename":"StatusContext","context":"agent/convergence-ready","state":"SUCCESS"}]},
    {"number":4,"title":"behind","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"BEHIND","headRefOid":"4444444444444444444444444444444444444444","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/4","labels":[],"statusCheckRollup":[{"__typename":"StatusContext","context":"agent/convergence-ready","state":"SUCCESS"}]},
    {"number":5,"title":"old explicit ready","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"CLEAN","headRefOid":"5555555555555555555555555555555555555555","baseRefName":"main","createdAt":"2026-09-01T11:00:00Z","updatedAt":"2026-09-01T11:01:00Z","url":"https://example/5","labels":[],"statusCheckRollup":[{"__typename":"StatusContext","context":"agent/convergence-ready","state":"SUCCESS"}]},
    {"number":6,"title":"old unmarked","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"CLEAN","headRefOid":"6666666666666666666666666666666666666666","baseRefName":"main","createdAt":"2026-09-01T11:00:00Z","updatedAt":"2026-09-01T11:01:00Z","url":"https://example/6","labels":[],"statusCheckRollup":[]}
  ],
  "o/check": [
    {"number":7,"title":"check success","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"UNSTABLE","headRefOid":"7777777777777777777777777777777777777777","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/7","labels":[],"statusCheckRollup":[{"__typename":"CheckRun","name":"verify","workflowName":"ci","status":"COMPLETED","conclusion":"SUCCESS"}]},
    {"number":8,"title":"check pending","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"UNSTABLE","headRefOid":"8888888888888888888888888888888888888888","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/8","labels":[],"statusCheckRollup":[{"__typename":"CheckRun","name":"verify","workflowName":"ci","status":"IN_PROGRESS","conclusion":""}]}
  ],
  "o/p3": [
    {"number":9,"title":"guard","isDraft":false,"mergeable":"MERGEABLE","mergeStateStatus":"UNSTABLE","headRefOid":"9999999999999999999999999999999999999999","baseRefName":"main","createdAt":"2026-09-11T11:00:00Z","updatedAt":"2026-09-11T11:01:00Z","url":"https://example/9","labels":[],"statusCheckRollup":[]}
  ]
}
'@ | Set-Content -LiteralPath $snapshotPath -Encoding UTF8

    $json = & $script -ConfigPath $configPath -StatePath $statePath -SnapshotPath $snapshotPath -NoMutate -NowUtc '2026-09-11T11:02:00Z'
    $result = $json | ConvertFrom-Json
    $byPr = @{}
    foreach ($item in @($result.results)) { $byPr[[int]$item.pr] = [string]$item.decision }
    $expected = @{
        1='MERGE'
        2='WAIT_READINESS'
        3='BLOCKED_CONFLICT'
        4='UPDATE_BRANCH'
        5='MERGE'
        6='LEGACY_OBSERVE_ONLY'
        7='MERGE'
        8='WAIT_REQUIRED_CHECK'
        9='RUN_P3_GUARD'
    }
    foreach ($key in $expected.Keys) {
        if ($byPr[$key] -ne $expected[$key]) { throw "PR $key decision mismatch: expected=$($expected[$key]) actual=$($byPr[$key])" }
    }
    [ordered]@{
        ok = $true
        scenarios = $expected.Count
        exact_head_readiness = $true
        required_check_gate = $true
        safe_branch_update = $true
        conflict_block = $true
        p3_guard_delegation = $true
        legacy_backlog_not_blindly_merged = $true
    } | ConvertTo-Json -Compress
} finally {
    Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue
}
