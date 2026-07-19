param(
    [switch]$Install,
    [switch]$Remove,
    [switch]$Status,
    [switch]$Interactive,
    [switch]$All,
    [string]$Dir = ""
)

$ErrorActionPreference = "Continue"

if (-not $Dir) {
    $Dir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}

$binDir = Join-Path (Join-Path $env:USERPROFILE ".local") "bin"

function Add-ToUserPath {
    param([string]$Dir)
    if (-not $Dir -or -not (Test-Path $Dir)) { return }
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $dirs = $userPath.Split(';', [StringSplitOptions]::RemoveEmptyEntries)
    if ($Dir -in $dirs) { return }
    [Environment]::SetEnvironmentVariable("Path", ($userPath.TrimEnd(';') + ";$Dir"), "User")
    $env:Path = "$Dir;$env:Path"
    Write-Host "  Added $Dir to PATH" -ForegroundColor Green
}

# ── Utility functions ──────────────────────────────────────

function Test-NpmInstalled {
    return (Get-Command npm -ErrorAction SilentlyContinue) -ne $null
}

function Test-CliFound($name) {
    return (Get-Command $name -ErrorAction SilentlyContinue) -ne $null
}

function Test-PackageInstalled($package) {
    $result = npm list -g $package --depth=0 2>$null
    return $LASTEXITCODE -eq 0
}

function Get-PackageVersion($package) {
    $lines = npm list -g $package --depth=0 2>$null
    if ($LASTEXITCODE -eq 0 -and $lines) {
        $match = [regex]::Match($lines, "@(\d+\.\d+\.\d+)")
        if ($match.Success) { return $match.Groups[1].Value }
    }
    return $null
}

function Write-Step($text) {
    Write-Host "  $text" -ForegroundColor Cyan
}

function Write-Skip($text) {
    Write-Host "  $text" -ForegroundColor DarkGray
}

function Write-Done($text) {
    Write-Host "  $text" -ForegroundColor Green
}

function Confirm-Install($name, $desc) {
    if ($All) { return $true }
    if (-not $Interactive) { return $true }
    while ($true) {
        $answer = Read-Host "  Install $name $desc? [Y/n]"
        if ($answer -eq "" -or $answer -eq "y" -or $answer -eq "Y") { return $true }
        if ($answer -eq "n" -or $answer -eq "N") { return $false }
    }
}

# ── Node.js installer ──────────────────────────────────────

function Install-NodeJs {
    if (Test-CliFound "node") {
        $ver = & node --version 2>$null
        Write-Done "Node.js $ver already installed"
        return $true
    }

    Write-Step "Installing Node.js..."

    # Try winget (Windows 10+)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "    winget install OpenJS.NodeJS..."
        $result = winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -eq 0) {
            # Refresh PATH so npm is available immediately
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                        [Environment]::GetEnvironmentVariable("Path", "User") + ";" + $env:Path
            if (Test-CliFound "node") {
                Write-Done "Node.js installed via winget"
                return $true
            }
        }
        Write-Host "    winget failed, trying chocolatey..." -ForegroundColor DarkGray
    }

    # Try chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $result = choco install nodejs -y 2>&1
        if ($LASTEXITCODE -eq 0) {
            refreshenv 2>$null
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                        [Environment]::GetEnvironmentVariable("Path", "User") + ";" + $env:Path
            if (Test-CliFound "node") {
                Write-Done "Node.js installed via chocolatey"
                return $true
            }
        }
        Write-Host "    chocolatey failed, trying scoop..." -ForegroundColor DarkGray
    }

    # Try scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $result = scoop install nodejs 2>&1
        if ($LASTEXITCODE -eq 0) {
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                        [Environment]::GetEnvironmentVariable("Path", "User") + ";" + $env:Path
            if (Test-CliFound "node") {
                Write-Done "Node.js installed via scoop"
                return $true
            }
        }
    }

    Write-Host "  Could not install Node.js automatically." -ForegroundColor Yellow
    Write-Host "  Install it manually: https://nodejs.org" -ForegroundColor Yellow
    return $false
}

# ── Bundled agent (standalone .exe fallback) ──────────────

