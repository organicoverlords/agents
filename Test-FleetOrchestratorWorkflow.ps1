[CmdletBinding()]
param([string]$AgentsRoot = 'C:\Users\Lauri\.agents')
$ErrorActionPreference='Stop'
$failures=[System.Collections.Generic.List[string]]::new()
function Require-Match { param([string]$Text,[string]$Pattern,[string]$Scenario); if($Text -notmatch $Pattern){$failures.Add($Scenario)} }
$skillPath=Join-Path $AgentsRoot 'skills\orchestrate-fleet\SKILL.md'
$interfacePath=Join-Path $AgentsRoot 'skills\orchestrate-fleet\agents\openai.yaml'
$skill=if(Test-Path $skillPath){Get-Content $skillPath -Raw}else{$failures.Add('orchestrate-fleet skill exists');''}
$interface=if(Test-Path $interfacePath){Get-Content $interfacePath -Raw}else{$failures.Add('skill interface exists');''}
Require-Match $interface 'allow_implicit_invocation:\s*false' 'explicit sweep remains optional'
Require-Match $skill '(?is)current automation state.*live truth' 'sweep reads current scheduler state'
Require-Match $skill '(?is)convenience sweep, not an ownership tier' 'explicit sweep does not create hierarchy'
Require-Match $skill '(?is)Do not centralize resilience.*flat self-healing pool' 'timed pool keeps distributed resilience'
Require-Match $skill '(?is)repair obvious sibling scheduler-liveness faults' 'active workers can heal disabled or stalled siblings'
Require-Match $skill '(?is)does not steer or reassign peer task scope' 'liveness repair does not become peer orchestration'
Require-Match $skill '(?is)Fan-in is scope-owned rather than coordinator-owned' 'fan-in has no coordinator tier'
Require-Match $skill '(?is)scope-visible pending work.*provenance' 'blocked findings persist on shared scope'
Require-Match $skill '(?is)survives release.*next owner' 'pending finding survives owner transition'
if($skill -match '(?i)fleet owner'){ $failures.Add('no dedicated fleet-owner role') }
if(($skill -split '\s+').Count -gt 220){$failures.Add('explicit orchestrator skill stays small')}
if($failures.Count){$failures|%{Write-Host "FAIL: $_"};Write-Host "RESULT=FAIL count=$($failures.Count)";exit 1}
Write-Host 'RESULT=PASS scenarios=10'