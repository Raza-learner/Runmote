$ErrorActionPreference = "Continue"

# ── Color setup ──────────────────────────────────────────────────────
$interactive = [Environment]::UserInteractive -and -not $PSCommandPath.StartsWith("-")

# Defaults
$remote     = if ($env:ACP_REMOTE)    { $env:ACP_REMOTE }    else { "https://github.com/Raza-learner/acp-remote.git" }
$branch     = if ($env:ACP_BRANCH)    { $env:ACP_BRANCH }    else { "main" }
$installDir = if ($env:ACP_DIR)       { $env:ACP_DIR }       else { "$env:USERPROFILE\.local\share\acp" }
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
Install ACP daemon and configure auto-start.

Usage:
  iwr -useb https://raw.githubusercontent.com/Raza-learner/acp-remote/$branch/scripts/install.ps1 | iex
  `$env:ACP_RELAY_URL='ws://host:8000/daemon'; iwr -useb https://raw.githubusercontent.com/Raza-learner/acp-remote/$branch/scripts/install.ps1 | iex

Environment variables:
  ACP_RELAY_URL      WebSocket URL of the relay server
  ACP_DAEMON_TOKEN   Auth token for daemon-relay authentication
  ACP_DAEMON_ID      Daemon identifier (default: hostname)
  ACP_BRANCH         Git branch (default: main)
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
    Write-Host "Removing ACP daemon..."
    $setupScript = Join-Path $installDir "scripts" "setup-autostart.ps1"
    if (Test-Path $setupScript) { & $setupScript -Remove }
    if (Test-Path $installDir)  { Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue }
    Write-Host "ACP daemon uninstalled."
    return
}

# ── Interactive prompts ──────────────────────────────────────────────
if ($interactive) {
    Write-Host ""
    Write-Host "    █████╗  ██████╗ ██████╗ " -ForegroundColor Cyan
    Write-Host "   ██╔══██╗██╔════╝ ██╔══██╗" -ForegroundColor Cyan
    Write-Host "   ███████║██║  ███╗██████╔╝" -ForegroundColor Cyan
    Write-Host "   ██╔══██║██║   ██║██╔═══╝ " -ForegroundColor Cyan
    Write-Host "   ██║  ██║╚██████╔╝██║     " -ForegroundColor Cyan
    Write-Host "   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     " -ForegroundColor Cyan
    Write-Host "   Agent Client Protocol  —  Daemon Setup" -ForegroundColor DarkGray
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

Write-Host "  ACP Daemon Installer" -ForegroundColor Cyan
Write-Host "  Daemon: $daemonName  |  Install: $installDir" -ForegroundColor DarkGray
Write-Host ""

Write-Host "[1/3] Installing dependencies..."
Push-Location $installDir -ErrorAction SilentlyContinue
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    # Assume files were pre-copied (or run from repo)
    if (Test-Path "$PSScriptRoot\..\pyproject.toml") {
        $srcDir = Split-Path -Parent $PSScriptRoot
        Copy-Item "$srcDir\*" $installDir -Recurse -Force -Exclude ".git",".venv","__pycache__",".pytest_cache","*.db","logs"
    }
}
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
    Write-Host "  Auto-start skipped (use acp-remote start to start manually)" -ForegroundColor DarkGray
} else {
    Write-Host "[3/3] Configuring auto-start..."
    & (Join-Path $installDir "scripts" "setup-autostart.ps1") -Install
    Write-Host "  Done."
}

if ($env:ACP_ENABLE_AGENTS -ne "false") {
    Write-Host "[4/4] Installing agent adapters..."
    & (Join-Path $installDir "scripts" "setup-agents.ps1") -Install
    Write-Host "  Done."
} else {
    Write-Host ""
    Write-Host "  Agent adapters skipped (ACP_ENABLE_AGENTS=false)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  Installation Complete" -ForegroundColor Green
Write-Host ""
Write-Host "  Control the daemon:"
Write-Host "    acp-remote          interactive menu" -ForegroundColor Cyan
Write-Host "    acp-remote start    start daemon" -ForegroundColor Cyan
Write-Host "    acp-remote code     show pairing QR" -ForegroundColor Cyan
Write-Host "    acp-remote stop     stop daemon" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Pair with the ACP app:" -ForegroundColor White
Write-Host "  Start the daemon, then scan the QR code or type the"
Write-Host "  code shown in the terminal into the mobile app."
Write-Host ""
