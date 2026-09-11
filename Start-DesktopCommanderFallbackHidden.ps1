[CmdletBinding()]
param(
    [switch]$Probe,
    [switch]$ReadyProbe,
    [switch]$TreeCleanupProbe,
    [switch]$AllowInteractiveAuthorization
)

$ErrorActionPreference = 'Stop'

function Get-DesktopCommanderJwtEmail {
    param([string]$AccessToken)
    if ([string]::IsNullOrWhiteSpace($AccessToken)) { return $null }
    try {
        $parts = $AccessToken.Split('.')
        if ($parts.Count -lt 2) { return $null }
        $payload = $parts[1].Replace('-', '+').Replace('_', '/')
        switch ($payload.Length % 4) {
            2 { $payload += '==' }
            3 { $payload += '=' }
            1 { return $null }
        }
        $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
        $claims = $json | ConvertFrom-Json
        $email = [string]$claims.email
        if ([string]::IsNullOrWhiteSpace($email)) { return $null }
        return $email.Trim()
    }
    catch { return $null }
}

function Get-DesktopCommanderAuthorizationState {
    $configDir = Join-Path $env:USERPROFILE '.desktop-commander-device'
    $configPath = Join-Path $configDir 'device.json'
    $expectedAccountPath = Join-Path $configDir 'expected-account.txt'
    $expectedAccount = $null
    if (Test-Path -LiteralPath $expectedAccountPath -PathType Leaf) {
        try { $expectedAccount = (Get-Content -LiteralPath $expectedAccountPath -Raw).Trim() } catch {}
    }
    $state = [ordered]@{
        status = 'AUTHORIZATION_REQUIRED'
        ready = $false
        config_path = $configPath
        expected_account_path = $expectedAccountPath
        expected_account_email = $expectedAccount
        session_account_email = $null
        account_matches_expected = $false
        has_device_id = $false
        has_session = $false
        has_access_token = $false
        has_refresh_token = $false
    }
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return [pscustomobject]$state
    }
    try {
        $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    }
    catch {
        $state.status = 'INVALID_PERSISTED_CONFIG'
        return [pscustomobject]$state
    }
    $state.has_device_id = -not [string]::IsNullOrWhiteSpace([string]$config.deviceId)
    $state.has_session = $null -ne $config.session
    $state.has_access_token = $state.has_session -and -not [string]::IsNullOrWhiteSpace([string]$config.session.access_token)
    $state.has_refresh_token = $state.has_session -and -not [string]::IsNullOrWhiteSpace([string]$config.session.refresh_token)
    if (-not ($state.has_device_id -and $state.has_access_token -and $state.has_refresh_token)) {
        return [pscustomobject]$state
    }
    if ([string]::IsNullOrWhiteSpace($expectedAccount)) {
        $state.status = 'EXPECTED_ACCOUNT_REQUIRED'
        return [pscustomobject]$state
    }
    $state.session_account_email = Get-DesktopCommanderJwtEmail -AccessToken ([string]$config.session.access_token)
    if ([string]::IsNullOrWhiteSpace([string]$state.session_account_email)) {
        $state.status = 'SESSION_IDENTITY_UNREADABLE'
        return [pscustomobject]$state
    }
    $state.account_matches_expected = [string]::Equals(
        [string]$state.session_account_email,
        [string]$expectedAccount,
        [StringComparison]::OrdinalIgnoreCase
    )
    if (-not $state.account_matches_expected) {
        $state.status = 'ACCOUNT_MISMATCH'
        return [pscustomobject]$state
    }
    $state.ready = $true
    $state.status = 'READY'
    return [pscustomobject]$state
}

