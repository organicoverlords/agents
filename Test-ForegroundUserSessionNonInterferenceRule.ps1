$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$rules = Get-Content -LiteralPath (Join-Path $root 'RULES.md') -Raw
$agents = Get-Content -LiteralPath (Join-Path $root 'AGENTS.md') -Raw

$checks = [ordered]@{
    rule_present = $rules -match 'FOREGROUND USER-SESSION INTERACTION IS ANNOUNCE-BEFORE-ACT'
    background_allowed = $rules -match 'Background/headless automation' -and $rules -match 'remain allowed' -and $rules -match 'are preferred'
    foreground_examples = $rules -match 'moving/clicking the mouse' -and $rules -match 'injecting keyboard input' -and $rules -match 'switching/closing/reordering/reloading tabs' -and $rules -match 'opening/closing/repositioning application windows'
    notice_required = $rules -match 'must be preceded by a concise chat notice naming the application/window and the visible effect'
    explicit_request_satisfies_notice = $rules -match 'If the exact foreground action is already explicitly requested by the user in the current turn, that request satisfies the notice requirement'
    explicit_boundary_hard_block = $rules -match 'is a hard block until the user explicitly reverses it'
    browser_workaround_forbidden = $rules -match 'Never open a visible browser merely to work around a headless/browser-auth/tooling limitation without first announcing the visible action'
    agent_pointer = $agents -match 'foreground user-session interaction' -and $agents -match 'Background/headless automation is normal'
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })
if ($failed.Count -gt 0) {
    throw "Foreground user-session contract regression: $($failed -join ', ')"
}

[pscustomobject]$checks | ConvertTo-Json -Compress