Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
foreach ($name in @('RULES.md','AGENTS.md')) {
    $path = Join-Path $PSScriptRoot $name
    $text = [IO.File]::ReadAllText($path)
    foreach ($required in @(
        'Shared contract version: 65',
        'RESOURCE PRESSURE PROBES ARE TELEMETRY, NOT WORKER ADMISSION AUTHORITY',
        'must never create, inherit, or justify a task/issue/worker/swarm `BLOCKED` state from a generic threshold',
        'exact repo/executor owner',
        'fresh direct measurement plus that operation''s tested measured/predicted growth or reserve',
        'Only that exact invocation may refuse',
        'worker must continue another ready non-conflicting canonical contribution',
        'ownership/lifecycle driven, not pressure triggered',
        'cleanup failure must not prevent closeout',
        'one bounded owner-safe reclaim only when its own admission would otherwise fail',
        'never spin reclamation toward a target number'
    )) {
        if (-not $text.Contains($required)) { throw "RESOURCE_PRESSURE_AUTHORITY_CONTRACT_MISSING=$name|$required" }
    }
    foreach ($forbidden in @(
        'WINDOWS DISK HEADROOM IS A HARD BUILD-ADMISSION GATE',
        'require a fresh machine-routing probe showing at least **100 GiB free on C:**',
        'WINDOWS DISK CAPACITY IS MAINTAINED CONTINUOUSLY; ADMISSION IS THE LAST RESORT',
        'machine-hygiene owner samples C: headroom',
        'pressure watermark',
        '40 GiB free is a cleanup trigger',
        '25 GiB hard reserve',
        'soft/target watermarks in that tested executable owner'
    )) {
        if ($text.Contains($forbidden)) { throw "RESOURCE_PRESSURE_BLOCKING_REGRESSION=$name|$forbidden" }
    }
}
Write-Output 'PASS resource probes are telemetry; only exact executors own local admission/refusal'
