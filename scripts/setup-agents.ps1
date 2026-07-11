param(
    [switch]$Install,
    [switch]$Remove,
    [switch]$Status,
    [string]$Dir = ""
)

$ErrorActionPreference = "Continue"

if (-not $Dir) {
    $Dir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}

$binDir = Join-Path (Join-Path $env:USERPROFILE ".local") "bin"

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

function Install-IfCliFound($cli, $package) {
    if (-not (Test-CliFound $cli)) {
        Write-Host "  '$cli' not found -- skipping $package"
        return
    }
    if (Test-PackageInstalled $package) {
        $ver = Get-PackageVersion $package
        Write-Host "  $package v$ver already installed -- skipping"
    } else {
        Write-Host "  Installing $package (for $cli)..."
        npm install -g $package
    }
}

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
        Write-Host "  $name.cmd added to $binDir"
    }
}

function Install-AgentWrappers {
    if (Test-PackageInstalled "@agentclientprotocol/codex-acp") {
        Install-CmdWrapper "codex-acp"
    }
    if (Test-PackageInstalled "@agentclientprotocol/claude-agent-acp") {
        Install-CmdWrapper "claude-agent-acp"
    }
}

function Remove-CmdWrapper($name) {
    $cmdPath = Join-Path $binDir "${name}.cmd"
    if (Test-Path $cmdPath) {
        Remove-Item $cmdPath -Force
        Write-Host "  $name.cmd removed from $binDir"
    }
}

function Remove-AgentWrappers {
    Remove-CmdWrapper "codex-acp"
    Remove-CmdWrapper "claude-agent-acp"
}

function Install-Agents {
    Write-Host "Installing Runmote agent adapters..."
    Write-Host ""

    if (-not (Test-NpmInstalled)) {
        Write-Host "  npm not found. Install Node.js first: https://nodejs.org"
        exit 1
    }

    Install-IfCliFound "codex"       "@agentclientprotocol/codex-acp"
    Install-IfCliFound "claude"      "@agentclientprotocol/claude-agent-acp"
    Install-IfCliFound "claude-code" "@agentclientprotocol/claude-agent-acp"

    Install-AgentWrappers

    Write-Host ""
    Write-Host "Done."
}

function Remove-Agents {
    Write-Host "Removing Runmote agent adapters..."
    Write-Host ""

    if (-not (Test-NpmInstalled)) {
        Write-Host "  npm not found -- skipping"
        exit 0
    }

    if (Test-PackageInstalled "@agentclientprotocol/codex-acp") {
        Write-Host "  Removing @agentclientprotocol/codex-acp..."
        npm uninstall -g "@agentclientprotocol/codex-acp"
    } else {
        Write-Host "  @agentclientprotocol/codex-acp not installed -- skipping"
    }

    if (Test-PackageInstalled "@agentclientprotocol/claude-agent-acp") {
        Write-Host "  Removing @agentclientprotocol/claude-agent-acp..."
        npm uninstall -g "@agentclientprotocol/claude-agent-acp"
    } else {
        Write-Host "  @agentclientprotocol/claude-agent-acp not installed -- skipping"
    }

    Remove-AgentWrappers

    Write-Host ""
    Write-Host "Done."
}

function Get-AllCliStatus {
    @("codex", "claude", "claude-code") | ForEach-Object {
        $cli = $_
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
    @("@agentclientprotocol/codex-acp", "@agentclientprotocol/claude-agent-acp") | ForEach-Object {
        $pkg = $_
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
    @("codex-acp", "claude-agent-acp") | ForEach-Object {
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
    Write-Host "Runmote Agent Adapters Status"
    Write-Host ""

    Get-AllCliStatus
    Get-AllPackageStatus
    Get-AllWrapperStatus
}

# Prefer the npm package as the canonical path
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
