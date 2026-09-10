[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$RunnerRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RunnerRoot).Path
$commandProcessor = $env:ComSpec
if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
    $commandProcessor = Join-Path ([Environment]::SystemDirectory) 'cmd.exe'
}
if (-not (Test-Path -LiteralPath $commandProcessor -PathType Leaf)) {
    throw "GITHUB_RUNNER_COMMAND_PROCESSOR_MISSING=$commandProcessor"
}
$taskKill = Join-Path ([Environment]::SystemDirectory) 'taskkill.exe'
if (-not (Test-Path -LiteralPath $taskKill -PathType Leaf)) {
    throw "GITHUB_RUNNER_TASKKILL_MISSING=$taskKill"
}

if (-not ('GitHubRunnerHiddenConsoleProcess' -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;

public sealed class GitHubRunnerHiddenConsoleProcess : IDisposable
{
    private const uint CREATE_NEW_CONSOLE = 0x00000010;
    private const uint CREATE_UNICODE_ENVIRONMENT = 0x00000400;
    private const uint STARTF_USESHOWWINDOW = 0x00000001;
    private const ushort SW_HIDE = 0;
    private const uint WAIT_OBJECT_0 = 0x00000000;
    private const uint WAIT_TIMEOUT = 0x00000102;
    private const uint INFINITE = 0xFFFFFFFF;
    private const uint STILL_ACTIVE = 259;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct STARTUPINFO
    {
        public uint cb;
        public IntPtr lpReserved;
        public IntPtr lpDesktop;
        public IntPtr lpTitle;
        public uint dwX;
        public uint dwY;
        public uint dwXSize;
        public uint dwYSize;
        public uint dwXCountChars;
        public uint dwYCountChars;
        public uint dwFillAttribute;
        public uint dwFlags;
        public ushort wShowWindow;
        public ushort cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct PROCESS_INFORMATION
    {
        public IntPtr hProcess;
        public IntPtr hThread;
        public uint dwProcessId;
        public uint dwThreadId;
    }

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CreateProcessW(
        string lpApplicationName,
        StringBuilder lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        [MarshalAs(UnmanagedType.Bool)] bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetExitCodeProcess(IntPtr hProcess, out uint lpExitCode);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CloseHandle(IntPtr hObject);

    private IntPtr processHandle;
    private bool disposed;

    private GitHubRunnerHiddenConsoleProcess(IntPtr processHandle, uint processId)
    {
        this.processHandle = processHandle;
        this.Id = checked((int)processId);
    }

    public int Id { get; private set; }

    public bool HasExited
    {
        get
        {
            EnsureNotDisposed();
            uint code;
            if (!GetExitCodeProcess(this.processHandle, out code))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetExitCodeProcess failed");
            }
            return code != STILL_ACTIVE;
        }
    }

    public int ExitCode
    {
        get
        {
            EnsureNotDisposed();
            uint code;
            if (!GetExitCodeProcess(this.processHandle, out code))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetExitCodeProcess failed");
            }
            if (code == STILL_ACTIVE)
            {
                throw new InvalidOperationException("Process has not exited.");
            }
            return unchecked((int)code);
        }
    }

    public static GitHubRunnerHiddenConsoleProcess Start(string applicationPath, string arguments, string workingDirectory)
    {
        STARTUPINFO startupInfo = new STARTUPINFO();
        startupInfo.cb = checked((uint)Marshal.SizeOf(typeof(STARTUPINFO)));
        startupInfo.dwFlags = STARTF_USESHOWWINDOW;
        startupInfo.wShowWindow = SW_HIDE;

        StringBuilder commandLine = new StringBuilder();
        commandLine.Append('"').Append(applicationPath).Append('"');
        if (!String.IsNullOrWhiteSpace(arguments))
        {
            commandLine.Append(' ').Append(arguments);
        }

        PROCESS_INFORMATION processInformation;
        uint creationFlags = CREATE_NEW_CONSOLE | CREATE_UNICODE_ENVIRONMENT;
        if (!CreateProcessW(
            applicationPath,
            commandLine,
            IntPtr.Zero,
            IntPtr.Zero,
            false,
            creationFlags,
            IntPtr.Zero,
            workingDirectory,
            ref startupInfo,
            out processInformation))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateProcessW hidden-console launch failed");
        }

        if (processInformation.hThread != IntPtr.Zero)
        {
            CloseHandle(processInformation.hThread);
        }
        return new GitHubRunnerHiddenConsoleProcess(processInformation.hProcess, processInformation.dwProcessId);
    }

    public bool WaitForExit(int milliseconds)
    {
        EnsureNotDisposed();
        uint timeout = milliseconds < 0 ? INFINITE : checked((uint)milliseconds);
        uint waitResult = WaitForSingleObject(this.processHandle, timeout);
        if (waitResult == WAIT_OBJECT_0) { return true; }
        if (waitResult == WAIT_TIMEOUT) { return false; }
        throw new Win32Exception(Marshal.GetLastWin32Error(), "WaitForSingleObject failed");
    }

    private void EnsureNotDisposed()
    {
        if (this.disposed) { throw new ObjectDisposedException("GitHubRunnerHiddenConsoleProcess"); }
    }

    public void Dispose()
    {
        if (this.disposed) { return; }
        this.disposed = true;
        if (this.processHandle != IntPtr.Zero)
        {
            CloseHandle(this.processHandle);
            this.processHandle = IntPtr.Zero;
        }
    }
}
"@
}


