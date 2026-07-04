#!/usr/bin/env bash
set -euo pipefail

# ── Color setup ──────────────────────────────────────────────────────
if [[ -t 1 ]] && [[ -t 0 ]]; then
    n() { printf '\033[%sm' "$1"; }
    BOLD="$(n 1)"
    DIM="$(n 2)"
    RESET="$(n 0)"
    RED="$(n 31)"
    GREEN="$(n 32)"
    YELLOW="$(n 33)"
    BLUE="$(n 34)"
    CYAN="$(n 36)"
    WHITE="$(n 97)"
    INTERACTIVE=1
else
    n() { :; }
    BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; WHITE=""
    INTERACTIVE=0
fi

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
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

# ── ASCII Logo ───────────────────────────────────────────────────────
show_logo() {
    echo ""
    echo "${CYAN}    █████╗  ██████╗ ██████╗ ${RESET}"
    echo "${CYAN}   ██╔══██╗██╔════╝ ██╔══██╗${RESET}"
    echo "${CYAN}   ███████║██║  ███╗██████╔╝${RESET}"
    echo "${CYAN}   ██╔══██║██║   ██║██╔═══╝ ${RESET}"
    echo "${CYAN}   ██║  ██║╚██████╔╝██║     ${RESET}"
    echo "${CYAN}   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ${RESET}"
    echo "${DIM}   Agent Client Protocol  —  Daemon Setup${RESET}"
    echo ""
}

# ── Helpers ──────────────────────────────────────────────────────────
success() { echo "  ${GREEN}✓${RESET} $*"; }
info()    { echo "  ${BLUE}→${RESET} $*"; }
warn()    { echo "  ${YELLOW}!${RESET} $*"; }
step()    { echo ""; echo "${BOLD}${CYAN}[$1/4]${RESET} ${BOLD}$2${RESET}"; }

ensure_uv() {
    if command -v uv &>/dev/null; then
        return 0
    fi
    info "Installing uv (Python package manager)..."
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
        echo "${RED}Error: uv installation failed. Install manually: https://docs.astral.sh/uv${RESET}"
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
    echo "${BOLD}${GREEN}  ✓ Installation Complete${RESET}"
    echo ""
    echo "  ${BOLD}Control the daemon:${RESET}"
    echo "    ${CYAN}acp-remote${RESET}          interactive menu"
    echo "    ${CYAN}acp-remote start${RESET}    start daemon"
    echo "    ${CYAN}acp-remote code${RESET}     show pairing QR"
    echo "    ${CYAN}acp-remote stop${RESET}     stop daemon"

    case "$os" in
        linux)  echo ""; echo "  ${DIM}Logs: journalctl --user -u acp-daemon -f${RESET}" ;;
        darwin) echo ""; echo "  ${DIM}Logs: tail -f ~/Library/Logs/acp-daemon.log${RESET}" ;;
    esac

    echo ""
    echo "  ${BOLD}Pair with the ACP app:${RESET}"
    echo "  Start the daemon, then scan the QR code or type the"
    echo "  code shown in the terminal into the mobile app."
    echo "  ${DIM}Run ${CYAN}acp-remote code${DIM} to see the pairing code.${RESET}"
    echo ""
}

# ── Symlink helper ───────────────────────────────────────────────────
_install_symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
}

# ── Source detection ─────────────────────────────────────────────────
if [[ "$0" == "bash" ]] || [[ "$0" == "/bin/bash" ]] || [[ "$0" == "/usr/bin/bash" ]]; then
    if [[ -f "$PWD/pyproject.toml" ]]; then
        SOURCE_DIR="$PWD"
    else
        SOURCE_DIR=""
    fi
else
    SOURCE_DIR="$(cd "$SELF_DIR/.." && pwd)"
fi

IS_LOCAL=0
if [[ -n "$SOURCE_DIR" ]] && [[ -f "$SOURCE_DIR/pyproject.toml" ]]; then
    IS_LOCAL=1
fi

# ── Remove mode ──────────────────────────────────────────────────────
if [[ "$MODE" == "remove" ]]; then
    echo "Removing ACP daemon..."
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
    success "ACP daemon uninstalled."
    exit 0
