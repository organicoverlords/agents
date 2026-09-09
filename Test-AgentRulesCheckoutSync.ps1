Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sync = Join-Path $PSScriptRoot 'Sync-AgentRulesCheckout.ps1'
if (-not (Test-Path -LiteralPath $sync)) { throw 'Sync-AgentRulesCheckout.ps1 missing' }
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))
foreach ($required in @(
    'serving checkout for shared behavior, not a worker WIP surface',
    '`Sync-AgentRulesCheckout.ps1`',
    '`source_freshness.canonical_checkout`',
    '`coherent` is false, run `C:\Users\Lauri\.agents\Sync-AgentRulesCheckout.ps1` once',
    'An exact `head_matches_remote_main` false value while `coherent` is true is diagnostic cache-lag evidence only and does not require sync',
    'once before selecting repo work or relying on the serving checkout for current shared behavior',
    'Do not add Git fetch/convergence work inside bootstrap itself, create a watcher/scheduler',
    'separate worktree based on current `origin/main`',
    'preserves the exact index/worktree on a local `preserve/agents-live-*` branch')) {
    if (-not $agents.Contains($required)) { throw "AGENTS serving-checkout rule missing invariant: $required" }
}

function Invoke-Git {
    param([string]$Repo,[string[]]$GitArgs)
    $errFile = Join-Path ([IO.Path]::GetTempPath()) ('agents-sync-test-giterr-' + [Guid]::NewGuid().ToString('N'))
    $savedPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& git -C $Repo @GitArgs 2> $errFile)
        $code = $LASTEXITCODE
        $stderr = if (Test-Path -LiteralPath $errFile) { [IO.File]::ReadAllText($errFile).Trim() } else { '' }
    }
    finally {
        $ErrorActionPreference = $savedPreference
        Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue
    }
    if ($code -ne 0) { throw "git -C $Repo $($GitArgs -join ' ') failed: $((@($output,$stderr) -join "`n").Trim())" }
    (($output | ForEach-Object { [string]$_ }) -join "`n").Trim()
}
function Invoke-Sync {
    param([string]$Repo,[switch]$Repair)
    $invoke = @('-NoLogo','-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$sync,'-RepoRoot',$Repo)
    if ($Repair) { $invoke += '-Repair' }
    $output = @(& powershell.exe @invoke 2>&1)
    $code = $LASTEXITCODE
    $jsonLine = @($output | ForEach-Object { [string]$_ } | Where-Object { $_.TrimStart().StartsWith('{') }) | Select-Object -Last 1
    if (-not $jsonLine) { throw "sync emitted no JSON: $($output -join "`n")" }
    [pscustomobject]@{ Code=$code; Data=($jsonLine | ConvertFrom-Json); Output=$output }
}

$root = Join-Path ([IO.Path]::GetTempPath()) ('agents-sync-rule-' + [Guid]::NewGuid().ToString('N'))
$remote = Join-Path $root 'remote.git'
$seed = Join-Path $root 'seed'
$live = Join-Path $root 'live'
try {
    New-Item -ItemType Directory -Path $root | Out-Null
    & git init --bare $remote | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git init --bare failed' }
    & git init -b main $seed | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git init seed failed' }
    Invoke-Git $seed @('config','user.name','agents-sync-test') | Out-Null
    Invoke-Git $seed @('config','user.email','agents-sync-test@example.invalid') | Out-Null
    [IO.File]::WriteAllText((Join-Path $seed 'AGENTS.md'),"remote-v1`n")
    Invoke-Git $seed @('add','AGENTS.md') | Out-Null
    Invoke-Git $seed @('commit','-m','v1') | Out-Null
    Invoke-Git $seed @('remote','add','origin',$remote) | Out-Null
    Invoke-Git $seed @('push','-u','origin','main') | Out-Null
    & git --git-dir=$remote symbolic-ref HEAD refs/heads/main
    if ($LASTEXITCODE -ne 0) { throw 'set bare HEAD failed' }
    & git clone $remote $live | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }
    Invoke-Git $live @('config','user.name','agents-sync-test') | Out-Null
    Invoke-Git $live @('config','user.email','agents-sync-test@example.invalid') | Out-Null

    $current = Invoke-Sync $live
    if ($current.Code -ne 0 -or $current.Data.status -ne 'CURRENT') { throw "current case failed: $($current.Output -join "`n")" }

    [IO.File]::WriteAllText((Join-Path $seed 'AGENTS.md'),"remote-v2`n")
    Invoke-Git $seed @('add','AGENTS.md') | Out-Null
    Invoke-Git $seed @('commit','-m','v2') | Out-Null
    Invoke-Git $seed @('push','origin','main') | Out-Null
    $ff = Invoke-Sync $live
    if ($ff.Code -ne 0 -or $ff.Data.status -ne 'FAST_FORWARDED') { throw "clean fast-forward failed: $($ff.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','HEAD')) -ne (Invoke-Git $seed @('rev-parse','HEAD'))) { throw 'clean fast-forward did not reach remote head' }

    Invoke-Git $live @('switch','-c','feature/wrong-serving-branch') | Out-Null
    [IO.File]::WriteAllText((Join-Path $live 'feature-only.txt'),"durable-feature`n")
    Invoke-Git $live @('add','feature-only.txt') | Out-Null
    Invoke-Git $live @('commit','-m','feature branch') | Out-Null
    $featureHead = Invoke-Git $live @('rev-parse','HEAD')
    [IO.File]::WriteAllText((Join-Path $live 'feature-only.txt'),"dirty-feature`n")

    $wrongDirty = Invoke-Sync $live -Repair
    if ($wrongDirty.Code -eq 0 -or $wrongDirty.Data.status -ne 'WRONG_BRANCH_DIRTY_BLOCKED') { throw "dirty wrong-branch repair did not fail closed: $($wrongDirty.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','--abbrev-ref','HEAD')) -ne 'feature/wrong-serving-branch') { throw 'dirty wrong-branch repair switched branches' }
    Invoke-Git $live @('restore','feature-only.txt') | Out-Null

    $wrong = Invoke-Sync $live
    if ($wrong.Code -eq 0 -or $wrong.Data.status -ne 'WRONG_BRANCH') { throw "wrong-branch default did not fail closed: $($wrong.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','--abbrev-ref','HEAD')) -ne 'feature/wrong-serving-branch') { throw 'default wrong-branch check switched branches' }

    $wrongRepaired = Invoke-Sync $live -Repair
    if ($wrongRepaired.Code -ne 0 -or $wrongRepaired.Data.status -ne 'WRONG_BRANCH_REPAIRED') { throw "clean wrong-branch repair failed: $($wrongRepaired.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','--abbrev-ref','HEAD')) -ne 'main') { throw 'wrong-branch repair did not restore main' }
    if ((Invoke-Git $live @('rev-parse','HEAD')) -ne (Invoke-Git $seed @('rev-parse','HEAD'))) { throw 'wrong-branch repair did not restore current remote main' }
    if ((Invoke-Git $live @('rev-parse','feature/wrong-serving-branch')) -ne $featureHead) { throw 'wrong-branch repair lost the feature branch commit' }

    [IO.File]::WriteAllText((Join-Path $seed 'AGENTS.md'),"remote-v3`n")
    [IO.File]::WriteAllText((Join-Path $seed 'remote-only.txt'),"remote-only`n")
    Invoke-Git $seed @('add','-A') | Out-Null
    Invoke-Git $seed @('commit','-m','v3') | Out-Null
    Invoke-Git $seed @('push','origin','main') | Out-Null

    [IO.File]::WriteAllText((Join-Path $live 'AGENTS.md'),"index-version`n")
    Invoke-Git $live @('add','AGENTS.md') | Out-Null
    [IO.File]::WriteAllText((Join-Path $live 'AGENTS.md'),"worktree-version`n")
    [IO.File]::WriteAllText((Join-Path $live 'local-note.txt'),"unique-untracked`n")
    $headBeforeBlock = Invoke-Git $live @('rev-parse','HEAD')

    $blocked = Invoke-Sync $live
    if ($blocked.Code -eq 0 -or $blocked.Data.status -ne 'DIRTY_BLOCKED') { throw "dirty default did not fail closed: $($blocked.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','HEAD')) -ne $headBeforeBlock) { throw 'dirty blocked run moved HEAD' }
    if ([IO.File]::ReadAllText((Join-Path $live 'AGENTS.md')).Trim() -ne 'worktree-version') { throw 'dirty blocked run changed worktree' }
    if (-not (Test-Path -LiteralPath (Join-Path $live 'local-note.txt'))) { throw 'dirty blocked run removed untracked work' }

    $repaired = Invoke-Sync $live -Repair
    if ($repaired.Code -ne 0 -or $repaired.Data.status -ne 'REPAIRED') { throw "dirty repair failed: $($repaired.Output -join "`n")" }
    if ((Invoke-Git $live @('rev-parse','HEAD')) -ne (Invoke-Git $seed @('rev-parse','HEAD'))) { throw 'repair did not reach remote head' }
    if (-not [string]::IsNullOrWhiteSpace((Invoke-Git $live @('status','--porcelain=v1','--untracked-files=normal')))) { throw 'repair did not leave live checkout clean' }

    $preserve = [string]$repaired.Data.preservation_branch
    if (-not $preserve.StartsWith('preserve/agents-live-')) { throw "unexpected preservation branch: $preserve" }
    if ((Invoke-Git $live @('show',"$preserve`:AGENTS.md")).Trim() -ne 'worktree-version') { throw 'preservation branch lost worktree version' }
    if ((Invoke-Git $live @('show',"$preserve^`:AGENTS.md")).Trim() -ne 'index-version') { throw 'preservation history lost staged index version' }
    if ((Invoke-Git $live @('show',"$preserve`:local-note.txt")).Trim() -ne 'unique-untracked') { throw 'preservation branch lost untracked file' }
    if ([IO.File]::ReadAllText((Join-Path $live 'AGENTS.md')).Trim() -ne 'remote-v3') { throw 'repair did not restore canonical remote file' }
    if (Test-Path -LiteralPath (Join-Path $live 'local-note.txt')) { throw 'repair left captured untracked file in serving checkout' }

    $branchesBefore = @(Invoke-Git $live @('for-each-ref','--format=%(refname:short)','refs/heads/preserve/agents-live-*') -split "`n").Count
    $again = Invoke-Sync $live
    $branchesAfter = @(Invoke-Git $live @('for-each-ref','--format=%(refname:short)','refs/heads/preserve/agents-live-*') -split "`n").Count
    if ($again.Code -ne 0 -or $again.Data.status -ne 'CURRENT') { throw 'idempotent current rerun failed' }
    if ($branchesAfter -ne $branchesBefore) { throw 'current rerun created unnecessary preservation branch' }

    Write-Output 'PASS agent rules serving checkout sync'
}
finally {
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
}

