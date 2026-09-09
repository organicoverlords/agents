[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('PowerShell','Python')][string]$Language,
    [Parameter(Mandatory=$true)][AllowEmptyString()][string]$ScriptText,
    [string[]]$ArgumentList = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$extension = if ($Language -eq 'PowerShell') { '.ps1' } else { '.py' }
$stamp = [Guid]::NewGuid().ToString('N')
$tempRoot = [IO.Path]::GetTempPath()
$targetPath = Join-Path $tempRoot ("agents-literal-script-$stamp$extension")
$argsPath = Join-Path $tempRoot ("agents-literal-script-$stamp.args.json")
$bootstrapPath = Join-Path $tempRoot ("agents-literal-script-$stamp.bootstrap$extension")
$utf8 = New-Object Text.UTF8Encoding($false)

[IO.File]::WriteAllText($targetPath, $ScriptText, $utf8)
$argsJson = ConvertTo-Json -Compress -InputObject ([object[]]$ArgumentList)
[IO.File]::WriteAllText($argsPath, $argsJson, $utf8)

try {
    if ($Language -eq 'PowerShell') {
        $bootstrap = @'
param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [Parameter(Mandatory=$true)][string]$ArgumentsPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$arguments = [object[]](Get-Content -LiteralPath $ArgumentsPath -Raw | ConvertFrom-Json)
& $TargetPath @arguments
'@
        [IO.File]::WriteAllText($bootstrapPath, $bootstrap, $utf8)
        $output = @(& powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $bootstrapPath $targetPath $argsPath)
    }
    else {
        $bootstrap = @'
import json
import runpy
import sys

target_path = sys.argv[1]
arguments_path = sys.argv[2]
with open(arguments_path, "r", encoding="utf-8") as handle:
    arguments = json.load(handle)
sys.argv = [target_path] + [str(value) for value in arguments]
runpy.run_path(target_path, run_name="__main__")
'@
        [IO.File]::WriteAllText($bootstrapPath, $bootstrap, $utf8)
        $python = (Get-Command python.exe -ErrorAction Stop).Source
        $output = @(& $python $bootstrapPath $targetPath $argsPath)
    }
    $code = $LASTEXITCODE
    $output | Write-Output
    if ($code -ne 0) {
        throw "LITERAL_SCRIPT_FAILED language=$Language exit_code=$code"
    }
}
finally {
    foreach ($path in @($targetPath,$argsPath,$bootstrapPath)) {
        Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    }
}