fi

# ── Interactive prompts ──────────────────────────────────────────────
if [[ "$INTERACTIVE" -eq 1 ]]; then
    show_logo

    echo "  ${BOLD}${CYAN}═══ Configuration ═══${RESET}"
    echo ""

    # Daemon name
    default_name="${ACP_DAEMON_ID:-}"
    if [[ -z "$default_name" ]]; then
        default_name="$(command -v hostname &>/dev/null && hostname || uname -n)"
    fi
    read -r -p "  ${BOLD}Daemon name${RESET} ${DIM}[${default_name}]${RESET}: " name_input
    if [[ -n "$name_input" ]]; then
        export ACP_DAEMON_ID="$name_input"
    else
        export ACP_DAEMON_ID="$default_name"
    fi

    # Install directory
    read -r -p "  ${BOLD}Install to${RESET} ${DIM}[${INSTALL_DIR}]${RESET}: " dir_input
    if [[ -n "$dir_input" ]]; then
        INSTALL_DIR="$dir_input"
    fi

    # Auto-start
    read -r -p "  ${BOLD}Auto-start on login?${RESET} ${DIM}[Y/n]${RESET}: " autostart_input
    case "${autostart_input,,}" in
        n|no) SKIP_AUTOSTART=1 ;;
        *)    SKIP_AUTOSTART=0 ;;
    esac

    echo ""
fi

# ── Install mode ─────────────────────────────────────────────────────
daemon_name="${ACP_DAEMON_ID:-$(command -v hostname &>/dev/null && hostname || uname -n)}"

echo "${BOLD}${CYAN}  ACP Daemon Installer${RESET}"
echo "  ${DIM}Daemon: ${daemon_name}  |  Install: ${INSTALL_DIR}${RESET}"

# Step 1
step "1" "Installing uv package manager..."
ensure_uv
success "uv ready"

# Step 2 — link from local repo
step "2" "Setting up files..."
if [[ "$IS_LOCAL" -eq 1 ]] && [[ "$INSTALL_DIR" != "$SOURCE_DIR" ]]; then
    info "Linking from local repo (live source)..."
    mkdir -p "$INSTALL_DIR" 2>/dev/null || true
    # Just create the symlink — no file copy needed
    _install_symlink "$SOURCE_DIR/scripts/acp-remote" "$HOME/.local/bin/acp-remote"
    success "acp-remote linked → source repo"
elif [[ "$INSTALL_DIR" == "$SOURCE_DIR" ]]; then
    info "Already in source directory, skipping."
    _install_symlink "$SOURCE_DIR/scripts/acp-remote" "$HOME/.local/bin/acp-remote"
    success "acp-remote linked"
else
    echo "${RED}  No local repo found. Run from project directory:${RESET}"
    echo "    ${CYAN}cd ~/Projects/ACP && bash scripts/install.sh${RESET}"
    exit 1
fi

# Step 3
step "3" "Installing Python dependencies..."
if [[ "$IS_LOCAL" -eq 1 ]]; then
    cd "$SOURCE_DIR"
else
    cd "$INSTALL_DIR"
fi
if ! uv sync --frozen; then
    warn "Frozen sync failed — running full sync..."
    uv sync
fi
success "Dependencies installed"

# Step 4
if [[ "${SKIP_AUTOSTART:-0}" -eq 1 ]]; then
    echo ""
    info "Auto-start ${DIM}skipped${RESET} (use ${CYAN}acp-remote start${RESET} to start manually)"
else
    step "4" "Configuring auto-start..."
    autostart_dir="$INSTALL_DIR"
    if [[ "$IS_LOCAL" -eq 1 ]]; then
        autostart_dir="$SOURCE_DIR"
    fi
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$SOURCE_DIR/scripts/setup-autostart.ps1" -Install
            ;;
        *)
            bash "$SOURCE_DIR/scripts/setup-autostart.sh" --install --dir "$autostart_dir"
            ;;
    esac
    success "Auto-start configured"
fi

print_postinstall
