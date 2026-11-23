<#
.SYNOPSIS
    Installs MTranServer as a local translation backend for the SS13 game server.

.DESCRIPTION
    Installs or updates the mtranserver npm package into a private prefix under
    -DataDir, downloads the requested translation directions, writes a launcher
    script and a token file, and registers a scheduled task that starts the
    service at boot. The service runs offline, without the web UI, at
    BelowNormal priority on the last -CpuCores logical cores, so Dream Daemon
    gets the CPU first.

    Run it again to update the package, the models and the settings in place.
    An existing token is kept unless -ApiToken is given.

    Requires an elevated Windows PowerShell 5.1 session and Node.js 18 or newer
    on PATH.

.PARAMETER BindAddress
    Address the service listens on. Keep the loopback default unless the game
    server runs on another machine.

.PARAMETER Port
    TCP port of the service.

.PARAMETER Languages
    Translation directions to download, in from_to form.

.PARAMETER ApiToken
    API token. When empty, the existing token is reused, or a random
    32-character token is generated.

.PARAMETER CpuCores
    Number of logical cores the service may use. The last N cores are used.

.PARAMETER DataDir
    Folder for the package, models, config, logs, launcher and token.

.PARAMETER TaskName
    Name of the scheduled task.

.PARAMETER RunAsCredential
    Account that runs the task. When omitted, the task runs as SYSTEM.

.PARAMETER Remove
    Stops and removes the task, the process, the launcher and the token.
    Models, config and logs are kept.

.PARAMETER UninstallPackage
    With -Remove, also uninstalls the npm package.

.PARAMETER SkipSmokeTest
    Skips the translation test after the service starts.

.EXAMPLE
    .\Install-MTranServer.ps1

    Installs with the defaults: 127.0.0.1:8989, en_ru and ru_en, two cores.

.EXAMPLE
    .\Install-MTranServer.ps1 -CpuCores 4

    Updates in place and lets the service use the last four logical cores.

.EXAMPLE
    .\Install-MTranServer.ps1 -RunAsCredential (Get-Credential 'HOST\mtran')

    Runs the task as a named local account instead of SYSTEM.

.EXAMPLE
    .\Install-MTranServer.ps1 -Remove -UninstallPackage

    Removes the task, launcher, token and npm package. Keeps the models.
#>
#Requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$BindAddress = '127.0.0.1',

    [ValidateRange(1, 65535)]
    [int]$Port = 8989,

    [ValidatePattern('^[A-Za-z-]+_[A-Za-z-]+$')]
    [string[]]$Languages = @('en_ru', 'ru_en'),

    [string]$ApiToken = '',

    [ValidateRange(1, 64)]
    [int]$CpuCores = 2,

    [ValidateNotNullOrEmpty()]
    [string]$DataDir = (Join-Path $env:ProgramData 'MTranServer'),

    [ValidateNotNullOrEmpty()]
    [string]$TaskName = 'MTranServer-SS13',

    [System.Management.Automation.PSCredential]$RunAsCredential,

    [switch]$Remove,

    [switch]$UninstallPackage,

    [switch]$SkipSmokeTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackageName = 'mtranserver'
$NodeDownloadUrl = 'https://nodejs.org/en/download'
$MinNodeMajor = 18
$WorkerIdleTimeoutSec = 86400
$HealthTimeoutSec = 180

$DataDir = [System.IO.Path]::GetFullPath($DataDir)
$AppDir = Join-Path $DataDir 'app'
$MainJs = Join-Path $AppDir "node_modules\$PackageName\dist\main.js"
$ShimPath = Join-Path $AppDir "$PackageName.cmd"
$ModelDir = Join-Path $DataDir 'models'
$ConfigDir = Join-Path $DataDir 'config'
$LogDir = Join-Path $DataDir 'logs'
$SecretsDir = Join-Path $DataDir 'secrets'
$TokenFile = Join-Path $SecretsDir 'api-token.txt'
$LauncherPath = Join-Path $DataDir 'Start-MTranServer.ps1'