function Install-BundledAgent {
    $exeName = "opencode.exe"
    $exePath = Join-Path $binDir $exeName

    if (Test-Path $exePath) {
        try {
            $ver = & $exePath --version 2>$null
            Write-Done "Bundled opencode $ver already at $exePath"
        } catch {
            Write-Done "Bundled opencode already at $exePath"
        }
        return $true
    }

    Write-Step "Downloading opencode.exe (fallback agent)..."

    # Detect Windows architecture
    $arch = switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64"   { "x64" }
        "ARM64"   { "arm64" }
        "x86"     { "x64-baseline" }
        default   { "x64" }
    }

    $repo = "anomalyco/opencode"
    $apiUrl = "https://api.github.com/repos/$repo/releases/latest"

    try {
        $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing -ErrorAction Stop
        $zipName = "opencode-windows-$arch.zip"
        $asset = $release.assets | Where-Object { $_.name -eq $zipName }
        if (-not $asset) {
            Write-Host "    Asset $zipName not found in latest opencode release" -ForegroundColor Yellow
            return $false
        }

        $zipPath = "$env:TEMP\opencode.zip"
        Write-Host "    Downloading $zipName..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing

        New-Item -ItemType Directory -Force -Path $binDir | Out-Null
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $binDir, $true)
        Remove-Item $zipPath -Force

        if (Test-Path $exePath) {
            try {
                $ver = & $exePath --version 2>$null
                Write-Done "opencode.exe $ver downloaded to $exePath"
            } catch {
                Write-Done "opencode.exe downloaded to $exePath"
            }
            return $true
        }
    } catch {
        Write-Host "    Download failed: $_" -ForegroundColor Yellow
    }
    return $false
}

# ── Agent tool installers ──────────────────────────────────

function Install-Opencode {
    $name = "opencode"
    $bundledExe = Join-Path $binDir "opencode.exe"

    if (Test-CliFound $name) {
        $ver = & $name --version 2>$null
        Write-Done "$name $ver already installed"
        return $true
    }
    if (Test-Path $bundledExe) {
        Write-Done "Bundled $name already at $bundledExe"
        return $true
    }
    if (-not (Confirm-Install $name "(native ACP, lightweight)")) {
        Write-Skip "  Skipped $name"
        return $false
    }
    Write-Step "Installing opencode..."
    npm install -g opencode 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0 -and (Test-CliFound $name)) {
        $ver = & $name --version 2>$null
        Write-Done "$name $ver installed"
        return $true
    }
    Write-Host "  opencode installation failed." -ForegroundColor Yellow
    return $false
}

function Install-ClaudeCode {
    $name = "claude"
    if (Test-CliFound $name) {
        Write-Done "Claude Code CLI already found"
    } else {
        if (-not (Confirm-Install "Claude Code" "(@anthropic-ai/claude-code + ACP adapter)")) {
            Write-Skip "  Skipped Claude Code"
            return $false
        }
        Write-Step "Installing @anthropic-ai/claude-code..."
        npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  claude-code installation failed." -ForegroundColor Yellow
            return $false
        }
        Write-Done "Claude Code CLI installed"
    }

    # Install ACP adapter for claude
    $adapter = "@agentclientprotocol/claude-agent-acp"
    if (Test-PackageInstalled $adapter) {
        $ver = Get-PackageVersion $adapter
        Write-Done "$adapter v$ver already installed"
    } else {
        Write-Step "Installing $adapter..."
        npm install -g $adapter 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $ver = Get-PackageVersion $adapter
            Write-Done "$adapter v$ver installed"
        } else {
            Write-Host "  $adapter installation failed." -ForegroundColor Yellow
        }
    }
    return $true
}

function Install-Codex {
    $name = "codex"
    if (Test-CliFound $name) {
        Write-Done "Codex CLI already found"
    } else {
        if (-not (Confirm-Install "Codex CLI" "(@openai/codex + ACP adapter)")) {
            Write-Skip "  Skipped Codex CLI"
            return $false
        }
        Write-Step "Installing @openai/codex..."
        npm install -g @openai/codex 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  codex installation failed." -ForegroundColor Yellow
            return $false
        }
        Write-Done "Codex CLI installed"
    }

    # Install ACP adapter for codex
    $adapter = "@agentclientprotocol/codex-acp"
    if (Test-PackageInstalled $adapter) {
        $ver = Get-PackageVersion $adapter
        Write-Done "$adapter v$ver already installed"
    } else {
        Write-Step "Installing $adapter..."
        npm install -g $adapter 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $ver = Get-PackageVersion $adapter
            Write-Done "$adapter v$ver installed"
        } else {
            Write-Host "  $adapter installation failed." -ForegroundColor Yellow
        }
    }
    return $true
}

