$ErrorActionPreference = "Continue"

# Defaults — environment variables only (no param() for iex compatibility)
$remote    = if ($env:ACP_REMOTE)    { $env:ACP_REMOTE }    else { "https://github.com/Raza-learner/acp-remote.git" }
$branch    = if ($env:ACP_BRANCH)    { $env:ACP_BRANCH }    else { "main" }
$installDir = if ($env:ACP_DIR)      { $env:ACP_DIR }       else { "$env:USERPROFILE\.local\share\acp" }
$mode      = "install"
$skipAutostart = $false

# Detect interactive mode
$interactive = [Environment]::UserInteractive -and -not $PSCommandPath.StartsWith("-")

# Parse $args for flags (when run as a file, not via iex)
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

# Ensure uv is installed (auto-downloads Python 3.13+ if missing)
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv (Python package manager)..."
    iex ((New-Object Net.WebClient).DownloadString('https://astral.sh/uv/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:Path
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host "Error: uv installation failed. Install manually: https://docs.astral.sh/uv"
        return
    }
}

# --- Remove ---
if ($mode -eq "remove") {
    Write-Host "Removing ACP daemon..."
    $setupScript = Join-Path $installDir "scripts" "setup-autostart.ps1"
    if (Test-Path $setupScript) { & $setupScript -Remove }
    if (Test-Path $installDir)  { Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue }
    Write-Host "ACP daemon uninstalled."
    return
}

# --- Interactive prompts ---
if ($interactive) {
    Write-Host ""
    Write-Host "  ACP Daemon Setup"
    Write-Host "  ================"
    Write-Host ""

    # Daemon name
    $defaultName = if ($env:ACP_DAEMON_ID) { $env:ACP_DAEMON_ID } else { $env:COMPUTERNAME }
    $nameInput = Read-Host "  Daemon name [$defaultName]"
    if ($nameInput) {
        $env:ACP_DAEMON_ID = $nameInput
    } else {
        $env:ACP_DAEMON_ID = $defaultName
    }

    # Install directory
    $dirInput = Read-Host "  Install directory [$installDir]"
    if ($dirInput) {
        $installDir = $dirInput
    }

    # Auto-start
    $autostartInput = Read-Host "  Enable auto-start on login? [Y/n]"
    if ($autostartInput -eq "n" -or $autostartInput -eq "N" -or $autostartInput -eq "no") {
        $skipAutostart = $true
    }

    Write-Host ""
}

# --- Install ---
$daemonName = if ($env:ACP_DAEMON_ID) { $env:ACP_DAEMON_ID } else { $env:COMPUTERNAME }
Write-Host "ACP daemon installer"
Write-Host "===================="
Write-Host "Daemon:  $daemonName"
Write-Host "Remote:  $remote"
Write-Host "Branch:  $branch"
Write-Host "Install: $installDir"
Write-Host ""

Write-Host "Step 1/4: Installing uv..."
Write-Host "  Done."

# Download repo
Write-Host "Step 2/4: Downloading repository..."
if (Test-Path $installDir) {
    if ($hasGit) {
        Write-Host "  Updating existing installation..."
        Push-Location $installDir
        git fetch origin; git checkout $branch; git pull origin $branch
        Pop-Location
    } else {
        Write-Host "  Updating via ZIP download..."
        $tmpDir = "$env:TEMP\acp-install-tmp"
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
        $zipFile = "$tmpDir\repo.zip"
        Invoke-WebRequest -Uri "https://github.com/Raza-learner/acp-remote/archive/$branch.zip" -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
        $extracted = Get-ChildItem "$tmpDir\acp-remote-*" | Select-Object -First 1
        if ($extracted) { Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue; Move-Item $extracted.FullName $installDir }
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
    }
} else {
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    if ($hasGit) {
        git clone --branch $branch --depth 1 $remote $installDir
    } else {
        Write-Host "  downloading ZIP..."
        $tmpDir = "$env:TEMP\acp-install-tmp"
        New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
        $zipFile = "$tmpDir\repo.zip"
        Invoke-WebRequest -Uri "https://github.com/Raza-learner/acp-remote/archive/$branch.zip" -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
        $extracted = Get-ChildItem "$tmpDir\acp-remote-*" | Select-Object -First 1
        if ($extracted) { Move-Item "$($extracted.FullName)\*" $installDir -Force }
        Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue | Out-Null
    }
}
Write-Host "  Done."

# Install deps
Write-Host "Step 3/4: Installing dependencies..."
Push-Location $installDir
uv sync --frozen
if ($LASTEXITCODE -ne 0) {
    Write-Host "  frozen sync failed — running full sync..."
    uv sync
}
Pop-Location
Write-Host "  Done."

# Configure auto-start
if ($skipAutostart) {
    Write-Host "  Auto-start skipped."
} else {
    Write-Host "Step 4/4: Configuring auto-start..."
    & (Join-Path $installDir "scripts" "setup-autostart.ps1") -Install
    Write-Host "  Done."
}

# Post-install
Write-Host ""
Write-Host "+----------------------------------------------------+"
Write-Host "|     ACP daemon installed successfully!             |"
Write-Host "|                                                    |"
Write-Host "|  It will start automatically after login.         |"
Write-Host "|                                                    |"
Write-Host "|  To control the daemon now:                        |"
Write-Host "|    acp-remote          (interactive menu)          |"
Write-Host "|    acp-remote start    (start daemon)              |"
Write-Host "|    acp-remote code     (show pairing code)         |"
Write-Host "|    acp-remote stop     (stop daemon)               |"
Write-Host "|                                                    |"
Write-Host "|  -- Pair with the ACP app --                       |"
Write-Host "|                                                    |"
Write-Host "|  Start the daemon, then use the app to scan the    |"
Write-Host "|  QR code shown in the terminal or type the code.   |"
Write-Host "|                                                    |"
Write-Host "|  Run: acp-remote code                              |"
Write-Host "|                                                    |"
Write-Host "|  See all paired devices and manage sessions        |"
Write-Host "|  directly from the app.                            |"
Write-Host "+----------------------------------------------------+"