$SidAdministrators = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
$SidSystem = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-18')
$SidUsers = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-545')

function Write-Step([string]$Message) {
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-Elevated {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Runs a native command with output on the console. Throws on a non-zero exit code.
# Stderr is not redirected, so npm warnings do not become terminating errors.
function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [Parameter(Mandatory = $true)][string]$What
    )
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $FilePath @Arguments | Out-Host
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($code -ne 0) {
        throw "$What failed with exit code $code."
    }
}

# Runs a native command and returns its stdout and stderr as strings.
function Invoke-NativeCapture {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [Parameter(Mandatory = $true)][string]$What
    )
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& $FilePath @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($code -ne 0) {
        $output | Out-Host
        throw "$What failed with exit code $code."
    }
    return $output
}

function New-RandomToken([int]$Length) {
    $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    $limit = 256 - (256 % $alphabet.Length)
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $builder = New-Object System.Text.StringBuilder
    $buffer = New-Object byte[] 64
    try {
        while ($builder.Length -lt $Length) {
            $rng.GetBytes($buffer)
            foreach ($b in $buffer) {
                if ($b -lt $limit -and $builder.Length -lt $Length) {
                    [void]$builder.Append($alphabet[$b % $alphabet.Length])
                }
            }
        }
    } finally {
        $rng.Dispose()
    }
    return $builder.ToString()
}

function ConvertFrom-CodePoint([int[]]$CodePoints) {
    return -join ($CodePoints | ForEach-Object { [char]$_ })
}

function Get-RunAsSid {
    if ($null -eq $RunAsCredential) {
        return $null
    }
    $account = New-Object System.Security.Principal.NTAccount($RunAsCredential.UserName)
    return $account.Translate([System.Security.Principal.SecurityIdentifier])
}

# Replaces the ACL of a file or folder: inheritance off, owner Administrators,
# Administrators and SYSTEM full control, plus the given extra grants.
function Set-ProtectedAcl {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [object[]]$ExtraGrants = @()
    )
    $item = Get-Item -LiteralPath $Path -Force
    $isDir = $item.PSIsContainer
    if ($isDir) {
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $inherit = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
    } else {
        $acl = New-Object System.Security.AccessControl.FileSecurity
        $inherit = [System.Security.AccessControl.InheritanceFlags]::None
    }
    $propagation = [System.Security.AccessControl.PropagationFlags]::None
    $allow = [System.Security.AccessControl.AccessControlType]::Allow
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner($SidAdministrators)

    $grants = @(
        @{ Sid = $SidAdministrators; Rights = 'FullControl' },
        @{ Sid = $SidSystem; Rights = 'FullControl' }
    ) + $ExtraGrants
    foreach ($grant in $grants) {
        if ($null -eq $grant.Sid) {
            continue
        }
        $rights = [System.Security.AccessControl.FileSystemRights]$grant.Rights
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($grant.Sid, $rights, $inherit, $propagation, $allow)
        $acl.AddAccessRule($rule)
    }
    $item.SetAccessControl($acl)
}

function Find-ServiceProcess {
    $found = @()
    $all = @(Get-CimInstance -ClassName Win32_Process -Property ProcessId, Name, CommandLine)
    foreach ($proc in $all) {
        $cmd = $proc.CommandLine
        if ([string]::IsNullOrEmpty($cmd)) {
            continue
        }
        $isNode = ($proc.Name -ieq 'node.exe') -and ($cmd.IndexOf($MainJs, [StringComparison]::OrdinalIgnoreCase) -ge 0)
        $isLauncher = ($proc.Name -ieq 'powershell.exe') -and ($cmd.IndexOf($LauncherPath, [StringComparison]::OrdinalIgnoreCase) -ge 0)
        if ($isNode -or $isLauncher) {
            $found += $proc
        }
    }
    return $found
}

