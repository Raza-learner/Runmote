#!/usr/bin/env bash
set -euo pipefail

REMOTE="${ACP_REMOTE:-https://github.com/Raza-learner/acp-remote.git}"
REMOTE_RAW="${ACP_REMOTE_RAW:-https://raw.githubusercontent.com/Raza-learner/acp-remote}"
BRANCH="${ACP_BRANCH:-main}"
INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/acp}"
MODE="install"
INTERACTIVE=0

if [[ -t 0 ]] && [[ -t 1 ]]; then
    INTERACTIVE=1
fi

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
    echo "|     ACP daemon installed successfully!             |"
    echo "|                                                    |"
    echo "|  It will start automatically after next login.     |"

    case "$os" in
        linux)
            echo "|                                                    |"
            echo "|  To control the daemon now:                        |"
            echo "|    acp-remote          (interactive menu)          |"
            echo "|    acp-remote start    (start daemon)              |"
            echo "|    acp-remote code     (show pairing code)         |"
            echo "|    acp-remote stop     (stop daemon)               |"
            echo "|                                                    |"
            echo "|  Logs: journalctl --user -u acp-daemon -f          |"
            ;;
        darwin)
            echo "|                                                    |"
            echo "|  To control the daemon now:                        |"
            echo "|    acp-remote          (interactive menu)          |"
            echo "|    acp-remote start    (start daemon)              |"
            echo "|    acp-remote code     (show pairing code)         |"
            echo "|    acp-remote stop     (stop daemon)               |"
            echo "|                                                    |"
            echo "|  Logs: tail -f ~/Library/Logs/acp-daemon.log       |"
            ;;
        windows)
            echo "|                                                    |"
            echo "|  To control the daemon now:                        |"
            echo "|    acp-remote          (interactive menu)          |"
            echo "|    acp-remote start    (start daemon)              |"
            echo "|    acp-remote code     (show pairing code)         |"
            echo "|    acp-remote stop     (stop daemon)               |"
            ;;
    esac

    echo "|                                                    |"
    echo "|  -- Pair with the ACP app --                       |"
    echo "|                                                    |"
    echo "|  Start the daemon, then use the app to scan the    |"
    echo "|  QR code shown in the terminal or type the code.   |"
    echo "|                                                    |"
    echo "|  Run: acp-remote code                              |"
    echo "|                                                    |"
    echo "|  See all paired devices and manage sessions        |"
    echo "|  directly from the app.                            |"
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

# --- Interactive prompts ---
if [[ "$INTERACTIVE" -eq 1 ]]; then
    echo ""
    echo "  ACP Daemon Setup"
    echo "  ================"
    echo ""

    # Daemon name
    default_name="${ACP_DAEMON_ID:-}"
    if [[ -z "$default_name" ]]; then
        default_name="$(command -v hostname &>/dev/null && hostname || uname -n)"
    fi
    read -r -p "  Daemon name [$default_name]: " name_input
    if [[ -n "$name_input" ]]; then
        export ACP_DAEMON_ID="$name_input"
    else
        export ACP_DAEMON_ID="$default_name"
    fi

    # Install directory
    read -r -p "  Install directory [$INSTALL_DIR]: " dir_input
    if [[ -n "$dir_input" ]]; then
        INSTALL_DIR="$dir_input"
    fi

    # Auto-start
    read -r -p "  Enable auto-start on login? [Y/n]: " autostart_input
    case "${autostart_input,,}" in
        n|no) SKIP_AUTOSTART=1 ;;
        *)    SKIP_AUTOSTART=0 ;;
    esac

    echo ""
fi

# --- Install mode ---
echo "ACP daemon installer"
echo "===================="
echo "Daemon:  ${ACP_DAEMON_ID:-$(command -v hostname &>/dev/null && hostname || uname -n)}"
echo "Remote:  $REMOTE"
echo "Branch:  $BRANCH"
echo "Install: $INSTALL_DIR"
echo ""

echo "Step 1/4: Installing uv..."
ensure_uv
echo "  Done."

echo "Step 2/4: Downloading repository..."
if command -v git &>/dev/null; then
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo "  Updating existing installation..."
        git -C "$INSTALL_DIR" fetch origin
        git -C "$INSTALL_DIR" checkout "$BRANCH"
        git -C "$INSTALL_DIR" pull origin "$BRANCH"
    else
        echo "  Cloning repository..."
        git clone --branch "$BRANCH" --depth 1 "$REMOTE" "$INSTALL_DIR"
    fi
else
    echo "  git not found — downloading ZIP..."
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
echo "  Done."

echo "Step 3/4: Installing dependencies..."
cd "$INSTALL_DIR"
if ! uv sync --frozen; then
    echo "  frozen sync failed — running full sync..."
    uv sync
fi
echo "  Done."

if [[ "${SKIP_AUTOSTART:-0}" -eq 1 ]]; then
    echo "  Auto-start skipped."
else
    echo "Step 4/4: Configuring auto-start..."
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTALL_DIR/scripts/setup-autostart.ps1" -Install
            ;;
        *)
            bash "$INSTALL_DIR/scripts/setup-autostart.sh" --install --dir "$INSTALL_DIR"
            ;;
    esac
    echo "  Done."
fi

print_postinstall
