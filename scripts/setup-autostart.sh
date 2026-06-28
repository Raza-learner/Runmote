#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_DIR="$(cd "$SELF_DIR/.." && pwd)"
PROJECT_DIR="$DEFAULT_DIR"
MODE="install"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--install|--remove|--status] [--dir <path>]

Configure ACP daemon to start automatically after login.

Options:
  --install          Install and enable auto-start (default)
  --remove           Disable and remove auto-start
  --status           Show auto-start status
  --dir <path>       Project directory (auto-detected by default)
  --help             Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install) MODE="install"; shift ;;
        --remove)  MODE="remove"; shift ;;
        --status)  MODE="status"; shift ;;
        --dir)     PROJECT_DIR="$2"; shift 2 ;;
        --help)    usage ;;
        *)         echo "Unknown option: $1"; usage ;;
    esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo "Error: directory '$PROJECT_DIR' not found"
    exit 1
}

detect_python() {
    local py
    if [[ -f "$PROJECT_DIR/.venv/bin/python" ]]; then
        py="$PROJECT_DIR/.venv/bin/python"
    elif [[ -f "$PROJECT_DIR/.venv/Scripts/python.exe" ]]; then
        py="$PROJECT_DIR/.venv/Scripts/python.exe"
    elif command -v python3 &>/dev/null; then
        py="$(command -v python3)"
    elif command -v python &>/dev/null; then
        py="$(command -v python)"
    else
        echo "Error: no Python found. Run 'uv sync' in $PROJECT_DIR first."
        exit 1
    fi
    echo "$py"
}

PYTHON="$(detect_python)"
DAEMON_CMD="$PYTHON -m src.daemon.main"

detect_os() {
    case "$(uname -s)" in
        Linux)   echo "linux" ;;
        Darwin)  echo "darwin" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)       echo "unknown" ;;
    esac
}

OS="$(detect_os)"

# Build env var directives for each platform
_build_env_systemd() {
    local out=""
    [[ -n "${ACP_DAEMON_TOKEN:-}" ]] && out="$out${out:+$'\n'}Environment=ACP_DAEMON_TOKEN=$ACP_DAEMON_TOKEN"
    [[ -n "${ACP_DAEMON_ID:-}" ]]    && out="$out${out:+$'\n'}Environment=ACP_DAEMON_ID=$ACP_DAEMON_ID"
    [[ -n "${ACP_RELAY_URL:-}" ]]    && out="$out${out:+$'\n'}Environment=ACP_RELAY_URL=$ACP_RELAY_URL"
    echo "$out"
}

_build_env_launchd() {
    local out=""
    [[ -n "${ACP_DAEMON_TOKEN:-}" ]] && out="$out        <key>ACP_DAEMON_TOKEN</key><string>$ACP_DAEMON_TOKEN</string>"$'\n'
    [[ -n "${ACP_DAEMON_ID:-}" ]]    && out="$out        <key>ACP_DAEMON_ID</key><string>$ACP_DAEMON_ID</string>"$'\n'
    [[ -n "${ACP_RELAY_URL:-}" ]]    && out="$out        <key>ACP_RELAY_URL</key><string>$ACP_RELAY_URL</string>"$'\n'
    echo "$out"
}

_install_symlink() {
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    ln -sf "$PROJECT_DIR/scripts/acp-remote" "$bin_dir/acp-remote"
    echo "acp-remote command added to PATH: $bin_dir/acp-remote"
}

_remove_symlink() {
    rm -f "$HOME/.local/bin/acp-remote"
    echo "acp-remote symlink removed"
}

# --- Linux: systemd user service ---
linux_install() {
    local unit_dir="$HOME/.config/systemd/user"
    local unit_file="$unit_dir/acp-daemon.service"
    local env_block
    env_block="$(_build_env_systemd)"

    mkdir -p "$unit_dir"

    cat > "$unit_file" <<-SERVICEEOF
[Unit]
Description=ACP Daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$DAEMON_CMD
WorkingDirectory=$PROJECT_DIR
Restart=always
RestartSec=5
${env_block}

[Install]
WantedBy=default.target
SERVICEEOF

    systemctl --user daemon-reload
    systemctl --user enable --now acp-daemon.service
    echo "systemd user service enabled: $unit_file"
}

linux_remove() {
    systemctl --user disable --now acp-daemon.service 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/acp-daemon.service"
    systemctl --user daemon-reload 2>/dev/null || true
    echo "systemd user service removed"
}

linux_status() {
    if systemctl --user is-enabled acp-daemon.service &>/dev/null; then
        echo "ACP daemon: ENABLED (systemd user service)"
        systemctl --user status acp-daemon.service 2>/dev/null | grep -E "Active:|Process:"
    else
        echo "ACP daemon: NOT INSTALLED"
    fi
}