function Test-CommandLineContains {
    param(
        [AllowNull()]
        [string]$CommandLine,
        [Parameter(Mandatory)]
        [string]$Needle
    )
    return (-not [string]::IsNullOrWhiteSpace($CommandLine)) -and
        ($CommandLine.IndexOf($Needle, [StringComparison]::OrdinalIgnoreCase) -ge 0)
}

function Get-RunnerListenersForRoot {
    param([Parameter(Mandatory)][string]$Root)
    return @(
        Get-CimInstance Win32_Process -Filter "Name='Runner.Listener.exe'" -ErrorAction SilentlyContinue |
            Where-Object { Test-CommandLineContains -CommandLine $_.CommandLine -Needle $Root }
    )
}

function Get-RunnerWorkersForRoot {
    param([Parameter(Mandatory)][string]$Root)
    return @(
        Get-CimInstance Win32_Process -Filter "Name='Runner.Worker.exe'" -ErrorAction SilentlyContinue |
            Where-Object { Test-CommandLineContains -CommandLine $_.CommandLine -Needle $Root }
    )
}

function Get-CurrentLaunchLongBrokerBackoff {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumSeconds,
        [Parameter(Mandatory)][int]$PostJobTransitionGraceSeconds
    )
    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $pattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z WARN BrokerServer\] Back off (?<seconds>\d+(?:[.,]\d+)?) seconds before next retry\.'
    $jobCompletionPattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z INFO JobDispatcher\] finish job request for job [0-9a-fA-F-]+ with result: .+$'
    foreach ($log in @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 4)) {
        $lastJobCompletionAt = $null
        foreach ($line in @(Get-Content -LiteralPath $log.FullName -Tail 200 -ErrorAction SilentlyContinue)) {
            $completionMatch = [regex]::Match($line, $jobCompletionPattern)
            if ($completionMatch.Success) {
                $completionAt = [datetime]::ParseExact(
                    $completionMatch.Groups['observed'].Value,
                    'yyyy-MM-dd HH:mm:ss',
                    [Globalization.CultureInfo]::InvariantCulture,
                    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
                )
                if ($completionAt -ge $LaunchStartedUtc.AddSeconds(-1)) { $lastJobCompletionAt = $completionAt }
                continue
            }
            $match = [regex]::Match($line, $pattern)
            if (-not $match.Success) { continue }
            $observedAt = [datetime]::ParseExact(
                $match.Groups['observed'].Value,
                'yyyy-MM-dd HH:mm:ss',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
            )
            if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }
            [double]$seconds = 0
            $secondsText = $match.Groups['seconds'].Value.Replace(',', '.')
            if (-not [double]::TryParse($secondsText, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$seconds)) { continue }
            if ($seconds -lt [double]$MinimumSeconds) { continue }
            if ($null -ne $lastJobCompletionAt) {
                $secondsSinceJobCompletion = ($observedAt - $lastJobCompletionAt).TotalSeconds
                if ($secondsSinceJobCompletion -ge 0 -and $secondsSinceJobCompletion -le $PostJobTransitionGraceSeconds) { continue }
            }
            return [pscustomobject]@{
                ObservedAtUtc = $observedAt
                Seconds = $seconds
                LogPath = $log.FullName
            }
        }
    }
    return $null
}

