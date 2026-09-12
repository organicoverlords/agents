Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

$slop = @($rules -split "`r?`n" | Where-Object { $_ -match '^- `slopwall` is a \*\*mandatory correction-and-learning incident\*\*' })
if ($slop.Count -ne 1) { throw "expected exactly one mandatory Slopwall learning rule; found $($slop.Count)" }
foreach ($required in @(
  'Treat the immediately preceding assistant reply/action as failed against the inherited objective',
  'first resume the exact requested answer/work with the missing user-relevant substance',
  'identify the concrete failed behavior or decision',
  'infer the best-supported mechanism that produced it without inventing an unsupported root cause',
  'derive one reusable prevention lesson as an actionable condition/action rule that would have prevented the recurrence',
  'persist one compact durable correction containing the user''s literal `slopwall` signal, the rejected behavior, the diagnosis/mechanism, and the prevention lesson',
  'The durable correction is mandatory for literal `slopwall`',
  'Slopwall remains pending and the direct-reply pre-final gate must fail closed',
  'an apology, shorter rewrite, explanation, promise, or response-style change does not satisfy the incident',
  'A slopwall is not defined by length: it is substance displacement'
)) {
  if (-not $slop[0].Contains($required)) { throw "Slopwall rule missing invariant: $required" }
}

$agent = @($agents -split "`r?`n" | Where-Object { $_ -match '^- \*\*User corrections are answer-first; literal `slopwall` additionally requires a bounded durable learning loop\.\*\*' })
if ($agent.Count -ne 1) { throw "expected exactly one Slopwall durable-learning owner; found $($agent.Count)" }
foreach ($required in @(
  'Literal `slopwall` is the durability exception, not a task-priority exception',
  'pending fail-closed pre-final state',
  'accepted `memory_bank.py record --kind correction` result',
  'name the concrete rejected behavior',
  'infer the best-supported mechanism or decision failure',
  'derive one reusable prevention lesson that names the triggering condition and required different action',
  'persist one compact `memory_bank.py record --kind correction` entry',
  'The Slopwall record is mandatory and must be specific enough to change future selection behavior',
  'do not store merely `be concise`, `answer better`, an apology, or the complaint restated',
  'record the observable failure plus bounded uncertainty instead of fabricating a root cause',
  'after durability is secured, continue or finish the inherited task'
)) {
  if (-not $agent[0].Contains($required)) { throw "Slopwall durable owner missing invariant: $required" }
}

[ordered]@{
  ok = $true
  mandatory_diagnosis = $true
  mandatory_prevention_lesson = $true
  mandatory_durable_correction = $true
  inherited_task_preserved = $true
  unsupported_root_cause_forbidden = $true
} | ConvertTo-Json -Compress
