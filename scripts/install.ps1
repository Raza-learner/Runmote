$ErrorActionPreference = "Continue"

# Defaults — environment variables only (no param() for iex compatibility)
$remote    = if ($env:ACP_REMOTE)    { $env:ACP_REMOTE }    else { "https://github.com/Raza-learner/acp-remote.git" }
$branch    = if ($env:ACP_BRANCH)    { $env:ACP_BRANCH }    else { "main" }
$installDir = if ($env:ACP_DIR)      { $env:ACP_DIR }       else { "$env:USERPROFILE\.local\share\acp" }
$mode      = "install"

# Parse $args for flags (when run as a file, not via iex)
for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        "-Dir"    { $installDir = $args[++$i] }
        "-Branch" { $branch = $args[++$i] }
        "-Remove" { $mode = "remove" }
        "-Help"   {
            Write-Host @"
Usage: iex (iwr -Uri https://raw.githubusercontent.com/Raza-learner/acp-remote/$branch/scripts/install.ps1).Content

Or:    powershell -Command "`$env:ACP_RELAY_URL='ws://host:8000/daemon'; iex (iwr -Uri https://raw.githubusercontent.com/Raza-learner/acp-remote/$branch/scripts/install.ps1).Content"

Environment variables:
  ACP_RELAY_URL      WebSocket URL of the relay server (required if not local)
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

# --- Install ---
Write-Host "ACP daemon installer"
Write-Host "===================="
Write-Host "Remote:  $remote"
Write-Host "Branch:  $branch"
Write-Host "Install: $installDir"
Write-Host ""

# Download repo
if (Test-Path $installDir) {
    if ($hasGit) {
        Write-Host "Updating existing installation..."
        Push-Location $installDir
        git fetch origin; git checkout $branch; git pull origin $branch
        Pop-Location
    } else {
        Write-Host "Updating via ZIP download..."
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

# Install deps (uv sync auto-downloads Python 3.13+ if missing)
Write-Host ""
Write-Host "Installing dependencies..."
Push-Location $installDir
uv sync --frozen 2>$null
if ($LASTEXITCODE -ne 0) { uv sync }
Pop-Location

# Configure auto-start
Write-Host ""
Write-Host "Configuring auto-start..."
& (Join-Path $installDir "scripts" "setup-autostart.ps1") -Install

# Post-install
Write-Host ""
Write-Host "+-----------------------------------------------+"
Write-Host "| ACP daemon installed successfully!            |"
Write-Host "|                                               |"
Write-Host "| It will start automatically after login.     |"
Write-Host "|                                               |"
Write-Host "| To start now:                                 |"
Write-Host "|   schtasks /Run /TN 'ACP Daemon'              |"
Write-Host "|                                               |"
Write-Host "| To check status:                              |"
Write-Host "|   schtasks /Query /TN 'ACP Daemon'            |"
Write-Host "|                                               |"
Write-Host "| To restart + get pairing code:                |"
Write-Host "|   acp-remote                                  |"
Write-Host "|                                               |"
Write-Host "| -- Pair with the app --                       |"
Write-Host "|                                               |"
Write-Host "| After starting, the daemon shows a code:     |"
Write-Host "|   +-----------------------------+             |"
Write-Host "|   |  Device Code: 123456       |             |"
Write-Host "|   +-----------------------------+             |"
Write-Host "|                                               |"
Write-Host "| Open the ACP mobile app and enter this code   |"
Write-Host "| to pair with your device.                     |"
Write-Host "|                                               |"
Write-Host "| See all paired devices and manage sessions    |"
Write-Host "| directly from the app.                        |"
Write-Host "+-----------------------------------------------+"