# ── Cmd wrappers (legacy PATH compatibility) ───────────────

function Install-CmdWrapper($name) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    $cmdPath = Join-Path $binDir "${name}.cmd"
    $npmPath = Join-Path (Join-Path $env:APPDATA "npm") "${name}.cmd"
    if (Test-Path $npmPath) {
        $cmdLines = @(
            "@echo off",
            "`"$npmPath`" %*"
        )
        Set-Content -Path $cmdPath -Value ($cmdLines -join "`r`n")
        Write-Host "  $name.cmd linked to $binDir"
    }
}

function Remove-CmdWrapper($name) {
    $cmdPath = Join-Path $binDir "${name}.cmd"
    if (Test-Path $cmdPath) {
        Remove-Item $cmdPath -Force
        Write-Host "  $name.cmd removed from $binDir"
    }
}

# ── Main install ───────────────────────────────────────────

function Install-Agents {
    Write-Host ""
    Write-Host "  Agent Setup" -ForegroundColor Cyan
    Write-Host "  ────────────────────────────────────────────"

    # Step 1: Bundled agent (standalone .exe fallback)
    Write-Host ""
    Write-Step "[1/4] Downloading bundled opencode.exe..."
    $bundledOk = Install-BundledAgent
    $hasNpm = $false

    # Step 2: Ensure Node.js + npm
    Write-Host ""
    Write-Step "[2/4] Checking Node.js..."
    if (Install-NodeJs) {
        $hasNpm = Test-NpmInstalled
        if (-not $hasNpm) {
            Write-Host "  npm not found after Node.js install." -ForegroundColor Yellow
            Write-Host "  Restart your terminal and re-run: runmote setup-agents" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  npm not available — skipping npm-based agent installs." -ForegroundColor Yellow
        Write-Host "  Only the bundled opencode.exe will be available." -ForegroundColor Yellow
    }

    # Step 3: Install CLI tools via npm (if available)
    Write-Host ""
    $installedAny = $bundledOk
    if ($hasNpm) {
        Write-Step "[3/4] Installing agent CLI tools..."
        if (Install-Opencode) { $installedAny = $true }
        if (Install-ClaudeCode) { $installedAny = $true }
        if (Install-Codex) { $installedAny = $true }
    } else {
        Write-Step "[3/4] Skipping npm-based agents (npm not available)"
    }

    if (-not $installedAny) {
        Write-Host ""
        Write-Host "  No agents were installed." -ForegroundColor Yellow
        Write-Host "  You can install them later: runmote setup-agents" -ForegroundColor Yellow
    }

    # Step 4: Link cmd wrappers
    Write-Host ""
    Write-Step "[4/4] Setting up PATH wrappers..."
    Install-CmdWrapper "opencode"
    Install-CmdWrapper "codex"
    Install-CmdWrapper "claude"
    Install-CmdWrapper "claude-code"
    Install-CmdWrapper "codex-acp"
    Install-CmdWrapper "claude-agent-acp"

    Write-Host ""
    Write-Done "Agent setup complete!"
    Write-Host ""
    Write-Host "  Detected agents:" -ForegroundColor White
    $allClis = @("opencode", "codex", "claude", "claude-code", "codex-acp", "claude-agent-acp")
    foreach ($cli in $allClis) {
        $found = Get-Command $cli -ErrorAction SilentlyContinue
        if ($found) {
            Write-Host "    $($cli): $($found.Source)" -ForegroundColor Green
        }
    }
    # Also check bundled exe
    $bundledExe = Join-Path $binDir "opencode.exe"
    if ((Test-Path $bundledExe) -and -not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Write-Host "    opencode (bundled): $bundledExe" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "  Agents are auto-detected when the daemon starts." -ForegroundColor DarkGray
    Write-Host "  Restart the daemon to pick up new agents: runmote restart" -ForegroundColor DarkGray

    # Ensure binDir is on PATH so bundled/npm agents are accessible
    Add-ToUserPath $binDir
}

# ── Remove ─────────────────────────────────────────────────

function Remove-Agents {
    Write-Host "Removing Runmote agent tools..."
    Write-Host ""

    # Remove npm packages (if npm available)
    if (Test-NpmInstalled) {
        $packages = @(
            "opencode",
            "@openai/codex",
            "@anthropic-ai/claude-code",
            "@agentclientprotocol/codex-acp",
            "@agentclientprotocol/claude-agent-acp"
        )

        foreach ($pkg in $packages) {
            if (Test-PackageInstalled $pkg) {
                Write-Host "  Removing $pkg..."
                npm uninstall -g $pkg 2>$null
            } else {
                Write-Host "  $pkg not installed -- skipping"
            }
        }
    } else {
        Write-Host "  npm not found -- skipping npm packages"
    }

    Remove-CmdWrapper "opencode"
    Remove-CmdWrapper "codex"
    Remove-CmdWrapper "claude"
    Remove-CmdWrapper "claude-code"
    Remove-CmdWrapper "codex-acp"
    Remove-CmdWrapper "claude-agent-acp"

    # Remove bundled opencode.exe
    $bundledExe = Join-Path $binDir "opencode.exe"
    if (Test-Path $bundledExe) {
        Remove-Item $bundledExe -Force
        Write-Host "  Removed bundled opencode.exe"
    }

    Write-Host ""
    Write-Host "Done."
}

# ── Status ─────────────────────────────────────────────────

function Get-AllCliStatus {
    $allClis = @("opencode", "codex", "claude", "claude-code", "codex-acp", "claude-agent-acp", "node", "npm")
    foreach ($cli in $allClis) {
        $found = Get-Command $cli -ErrorAction SilentlyContinue
        if ($found) {
            Write-Host "  ${cli}: found ($($found.Source))"
        } else {
            Write-Host "  ${cli}: not found"
        }
    }
}

function Get-AllPackageStatus {
    Write-Host ""
    $packages = @(
        "opencode",
        "@openai/codex",
        "@anthropic-ai/claude-code",
        "@agentclientprotocol/codex-acp",
        "@agentclientprotocol/claude-agent-acp"
    )
    if (-not (Test-NpmInstalled)) {
        Write-Host "  npm not available"
        return
    }
    foreach ($pkg in $packages) {
        $lines = npm list -g $pkg --depth=0 2>$null
        if ($LASTEXITCODE -eq 0 -and $lines) {
            $match = [regex]::Match($lines, "@(\d+\.\d+\.\d+)")
            $ver = if ($match.Success) { $match.Groups[1].Value } else { "?" }
            Write-Host "  ${pkg}: installed (v${ver})"
        } else {
            Write-Host "  ${pkg}: not installed"
        }
    }
}

function Get-AllWrapperStatus {
    Write-Host ""
    @("opencode", "codex", "claude", "claude-code", "codex-acp", "claude-agent-acp") | ForEach-Object {
        $bin = $_
        $cmdPath = Join-Path $binDir "${bin}.cmd"
        if (Test-Path $cmdPath) {
            Write-Host "  ${binDir}\${bin}.cmd: linked"
        } else {
            $global = Get-Command $bin -ErrorAction SilentlyContinue
            if ($global) {
                Write-Host "  $($global.Source): in PATH"
            } else {
                Write-Host "  ${bin}: not in PATH"
            }
        }
    }
}

function Status-Agents {
    Write-Host "Runmote Agent Status"
    Write-Host ""

    Write-Host "CLI Tools:" -ForegroundColor Cyan
    Get-AllCliStatus

    Write-Host ""
    Write-Host "npm Packages:" -ForegroundColor Cyan
    Get-AllPackageStatus

    Write-Host ""
    Write-Host "PATH Wrappers (${binDir}):" -ForegroundColor Cyan
    Get-AllWrapperStatus
}

# ── Entry point ────────────────────────────────────────────

# Delegate to npx version if available (for cloud-managed config)
$npx = Get-Command npx -ErrorAction SilentlyContinue
if ($npx) {
    if ($Install -or (-not $Remove -and -not $Status)) {
        $result = & npx -y runmote agents 2>&1
        if ($LASTEXITCODE -eq 0) { return }
    } elseif ($Remove) {
        $result = & npx -y runmote uninstall 2>&1
        if ($LASTEXITCODE -eq 0) { return }
    } elseif ($Status) {
        $result = & npx -y runmote status 2>&1
        if ($LASTEXITCODE -eq 0) { return }
    }
}

if ($Install) {
    Install-Agents
} elseif ($Remove) {
    Remove-Agents
} elseif ($Status) {
    Status-Agents
} else {
    Install-Agents
}
