param(
    [switch]$Start,
    [switch]$Stop,
    [switch]$Code,
    [switch]$Status
)

$ErrorActionPreference = "Continue"

$taskName = "ACP Daemon"
$logFile = "$env:TEMP\acp-daemon.log"

$scriptDir = Split-Path -Parent $PSCommandPath
$installDir = Split-Path -Parent $scriptDir
$python = Join-Path $installDir ".venv" "Scripts" "python.exe"

function Get-DaemonName {
    if ($env:ACP_DAEMON_ID) { return $env:ACP_DAEMON_ID }
    return $env:COMPUTERNAME
}

function Test-IsRunning {
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        return $task.State -eq "Running"
    } catch {
        return $false
    }
}

function Start-Daemon {
    try {
        Start-ScheduledTask -TaskName $taskName | Out-Null
        Write-Host "Daemon started."
    } catch {
        Write-Host "Error: could not start '$taskName'."
    }
}

function Stop-Daemon {
    try {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Daemon stopped."
    } catch {
        Write-Host "Error: could not stop '$taskName'."
    }
}

function Get-PairingCode {
    if (Test-Path $logFile) {
        $match = Select-String -Path $logFile -Pattern 'pairing code:\s+(\S+)' | Select-Object -Last 1
        if ($match) { return $match.Matches.Groups[1].Value }
    }
    return $null
}

function Show-CodeFallback($code) {
    $formatted = $code.Substring(0, 4) + "-" + $code.Substring(4)
    Write-Host ""
    Write-Host "  +-----------------------------+"
    Write-Host ("  |  Pairing Code: {0,-12}  |" -f $formatted)
    Write-Host "  |                             |"
    Write-Host "  |  Enter this in the app      |"
    Write-Host "  +-----------------------------+"
    Write-Host ""
}

function Show-QR {
    if (-not (Test-IsRunning)) {
        Write-Host "Daemon is not running. Start it first: acp-remote start"
        return
    }

    Write-Host "Fetching pairing code..."
    $code = $null
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        $code = Get-PairingCode
        if ($code) { break }
    }

    if (-not $code) {
        Write-Host "Could not retrieve pairing code. Is the daemon connected to the relay?"
        return
    }

    Write-Host ""
    if ((Test-Path $python) -and (Test-Path "$installDir\src")) {
        & $python -c @"
import sys; sys.path.insert(0, r'$installDir\src')
from daemon.main import _pairing_banner
print(_pairing_banner('$code'))
"@ 2>$null
        if ($LASTEXITCODE -eq 0) { return }
    }
    Show-CodeFallback $code
}

function Show-Menu {
    $status = if (Test-IsRunning) { "RUNNING" } else { "STOPPED" }
    $name = Get-DaemonName

    Write-Host ""
    Write-Host "  ACP Daemon Control"
    Write-Host "  $('=' * 40)"
    Write-Host "  Status: $status  |  Daemon: $name"
    Write-Host ""
    Write-Host "    1) Start daemon"
    Write-Host "    2) Stop daemon"
    Write-Host "    3) Show pairing QR code"
    Write-Host "    q) Quit"
    Write-Host ""

    while ($true) {
        $choice = Read-Host "  Choice"
        switch ($choice) {
            "1" { Write-Host ""; Start-Daemon; break }
            "2" { Write-Host ""; Stop-Daemon; break }
            "3" { Write-Host ""; Show-QR; break }
            "q" { exit 0 }
            "Q" { exit 0 }
            default { Write-Host "  Invalid choice" }
        }
    }
}

# --- CLI dispatch ---
if ($Start)    { Start-Daemon; exit 0 }
if ($Stop)     { Stop-Daemon; exit 0 }
if ($Code)     { Show-QR; exit 0 }
if ($Status)   {
    $name = Get-DaemonName
    if (Test-IsRunning) {
        Write-Host "Daemon: RUNNING ($name)"
    } else {
        Write-Host "Daemon: STOPPED ($name)"
    }
    exit 0
}
Show-Menu
