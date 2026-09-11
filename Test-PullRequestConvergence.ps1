Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot 'Converge-PullRequest.ps1'
$fixture = Join-Path $env:TEMP ('pr-convergence-fixture-' + [guid]::NewGuid().ToString('N') + '.json')
$base = @{state='OPEN';isDraft=$false;mergeable='MERGEABLE';mergeStateStatus='CLEAN';reviewDecision='';statusCheckRollup=@();headRefOid='abc';autoMergeRequest=$null;url='https://example/pr/12'}
function Plan([hashtable]$Data,[string]$Repo='organicoverlords/example',[switch]$Superseded) {
    [IO.File]::WriteAllText($fixture,($Data|ConvertTo-Json -Compress -Depth 8),[Text.UTF8Encoding]::new($false))
    $args=@('-NoLogo','-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$helper,'-Repository',$Repo,'-PullRequest','12','-NoExecute','-FixturePath',$fixture)
    if($Superseded){$args+='-Superseded'}
    $o=& powershell.exe @args
    if($LASTEXITCODE -ne 0){throw "PLAN_FAILED=$LASTEXITCODE"}
    return (($o|Select-Object -Last 1)|ConvertFrom-Json)
}
try {
    $r=Plan $base; if($r.outcome -ne 'merged' -or $r.action -ne 'merge'){throw 'GREEN'}
    $f=$base.Clone();$f.statusCheckRollup=@(@{name='unit';status='IN_PROGRESS';conclusion=''});$r=Plan $f;if($r.outcome -ne 'auto_merge_enabled' -or $r.action -ne 'auto_merge'){throw 'PENDING'}
    $f=$base.Clone();$f.statusCheckRollup=@(@{name='unit';status='COMPLETED';conclusion='FAILURE'});$r=Plan $f;if($r.outcome -ne 'repair_required' -or $r.action -ne 'none'){throw 'FAILED'}
    $f=$base.Clone();$f.isDraft=$true;$r=Plan $f;if($r.outcome -ne 'draft_not_integrated'){throw 'DRAFT'}
    $f=$base.Clone();$f.mergeable='CONFLICTING';$f.mergeStateStatus='DIRTY';$r=Plan $f;if($r.outcome -ne 'rebase_required'){throw 'CONFLICT'}
    $r=Plan $base -Superseded;if($r.outcome -ne 'closed_superseded' -or $r.action -ne 'close'){throw 'SUPERSEDED'}
    $r=Plan $base 'organicoverlords/p3';if($r.outcome -ne 'p3_merge_guard_required' -or $r.action -ne 'p3_guard'){throw 'P3'}
    if(-not ([IO.File]::ReadAllText($helper).Contains('FIXTURE_DATA_REQUIRES_NOEXECUTE'))){throw 'FIXTURE_MUTATION_GUARD'}
    Write-Output 'PASS pull request convergence classification is deterministic and fixture data cannot execute mutations'
} finally { Remove-Item -LiteralPath $fixture -Force -ErrorAction SilentlyContinue }