function Get-CurrentLaunchRepeatedSessionConflict {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumCount,
        [Parameter(Mandatory)][int]$MinimumSpanSeconds,
        [Parameter(Mandatory)][int]$MaximumAgeSeconds
    )
    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $sessionConflictPattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z ERR  Terminal\] WRITE ERROR: A session for this runner already exists\.$'
    $observed = @()
    foreach ($log in @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 4)) {
        foreach ($line in @(Get-Content -LiteralPath $log.FullName -Tail 240 -ErrorAction SilentlyContinue)) {
            $match = [regex]::Match($line, $sessionConflictPattern)
            if (-not $match.Success) { continue }
            $observedAt = [datetime]::ParseExact(
                $match.Groups['observed'].Value,
                'yyyy-MM-dd HH:mm:ss',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
            )
            if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }
            $observed += $observedAt
        }
    }
    $observed = @($observed | Sort-Object -Unique)
    if ($observed.Count -lt $MinimumCount) { return $null }
    $first = $observed[0]
    $latest = $observed[-1]
    $spanSeconds = [int][Math]::Floor(($latest - $first).TotalSeconds)
    if ($spanSeconds -lt $MinimumSpanSeconds) { return $null }
    $ageSeconds = [int][Math]::Floor(([datetime]::UtcNow - $latest).TotalSeconds)
    if ($ageSeconds -lt 0 -or $ageSeconds -gt $MaximumAgeSeconds) { return $null }
    return [pscustomobject]@{
        FirstObservedAtUtc = $first
        LatestObservedAtUtc = $latest
        Count = $observed.Count
        SpanSeconds = $spanSeconds
    }
}

function Get-CurrentLaunchRepeatedCancellationStorm {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumCount,
        [Parameter(Mandatory)][int]$MinimumSpanSeconds,
        [Parameter(Mandatory)][int]$MaximumAgeSeconds
    )
    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $cancellationPattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z INFO JobDispatcher\] Job cancellation request (?<job>[0-9a-fA-F-]+) received, cancellation timeout \d+ minutes\.$'
    $byJob = @{}
    foreach ($log in @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 4)) {
        foreach ($line in @(Get-Content -LiteralPath $log.FullName -Tail 240 -ErrorAction SilentlyContinue)) {
            $match = [regex]::Match($line, $cancellationPattern)
            if (-not $match.Success) { continue }
            $observedAt = [datetime]::ParseExact(
                $match.Groups['observed'].Value,
                'yyyy-MM-dd HH:mm:ss',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
            )
            if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }
            $jobId = $match.Groups['job'].Value.ToLowerInvariant()
            if (-not $byJob.ContainsKey($jobId)) { $byJob[$jobId] = @() }
            $byJob[$jobId] += $observedAt
        }
    }
    foreach ($jobId in @($byJob.Keys)) {
        $observed = @($byJob[$jobId] | Sort-Object)
        if ($observed.Count -lt $MinimumCount) { continue }
        $first = $observed[0]
        $latest = $observed[-1]
        $spanSeconds = [int][Math]::Floor(($latest - $first).TotalSeconds)
        if ($spanSeconds -lt $MinimumSpanSeconds) { continue }
        $ageSeconds = [int][Math]::Floor(([datetime]::UtcNow - $latest).TotalSeconds)
        if ($ageSeconds -lt 0 -or $ageSeconds -gt $MaximumAgeSeconds) { continue }
        return [pscustomobject]@{
            JobId = $jobId
            FirstObservedAtUtc = $first
            LatestObservedAtUtc = $latest
            Count = $observed.Count
            SpanSeconds = $spanSeconds
        }
    }
    return $null
}


