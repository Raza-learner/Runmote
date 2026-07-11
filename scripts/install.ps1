$ErrorActionPreference = "Continue"

# ── Bootstrap: if running via irm | iex, download the repo first ────
$hasLocalFiles = [bool]$PSScriptRoot -and (Test-Path "$PSScriptRoot\..\pyproject.toml" -ErrorAction SilentlyContinue)
if (-not $hasLocalFiles -and -not $env:ACP_BOOTSTRAPPED) {
    $remote  = if ($env:ACP_REMOTE) { $env:ACP_REMOTE } else { "https://github.com/Raza-learner/Runmote.git" }
    $branch  = if ($env:ACP_BRANCH) { $env:ACP_BRANCH } else { "dev" }
    $tmpDir  = "$env:TEMP\runmote-install"
    $extract = "$tmpDir\repo"

    Write-Host "Downloading Runmote installer ($branch branch)..." -ForegroundColor Cyan

    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType Directory -Force -Path $extract | Out-Null

    # Try archive download (fast)
    try {
        $zipUrl = "https://github.com/Raza-learner/Runmote/archive/refs/heads/$branch.zip"
        $zipFile = "$tmpDir\repo.zip"
        Invoke-WebRequest -UseBasicParsing -Uri $zipUrl -OutFile $zipFile -ErrorAction Stop
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tmpDir)
        # GitHub archives extract to "Runmote-$branch" folder
        $extracted = Get-ChildItem "$tmpDir\Runmote-*" -Directory | Select-Object -First 1
        if ($extracted) {
            Move-Item "$($extracted.FullName)\*" $extract -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # Fallback: shallow git clone
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Host "Error: git or internet connection required." -ForegroundColor Red
            exit 1
        }
        git clone --depth 1 --branch "$branch" "$remote" $extract 2>$null
        if ($LASTEXITCODE -ne 0) {
            git clone --depth 1 --branch "$branch" "git@github.com:Raza-learner/Runmote.git" $extract 2>$null
        }
    }

    if (-not (Test-Path "$extract\scripts\install.ps1")) {
        Write-Host "Error: failed to download installer." -ForegroundColor Red
        exit 1
    }

    $env:ACP_BOOTSTRAPPED = "1"
    $env:ACP_BOOTSTRAP_DIR = "$extract"
    Get-Content "$extract\scripts\install.ps1" -Raw -Encoding UTF8 | Invoke-Expression
    exit $LASTEXITCODE
}

# ── Bypass execution policy for this process (uv installer needs it) ─
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue

# ── Color setup ──────────────────────────────────────────────────────
$interactive = [Environment]::UserInteractive -and -not $PSCommandPath.StartsWith("-")

# Defaults
$remote     = if ($env:ACP_REMOTE)    { $env:ACP_REMOTE }    else { "https://github.com/Raza-learner/Runmote.git" }
$branch     = if ($env:ACP_BRANCH)    { $env:ACP_BRANCH }    else { "dev" }
$installDir = if ($env:ACP_DIR)       { $env:ACP_DIR }       else { "$env:USERPROFILE\.local\share\runmote" }
$mode       = "install"
$skipAutostart = $false

