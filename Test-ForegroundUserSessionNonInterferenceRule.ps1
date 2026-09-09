$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$rules = Get-Content -LiteralPath (Join-Path $root 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $root 'AGENTS.md') -Raw

$checks = [ordered]@{
    rule_present = $rules -match 'FOREGROUND USER-SESSION NON-INTERFERENCE IS DENY-BY-DEFAULT'
    background_allowed = $rules -match 'Background/headless automation' -and $rules -match 'remain allowed'
    foreground_examples = $rules -match 'move/click the mouse' -and $rules -match 'inject keyboard input' -and $rules -match 'visible browser tab' -and $rules -match 'visible application windows'
    explicit_authorization = $rules -match 'explicitly authorizes foreground interaction for the current task'
    unattended_exception = $rules -match 'positively establishes that the interactive machine/session is unattended'
    uncertainty_fails_closed = $rules -match 'If unattended state is uncertain, assume the user may be active'
    agent_pointer = $agents -match 'foreground user-session non-interference' -and $agents -match 'Background/headless automation is normal'
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })
if ($failed.Count -gt 0) {
    throw "Foreground user-session contract regression: $($failed -join ', ')"
}

[pscustomobject]$checks | ConvertTo-Json -Compress