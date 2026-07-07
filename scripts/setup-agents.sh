#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--install|--remove|--status]

Detect coding agent CLIs (codex, claude) and install/uninstall their
Runmote adapters as global npm packages.

Options:
  --install          Install Runmote adapters for detected CLIs (default)
  --remove           Remove Runmote adapter packages and symlinks
  --status           Show installed Runmote adapter status
  --help             Show this help
EOF
    exit 0
}

MODE="${1:-install}"
case "$MODE" in
    --install) MODE="install"; shift 2>/dev/null || true ;;
    --remove)  MODE="remove";  shift 2>/dev/null || true ;;
    --status)  MODE="status";  shift 2>/dev/null || true ;;
    --help)    usage ;;
    *)         MODE="install" ;;
esac

# Prefer the npm package as the canonical path
if command -v npx &>/dev/null; then
    case "$MODE" in
        install) npx -y runmote agents 2>/dev/null && exit 0 || true ;;
        remove)  npx -y runmote uninstall 2>/dev/null && exit 0 || true ;;
        status)  npx -y runmote status 2>/dev/null && exit 0 || true ;;
    esac
fi

detect_os() {
    case "$(uname -s)" in
        Linux)   echo "linux" ;;
        Darwin)  echo "darwin" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)       echo "unknown" ;;
    esac
}

OS="$(detect_os)"

_install_symlinks() {
    mkdir -p "$BIN_DIR"
    if command -v codex-acp &>/dev/null; then
        local src
        src="$(command -v codex-acp)"
        ln -sf "$src" "$BIN_DIR/codex-acp" 2>/dev/null || true
        echo "  codex-acp linked to $BIN_DIR"
    fi
    if command -v claude-agent-acp &>/dev/null; then
        local src
        src="$(command -v claude-agent-acp)"
        ln -sf "$src" "$BIN_DIR/claude-agent-acp" 2>/dev/null || true
        echo "  claude-agent-acp linked to $BIN_DIR"
    fi
}

_remove_symlinks() {
    rm -f "$BIN_DIR/codex-acp" "$BIN_DIR/claude-agent-acp"
}

_ensure_npm() {
    if ! command -v npm &>/dev/null; then
        echo "  npm not found. Install Node.js first: https://nodejs.org"
        return 1
    fi
}

_install_if_cli_found() {
    local cli="$1"
    local pkg="$2"

    if ! command -v "$cli" &>/dev/null; then
        echo "  '$cli' not found — skipping $pkg"
        return
    fi

    if npm list -g "$pkg" &>/dev/null; then
        echo "  $pkg already installed — skipping"
    else
        echo "  Installing $pkg (for $cli)..."
        npm install -g "$pkg"
    fi
}

_remove_package() {
    local pkg="$1"
    if npm list -g "$pkg" &>/dev/null; then
        echo "  Removing $pkg..."
        npm uninstall -g "$pkg"
    else
        echo "  $pkg not installed — skipping"
    fi
}

install_agents() {
    echo "Installing Runmote agent adapters..."
    echo ""

    _ensure_npm || return 1

    _install_if_cli_found "codex"       "@agentclientprotocol/codex-acp"
    _install_if_cli_found "claude"      "@agentclientprotocol/claude-agent-acp"
    _install_if_cli_found "claude-code" "@agentclientprotocol/claude-agent-acp"

    _install_symlinks

    echo ""
    echo "Done."
}

remove_agents() {
    echo "Removing Runmote agent adapters..."
    echo ""

    _ensure_npm || return 0

    _remove_package "@agentclientprotocol/codex-acp"
    _remove_package "@agentclientprotocol/claude-agent-acp"

    _remove_symlinks

    echo ""
    echo "Done."
}

status_agents() {
    echo "Runmote Agent Adapters Status"
    echo ""

    for cli in codex claude claude-code; do
        if command -v "$cli" &>/dev/null; then
            echo "  $cli: found ($(command -v "$cli"))"
        else
            echo "  $cli: not found"
        fi
    done

    echo ""
    for pkg in "@agentclientprotocol/codex-acp" "@agentclientprotocol/claude-agent-acp"; do
        if npm list -g "$pkg" &>/dev/null; then
            local ver
            ver="$(npm list -g "$pkg" --depth=0 2>/dev/null | grep "$pkg" | sed 's/.*@//')"
            echo "  $pkg: installed (v$ver)"
        else
            echo "  $pkg: not installed"
        fi
    done

    echo ""
    for bin in codex-acp claude-agent-acp; do
        if [[ -f "$BIN_DIR/$bin" ]]; then
            echo "  $BIN_DIR/$bin: linked"
        elif command -v "$bin" &>/dev/null; then
            echo "  $(command -v "$bin"): in PATH"
        else
            echo "  $bin: not in PATH"
        fi
    done
}

case "$MODE" in
    install) install_agents ;;
    remove)  remove_agents  ;;
    status)  status_agents  ;;
esac
