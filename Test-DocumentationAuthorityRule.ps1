$ErrorActionPreference = 'Stop'

$rules = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'RULES.md'))
$agents = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'AGENTS.md'))

if (-not $rules.Contains('Human-facing repository documentation, including North Stars, roadmaps, architecture/design prose, README/start-here guidance, and changelogs, has one authority: `organicoverlords/agents@main` under `docs/repos/<repo>/`.')) {
    throw 'central human-document authority rule missing from RULES.md'
}
if (-not $agents.Contains('Human-facing repository documentation and product direction are centralized in `organicoverlords/agents@main` under `docs/repos/<repo>/`.')) {
    throw 'central human-document routing missing from AGENTS.md'
}

$changelogs = @(
    'docs/repos/p3/CHANGELOG.md',
    'docs/repos/tiny3d/CHANGELOG.md',
    'docs/repos/lowvram3d-studio/CHANGELOG.md'
)
foreach ($relative in $changelogs) {
    $path = Join-Path $PSScriptRoot $relative
    $lines = [IO.File]::ReadAllLines($path)
    $ruleLines = @($lines | Where-Object { $_.StartsWith('The rule this file follows is ') })
    if ($ruleLines.Count -ne 1) { throw "$relative must contain exactly one current changelog-standard header" }
    if (-not $ruleLines[0].Contains('docs/repos/docs/standards/changelog.md')) { throw "$relative does not point at the central Agents changelog standard" }
    if ($ruleLines[0].Contains('organicoverlords/docs')) { throw "$relative still names the retired standalone docs authority in its current header" }
}

$traycerPath = Join-Path $PSScriptRoot 'docs/repos/lowvram3d-studio/TRAYCER.md'
$traycer = [IO.File]::ReadAllText($traycerPath)
foreach ($required in @('../../../RULES.md', '../../../AGENTS.md')) {
    if (-not $traycer.Contains($required)) { throw "LowVRAM TRAYCER.md missing direct Agents authority link: $required" }
}
if ($traycer.Contains('github.com/organicoverlords/lowvram3d-studio/blob/main/AGENTS.md')) {
    throw 'LowVRAM TRAYCER.md still routes policy through the product-repo pointer'
}

$standard = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'docs/repos/docs/standards/changelog.md'))
if (-not $standard.Contains('docs/repos/<repo>/CHANGELOG.md')) { throw 'central changelog standard does not name the Agents canonical path' }
if (-not $standard.Contains('compatibility pointer')) { throw 'central changelog standard does not preserve pointer-only legacy semantics' }

Get-ChildItem (Join-Path $PSScriptRoot 'docs/repos') -Filter '_MIGRATION.json' -Recurse -File | ForEach-Object {
    $manifest = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
    if ($manifest.authority -ne 'organicoverlords/agents') { throw "migration manifest has wrong authority: $($_.FullName)" }
}

Write-Output 'PASS documentation authority rule'