if ($ReadyProbe) {
    $authorization = Get-DesktopCommanderAuthorizationState
    $authorization | ConvertTo-Json -Compress
    if ($authorization.ready) { exit 0 }
    exit 2
}
$commandProcessor = $env:ComSpec
if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
    $commandProcessor = Join-Path ([Environment]::SystemDirectory) 'cmd.exe'
}
if (-not (Test-Path -LiteralPath $commandProcessor -PathType Leaf)) {
    throw "DESKTOP_COMMANDER_COMMAND_PROCESSOR_MISSING=$commandProcessor"
}
if (-not ('DesktopCommanderProcessJob' -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class DesktopCommanderProcessJob
{
    [StructLayout(LayoutKind.Sequential)]
    public struct JOBOBJECT_BASIC_LIMIT_INFORMATION
    {
        public long PerProcessUserTimeLimit;
        public long PerJobUserTimeLimit;
        public uint LimitFlags;
        public UIntPtr MinimumWorkingSetSize;
        public UIntPtr MaximumWorkingSetSize;
        public uint ActiveProcessLimit;
        public UIntPtr Affinity;
        public uint PriorityClass;
        public uint SchedulingClass;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct IO_COUNTERS
    {
        public ulong ReadOperationCount;
        public ulong WriteOperationCount;
        public ulong OtherOperationCount;
        public ulong ReadTransferCount;
        public ulong WriteTransferCount;
        public ulong OtherTransferCount;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct JOBOBJECT_EXTENDED_LIMIT_INFORMATION
    {
        public JOBOBJECT_BASIC_LIMIT_INFORMATION BasicLimitInformation;
        public IO_COUNTERS IoInfo;
        public UIntPtr ProcessMemoryLimit;
        public UIntPtr JobMemoryLimit;
        public UIntPtr PeakProcessMemoryUsed;
        public UIntPtr PeakJobMemoryUsed;
    }

    private const uint JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000;
    private const int JobObjectExtendedLimitInformation = 9;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr CreateJobObject(IntPtr jobAttributes, string name);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool SetInformationJobObject(IntPtr job, int infoClass, ref JOBOBJECT_EXTENDED_LIMIT_INFORMATION info, uint length);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr handle);

    public static IntPtr CreateKillOnCloseJob()
    {
        IntPtr job = CreateJobObject(IntPtr.Zero, null);
        if (job == IntPtr.Zero)
            throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateJobObject failed");

        var info = new JOBOBJECT_EXTENDED_LIMIT_INFORMATION();
        info.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
        uint size = (uint)Marshal.SizeOf(typeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION));
        if (!SetInformationJobObject(job, JobObjectExtendedLimitInformation, ref info, size))
        {
            int error = Marshal.GetLastWin32Error();
            CloseHandle(job);
            throw new Win32Exception(error, "SetInformationJobObject failed");
        }
        return job;
    }

    public static void Assign(IntPtr job, IntPtr process)
    {
        if (!AssignProcessToJobObject(job, process))
            throw new Win32Exception(Marshal.GetLastWin32Error(), "AssignProcessToJobObject failed");
    }
}
"@
}

$script:DesktopCommanderJob = [DesktopCommanderProcessJob]::CreateKillOnCloseJob()

function Start-HiddenChild {
    param(
        [Parameter(Mandatory)][string]$FileName,
        [Parameter(Mandatory)][string]$Arguments
    )
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FileName
    $startInfo.Arguments = $Arguments
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw "DESKTOP_COMMANDER_HIDDEN_START_FAILED=$FileName"
    }
    try {
        [DesktopCommanderProcessJob]::Assign($script:DesktopCommanderJob, $process.Handle)
    }
    catch {
        try { $process.Kill() } catch {}
        throw
    }
    return $process
}

function Get-DescendantProcessIds {
    param([Parameter(Mandatory)][int]$ParentPid)
    $result = [System.Collections.Generic.List[int]]::new()
    $queue = [System.Collections.Generic.Queue[int]]::new()
    $queue.Enqueue($ParentPid)
    while ($queue.Count -gt 0) {
        $parent = $queue.Dequeue()
        foreach ($child in @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$parent" -ErrorAction SilentlyContinue)) {
            $childPid = [int]$child.ProcessId
            if (-not $result.Contains($childPid)) {
                $result.Add($childPid)
                $queue.Enqueue($childPid)
            }
        }
    }
    return @($result)
}