function Stop-ServiceInstance {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $task) {
        if ($task.State -eq 'Running') {
            Write-Host "Stopping scheduled task '$TaskName'."
            Stop-ScheduledTask -TaskName $TaskName
        }
    }
    # Stop the launcher first so it cannot restart node, then node itself.
    $procs = Find-ServiceProcess
    $ordered = @($procs | Where-Object { $_.Name -ieq 'powershell.exe' }) + @($procs | Where-Object { $_.Name -ieq 'node.exe' })
    foreach ($proc in $ordered) {
        Write-Host "Stopping $($proc.Name) (PID $($proc.ProcessId))."
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
    }
    $deadline = (Get-Date).AddSeconds(15)
    while ((@(Find-ServiceProcess).Count -gt 0) -and ((Get-Date) -lt $deadline)) {
        Start-Sleep -Milliseconds 500
    }
    if (@(Find-ServiceProcess).Count -gt 0) {
        throw 'The MTranServer process did not stop. Stop it in Task Manager and run the script again.'
    }
}

function Get-ConnectHost {
    $ip = $null
    if (-not [System.Net.IPAddress]::TryParse($BindAddress, [ref]$ip)) {
        return $BindAddress
    }
    if ($ip.Equals([System.Net.IPAddress]::Any)) {
        return '127.0.0.1'
    }
    if ($ip.Equals([System.Net.IPAddress]::IPv6Any)) {
        return '[::1]'
    }
    if ($ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6) {
        return "[$BindAddress]"
    }
    return $BindAddress
}

function Wait-Health([string]$BaseUrl) {
    $deadline = (Get-Date).AddSeconds($HealthTimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $resp = Invoke-RestMethod -Uri "$BaseUrl/health" -Method Get -UseBasicParsing -TimeoutSec 5
            if (($null -ne $resp) -and ($null -ne $resp.PSObject.Properties['status']) -and ($resp.status -eq 'ok')) {
                return
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
        Start-Sleep -Seconds 2
    }
    throw "The service did not answer $BaseUrl/health within $HealthTimeoutSec seconds. Check the logs in $LogDir."
}

function Invoke-Translate {
    param([string]$BaseUrl, [string]$Token, [string]$From, [string]$To, [string]$Text)
    $payload = @{ from = $From; to = $To; text = $Text; html = $false } | ConvertTo-Json -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    $request = [System.Net.HttpWebRequest]::Create("$BaseUrl/translate")
    $request.Method = 'POST'
    $request.ContentType = 'application/json; charset=utf-8'
    $request.Accept = 'application/json'
    $request.Headers.Add('Authorization', "Bearer $Token")
    $request.Timeout = 300000
    $request.Proxy = $null
    $request.ContentLength = $bytes.Length
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $stream = $request.GetRequestStream()
    try {
        $stream.Write($bytes, 0, $bytes.Length)
    } finally {
        $stream.Dispose()
    }
    $response = $request.GetResponse()
    try {
        $reader = New-Object System.IO.StreamReader($response.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $body = $reader.ReadToEnd()
        $reader.Dispose()
    } finally {
        $response.Dispose()
    }
    $watch.Stop()
    $parsed = $body | ConvertFrom-Json
    if ($null -eq $parsed.PSObject.Properties['result']) {
        throw "Unexpected /translate response for $From to $To."
    }
    return [pscustomobject]@{ Result = [string]$parsed.result; Ms = $watch.ElapsedMilliseconds }
}

function Get-AffinityMask([int]$Cores) {
    $count = [Environment]::ProcessorCount
    $take = [Math]::Min($Cores, $count)
    [long]$mask = 0
    for ($i = $count - $take; $i -lt $count; $i++) {
        $mask = $mask -bor ([long]1 -shl $i)
    }
    return $mask
}

function ConvertTo-QuotedLiteral([string]$Value) {
    return "'" + $Value.Replace("'", "''") + "'"
}

# The launcher runs under the scheduled task. Placeholders are filled by the installer.
$LauncherTemplate = @'
# Generated by Install-MTranServer.ps1. Run the installer again to change settings.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$NodeExe = @@NODE@@
$MainJs = @@MAINJS@@
$DataDir = @@DATADIR@@
$TokenFile = @@TOKENFILE@@
$LogDir = @@LOGDIR@@
$CpuCores = @@CPUCORES@@
$MaxRestarts = 3
$RestartDelaySec = 60
$StableRunMinutes = 10
$LogRetentionDays = 14

$LauncherLog = Join-Path $LogDir 'launcher.log'
$StdoutLog = Join-Path $LogDir 'stdout.log'
$StderrLog = Join-Path $LogDir 'stderr.log'

function Write-LauncherLog([string]$Message) {
    $line = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $Message
    Add-Content -LiteralPath $LauncherLog -Value $line -Encoding UTF8
}

function Get-AffinityMask([int]$Cores) {
    $count = [Environment]::ProcessorCount
    $take = [Math]::Min($Cores, $count)
    [long]$mask = 0
    for ($i = $count - $take; $i -lt $count; $i++) {
        $mask = $mask -bor ([long]1 -shl $i)
    }
    return $mask
}

# Applies priority and affinity to the process and all its descendants.
function Set-ProcessLimits([int]$RootId, [long]$Mask) {
    $all = @(Get-CimInstance -ClassName Win32_Process -Property ProcessId, ParentProcessId)
    $ids = New-Object 'System.Collections.Generic.List[int]'
    $ids.Add($RootId)
    $i = 0
    while ($i -lt $ids.Count) {
        foreach ($p in $all) {
            if (([int]$p.ParentProcessId -eq $ids[$i]) -and (-not $ids.Contains([int]$p.ProcessId))) {
                $ids.Add([int]$p.ProcessId)
            }
        }
        $i++
    }
    foreach ($id in $ids) {
        try {
            $proc = Get-Process -Id $id -ErrorAction Stop
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
            $proc.ProcessorAffinity = [IntPtr]$Mask
        } catch {
            Write-LauncherLog "Could not limit PID ${id}: $($_.Exception.Message)"
        }
    }
}

New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
Get-ChildItem -LiteralPath $LogDir -Filter 'mtran-*.log' -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$LogRetentionDays) } |
    Remove-Item -Force -ErrorAction SilentlyContinue