function Get-CurrentLaunchDisconnectedReadyListener {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumReadyAgeSeconds,
        [scriptblock]$ConnectionProbe = $null
    )
    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $readyPattern = '^\[(?<observed>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})Z INFO Terminal\] WRITE LINE: .*: Listening for Jobs$'
    $readyAt = $null
    $readyLogPath = $null
    foreach ($log in @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 4)) {
        foreach ($line in @(Get-Content -LiteralPath $log.FullName -Tail 240 -ErrorAction SilentlyContinue)) {
            $match = [regex]::Match($line, $readyPattern)
            if (-not $match.Success) { continue }
            $observedAt = [datetime]::ParseExact(
                $match.Groups['observed'].Value,
                'yyyy-MM-dd HH:mm:ss',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
            )
            if ($observedAt -lt $LaunchStartedUtc.AddSeconds(-1)) { continue }
            if ($null -eq $readyAt -or $observedAt -gt $readyAt) {
                $readyAt = $observedAt
                $readyLogPath = $log.FullName
            }
        }
    }
    if ($null -eq $readyAt) { return $null }

    $readyAgeSeconds = [int][Math]::Floor(([datetime]::UtcNow - $readyAt).TotalSeconds)
    if ($readyAgeSeconds -lt $MinimumReadyAgeSeconds) { return $null }

    $listeners = @(Get-RunnerListenersForRoot -Root $Root)
    if ($listeners.Count -ne 1) { return $null }
    $listener = $listeners[0]

    if ($null -eq $ConnectionProbe) {
        $ConnectionProbe = {
            param([int]$ListenerPid)
            return @(
                Get-CimInstance -Namespace root/StandardCimv2 -ClassName MSFT_NetTCPConnection -Filter "OwningProcess = $ListenerPid AND State = 5" -ErrorAction Stop |
                    Where-Object { $_.RemotePort -eq 443 }
            )
        }
    }

    try {
        $establishedBrokerConnections = @(& $ConnectionProbe ([int]$listener.ProcessId))
    }
    catch {
        # Transport introspection is a recovery hint, not authority to disrupt a runner.
        return $null
    }
    if ($establishedBrokerConnections.Count -gt 0) { return $null }

    return [pscustomobject]@{
        ReadyAtUtc = $readyAt
        ReadyAgeSeconds = $readyAgeSeconds
        ListenerPid = [int]$listener.ProcessId
        LogPath = $readyLogPath
    }
}


function Get-CurrentLaunchPreReadyNoLogStall {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][datetime]$LaunchStartedUtc,
        [Parameter(Mandatory)][int]$MinimumLaunchAgeSeconds,
        [Parameter(Mandatory)][int]$HelperPid
    )
    $launchAgeSeconds = [int][Math]::Floor(([datetime]::UtcNow - $LaunchStartedUtc).TotalSeconds)
    if ($launchAgeSeconds -lt $MinimumLaunchAgeSeconds) { return $null }

    $diagRoot = Join-Path $Root '_diag'
    if (-not (Test-Path -LiteralPath $diagRoot -PathType Container)) { return $null }

    $listeners = @(Get-RunnerListenersForRoot -Root $Root)
    if ($listeners.Count -ne 1) { return $null }
    $listener = $listeners[0]
    if ([int]$listener.ParentProcessId -ne $HelperPid) { return $null }

    $currentLaunchLogs = @(Get-ChildItem -LiteralPath $diagRoot -Filter 'Runner_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTimeUtc -ge $LaunchStartedUtc.AddSeconds(-1) } |
        Select-Object -First 1)
    if ($currentLaunchLogs.Count -gt 0) { return $null }

    return [pscustomobject]@{
        LaunchAgeSeconds = $launchAgeSeconds
        ListenerPid = [int]$listener.ProcessId
        HelperPid = $HelperPid
    }
}


function Test-ListenerHasLiveLauncher {
    param(
        [Parameter(Mandatory)]$Listener,
        [Parameter(Mandatory)][string]$Root
    )
    $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($Listener.ParentProcessId)" -ErrorAction SilentlyContinue
    if (-not $parent) { return $false }
    $launcher = Get-CimInstance Win32_Process -Filter "ProcessId=$($parent.ParentProcessId)" -ErrorAction SilentlyContinue
    if (-not $launcher) { return $false }
    return (Test-CommandLineContains -CommandLine $launcher.CommandLine -Needle 'Start-GitHubRunnerHidden.ps1') -and
        (Test-CommandLineContains -CommandLine $launcher.CommandLine -Needle $Root)
}

