Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$installer = Join-Path $PSScriptRoot 'Install-AgentEntrypoints.ps1'
$temp = Join-Path ([IO.Path]::GetTempPath()) ('agent-entrypoints-' + [guid]::NewGuid().ToString('N'))
$canonical = Join-Path $temp '.agents'
$codex = Join-Path $temp '.codex\AGENTS.md'
$opencode = Join-Path $temp '.config\opencode\AGENTS.md'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Invoke-Installer([switch]$Check) {
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer,
        '-CanonicalRoot', $canonical,
        '-CodexAgentsPath', $codex,
        '-OpenCodeAgentsPath', $opencode)
    if ($Check) { $args += '-Check' }
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell.exe @args 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = ($output -join "`n") }
}

try {
    New-Item -ItemType Directory -Path $canonical -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $canonical 'RULES.md'), "rules`n", $utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $canonical 'AGENTS.md'), "agents`n", $utf8NoBom)

    $first = Invoke-Installer
    if ($first.ExitCode -ne 0) { throw "initial install failed: $($first.Output)" }
    $hashes1 = @((Get-FileHash -LiteralPath $codex).Hash, (Get-FileHash -LiteralPath $opencode).Hash)

    $second = Invoke-Installer
    if ($second.ExitCode -ne 0) { throw "idempotent install failed: $($second.Output)" }
    $hashes2 = @((Get-FileHash -LiteralPath $codex).Hash, (Get-FileHash -LiteralPath $opencode).Hash)
    if (($hashes1 -join '|') -ne ($hashes2 -join '|')) { throw 'idempotent install changed pointer bytes' }

    $check = Invoke-Installer -Check
    if ($check.ExitCode -ne 0) { throw "clean check failed: $($check.Output)" }

    [IO.File]::WriteAllText($codex, "Canonical rules: C:\Users\Lauri\Documents\agent-rules\RULES.md`n", $utf8NoBom)
    $stale = Invoke-Installer -Check
    if ($stale.ExitCode -eq 0) { throw 'check accepted retired agent-rules pointer' }

    $repair = Invoke-Installer
    if ($repair.ExitCode -ne 0) { throw "repair install failed: $($repair.Output)" }
    [IO.File]::AppendAllText($opencode, "Local policy: do something extra`n", $utf8NoBom)
    $policy = Invoke-Installer -Check
    if ($policy.ExitCode -eq 0) { throw 'check accepted local policy body' }

    $final = Invoke-Installer
    if ($final.ExitCode -ne 0) { throw "final repair failed: $($final.Output)" }
    $finalCheck = Invoke-Installer -Check
    if ($finalCheck.ExitCode -ne 0) { throw "final check failed: $($finalCheck.Output)" }

    foreach ($target in @($codex, $opencode)) {
        $text = [IO.File]::ReadAllText($target)
        if ($text -match 'Documents\\agent-rules') { throw "retired pointer survived in $target" }
        if ($text -notmatch [regex]::Escape((Join-Path $canonical 'RULES.md'))) { throw "canonical RULES pointer missing in $target" }
        if ($text -notmatch [regex]::Escape((Join-Path $canonical 'AGENTS.md'))) { throw "canonical AGENTS pointer missing in $target" }
    }

    [ordered]@{ ok = $true; idempotent = $true; stale_pointer_rejected = $true; local_policy_rejected = $true } | ConvertTo-Json -Compress
}
finally {
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}