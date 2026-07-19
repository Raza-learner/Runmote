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

# ── Agent tool installers ──────────────────────────────────

function Install-Opencode {
    $name = "opencode"
    if (Test-CliFound $name) {
        $ver = & $name --version 2>$null
        Write-Done "$name $ver already installed"
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

    # Step 1: Ensure Node.js + npm
    Write-Host ""
    Write-Step "[1/3] Checking Node.js..."
    if (-not (Install-NodeJs)) {
        Write-Host "  Without Node.js, agents cannot be installed." -ForegroundColor Yellow
        Write-Host "  Install from https://nodejs.org then re-run: runmote setup-agents" -ForegroundColor Yellow
        return
    }
    if (-not (Test-NpmInstalled)) {
        Write-Host "  npm not found after Node.js install." -ForegroundColor Yellow
        Write-Host "  Restart your terminal and re-run: runmote setup-agents" -ForegroundColor Yellow
        return
    }

    # Step 2: Install CLI tools
    Write-Host ""
    Write-Step "[2/3] Installing agent CLI tools..."
    $installedAny = $false

    if (Install-Opencode) { $installedAny = $true }
    if (Install-ClaudeCode) { $installedAny = $true }
    if (Install-Codex) { $installedAny = $true }

    if (-not $installedAny) {
        Write-Host ""
        Write-Host "  No agents were installed." -ForegroundColor Yellow
        Write-Host "  You can install them later: runmote setup-agents" -ForegroundColor Yellow
    }

    # Step 3: Link cmd wrappers
    Write-Host ""
    Write-Step "[3/3] Setting up PATH wrappers..."
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
    Write-Host ""
    Write-Host "  Agents are auto-detected when the daemon starts." -ForegroundColor DarkGray
    Write-Host "  Restart the daemon to pick up new agents: runmote restart" -ForegroundColor DarkGray
}

# ── Remove ─────────────────────────────────────────────────

function Remove-Agents {
    Write-Host "Removing Runmote agent tools..."
    Write-Host ""

    if (-not (Test-NpmInstalled)) {
        Write-Host "  npm not found -- skipping"
        exit 0
    }

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

    Remove-CmdWrapper "opencode"
    Remove-CmdWrapper "codex"
    Remove-CmdWrapper "claude"
    Remove-CmdWrapper "claude-code"
    Remove-CmdWrapper "codex-acp"
    Remove-CmdWrapper "claude-agent-acp"

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
