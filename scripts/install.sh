#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# ACP Installer
# ==========================================================

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
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

    echo

    if [[ "$code" -eq 0 ]]; then
        success "Installer finished."
    else
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

    wizard_device_name
    wizard_device_summary

    wizard_relay
    wizard_relay_summary

    wizard_autostart
    wizard_autostart_summary

    wizard_confirm

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

    wizard_finish

}

main "$@"

cleanup_and_exit 0