function Remove-OrphanedRunnerListeners {
    param([Parameter(Mandatory)][string]$Root)
    foreach ($listener in @(Get-RunnerListenersForRoot -Root $Root)) {
        $worker = Get-CimInstance Win32_Process -Filter "Name='Runner.Worker.exe' AND ParentProcessId=$($listener.ProcessId)" -ErrorAction SilentlyContinue
        if ($worker) {
            throw "GITHUB_RUNNER_EXISTING_ACTIVE_WORKER=root:$Root|listener_pid:$($listener.ProcessId)|worker_pid:$($worker.ProcessId)"
        }
        if (Test-ListenerHasLiveLauncher -Listener $listener -Root $Root) {
            throw "GITHUB_RUNNER_LAUNCHER_ALREADY_ACTIVE=root:$Root|listener_pid:$($listener.ProcessId)"
        }

        & $taskKill /PID ([string]$listener.ProcessId) /T /F | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "GITHUB_RUNNER_ORPHAN_CLEANUP_FAILED=root:$Root|listener_pid:$($listener.ProcessId)|exit:$LASTEXITCODE"
        }
        Start-Sleep -Milliseconds 200
        if (Get-Process -Id $listener.ProcessId -ErrorAction SilentlyContinue) {
            throw "GITHUB_RUNNER_ORPHAN_SURVIVED=root:$Root|listener_pid:$($listener.ProcessId)"
        }
    }
}

$helperTemplate = Join-Path $root 'run-helper.cmd.template'
$helperCommand = Join-Path $root 'run-helper.cmd'
if (-not (Test-Path -LiteralPath $helperTemplate -PathType Leaf)) {
    throw "GITHUB_RUNNER_HELPER_TEMPLATE_MISSING=$helperTemplate"
}

Get-ChildItem -LiteralPath $root -File | Unblock-File -ErrorAction SilentlyContinue

