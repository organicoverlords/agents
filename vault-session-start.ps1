$ErrorActionPreference = 'Continue'
$bootstrap = 'C:\Users\Lauri\Desktop\vault\tools\memory_bank.py'

function Invoke-VaultBootstrap {
    $output = & python $bootstrap bootstrap 2>&1 | Out-String
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output.Trim() }
}

$result = Invoke-VaultBootstrap
if ($result.ExitCode -ne 0) {
    $result = Invoke-VaultBootstrap
}

if ($result.ExitCode -eq 0) {
    $context = "Vault bootstrap completed. Treat the returned behavior/policy profiles and fresh_session_startup as governing startup; current user direction and verified live state win. MCP/plugin availability is transport, not ownership authority.`n`n$($result.Output)"
} else {
    $detail = $result.Output
    if ($detail.Length -gt 2000) { $detail = $detail.Substring($detail.Length - 2000) }
    $context = "Vault bootstrap failed twice. Continue from current user instruction, shared/repo policy, and verified live state; do not turn memory recovery into the task. Last bootstrap output:`n$detail"
}

@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $context } } |
    ConvertTo-Json -Depth 5 -Compress
exit 0
