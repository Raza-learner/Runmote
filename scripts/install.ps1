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

    # Inject relay config from Worker (replaces placeholders at serve time)
    # These values persist as env vars for the re-invoked script
    if (-not $env:ACP_RELAY_URL)    { $env:ACP_RELAY_URL = "__ACP_RELAY_URL__" }
    if (-not $env:ACP_DAEMON_TOKEN) { $env:ACP_DAEMON_TOKEN = "__ACP_DAEMON_TOKEN__" }
    # Check if placeholders weren't replaced (local run / git fallback) — use
    # concatenation so Worker replaceAll doesn't also change the check string.
    $phr = "__ACP_RELAY" + "_URL__"
    $pht = "__ACP_DAEMON" + "_TOKEN__"
    if ($env:ACP_RELAY_URL -eq $phr -or $env:ACP_DAEMON_TOKEN -eq $pht) {
        try {
            $cu = if ($branch -eq "dev") { "https://runmote.dev/config/dev" } else { "https://runmote.dev/config" }
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $r = Invoke-WebRequest -UseBasicParsing -Uri $cu -ErrorAction Stop
            $c = $r.Content | ConvertFrom-Json
            if ($env:ACP_RELAY_URL -eq $phr)    { $env:ACP_RELAY_URL = $c.relayUrl }
            if ($env:ACP_DAEMON_TOKEN -eq $pht)  { $env:ACP_DAEMON_TOKEN = $c.token }
        } catch { Write-Host "  Warning: could not fetch relay config" -ForegroundColor DarkGray }
    }

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

# ── Relay config (set by bootstrap block for irm | iex; for local runs set env vars) ──
# Derive public URL from relay URL
if ($env:ACP_RELAY_URL -and -not $env:ACP_RELAY_PUBLIC_URL) {
    $base = $env:ACP_RELAY_URL -replace '/daemon$', ''
    $base = $base -replace '^wss:', 'https:'
    $base = $base -replace '^ws:', 'http:'
    $env:ACP_RELAY_PUBLIC_URL = $base
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
# Always install runmote launcher, even if auto-start skipped
& "$installDir\scripts\setup-autostart.ps1" -InstallCmd
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
# Kill stale daemon processes from previous installs
cmd /c "wmic process where ""commandline like '%%src.daemon.main%%' and name like '%%python%%'"" delete 2>nul" | Out-Null
Start-Sleep -Seconds 1
# Clean up old temp files (ignore errors if file is locked)
Remove-Item "$env:TEMP\runmote-daemon.log" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\runmote-daemon.err" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\runmote-pairing-code.txt" -Force -ErrorAction SilentlyContinue
$python = Join-Path (Join-Path (Join-Path $installDir ".venv") "Scripts") "python.exe"
$logFile = "$env:TEMP\runmote-daemon.log"
$errFile = "$env:TEMP\runmote-daemon.err"
Write-Host "  [D] relay=$env:ACP_RELAY_URL" -ForegroundColor DarkGray
Write-Host "  [D] token=$(if ($env:ACP_DAEMON_TOKEN) { $env:ACP_DAEMON_TOKEN.Substring(0,4) + '...' } else { 'EMPTY' })" -ForegroundColor DarkGray
Write-Host "  [D] python=$python  exists=$(Test-Path $python)" -ForegroundColor DarkGray
Write-Host "  [D] cwd=$installDir" -ForegroundColor DarkGray
try { Start-ScheduledTask -TaskName "Runmote Daemon" -ErrorAction SilentlyContinue | Out-Null } catch {}
if (Test-Path $python) {
    $env:ACP_DAEMON_ID = $daemonName
    Start-Process -WindowStyle Hidden -FilePath $python -ArgumentList "-m", "src.daemon.main" -WorkingDirectory $installDir -RedirectStandardOutput $logFile -RedirectStandardError $errFile
    Write-Host "  [D] daemon launched" -ForegroundColor DarkGray
}
# Wait for pairing code (daemon writes it to temp file)
$codeFile = "$env:TEMP\runmote-pairing-code.txt"
$pairingCode = $null
for ($i = 1; $i -le 20; $i++) {
    Start-Sleep -Seconds 1
    Write-Host "  [D] wait ${i}s  log=$((Get-Item $logFile -ErrorAction SilentlyContinue).Length) bytes  codeFile=$(Test-Path $codeFile)" -ForegroundColor DarkGray
    if (Test-Path $codeFile) {
        try {
            $pairingCode = (Get-Content $codeFile -Raw).Trim()
            Write-Host "  [D] codeFile found: [$pairingCode]" -ForegroundColor DarkGray
            if ($pairingCode) { break }
        } catch {}
    }
}
if (-not $pairingCode) {
    Write-Host "  [D] no pairing code — dumping log:" -ForegroundColor DarkGray
    if (Test-Path $logFile) { Get-Content $logFile -Tail 20 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray } }
    if (Test-Path $errFile) { Get-Content $errFile -Tail 10 | ForEach-Object { Write-Host "    [ERR] $_" -ForegroundColor DarkGray } }
}
if ($pairingCode) {
    $formatted = $pairingCode.Substring(0, 4) + "-" + $pairingCode.Substring(4)
    Write-Host ""
    Write-Host "  +-----------------------------+"
    Write-Host ("  |  Pairing Code: {0,-12}  |" -f $formatted)
    Write-Host "  |                             |"
    Write-Host "  |  Enter this in the app      |"
    Write-Host "  +-----------------------------+"
    Write-Host ""
} else {
    Write-Host "  Run 'runmote code' after daemon connects to get pairing code."
}

Write-Host ""
Write-Host "  Control the daemon:" -ForegroundColor White
Write-Host "    runmote             interactive menu" -ForegroundColor Cyan
Write-Host "    runmote start       start daemon" -ForegroundColor Cyan
Write-Host "    runmote code        show pairing QR" -ForegroundColor Cyan
Write-Host "    runmote stop        stop daemon" -ForegroundColor Cyan
