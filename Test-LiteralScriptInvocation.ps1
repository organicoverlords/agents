Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$helper = Join-Path $PSScriptRoot 'Invoke-LiteralScript.ps1'
if (-not (Test-Path -LiteralPath $helper)) { throw 'Invoke-LiteralScript.ps1 missing' }

# Historical failure class: a variable intended for a nested PowerShell command is
# expanded by the parent before the child sees it, leaving an empty LiteralPath.
$childOnlyPath = ''
$hazardCommand = 'Test-Path -LiteralPath "' + $childOnlyPath + '"'
$hazardEncoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($hazardCommand))
$savedPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $hazardOutput = @(& powershell.exe -NoLogo -NoProfile -NonInteractive -EncodedCommand $hazardEncoded 2>&1)
    $hazardCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $savedPreference
}
$hazardText = (($hazardOutput | ForEach-Object { [string]$_ }) -join "`n")
if ($hazardCode -eq 0) { throw 'historical nested command unexpectedly accepted empty LiteralPath' }
if ($hazardText -notmatch '(?i)LiteralPath' -or $hazardText -notmatch '(?i)empty') {
    throw "historical nested command did not reproduce empty LiteralPath: $hazardText"
}

$root = Join-Path ([IO.Path]::GetTempPath()) ('agents-literal-script-test-' + [Guid]::NewGuid().ToString('N'))
try {
    $expectedPath = Join-Path $root 'folder with spaces'
    New-Item -ItemType Directory -Force -Path $expectedPath | Out-Null
    $token = 'dollar=$childOnlyPath; quote="two words"; single=''x'''

    $powershellPayload = @'
param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Token
)
if ([string]::IsNullOrEmpty($Path)) { throw 'literal path was empty' }
Write-Output ('PATH=' + $Path)
Write-Output ('TOKEN=' + $Token)
'@
    $psOutput = @(& $helper -Language PowerShell -ScriptText $powershellPayload -ArgumentList @($expectedPath,$token))
    if ($psOutput.Count -ne 2) { throw "unexpected PowerShell output count: $($psOutput.Count)" }
    if ([string]$psOutput[0] -ne "PATH=$expectedPath") { throw "PowerShell path changed: $($psOutput[0])" }
    if ([string]$psOutput[1] -ne "TOKEN=$token") { throw "PowerShell token changed: $($psOutput[1])" }

    $pythonPayload = @'
import json
import sys
print(json.dumps(sys.argv[1:], ensure_ascii=False))
'@
    $pythonOutput = @(& $helper -Language Python -ScriptText $pythonPayload -ArgumentList @($expectedPath,$token))
    if ($pythonOutput.Count -ne 1) { throw "unexpected Python output count: $($pythonOutput.Count)" }
    $pythonArgs = [object[]]($pythonOutput[0] | ConvertFrom-Json)
    if ($pythonArgs.Count -ne 2) { throw "unexpected Python argv count: $($pythonArgs.Count)" }
    if ([string]$pythonArgs[0] -ne $expectedPath) { throw "Python path changed: $($pythonArgs[0])" }
    if ([string]$pythonArgs[1] -ne $token) { throw "Python token changed: $($pythonArgs[1])" }

    Write-Output 'PASS literal script invocation preserves PowerShell/Python payload values'
}
finally {
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}
