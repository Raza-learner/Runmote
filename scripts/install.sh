#!/usr/bin/env bash
set -euo pipefail

REMOTE="${ACP_REMOTE:-https://github.com/Raza-learner/acp-remote.git}"
REMOTE_RAW="${ACP_REMOTE_RAW:-https://raw.githubusercontent.com/Raza-learner/acp-remote}"
BRANCH="${ACP_BRANCH:-main}"
INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/acp}"
MODE="install"

usage() {
    cat <<EOF
Install ACP daemon and configure auto-start.

Usage:
  curl -fsSL $REMOTE_RAW/$BRANCH/scripts/install.sh | bash
  curl -fsSL $REMOTE_RAW/$BRANCH/scripts/install.sh | ACP_RELAY_URL='ws://host:8000/daemon' bash

Options:
  --dir <path>       Install directory (default: \$HOME/.local/share/acp)
  --branch <name>    Git branch (default: main)
  --remove           Uninstall and remove auto-start
  --help             Show this help

Environment variables:
  ACP_RELAY_URL      WebSocket URL of the relay server
  ACP_DAEMON_TOKEN   Auth token for daemon-relay authentication
  ACP_DAEMON_ID      Daemon identifier (default: hostname)
  ACP_DIR            Install directory (overrides --dir default)
  ACP_BRANCH         Git branch (overrides --branch default)
  ACP_REMOTE         Git remote URL
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

mkdir -p "$INSTALL_DIR" 2>/dev/null || true

ensure_uv() {
    if command -v uv &>/dev/null; then
        return 0
    fi
    echo "Installing uv (Python package manager)..."
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object Net.WebClient).DownloadString('https://astral.sh/uv/install.ps1'))"
            ;;
        *)
            curl -LsSf https://astral.sh/uv/install.sh | sh
            ;;
    esac
    # Refresh PATH
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
    if ! command -v uv &>/dev/null; then
        echo "Error: uv installation failed. Install manually: https://docs.astral.sh/uv"
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
    echo "+----------------------------------------------------+"
    echo "| ACP daemon installed successfully!                 |"
    echo "|                                                    |"
    echo "| It will start automatically after your next login. |"

    case "$os" in
        linux)
            echo "|                                                    |"
            echo "| To start now:                                      |"
            echo "|   systemctl --user start acp-daemon                |"
            echo "|                                                    |"
            echo "| To check status:                                   |"
            echo "|   systemctl --user status acp-daemon               |"
            echo "|                                                    |"
            echo "| Logs:                                              |"
            echo "|   journalctl --user -u acp-daemon -f               |"
            ;;
        darwin)
            echo "|                                                    |"
            echo "| To start now:                                      |"
            echo "|   launchctl load ~/Library/LaunchAgents/com.acp.daemon.plist |"
            echo "|                                                    |"
            echo "| To check status:                                   |"
            echo "|   launchctl list com.acp.daemon                    |"
            echo "|                                                    |"
            echo "| Logs:                                              |"
            echo "|   tail -f ~/Library/Logs/acp-daemon.log            |"
            ;;
        windows)
            echo "|                                                    |"
            echo "| To start now:                                      |"
            echo "|   schtasks /Run /TN \"ACP Daemon\"                  |"
            echo "|                                                    |"
            echo "| To check status:                                   |"
            echo "|   schtasks /Query /TN \"ACP Daemon\"                |"
            echo "|                                                    |"
            echo "| To restart + get pairing code:                     |"
            echo "|   acp-remote                                        |"
            ;;
    esac

    echo "|                                                    |"
    echo "| -- Pair with the app --                            |"
    echo "|                                                    |"
    echo "| After starting, the daemon shows a pairing code:   |"
    echo "|   +-----------------------------+                  |"
    echo "|   |  Device Code: 123456       |                  |"
    echo "|   +-----------------------------+                  |"
    echo "|                                                    |"
    echo "| Open the ACP mobile app and enter this code        |"
    echo "| to pair with your device.                          |"
    echo "|                                                    |"
    echo "| See all paired devices and manage sessions         |"
    echo "| directly from the app.                             |"
    echo "+----------------------------------------------------+"
}

# --- Remove mode ---
if [[ "$MODE" == "remove" ]]; then
    echo "Removing auto-start..."
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            if [[ -f "$INSTALL_DIR/scripts/setup-autostart.ps1" ]]; then
                powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTALL_DIR/scripts/setup-autostart.ps1" -Remove
            fi
            ;;
        *)
            if [[ -f "$INSTALL_DIR/scripts/setup-autostart.sh" ]]; then
                bash "$INSTALL_DIR/scripts/setup-autostart.sh" --remove --dir "$INSTALL_DIR"
            fi
            ;;
    esac

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

ensure_uv

# Clone or update
if command -v git &>/dev/null; then
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo "Updating existing installation..."
        git -C "$INSTALL_DIR" fetch origin
        git -C "$INSTALL_DIR" checkout "$BRANCH"
        git -C "$INSTALL_DIR" pull origin "$BRANCH"
    else
        echo "Cloning repository..."
        git clone --branch "$BRANCH" --depth 1 "$REMOTE" "$INSTALL_DIR"
    fi
else
    echo "git not found — downloading ZIP instead..."
    tmp_dir="/tmp/acp-install-tmp"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    zip_url="$REMOTE_RAW/$BRANCH.zip"
    if command -v curl &>/dev/null; then
        curl -fsSL -o "$tmp_dir/repo.zip" "$zip_url"
    elif command -v wget &>/dev/null; then
        wget -q -O "$tmp_dir/repo.zip" "$zip_url"
    else
        echo "Error: need curl or wget to download repository"
        exit 1
    fi
    if ! command -v unzip &>/dev/null; then
        echo "Error: 'unzip' is required. Install it (apt install unzip / brew install unzip) or install git."
        exit 1
    fi
    unzip -q "$tmp_dir/repo.zip" -d "$tmp_dir"
    extracted="$(find "$tmp_dir" -maxdepth 1 -type d -name 'acp-remote-*' 2>/dev/null | head -1)"
    if [[ -n "$extracted" ]]; then
        rm -rf "$INSTALL_DIR"
        mv "$extracted" "$INSTALL_DIR"
    else
        echo "Error: failed to extract repository"
        exit 1
    fi
    rm -rf "$tmp_dir"
fi

echo ""
echo "Installing dependencies..."
cd "$INSTALL_DIR"

# uv sync auto-downloads Python 3.13+ if not found, creates .venv, installs deps
if ! uv sync --frozen; then
    echo "Warning: frozen sync failed — running full sync..."
    uv sync
fi

echo ""
echo "Configuring auto-start..."
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTALL_DIR/scripts/setup-autostart.ps1" -Install
        ;;
    *)
        bash "$INSTALL_DIR/scripts/setup-autostart.sh" --install --dir "$INSTALL_DIR"
        ;;
esac

print_postinstall
