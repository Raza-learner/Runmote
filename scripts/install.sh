#!/usr/bin/env bash
set -euo pipefail

REMOTE="${ACP_REMOTE:-https://github.com/Raza-learner/acp-remote.git}"
BRANCH="${ACP_BRANCH:-main}"
INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/acp}"
MODE="install"

usage() {
    cat <<EOF
Usage: curl -sL $REMOTE/raw/$BRANCH/scripts/install.sh | bash

Install ACP daemon and configure auto-start.

Options:
  --dir <path>       Install directory (default: \$HOME/.local/share/acp)
  --branch <name>    Git branch (default: main)
  --remove           Uninstall and remove auto-start
  --help             Show this help

Environment variables:
  ACP_DIR            Install directory (overrides --dir default)
  ACP_BRANCH         Git branch (overrides --branch default)
  ACP_REMOTE         Git remote URL (default: ACP default remote)
  ACP_DAEMON_TOKEN   Auth token for daemon-relay authentication
  ACP_DAEMON_ID      Daemon identifier (default: hostname)
  ACP_RELAY_URL      WebSocket URL of the relay server
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)    INSTALL_DIR="$2"; shift 2 ;;
        --branch) BRANCH="$2"; shift 2 ;;
        --remove) MODE="remove"; shift ;;
        --help)   usage ;;
        *)        echo "Unknown option: $1"; usage ;;
    esac
done

INSTALL_DIR="$(cd "$INSTALL_DIR" 2>/dev/null && pwd)" || INSTALL_DIR="$INSTALL_DIR"

check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: '$1' is required but not installed."
        case "$1" in
            git) echo "  Install: https://git-scm.com/downloads" ;;
            python3|python) echo "  Install: https://python.org/downloads" ;;
            uv)  echo "  Install: curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
        esac
        exit 1
    fi
}

detect_python() {
    if command -v python3 &>/dev/null; then
        echo "python3"
    elif command -v python &>/dev/null; then
        echo "python"
    else
        echo "Error: Python 3.13+ is required."
        exit 1
    fi
}

print_postinstall() {
    local os
    case "$(uname -s)" in
        Linux)   os="linux" ;;
        Darwin)  os="darwin" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *)       os="unknown" ;;
    esac

    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     ACP daemon installed successfully!              ║"
    echo "║                                                     ║"
    echo "║  It will start automatically after your next login. ║"

    case "$os" in
        linux)
            echo "║                                                     ║"
            echo "║  To start now:                                       ║"
            echo "║    systemctl --user start acp-daemon                 ║"
            echo "║                                                     ║"
            echo "║  To check status:                                    ║"
            echo "║    systemctl --user status acp-daemon                ║"
            echo "║                                                     ║"
            echo "║  Logs:                                               ║"
            echo "║    journalctl --user -u acp-daemon -f                ║"
            ;;
        darwin)
            echo "║                                                     ║"
            echo "║  To start now:                                       ║"
            echo "║    launchctl load ~/Library/LaunchAgents/com.acp.daemon.plist  ║"
            echo "║                                                     ║"
            echo "║  To check status:                                    ║"
            echo "║    launchctl list com.acp.daemon                     ║"
            echo "║                                                     ║"
            echo "║  Logs:                                               ║"
            echo "║    tail -f ~/Library/Logs/acp-daemon.log             ║"
            ;;
        windows)
            echo "║                                                     ║"
            echo "║  To start now:                                       ║"
            echo "║    Run 'Startup Tasks' and run 'ACP Daemon'         ║"
            echo "║                                                     ║"
            echo "║  To check status:                                    ║"
            echo "║    schtasks /Query /TN \"ACP Daemon\"                  ║"
            ;;
    esac

    echo "║                                                     ║"
    echo "║  ── Pair with the app ──                             ║"
    echo "║                                                     ║"
    echo "║  After starting, the daemon shows a pairing code:   ║"
    echo "║  ╔═══════════════════════╗                          ║"
    echo "║  ║  Device Code: 123456  ║                          ║"
    echo "║  ╚═══════════════════════╝                          ║"
    echo "║                                                     ║"
    echo "║  Open the ACP mobile app and enter this code        ║"
    echo "║  to pair with your device.                          ║"
    echo "║                                                     ║"
    echo "║  See all paired devices and manage sessions         ║"
    echo "║  directly from the app.                             ║"
    echo "╚══════════════════════════════════════════════════════╝"
}

# --- Remove mode ---
if [[ "$MODE" == "remove" ]]; then
    if [[ -d "$INSTALL_DIR" ]] && [[ -f "$INSTALL_DIR/scripts/setup-autostart.sh" ]]; then
        echo "Removing auto-start..."
        bash "$INSTALL_DIR/scripts/setup-autostart.sh" --remove --dir "$INSTALL_DIR"
    fi

    echo "Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    echo "ACP daemon uninstalled."
    exit 0
fi

# --- Install mode ---
echo "ACP daemon installer"
echo "===================="
echo "Remote:  $REMOTE"
echo "Branch:  $BRANCH"
echo "Install: $INSTALL_DIR"
echo ""

check_cmd git
PYTHON="$(detect_python)"

if command -v uv &>/dev/null; then
    INSTALLER="uv"
elif "$PYTHON" -m pip --version &>/dev/null; then
    INSTALLER="pip"
else
    INSTALLER=""
fi

# Clone or update
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "Updating existing installation..."
    git -C "$INSTALL_DIR" fetch origin
    git -C "$INSTALL_DIR" checkout "$BRANCH"
    git -C "$INSTALL_DIR" pull origin "$BRANCH"
else
    echo "Cloning repository..."
    git clone --branch "$BRANCH" --depth 1 "$REMOTE" "$INSTALL_DIR"
fi

echo ""
echo "Installing dependencies..."
cd "$INSTALL_DIR"

case "$INSTALLER" in
    uv)
        uv sync --frozen 2>/dev/null || uv sync
        ;;
    pip)
        "$PYTHON" -m venv .venv
        if [[ "$("$PYTHON" -c "import sys; print(''.join(map(str, sys.version_info[:2])))")" -ge 313 ]]; then
            .venv/bin/pip install -e ".[daemon]"
        else
            echo "Error: Python 3.13+ required."
            exit 1
        fi
        ;;
    *)
        echo "Error: neither 'uv' nor 'pip' found."
        exit 1
        ;;
esac

echo ""
echo "Configuring auto-start..."
bash "$INSTALL_DIR/scripts/setup-autostart.sh" --install --dir "$INSTALL_DIR"

print_postinstall