$env:MT_HOST = @@HOST@@
$env:MT_PORT = @@PORT@@
$env:MT_MODEL_DIR = @@MODELDIR@@
$env:MT_CONFIG_DIR = @@CONFIGDIR@@
$env:MT_LOG_DIR = $LogDir
$env:MT_LOG_TO_FILE = 'true'
$env:MT_LOG_LEVEL = 'info'
$env:MT_LOG_REQUESTS = 'false'
$env:MT_ENABLE_UI = 'false'
$env:MT_CHECK_UPDATE = 'false'
$env:MT_OFFLINE = 'true'
$env:MT_FAST = 'false'
$env:MT_CPU_ONLY = 'true'
$env:MT_WORKER_IDLE_TIMEOUT = @@IDLETIMEOUT@@
$env:UV_THREADPOOL_SIZE = [string]$CpuCores
$env:MT_API_TOKEN = ([System.IO.File]::ReadAllText($TokenFile)).Trim()

# Children inherit BelowNormal priority and affinity from this process.
$mask = Get-AffinityMask $CpuCores
$self = [System.Diagnostics.Process]::GetCurrentProcess()
$self.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
$self.ProcessorAffinity = [IntPtr]$mask

$restarts = 0
while ($true) {
    foreach ($log in @($StdoutLog, $StderrLog)) {
        if (Test-Path -LiteralPath $log) {
            Move-Item -LiteralPath $log -Destination "$log.1" -Force
        }
    }
    $started = Get-Date
    $node = Start-Process -FilePath $NodeExe -ArgumentList @('"' + $MainJs + '"') -WorkingDirectory $DataDir `
        -NoNewWindow -PassThru -RedirectStandardOutput $StdoutLog -RedirectStandardError $StderrLog
    $null = $node.Handle
    Write-LauncherLog ('Started node PID {0}, affinity mask 0x{1:X}.' -f $node.Id, $mask)
    Set-ProcessLimits -RootId $node.Id -Mask $mask
    Start-Sleep -Seconds 5
    if (-not $node.HasExited) {
        Set-ProcessLimits -RootId $node.Id -Mask $mask
    }
    $node.WaitForExit()
    $code = $node.ExitCode
    Write-LauncherLog "Node exited with code $code."
    if (((Get-Date) - $started).TotalMinutes -ge $StableRunMinutes) {
        $restarts = 0
    }
    if ($restarts -ge $MaxRestarts) {
        Write-LauncherLog 'Restart limit reached. The launcher exits.'
        if ($code -eq 0) { exit 1 } else { exit $code }
    }
    $restarts++
    Start-Sleep -Seconds $RestartDelaySec
}
'@

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

if (-not (Test-Elevated)) {
    throw 'Run this script from an elevated PowerShell window (Run as administrator).'
}

if ($Remove) {
    Write-Step 'Removing MTranServer service'
    Stop-ServiceInstance

    if ($null -ne (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed scheduled task '$TaskName'."
    }
    if (Test-Path -LiteralPath $LauncherPath) {
        Remove-Item -LiteralPath $LauncherPath -Force
        Write-Host "Removed $LauncherPath."
    }
    if (Test-Path -LiteralPath $SecretsDir) {
        Remove-Item -LiteralPath $SecretsDir -Recurse -Force
        Write-Host "Removed $SecretsDir."
    }

    if ($UninstallPackage) {
        if (Test-Path -LiteralPath $AppDir) {
            $npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
            if ($null -ne $npmCmd) {
                Invoke-Native -FilePath $npmCmd.Source -Arguments @('uninstall', '--global', '--prefix', $AppDir, $PackageName) -What 'npm uninstall'
            }
            Remove-Item -LiteralPath $AppDir -Recurse -Force
            Write-Host "Removed the $PackageName package from $AppDir."
        }
    } else {
        Write-Host "The npm package is kept in $AppDir. Add -UninstallPackage to remove it."
    }

    Write-Host ''
    Write-Host 'Kept on disk:'
    Write-Host "  Models: $ModelDir"
    Write-Host "  Config: $ConfigDir"
    Write-Host "  Logs:   $LogDir"
    Write-Host "Delete $DataDir by hand if you no longer need them."
    Write-Host 'Remove the TRANSLATE_* lines from config/autotranslate.txt or set the provider to none.'
    return
}

Write-Step 'Checking prerequisites'

$ipCheck = $null
if (-not [System.Net.IPAddress]::TryParse($BindAddress, [ref]$ipCheck)) {
    throw "BindAddress '$BindAddress' is not an IP address."
}
if (-not [System.Net.IPAddress]::IsLoopback($ipCheck)) {
    Write-Warning "BindAddress $BindAddress is not loopback. Other machines can reach the service. Block the port in the firewall if that is not intended."
}

$nodeCmd = Get-Command node.exe -ErrorAction SilentlyContinue
$npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
if (($null -eq $nodeCmd) -or ($null -eq $npmCmd)) {
    Write-Host ''
    Write-Host 'Node.js and npm were not found on PATH.' -ForegroundColor Yellow
    Write-Host "Install the Node.js LTS version (Windows Installer, .msi) from $NodeDownloadUrl"
    Write-Host 'Keep the default options, open a new elevated PowerShell window, and run this script again.'
    throw 'Node.js is not installed.'
}
$NodeExe = $nodeCmd.Source
$NpmCmdPath = $npmCmd.Source

$nodeVersionText = ([string]@(Invoke-NativeCapture -FilePath $NodeExe -Arguments @('--version') -What 'node --version')[0]).Trim()
$nodeMajor = 0
if (-not ($nodeVersionText -match '^v(\d+)\.') -or (-not [int]::TryParse($Matches[1], [ref]$nodeMajor)) -or ($nodeMajor -lt $MinNodeMajor)) {
    throw "Node.js $nodeVersionText is too old. Install the LTS version from $NodeDownloadUrl."
}
Write-Host "Node.js $nodeVersionText at $NodeExe"

if ($NodeExe.StartsWith((Join-Path $env:SystemDrive 'Users'), [StringComparison]::OrdinalIgnoreCase)) {
    Write-Warning "node.exe is inside a user profile ($NodeExe). The task account must be able to read it. The Node.js .msi installer avoids this."
}

$logicalCores = [Environment]::ProcessorCount
if ($CpuCores -ge $logicalCores) {
    Write-Warning "CpuCores $CpuCores is not less than the $logicalCores logical cores. The service may use every core."
}

$runAsSid = Get-RunAsSid
$ApiToken = $ApiToken.Trim()
if (($ApiToken.Length -gt 0) -and (($ApiToken.Length -lt 16) -or ($ApiToken -match '\s'))) {
    throw 'ApiToken must be at least 16 characters and contain no spaces.'
}

Write-Step 'Stopping the running instance, if any'
Stop-ServiceInstance

$listener = @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
if ($listener.Count -gt 0) {
    $owner = Get-Process -Id $listener[0].OwningProcess -ErrorAction SilentlyContinue
    $ownerName = if ($null -ne $owner) { $owner.ProcessName } else { "PID $($listener[0].OwningProcess)" }
    throw "Port $Port is already used by $ownerName. Free it or pass another -Port."
}

# ---------------------------------------------------------------------------
# Folders and permissions
# ---------------------------------------------------------------------------

Write-Step "Preparing $DataDir"
foreach ($dir in @($DataDir, $AppDir, $ModelDir, $ConfigDir, $LogDir, $SecretsDir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
Set-ProtectedAcl -Path $DataDir -ExtraGrants @(
    @{ Sid = $SidUsers; Rights = 'ReadAndExecute' },
    @{ Sid = $runAsSid; Rights = 'ReadAndExecute' }
)
foreach ($dir in @($ModelDir, $ConfigDir)) {
    Set-ProtectedAcl -Path $dir -ExtraGrants @(
        @{ Sid = $SidUsers; Rights = 'ReadAndExecute' },
        @{ Sid = $runAsSid; Rights = 'Modify' }
    )
}
Set-ProtectedAcl -Path $LogDir -ExtraGrants @(@{ Sid = $runAsSid; Rights = 'Modify' })
Set-ProtectedAcl -Path $SecretsDir -ExtraGrants @(@{ Sid = $runAsSid; Rights = 'Read' })

# ---------------------------------------------------------------------------
# Package
# ---------------------------------------------------------------------------

Write-Step "Installing or updating the $PackageName npm package"
Invoke-Native -FilePath $NpmCmdPath -Arguments @('install', '--global', '--prefix', $AppDir, '--no-fund', '--no-audit', "$PackageName@latest") -What 'npm install'
if (-not (Test-Path -LiteralPath $MainJs)) {
    throw "The package was installed but $MainJs is missing. The package layout may have changed."
}
$pkgJson = Get-Content -LiteralPath (Join-Path $AppDir "node_modules\$PackageName\package.json") -Raw | ConvertFrom-Json
Write-Host "Installed $PackageName $($pkgJson.version)"
Write-Host "  npm launcher: $ShimPath"
Write-Host "  entry point:  $MainJs (started with node.exe directly, without the npm shim)"

# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------

Write-Step "Downloading translation directions: $($Languages -join ', ')"
$envNames = @('MT_MODEL_DIR', 'MT_CONFIG_DIR', 'MT_LOG_LEVEL', 'MT_CHECK_UPDATE', 'MT_OFFLINE', 'MT_CPU_ONLY', 'MT_FAST', 'MT_LOG_TO_FILE')
$savedEnv = @{}
foreach ($name in $envNames) {
    $savedEnv[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
try {
    $env:MT_MODEL_DIR = $ModelDir
    $env:MT_CONFIG_DIR = $ConfigDir
    $env:MT_LOG_LEVEL = 'info'
    $env:MT_CHECK_UPDATE = 'false'
    $env:MT_OFFLINE = 'false'
    $env:MT_CPU_ONLY = 'true'
    $env:MT_FAST = 'false'
    $env:MT_LOG_TO_FILE = 'false'

    # --download only warns and exits 0 for an unknown pair, so check the list first.
    $listing = @(Invoke-NativeCapture -FilePath $NodeExe -Arguments @($MainJs, '--languages') -What 'mtranserver --languages')
    $available = @($listing | ForEach-Object { $_ -split '\s+' } | Where-Object { $_ -match '^[A-Za-z-]+_[A-Za-z-]+$' })
    foreach ($pair in $Languages) {
        if ($available -notcontains $pair) {
            throw "Direction $pair is not in the model list. Run '$ShimPath --languages' to see the available directions."
        }
    }

    Invoke-Native -FilePath $NodeExe -Arguments (@($MainJs, '--download') + $Languages) -What 'mtranserver --download'
} finally {
    foreach ($name in $envNames) {
        [Environment]::SetEnvironmentVariable($name, $savedEnv[$name], 'Process')
    }
}

# ---------------------------------------------------------------------------
# Token and launcher
# ---------------------------------------------------------------------------

Write-Step 'Writing the token file and the launcher'
if ($ApiToken.Length -eq 0) {
    if (Test-Path -LiteralPath $TokenFile) {
        $ApiToken = ([System.IO.File]::ReadAllText($TokenFile)).Trim()
        Write-Host "Reusing the existing token in $TokenFile."
    }
    if ($ApiToken.Length -lt 16) {
        $ApiToken = New-RandomToken 32
        Write-Host 'Generated a new 32-character token.'
    }
}
[System.IO.File]::WriteAllText($TokenFile, $ApiToken, (New-Object System.Text.ASCIIEncoding))
Set-ProtectedAcl -Path $TokenFile -ExtraGrants @(@{ Sid = $runAsSid; Rights = 'Read' })

$launcherText = $LauncherTemplate.
    Replace('@@NODE@@', (ConvertTo-QuotedLiteral $NodeExe)).
    Replace('@@MAINJS@@', (ConvertTo-QuotedLiteral $MainJs)).
    Replace('@@DATADIR@@', (ConvertTo-QuotedLiteral $DataDir)).
    Replace('@@TOKENFILE@@', (ConvertTo-QuotedLiteral $TokenFile)).
    Replace('@@LOGDIR@@', (ConvertTo-QuotedLiteral $LogDir)).
    Replace('@@MODELDIR@@', (ConvertTo-QuotedLiteral $ModelDir)).
    Replace('@@CONFIGDIR@@', (ConvertTo-QuotedLiteral $ConfigDir)).
    Replace('@@HOST@@', (ConvertTo-QuotedLiteral $BindAddress)).
    Replace('@@PORT@@', (ConvertTo-QuotedLiteral ([string]$Port))).
    Replace('@@IDLETIMEOUT@@', (ConvertTo-QuotedLiteral ([string]$WorkerIdleTimeoutSec))).
    Replace('@@CPUCORES@@', ([string]$CpuCores))
[System.IO.File]::WriteAllText($LauncherPath, $launcherText, (New-Object System.Text.UTF8Encoding($true)))
Set-ProtectedAcl -Path $LauncherPath -ExtraGrants @(@{ Sid = $runAsSid; Rights = 'ReadAndExecute' })
Write-Host "Launcher: $LauncherPath"
Write-Host "Token:    $TokenFile (Administrators and SYSTEM only)"

# ---------------------------------------------------------------------------
# Scheduled task
# ---------------------------------------------------------------------------

Write-Step "Registering scheduled task '$TaskName'"
$psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$action = New-ScheduledTaskAction -Execute $psExe `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$LauncherPath`"" `
    -WorkingDirectory $DataDir
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew -StartWhenAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -Priority 7
$description = 'MTranServer translation backend for the SS13 game server. Managed by Install-MTranServer.ps1.'

if ($null -eq $RunAsCredential) {
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Description $description -Action $action -Trigger $trigger `
        -Settings $settings -Principal $principal -Force | Out-Null
    Write-Host 'The task runs as SYSTEM.'
} else {
    Register-ScheduledTask -TaskName $TaskName -Description $description -Action $action -Trigger $trigger `
        -Settings $settings -User $RunAsCredential.UserName -Password $RunAsCredential.GetNetworkCredential().Password `
        -RunLevel Limited -Force | Out-Null
    Write-Host "The task runs as $($RunAsCredential.UserName)."
}
Start-ScheduledTask -TaskName $TaskName

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

$connectHost = Get-ConnectHost
$baseUrl = "http://${connectHost}:$Port"

Write-Step "Waiting for $baseUrl/health"
Wait-Health $baseUrl
Write-Host 'The service is up.'

$nodeProc = @(Find-ServiceProcess | Where-Object { $_.Name -ieq 'node.exe' }) | Select-Object -First 1
if ($null -ne $nodeProc) {
    $p = Get-Process -Id $nodeProc.ProcessId
    $expectedMask = Get-AffinityMask $CpuCores
    $actualMask = [long]$p.ProcessorAffinity
    Write-Host ('node.exe PID {0}: priority {1}, affinity mask 0x{2:X} (expected 0x{3:X}).' -f $p.Id, $p.PriorityClass, $actualMask, $expectedMask)
    if (($p.PriorityClass -ne [System.Diagnostics.ProcessPriorityClass]::BelowNormal) -or ($actualMask -ne $expectedMask)) {
        Write-Warning "Priority or affinity differ from the expected values. Check $(Join-Path $LogDir 'launcher.log')."
    }
} else {
    Write-Warning 'Could not find the node.exe process to check its priority and affinity.'
}

if (-not $SkipSmokeTest) {
    Write-Step 'Smoke test'
    # "Privet, kak dela?" in Cyrillic, built from code points so the file stays ASCII.
    $ruText = ConvertFrom-CodePoint @(0x041F, 0x0440, 0x0438, 0x0432, 0x0435, 0x0442, 0x002C, 0x0020,
        0x043A, 0x0430, 0x043A, 0x0020, 0x0434, 0x0435, 0x043B, 0x0430, 0x003F)
    # "Gde kuznets?" in Cyrillic.
    $ruText2 = ConvertFrom-CodePoint @(0x0413, 0x0434, 0x0435, 0x0020, 0x043A, 0x0443, 0x0437, 0x043D, 0x0435, 0x0446, 0x003F)
    $tests = @(
        @{ From = 'ru'; To = 'en'; Text = $ruText; Text2 = $ruText2 },
        @{ From = 'en'; To = 'ru'; Text = 'Good morning, where is the blacksmith?'; Text2 = 'The river is cold today.' }
    )
    $oldOutputEncoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
        foreach ($t in $tests) {
            # The first call may load the model. The second uses a different
            # sentence so the result cache does not hide the real time.
            foreach ($text in @($t.Text, $t.Text2)) {
                $r = Invoke-Translate -BaseUrl $baseUrl -Token $ApiToken -From $t.From -To $t.To -Text $text
                Write-Host ("{0} -> {1}: {2}" -f $t.From, $t.To, $text)
                Write-Host ("  result: {0}" -f $r.Result)
                Write-Host ("  round trip: {0} ms" -f $r.Ms)
            }
        }
    } finally {
        [Console]::OutputEncoding = $oldOutputEncoding
    }
}

Write-Step 'Done'
Write-Host "Logs:   $LogDir"
Write-Host "Models: $ModelDir"
Write-Host ''
Write-Host 'Add these lines to config/autotranslate.txt on the game server:' -ForegroundColor Green
Write-Host ''
Write-Host 'TRANSLATE_PROVIDER mtranserver'
Write-Host "TRANSLATE_HTTP_URL $baseUrl"
Write-Host "TRANSLATE_HTTP_TOKEN $ApiToken"
Write-Host ''
