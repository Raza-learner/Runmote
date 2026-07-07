#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Runmote Installer
# ==========================================================

# ── Bootstrap: detect pipe mode and download ──────────────
if [[ ! -f "$(dirname "$0")/lib/utils.sh" ]]; then
    echo "Downloading ACP installer..."

    BRANCH="${ACP_BRANCH:-dev}"
    REPO="${ACP_REMOTE:-https://github.com/Raza-learner/Runmote.git}"
    TMP_DIR="$(mktemp -d)"
    SCRIPT_DIR="$TMP_DIR/runmote"

    # Try archive download first (fast)
    if command -v curl &>/dev/null; then
        ARCHIVE="https://github.com/Raza-learner/Runmote/archive/$BRANCH.tar.gz"
        curl -sL "$ARCHIVE" -o "$TMP_DIR/repo.tar.gz" 2>/dev/null && \
        tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR" 2>/dev/null && \
        mv "$TMP_DIR"/*-"$BRANCH" "$SCRIPT_DIR" 2>/dev/null
    fi

    # Fallback: shallow git clone
    if [[ ! -f "$SCRIPT_DIR/scripts/install.sh" ]]; then
        command -v git &>/dev/null || {
            echo "Error: git or curl required. Install one and try again."
            exit 1
        }
        echo "Cloning repository (this may take a moment)..."
        # Try HTTPS first, then SSH (for private repos with keys)
        git clone --depth 1 --branch "$BRANCH" "$REPO" "$SCRIPT_DIR" 2>/dev/null || \
        git clone --depth 1 --branch "$BRANCH" "git@github.com:Raza-learner/Runmote.git" "$SCRIPT_DIR" || {
            echo "Error: failed to clone repository."
            echo "Make sure the repo is accessible or use a public repo."
            exit 1
        }
    fi

    export ACP_BOOTSTRAP_DIR="$SCRIPT_DIR"
    exec "$SCRIPT_DIR/scripts/install.sh" "$@"
fi

# ── Resolve paths from real filesystem ────────────────────
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SELF_DIR/lib"

# ----------------------------------------------------------
# Load Libraries
# ----------------------------------------------------------

source "$LIB_DIR/utils.sh"
source "$LIB_DIR/ui.sh"
source "$LIB_DIR/progress.sh"
source "$LIB_DIR/doctor.sh"
source "$LIB_DIR/wizard.sh"
source "$LIB_DIR/installer.sh"

# ----------------------------------------------------------
# Cleanup
# ----------------------------------------------------------

cleanup_and_exit() {

    local code="${1:-0}"

    if [[ "$code" -ne 0 ]]; then
        echo
        error "Installer failed."
    fi

    exit "$code"

}

trap 'cleanup_and_exit 1' ERR

# ----------------------------------------------------------
# Main
# ----------------------------------------------------------

main() {

    clear_screen

    show_logo

    #
    # System Checks
    #

    if ! run_doctor; then

        echo
        error "Your system is not ready for installation."
        echo

        exit 1

    fi

    press_enter

    #
    # Configuration Wizard
    #

    wizard_start

    run_wizard

    #
    # Install ACP
    #

    if ! install_acp; then

        error "Installation failed."

        exit 1

    fi

    #
    # Pair Device
    #

    wizard_pairing

    wizard_wait_for_pairing

    #
    # Finish
    #

    wizard_install_complete

}

main "$@"

cleanup_and_exit 0