if ($TreeCleanupProbe) {
    $treeProcess = Start-HiddenChild -FileName $commandProcessor -Arguments '/d /s /c "ping -t 127.0.0.1 >nul"'
    [pscustomobject]@{
        status = 'RUNNING'
        child_pid = $treeProcess.Id
    } | ConvertTo-Json -Compress
    [Console]::Out.Flush()
    $treeProcess.WaitForExit()
    exit $treeProcess.ExitCode
}
if ($Probe) {
    $probeProcess = Start-HiddenChild -FileName $commandProcessor -Arguments '/d /s /c "ping -n 4 127.0.0.1 >nul"'
    Start-Sleep -Milliseconds 300
    $ids = @($probeProcess.Id) + @(Get-DescendantProcessIds -ParentPid $probeProcess.Id)
    $visible = @()
    foreach ($processId in $ids) {
        $live = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($live -and $live.MainWindowHandle -ne 0) {
            $visible += [pscustomobject]@{ pid = $processId; name = $live.ProcessName; handle = $live.MainWindowHandle }
        }
    }
    $probeProcess.WaitForExit()
    [pscustomobject]@{
        status = if ($visible.Count -eq 0) { 'PASS' } else { 'FAIL' }
        root_pid = $probeProcess.Id
        observed_process_count = $ids.Count
        visible_processes = $visible
    } | ConvertTo-Json -Compress
    if ($visible.Count -ne 0) { exit 1 }
    exit $probeProcess.ExitCode
}

$authorization = Get-DesktopCommanderAuthorizationState
if (-not $authorization.ready -and -not $AllowInteractiveAuthorization) {
    throw "DESKTOP_COMMANDER_PERSISTED_SESSION_REQUIRED=$($authorization.config_path) status=$($authorization.status)"
}
if ($AllowInteractiveAuthorization) {
    if ([string]::IsNullOrWhiteSpace([string]$authorization.expected_account_email)) {
        throw "DESKTOP_COMMANDER_EXPECTED_ACCOUNT_REQUIRED=$($authorization.expected_account_path)"
    }
    if ((Test-Path -LiteralPath $authorization.config_path -PathType Leaf) -and $authorization.status -in @('ACCOUNT_MISMATCH','SESSION_IDENTITY_UNREADABLE','INVALID_PERSISTED_CONFIG')) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $quarantine = "$($authorization.config_path).rejected-$stamp"
        Move-Item -LiteralPath $authorization.config_path -Destination $quarantine -Force
    }
}

$npx = (Get-Command npx.cmd -ErrorAction Stop).Source
$escapedNpx = $npx.Replace('"', '""')
$child = Start-HiddenChild -FileName $commandProcessor -Arguments ('/d /s /c ""{0}" --yes @wonderwhy-er/desktop-commander@latest remote"' -f $escapedNpx)
if ($AllowInteractiveAuthorization) {
    while (-not $child.HasExited) {
        Start-Sleep -Milliseconds 250
        $liveAuthorization = Get-DesktopCommanderAuthorizationState
        if ($liveAuthorization.has_session) {
            if ($liveAuthorization.status -eq 'ACCOUNT_MISMATCH' -or $liveAuthorization.status -eq 'SESSION_IDENTITY_UNREADABLE') {
                [DesktopCommanderProcessJob]::CloseHandle($script:DesktopCommanderJob) | Out-Null
                $script:DesktopCommanderJob = [IntPtr]::Zero
                throw "DESKTOP_COMMANDER_AUTH_ACCOUNT_REJECTED expected=$($liveAuthorization.expected_account_email) actual=$($liveAuthorization.session_account_email) status=$($liveAuthorization.status)"
            }
            if ($liveAuthorization.ready) { break }
        }
    }
}
$child.WaitForExit()
exit $child.ExitCode