# Parse $args for flags
for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        "-Dir"    { $installDir = $args[++$i] }
        "-Branch" { $branch = $args[++$i] }
        "-Remove" { $mode = "remove" }
        "-Help"   {
            Write-Host @"
Install Runmote daemon and configure auto-start.

Usage:
  powershell -c "irm https://runmote.dev/install.ps1 | iex"
  `$env:ACP_RELAY_URL='ws://host:8000/daemon'; powershell -c "irm https://runmote.dev/install.ps1 | iex"

Environment variables:
  ACP_RELAY_URL      WebSocket URL of the relay server
  ACP_DAEMON_TOKEN   Auth token for daemon-relay authentication
  ACP_DAEMON_ID      Daemon identifier (default: hostname)
  ACP_BRANCH         Git branch (default: dev)
  ACP_DIR            Install directory
  ACP_REMOTE         Git remote URL
"@
            return
        }
    }
}

$hasGit = Get-Command git -ErrorAction SilentlyContinue

# Ensure uv
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv (Python package manager)..."
    iex ((New-Object Net.WebClient).DownloadString('https://astral.sh/uv/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:Path
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "Error: uv installation failed. Install manually: https://docs.astral.sh/uv"
        return
    }
}

# ── Remove mode ──────────────────────────────────────────────────────
if ($mode -eq "remove") {
    Write-Host "Removing Runmote daemon..."
    $setupScript = Join-Path $installDir "scripts" "setup-autostart.ps1"
    if (Test-Path $setupScript) { & $setupScript -Remove }
    if (Test-Path $installDir)  { Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue }
    Write-Host "Runmote daemon uninstalled."
    return
}

# ── Interactive prompts ──────────────────────────────────────────────
if ($interactive) {
    Write-Host ""
    Write-Host "   ██████╗ ██╗   ██╗███╗   ██╗███╗   ███╗ ██████╗ ████████╗███████╗" -ForegroundColor Cyan
    Write-Host "   ██╔══██╗██║   ██║████╗  ██║████╗ ████║██╔═══██╗╚══██╔══╝██╔════╝" -ForegroundColor Cyan
    Write-Host "   ██████╔╝██║   ██║██╔██╗ ██║██╔████╔██║██║   ██║   ██║   █████╗  " -ForegroundColor Cyan
    Write-Host "   ██╔══██╗██║   ██║██║╚██╗██║██║╚██╔╝██║██║   ██║   ██║   ██╔══╝  " -ForegroundColor Cyan
    Write-Host "   ██║  ██║╚██████╔╝██║ ╚████║██║ ╚═╝ ██║╚██████╔╝   ██║   ███████╗" -ForegroundColor Cyan
    Write-Host "   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝    ╚═╝   ╚══════╝" -ForegroundColor Cyan
    Write-Host "   Runmote  —  Daemon Setup" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "  Configuration" -ForegroundColor Cyan
    Write-Host ""

    $defaultName = if ($env:ACP_DAEMON_ID) { $env:ACP_DAEMON_ID } else { $env:COMPUTERNAME }
    $nameInput = Read-Host "  Daemon name [$defaultName]"
    if ($nameInput) { $env:ACP_DAEMON_ID = $nameInput } else { $env:ACP_DAEMON_ID = $defaultName }

    $dirInput = Read-Host "  Install to [$installDir]"
    if ($dirInput) { $installDir = $dirInput }

    $autostartInput = Read-Host "  Auto-start on login? [Y/n]"
    if ($autostartInput -eq "n" -or $autostartInput -eq "N" -or $autostartInput -eq "no") {
        $skipAutostart = $true
    }
    Write-Host ""
}

# ── Install ──────────────────────────────────────────────────────────
$daemonName = if ($env:ACP_DAEMON_ID) { $env:ACP_DAEMON_ID } else { $env:COMPUTERNAME }

Write-Host "  Runmote Daemon Installer" -ForegroundColor Cyan
Write-Host "  Daemon: $daemonName  |  Install: $installDir" -ForegroundColor DarkGray
Write-Host ""

Write-Host "[1/3] Installing dependencies..."
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
}
# Copy project files to install dir (bootstrap dir set by irm | iex flow)
$srcDir = if ($env:ACP_BOOTSTRAP_DIR) { $env:ACP_BOOTSTRAP_DIR } elseif ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { "" }
if ($srcDir -and (Test-Path "$srcDir\pyproject.toml")) {
    Copy-Item "$srcDir\*" $installDir -Recurse -Force -Exclude ".git",".venv","__pycache__",".pytest_cache","*.db","logs"
}
Push-Location $installDir -ErrorAction SilentlyContinue
uv sync --frozen
if ($LASTEXITCODE -ne 0) {
    Write-Host "  frozen sync failed — running full sync..."
    uv sync
}
Pop-Location -ErrorAction SilentlyContinue
Write-Host "  Done."

Write-Host "[2/3] Setting up files..."
Write-Host "  Done."

if ($skipAutostart) {
    Write-Host ""
    Write-Host "  Auto-start skipped (use runmote start to start manually)" -ForegroundColor DarkGray
} else {
    Write-Host "[3/3] Configuring auto-start..."
    & "$installDir\scripts\setup-autostart.ps1" -Install
    Write-Host "  Done."
}

if ($env:ACP_ENABLE_AGENTS -ne "false") {
    Write-Host "[4/4] Installing agent adapters..."
    & "$installDir\scripts\setup-agents.ps1" -Install
    Write-Host "  Done."
} else {
    Write-Host ""
    Write-Host "  Agent adapters skipped (ACP_ENABLE_AGENTS=false)" -ForegroundColor DarkGray
}

Write-Host "  Installation Complete" -ForegroundColor Green
Write-Host ""

# Start daemon and show pairing code
Write-Host "  Starting daemon..." -ForegroundColor Gray
$logFile = "$env:TEMP\runmote-daemon.log"
$wrapper = "$installDir\scripts\run-daemon.ps1"
try { Start-ScheduledTask -TaskName "Runmote Daemon" -ErrorAction SilentlyContinue | Out-Null } catch {}
Start-Sleep -Seconds 2
if (Test-Path $wrapper) { & $wrapper }
$pairingCode = $null
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 1
    $errFile = "$env:TEMP\runmote-daemon.err"
    foreach ($lf in @($logFile, $errFile)) {
        if (Test-Path $lf) {
            try {
                $match = Select-String -Path $lf -Pattern 'pairing code:\s+(\S+)' -ErrorAction SilentlyContinue | Select-Object -Last 1
                if ($match) { $pairingCode = $match.Matches.Groups[1].Value; break }
            } catch {}
        }
    }
    if ($pairingCode) { break }
}
if ($pairingCode) {
    $python = Join-Path (Join-Path (Join-Path $installDir ".venv") "Scripts") "python.exe"
    if (Test-Path $python) {
        & $python -c @"
import sys; sys.path.insert(0, r'$installDir\src')
from daemon.main import _pairing_banner
print(_pairing_banner('$pairingCode'))
"@ 2>$null
    }
    if (-not $?) {
        $formatted = $pairingCode.Substring(0, 4) + "-" + $pairingCode.Substring(4)
        Write-Host ""
        Write-Host "  +-----------------------------+"
        Write-Host ("  |  Pairing Code: {0,-12}  |" -f $formatted)
        Write-Host "  |                             |"
        Write-Host "  |  Enter this in the app      |"
        Write-Host "  +-----------------------------+"
        Write-Host ""
    }
} else {
    Write-Host "  Run 'runmote code' after daemon connects to get pairing code."
}

Write-Host ""
Write-Host "  Control the daemon:" -ForegroundColor White
Write-Host "    runmote             interactive menu" -ForegroundColor Cyan
Write-Host "    runmote start       start daemon" -ForegroundColor Cyan
Write-Host "    runmote code        show pairing QR" -ForegroundColor Cyan
Write-Host "    runmote stop        stop daemon" -ForegroundColor Cyan
