param(
    [string]$Dir = "",
    [string]$Branch = "",
    [switch]$Remove,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Defaults
$remote = if ($env:ACP_REMOTE) { $env:ACP_REMOTE } else { "https://github.com/Raza-learner/acp-remote.git" }
$branch = if ($Branch) { $Branch } elseif ($env:ACP_BRANCH) { $env:ACP_BRANCH } else { "main" }
$installDir = if ($Dir) { $Dir } elseif ($env:ACP_DIR) { $env:ACP_DIR } else { "$env:USERPROFILE\.local\share\acp" }

function Print-Help {
    Write-Host @"
Usage: iex (iwr -Uri https://raw.githubusercontent.com/Raza-learner/acp-remote/$branch/scripts/install.ps1).Content

Install ACP daemon and configure auto-start on Windows.

Options:
  -Dir <path>        Install directory (default: `$env:USERPROFILE\.local\share\acp)
  -Branch <name>     Git branch (default: main)
  -Remove            Uninstall and remove auto-start
  -Help              Show this help

Environment variables:
  ACP_DIR            Install directory (overrides -Dir default)
  ACP_BRANCH         Git branch (overrides -Branch default)
  ACP_REMOTE         Git remote URL
  ACP_DAEMON_TOKEN   Auth token for daemon-relay authentication
  ACP_DAEMON_ID      Daemon identifier (default: hostname)
  ACP_RELAY_URL      WebSocket URL of the relay server
"@
    exit 0
}

if ($Help) { Print-Help }

# --- Remove mode ---
if ($Remove) {
    Write-Host "Removing ACP daemon..."

    $setupScript = Join-Path $installDir "scripts" "setup-autostart.ps1"
    if (Test-Path $setupScript) {
        & $setupScript -Remove
    }

    if (Test-Path $installDir) {
        Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
        Write-Host "  removed: $installDir"
    }

    Write-Host "ACP daemon uninstalled."
    exit 0
}

# --- Install mode ---
Write-Host "ACP daemon installer"
Write-Host "===================="
Write-Host "Remote:  $remote"
Write-Host "Branch:  $branch"
Write-Host "Install: $installDir"
Write-Host ""

# Check prerequisites
$hasGit = Get-Command git -ErrorAction SilentlyContinue

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    Write-Host "Error: Python 3.13+ is required. Download from https://python.org"
    exit 1
}

$pyVersion = & $python.Source -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"
if ([version]$pyVersion -lt [version]"3.13") {
    Write-Host "Error: Python 3.13+ required (found $pyVersion)"
    exit 1
}

$hasUv = Get-Command uv -ErrorAction SilentlyContinue

# Download repo
if (Test-Path $installDir) {
    if ($hasGit) {
        Write-Host "Updating existing installation..."
        Push-Location $installDir
        try {
            git fetch origin
            git checkout $branch
            git pull origin $branch
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Updating via ZIP download..."
        $tmpDir = "$env:TEMP\acp-install-tmp"
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

        $zipUrl = "https://github.com/Raza-learner/acp-remote/archive/$branch.zip"
        $zipFile = "$tmpDir\repo.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

        Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
        $extracted = Get-ChildItem "$tmpDir\acp-remote-*" | Select-Object -First 1
        if ($extracted) {
            Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue | Out-Null
            Move-Item $extracted.FullName $installDir
        }
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
    }
} else {
    Write-Host "Downloading repository..."
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    if ($hasGit) {
        git clone --branch $branch --depth 1 $remote $installDir
    } else {
        $zipUrl = "https://github.com/Raza-learner/acp-remote/archive/$branch.zip"
        Write-Host "  downloading ZIP from $zipUrl"
        $tmpDir = "$env:TEMP\acp-install-tmp"
        $zipFile = "$tmpDir\repo.zip"
        New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
        $extracted = Get-ChildItem "$tmpDir\acp-remote-*" | Select-Object -First 1
        if ($extracted) {
            Move-Item "$extracted\*" $installDir -Force
        }
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
    }
}

Write-Host ""
Write-Host "Installing dependencies..."
Push-Location $installDir
try {
    if ($hasUv) {
        uv sync --frozen 2>$null
        if ($LASTEXITCODE -ne 0) {
            uv sync 2>$null
        }
    } else {
        # pip fallback
        & $python.Source -m venv .venv
        $venvPip = Join-Path $installDir ".venv" "Scripts" "pip.exe"
        & $venvPip install -e ".[daemon]"
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Configuring auto-start..."
$setupScript = Join-Path $installDir "scripts" "setup-autostart.ps1"
& $setupScript -Install

# Print post-install message
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗"
Write-Host "║     ACP daemon installed successfully!              ║"
Write-Host "║                                                     ║"
Write-Host "║  It will start automatically after your next login. ║"
Write-Host "║                                                     ║"
Write-Host "║  To start now:                                       ║"
Write-Host "║    schtasks /Run /TN ""ACP Daemon""                  ║"
Write-Host "║                                                     ║"
Write-Host "║  To check status:                                    ║"
Write-Host "║    schtasks /Query /TN ""ACP Daemon""                ║"
Write-Host "║                                                     ║"
Write-Host "║  To restart + get pairing code:                      ║"
Write-Host "║    acp-remote                                         ║"
Write-Host "║                                                     ║"
Write-Host "║  ── Pair with the app ──                             ║"
Write-Host "║                                                     ║"
Write-Host "║  After starting, the daemon shows a pairing code:   ║"
Write-Host "║  ╔═══════════════════════╗                          ║"
Write-Host "║  ║  Device Code: 123456  ║                          ║"
Write-Host "║  ╚═══════════════════════╝                          ║"
Write-Host "║                                                     ║"
Write-Host "║  Open the ACP mobile app and enter this code        ║"
Write-Host "║  to pair with your device.                          ║"
Write-Host "║                                                     ║"
Write-Host "║  See all paired devices and manage sessions         ║"
Write-Host "║  directly from the app.                             ║"
Write-Host "╚══════════════════════════════════════════════════════╝"