# --- macOS: launchd agent ---
darwin_install() {
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/com.acp.daemon.plist"
    local log_file="$HOME/Library/Logs/acp-daemon.log"
    local env_block
    env_block="$(_build_env_launchd)"

    mkdir -p "$plist_dir"

    cat > "$plist_file" <<-PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.acp.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>$PYTHON</string>
        <string>-m</string>
        <string>src.daemon.main</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$log_file</string>
    <key>StandardErrorPath</key>
    <string>$log_file</string>
    <key>EnvironmentVariables</key>
    <dict>
$env_block    </dict>
</dict>
</plist>
PLISTEOF

    launchctl load -w "$plist_file" 2>/dev/null || true
    echo "launchd agent installed: $plist_file"
}

darwin_remove() {
    local plist_file="$HOME/Library/LaunchAgents/com.acp.daemon.plist"
    launchctl unload -w "$plist_file" 2>/dev/null || true
    rm -f "$plist_file"
    echo "launchd agent removed"
}

darwin_status() {
    if [[ -f "$HOME/Library/LaunchAgents/com.acp.daemon.plist" ]]; then
        echo "ACP daemon: ENABLED (launchd agent)"
        launchctl list com.acp.daemon 2>/dev/null | grep -v "Could not"
    else
        echo "ACP daemon: NOT INSTALLED"
    fi
}

# --- Windows: Task Scheduler ---
windows_install() {
    local task_name="ACP Daemon"
    local wrapper_ps1="$PROJECT_DIR/scripts/run-daemon.ps1"

    mkdir -p "$PROJECT_DIR/scripts"

    # Write wrapper script: single-quoted printf format avoids bash interpreting $env:
    printf '# ACP daemon launcher (generated by setup-autostart.sh)\n' > "$wrapper_ps1"
    printf '$logFile = "$env:TEMP\\acp-daemon.log"\n' >> "$wrapper_ps1"
    [[ -n "${ACP_DAEMON_TOKEN:-}" ]] && printf '$env:ACP_DAEMON_TOKEN='\''%s'\''\n' "$ACP_DAEMON_TOKEN" >> "$wrapper_ps1"
    [[ -n "${ACP_DAEMON_ID:-}" ]]    && printf '$env:ACP_DAEMON_ID='\''%s'\''\n' "$ACP_DAEMON_ID" >> "$wrapper_ps1"
    [[ -n "${ACP_RELAY_URL:-}" ]]    && printf '$env:ACP_RELAY_URL='\''%s'\''\n' "$ACP_RELAY_URL" >> "$wrapper_ps1"
    printf 'Start-Process -NoNewWindow -FilePath "%s" -ArgumentList "-m", "src.daemon.main" -WorkingDirectory "%s" -RedirectStandardOutput $logFile -RedirectStandardError $logFile\n' "$PYTHON" "$PROJECT_DIR" >> "$wrapper_ps1"

    powershell.exe -Command "
        \$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File \"$wrapper_ps1\"'
        \$trigger = New-ScheduledTaskTrigger -AtLogOn
        \$trigger.Delay = 'PT15S'
        \$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)
        Register-ScheduledTask -TaskName '$task_name' -Action \$action -Trigger \$trigger -Settings \$settings -Force | Out-Null
    "

    echo "Task Scheduler task installed: $task_name"
}

windows_remove() {
    local task_name="ACP Daemon"
    schtasks.exe /Delete /TN "$task_name" /F 2>/dev/null || true
    rm -f "$PROJECT_DIR/scripts/run-daemon.ps1"
    echo "Task Scheduler task removed: $task_name"
}

windows_status() {
    local task_name="ACP Daemon"
    if schtasks.exe /Query /TN "$task_name" 2>/dev/null | grep -q "$task_name"; then
        echo "ACP daemon: ENABLED (Task Scheduler)"
        schtasks.exe /Query /TN "$task_name" /FO LIST 2>/dev/null | grep -E "TaskName|Status|Next Run"
    else
        echo "ACP daemon: NOT INSTALLED"
    fi
}

# --- Dispatch ---
case "$OS" in
    linux)
        case "$MODE" in
            install) linux_install; _install_symlink ;;
            remove)  linux_remove;  _remove_symlink  ;;
            status)  linux_status  ;;
        esac
        ;;
    darwin)
        case "$MODE" in
            install) darwin_install; _install_symlink ;;
            remove)  darwin_remove;  _remove_symlink  ;;
            status)  darwin_status  ;;
        esac
        ;;
    windows)
        case "$MODE" in
            install) windows_install; _install_symlink ;;
            remove)  windows_remove;  _remove_symlink  ;;
            status)  windows_status  ;;
        esac
        ;;
    *)
        echo "Error: unsupported OS ($(uname -s)). Supported: Linux, macOS, Windows."
        exit 1
        ;;
esac