while ($true) {
    Remove-OrphanedRunnerListeners -Root $root
    Copy-Item -LiteralPath $helperTemplate -Destination $helperCommand -Force

    # Create an explicit hidden console for the helper. Runner.Listener, Runner.Worker,
    # and action descendants inherit it, so console-subsystem children do not allocate
    # their own visible console windows. Do not inherit the scheduled task's std handles;
    # they are not guaranteed to be valid in the Interactive task host.
    $helperArguments = '/d /s /c ""{0}""' -f $helperCommand
    $launchStartedUtc = [datetime]::UtcNow
    $process = [GitHubRunnerHiddenConsoleProcess]::Start($commandProcessor, $helperArguments, $root)

    $brokerBackoffMinimumSeconds = 300
    $brokerBackoffPostJobGraceSeconds = 15
    $sessionConflictMinimumCount = 3
    $sessionConflictMinimumSpanSeconds = 45
    $sessionConflictMaximumAgeSeconds = 60
    $cancellationStormMinimumCount = 12
    $cancellationStormMinimumSpanSeconds = 5
    $cancellationStormMaximumAgeSeconds = 15
    $disconnectedReadyMinimumAgeSeconds = 120
    $disconnectedReadyProbeIntervalSeconds = 30
    $nextDisconnectedReadyProbeUtc = $launchStartedUtc.AddSeconds($disconnectedReadyMinimumAgeSeconds)
    $preReadyNoLogMinimumAgeSeconds = 300
    $preReadyNoLogProbeIntervalSeconds = 30
    $nextPreReadyNoLogProbeUtc = $launchStartedUtc.AddSeconds($preReadyNoLogMinimumAgeSeconds)
    # Observed server-side session release after an owned recycle took up to 188 seconds on RR-KONE-02.
    # Wait slightly longer before spawning a replacement so recovery does not manufacture its own 409 loop.
    $brokerSessionReleaseSeconds = 210
    $brokerRecycleTriggered = $false
    while (-not $process.WaitForExit(1000)) {
        $backoff = Get-CurrentLaunchLongBrokerBackoff -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumSeconds $brokerBackoffMinimumSeconds -PostJobTransitionGraceSeconds $brokerBackoffPostJobGraceSeconds
        $sessionConflict = Get-CurrentLaunchRepeatedSessionConflict -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumCount $sessionConflictMinimumCount -MinimumSpanSeconds $sessionConflictMinimumSpanSeconds -MaximumAgeSeconds $sessionConflictMaximumAgeSeconds
        $cancellationStorm = Get-CurrentLaunchRepeatedCancellationStorm -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumCount $cancellationStormMinimumCount -MinimumSpanSeconds $cancellationStormMinimumSpanSeconds -MaximumAgeSeconds $cancellationStormMaximumAgeSeconds
        $disconnectedReady = $null
        $preReadyNoLog = $null
        $probeNowUtc = [datetime]::UtcNow
        if ($probeNowUtc -ge $nextDisconnectedReadyProbeUtc) {
            $disconnectedReady = Get-CurrentLaunchDisconnectedReadyListener -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumReadyAgeSeconds $disconnectedReadyMinimumAgeSeconds
            $nextDisconnectedReadyProbeUtc = $probeNowUtc.AddSeconds($disconnectedReadyProbeIntervalSeconds)
        }
        if ($probeNowUtc -ge $nextPreReadyNoLogProbeUtc) {
            $preReadyNoLog = Get-CurrentLaunchPreReadyNoLogStall -Root $root -LaunchStartedUtc $launchStartedUtc -MinimumLaunchAgeSeconds $preReadyNoLogMinimumAgeSeconds -HelperPid $process.Id
            $nextPreReadyNoLogProbeUtc = $probeNowUtc.AddSeconds($preReadyNoLogProbeIntervalSeconds)
        }
        if ($null -eq $backoff -and $null -eq $sessionConflict -and $null -eq $cancellationStorm -and $null -eq $disconnectedReady -and $null -eq $preReadyNoLog) { continue }
        $workers = @(Get-RunnerWorkersForRoot -Root $root)
        if ($workers.Count -gt 0) { continue }

        if ($null -ne $backoff) {
            Write-Warning "GITHUB_RUNNER_BROKER_BACKOFF_RECOVERY=root:$root|seconds:$($backoff.Seconds)|log:$($backoff.LogPath)|helper_pid:$($process.Id)"
        } elseif ($null -ne $sessionConflict) {
            Write-Warning "GITHUB_RUNNER_SESSION_CONFLICT_RECOVERY=root:$root|count:$($sessionConflict.Count)|span_seconds:$($sessionConflict.SpanSeconds)|helper_pid:$($process.Id)"
        } elseif ($null -ne $cancellationStorm) {
            Write-Warning "GITHUB_RUNNER_CANCELLATION_STORM_RECOVERY=root:$root|job:$($cancellationStorm.JobId)|count:$($cancellationStorm.Count)|span_seconds:$($cancellationStorm.SpanSeconds)|helper_pid:$($process.Id)"
        } elseif ($null -ne $disconnectedReady) {
            Write-Warning "GITHUB_RUNNER_DISCONNECTED_READY_RECOVERY=root:$root|listener_pid:$($disconnectedReady.ListenerPid)|ready_age_seconds:$($disconnectedReady.ReadyAgeSeconds)|log:$($disconnectedReady.LogPath)|helper_pid:$($process.Id)"
        } else {
            Write-Warning "GITHUB_RUNNER_PRE_READY_NO_LOG_RECOVERY=root:$root|listener_pid:$($preReadyNoLog.ListenerPid)|launch_age_seconds:$($preReadyNoLog.LaunchAgeSeconds)|helper_pid:$($process.Id)"
        }
        & $taskKill /PID ([string]$process.Id) /T /F | Out-Null
        if ($LASTEXITCODE -ne 0 -and -not $process.HasExited) {
            throw "GITHUB_RUNNER_BROKER_RECYCLE_FAILED=root:$root|helper_pid:$($process.Id)|exit:$LASTEXITCODE"
        }
        if (-not $process.WaitForExit(10000)) {
            throw "GITHUB_RUNNER_BROKER_RECYCLE_TIMEOUT=root:$root|helper_pid:$($process.Id)"
        }
        $brokerRecycleTriggered = $true
        break
    }
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($env:ACTIONS_RUNNER_RETURN_VERSION_DEPRECATED_EXIT_CODE -eq '1' -and $exitCode -eq 7) {
        exit $exitCode
    }
    if ($brokerRecycleTriggered) {
        Write-Warning "GITHUB_RUNNER_BROKER_SESSION_RELEASE_WAIT=root:$root|seconds:$brokerSessionReleaseSeconds"
        Start-Sleep -Seconds $brokerSessionReleaseSeconds
        continue
    }

    # This launcher owns a persistent runner. Any helper exit other than the explicit
    # version-deprecated handoff is a recoverable loss of service, including exit 0.
    Write-Warning "GITHUB_RUNNER_HELPER_EXITED=root:$root|exit:$exitCode|restart_seconds:2"
    Start-Sleep -Seconds 2
    continue
}
