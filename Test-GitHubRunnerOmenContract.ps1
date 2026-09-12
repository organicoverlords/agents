$ErrorActionPreference = 'Stop'
$script = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Install-GitHubRunnerOmen.sh'))

$required = @(
    'GITHUB_RUNNER_REGISTRATION_TOKEN',
    'EXPECTED_HOST="aatuska-OMEN-by-HP-Laptop-15-dc0xxx"',
    'RUNNER_VERSION="2.337.0"',
    'RUNNER_SHA256="70920811a4f8ad4328818682bca5c6469c1c942fab52448868071d0063816613"',
    'GITHUB_RUNNER_OMEN_ROOT_ALREADY_EXISTS',
    '/mnt/ue/ci-runners/*',
    'systemctl --user enable --now',
    'Restart=always',
    '--token "$GITHUB_RUNNER_REGISTRATION_TOKEN"',
    '--url "https://github.com/$repo"'
)
foreach ($needle in $required) {
    if (-not $script.Contains($needle)) {
        throw "OMEN_RUNNER_CONTRACT_MISSING=$needle"
    }
}
if ($script -match '(?m)^\s*echo\s+.*GITHUB_RUNNER_REGISTRATION_TOKEN') {
    throw 'OMEN_RUNNER_TOKEN_ECHO_FORBIDDEN'
}
if ($script.Contains('sudo ') -or $script.Contains('systemctl enable ')) {
    throw 'OMEN_RUNNER_ROOT_SERVICE_FORBIDDEN'
}
Write-Output 'OMEN_GITHUB_RUNNER_CONTRACT=PASS'
