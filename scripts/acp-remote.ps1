param(
    [switch]$Start,
    [switch]$Stop,
    [switch]$Code,
    [switch]$Text,
    [switch]$Status,
    [switch]$Uninstall
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
    } catch { return $false }
}

function Start-Daemon {
    try {
        Start-ScheduledTask -TaskName $taskName | Out-Null
        Write-Host "  Daemon started." -ForegroundColor Green
    } catch {
        Write-Host "  Error: could not start '$taskName'." -ForegroundColor Red
    }
}

function Stop-Daemon {
    try {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  Daemon stopped." -ForegroundColor Yellow
    } catch {
        Write-Host "  Error: could not stop '$taskName'." -ForegroundColor Red
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

function Show-TextCode {
    if (-not (Test-IsRunning)) {
        Write-Host "  Daemon is not running. Start it first." -ForegroundColor Yellow
        return
    }
    Write-Host "  Fetching pairing code..." -ForegroundColor Gray
    $code = $null
    for ($i = 0; $i -lt 5; $i++) {
        Start-Sleep -Seconds 1
        $code = Get-PairingCode
        if ($code) { break }
    }
    if (-not $code) {
        Write-Host "  Could not retrieve pairing code." -ForegroundColor Red
        return
    }
    Show-CodeFallback $code
}

function Show-QR {
    if (-not (Test-IsRunning)) {
        Write-Host "  Daemon is not running. Start it first." -ForegroundColor Yellow
        return
    }
    Write-Host "  Fetching pairing code..." -ForegroundColor Gray
    $code = $null
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        $code = Get-PairingCode
        if ($code) { break }
    }
    if (-not $code) {
        Write-Host "  Could not retrieve pairing code. Is the daemon connected?" -ForegroundColor Red
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

function Uninstall-Daemon {
    Write-Host ""
    $confirm = Read-Host "  Uninstall ACP daemon? This removes all files and auto-start. [y/N]"
    if ($confirm -notin @("y", "Y", "yes")) {
        Write-Host "  Cancelled." -ForegroundColor Gray
        return
    }
    Write-Host ""
    Write-Host "  Stopping daemon..."
    Stop-Daemon
    Write-Host "  Removing scheduled task..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  Removing acp-remote command..."
    Remove-Item -Force "$env:USERPROFILE\.local\bin\acp-remote.cmd" -ErrorAction SilentlyContinue
    Write-Host "  Removing wrapper script..."
    Remove-Item -Force (Join-Path $scriptDir "run-daemon.ps1") -ErrorAction SilentlyContinue
    Write-Host "  Removing install directory: $installDir"
    Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "  ACP daemon uninstalled." -ForegroundColor Green
}

function Draw-Menu($sel) {
    $W = 42
    $statusColor = "Red"; $statusText = "● STOPPED"
    if (Test-IsRunning) { $statusColor = "Green"; $statusText = "● RUNNING" }
    $name = Get-DaemonName

    $items = @(
        ""
        "    · Start daemon"
        "    · Stop daemon"
        "    · Show pairing QR code"
        "    · Show pairing code (text)"
        "    · Uninstall daemon"
        "    · Quit"
    )

    Write-Host ""
    Write-Host ("  " + ("═" * (14 + $W + 14)))
    Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║     ACP Daemon Control                   ║" -ForegroundColor Cyan
    Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Cyan

    Write-Host "  ║$(" " * 42)║" -ForegroundColor Cyan -NoNewline
    [Console]::SetCursorPosition(7, [Console]::CursorTop)
    Write-Host $statusText -ForegroundColor $statusColor -NoNewline
    Write-Host "$(" " * (42 - $statusText.Length - 7))"
    Write-Host "  ║" -ForegroundColor Cyan

    Write-Host "  ║$(" " * 42)║" -ForegroundColor Cyan -NoNewline
    [Console]::SetCursorPosition(4, [Console]::CursorTop)
    Write-Host "  Daemon: " -ForegroundColor Gray -NoNewline
    Write-Host $name -NoNewline
    Write-Host "$(" " * (42 - $name.Length - 12))"
    Write-Host "  ║" -ForegroundColor Cyan

    Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Cyan

    for ($i = 1; $i -le 6; $i++) {
        $text = $items[$i]
        $pad = 42 - $text.Length
        if ($i -eq $sel) {
            Write-Host "  ║" -ForegroundColor Cyan -NoNewline
            [Console]::BackgroundColor = "Cyan"
            [Console]::ForegroundColor = "Black"
            Write-Host $text -NoNewline
            Write-Host (" " * $pad) -NoNewline
            [Console]::ResetColor()
            Write-Host "║" -ForegroundColor Cyan
        } else {
            Write-Host ("  ║" + $text + (" " * $pad) + "║") -ForegroundColor Cyan
        }
    }

    Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ↑↓ navigate  ↵ select  q quit" -ForegroundColor Gray
}

function Exec-Action($sel) {
    switch ($sel) {
        1 { Start-Daemon; Start-Sleep -Seconds 1 }
        2 { Stop-Daemon; Start-Sleep -Seconds 1 }
        3 { Show-QR; Write-Host ""; Read-Host "  Press Enter to continue..." | Out-Null }
        4 { Show-TextCode; Write-Host ""; Read-Host "  Press Enter to continue..." | Out-Null }
        5 { Uninstall-Daemon; return $true }
        6 { Write-Host ""; exit 0 }
    }
    return $false
}

function Show-Menu {
    if ($Host.UI.SupportsVirtualTerminal) {
        [Console]::CursorVisible = $false
        $sel = 1
        Draw-Menu $sel

        while ($true) {
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                UpArrow { if ($sel -gt 1) { $sel-- } }
                DownArrow { if ($sel -lt 6) { $sel++ } }
                Q { [Console]::CursorVisible = $true; [Console]::ResetColor(); Write-Host ""; exit 0 }
                Escape { [Console]::CursorVisible = $true; [Console]::ResetColor(); Write-Host ""; exit 0 }
                Enter {
                    [Console]::CursorVisible = $true
                    [Console]::ResetColor()
                    Write-Host ""
                    Write-Host ""
                    $shouldExit = Exec-Action $sel
                    if ($shouldExit) { return }
                    [Console]::CursorVisible = $false
                }
            }

            # Move up 17 lines and redraw
            [Console]::SetCursorPosition(0, [Math]::Max(0, [Console]::CursorTop - 17))
            for ($i = 0; $i -lt 17; $i++) {
                Write-Host (" " * 80)
            }
            [Console]::SetCursorPosition(0, [Math]::Max(0, [Console]::CursorTop - 17))
            Draw-Menu $sel
        }
        [Console]::CursorVisible = $true
    } else {
        # Non-TTY fallback
        while ($true) {
            $statusColor = "Red"; $statusText = "STOPPED"
            if (Test-IsRunning) { $statusColor = "Green"; $statusText = "RUNNING" }
            $name = Get-DaemonName

            Write-Host ""
            Write-Host ("  ACP Daemon Control   " + $statusText + "   Daemon: " + $name) -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  1) · Start daemon       2) · Stop daemon"
            Write-Host "  3) · Show QR code       4) · Show code (text)"
            Write-Host "  5) · Uninstall daemon   q) · Quit"
            Write-Host ""

            $choice = Read-Host "  Choice"
            switch ($choice) {
                "1" { Write-Host ""; Start-Daemon; Start-Sleep -Seconds 1 }
                "2" { Write-Host ""; Stop-Daemon; Start-Sleep -Seconds 1 }
                "3" { Write-Host ""; Show-QR; Write-Host ""; Read-Host "  Press Enter to continue..." | Out-Null }
                "4" { Write-Host ""; Show-TextCode; Write-Host ""; Read-Host "  Press Enter to continue..." | Out-Null }
                "5" { Uninstall-Daemon; return }
                "q" { exit 0 }
                "Q" { exit 0 }
                default { Write-Host "  Invalid choice" -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
            }
        }
    }
}

# ── CLI dispatch ─────────────────────────────────────────────────────
if ($Start)     { Start-Daemon; exit 0 }
if ($Stop)      { Stop-Daemon; exit 0 }
if ($Code)      { Show-QR; exit 0 }
if ($Text)      { Show-TextCode; exit 0 }
if ($Uninstall) { Uninstall-Daemon; exit 0 }
if ($Status)    {
    $name = Get-DaemonName
    if (Test-IsRunning) {
        Write-Host "Daemon: RUNNING ($name)" -ForegroundColor Green
    } else {
        Write-Host "Daemon: STOPPED ($name)" -ForegroundColor Red
    }
    exit 0
}
Show-Menu
