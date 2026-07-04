#!/usr/bin/env bash

# ==========================================================
# ACP Wizard
# Interactive Installation Wizard
# ==========================================================

[[ -n "${ACP_WIZARD_LOADED:-}" ]] && return
ACP_WIZARD_LOADED=1

# ui.sh and doctor.sh must already be sourced
if [[ -z "${ACP_UI_LOADED:-}" ]]; then
    echo "wizard.sh requires ui.sh"
    return 1
fi

# ----------------------------------------------------------
# Wizard State
# ----------------------------------------------------------

ACP_DEVICE_NAME=""
ACP_INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/acp}"
ACP_RELAY_URL="${ACP_RELAY_URL:-}"
ACP_ENABLE_AUTOSTART=true

ACP_INSTALL_MODE="install"

# ----------------------------------------------------------
# Detect default device name
# ----------------------------------------------------------

wizard_default_device_name() {

    if [[ -n "${ACP_DAEMON_ID:-}" ]]; then
        echo "$ACP_DAEMON_ID"
        return
    fi

    if command -v hostname >/dev/null 2>&1; then
        hostname
        return
    fi

    uname -n
}

# ----------------------------------------------------------
# Reset Wizard
# ----------------------------------------------------------

wizard_reset() {

    ACP_DEVICE_NAME="$(wizard_default_device_name)"

    ACP_INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/acp}"

    ACP_RELAY_URL="${ACP_RELAY_URL:-}"

    ACP_ENABLE_AUTOSTART=true

}

# ----------------------------------------------------------
# Export Wizard Values
# ----------------------------------------------------------

wizard_export() {

    export ACP_DAEMON_ID="$ACP_DEVICE_NAME"

    export ACP_DIR="$ACP_INSTALL_DIR"

    export ACP_RELAY_URL="$ACP_RELAY_URL"

}

# ----------------------------------------------------------
# Initialize Wizard
# ----------------------------------------------------------

wizard_init() {

    wizard_reset

}

# ----------------------------------------------------------
# Welcome Screen
# ----------------------------------------------------------

wizard_welcome() {

    show_logo

    box "Welcome to ACP Remote"

    echo
    echo "ACP securely connects your computer"
    echo "to the ACP Mobile App."
    echo
    echo "This installer will:"
    echo
    success "Check your system"
    success "Install ACP"
    success "Configure the daemon"
    success "Enable auto-start"
    success "Pair your mobile device"
    echo

    divider

    echo
    read -rp "Press ENTER to continue..."
}

# ----------------------------------------------------------
# Introduction
# ----------------------------------------------------------

wizard_intro() {

    clear_screen

    section "Installation Wizard"

    echo
    info "We'll ask a few questions before installing ACP."
    echo

    printf "  %-20s %s\n" "Operating System:" "$(uname -s)"
    printf "  %-20s %s\n" "Architecture:" "$(uname -m)"
    printf "  %-20s %s\n" "Install Mode:" "$ACP_INSTALL_MODE"

    echo

    if [[ -n "$ACP_INSTALL_DIR" ]]; then
        printf "  %-20s %s\n" "Install Directory:" "$ACP_INSTALL_DIR"
    fi

    divider

    echo
    read -rp "Continue? [Y/n]: " answer

    case "${answer,,}" in
        ""|y|yes)
            return 0
            ;;
        *)
            echo
            warn "Installation cancelled."
            exit 0
            ;;
    esac
}

# ----------------------------------------------------------
# Start Wizard
# ----------------------------------------------------------

wizard_start() {

    wizard_init

    wizard_welcome

    wizard_intro
}

# ----------------------------------------------------------
# Device Name
# ----------------------------------------------------------

validate_device_name() {

    local name="$1"

    # Remove leading/trailing spaces
    name="$(echo "$name" | xargs)"

    if [[ -z "$name" ]]; then
        return 1
    fi

    if [[ ${#name} -gt 50 ]]; then
        return 1
    fi

    if [[ ! "$name" =~ ^[a-zA-Z0-9._\ -]+$ ]]; then
        return 1
    fi

    return 0
}

# ----------------------------------------------------------
# Device Configuration
# ----------------------------------------------------------

wizard_device_name() {

    while true; do

        clear_screen

        section "Device Configuration"

        echo
        info "Choose a name for this computer."
        echo "This name will appear in the ACP mobile app."
        echo

        read -rp "Device Name [$ACP_DEVICE_NAME]: " input

        if [[ -z "$input" ]]; then
            input="$ACP_DEVICE_NAME"
        fi

        if validate_device_name "$input"; then
            ACP_DEVICE_NAME="$input"
            break
        fi

        echo
        error "Invalid device name."
        echo
        echo "Rules:"
        echo " • Cannot be empty"
        echo " • Maximum 50 characters"
        echo " • Allowed: letters, numbers, spaces, . _ -"
        echo

        press_enter

    done

}

# ----------------------------------------------------------
# Preview Device Configuration
# ----------------------------------------------------------

wizard_device_summary() {

    clear_screen

    section "Device"

    printf " %-18s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

    divider

    echo

    press_enter

}
# ----------------------------------------------------------
# Relay URL Validation
# ----------------------------------------------------------

validate_relay_url() {

    local url="$1"

    # Allow empty (default relay)
    [[ -z "$url" ]] && return 0

    if [[ "$url" =~ ^wss?://.+$ ]]; then
        return 0
    fi

    return 1
}

# ----------------------------------------------------------
# Relay Configuration
# ----------------------------------------------------------

wizard_relay() {

    while true; do

        clear_screen

        section "Relay Configuration"

        echo
        info "ACP uses a relay server to connect your devices."
        echo

        echo "Examples:"
        echo "  ws://localhost:8000/daemon"
        echo "  wss://relay.example.com/daemon"
        echo

        read -rp "Relay URL [Default]: " input

        if validate_relay_url "$input"; then

            ACP_RELAY_URL="$input"

            break

        fi

        echo
        error "Invalid Relay URL."
        echo
        echo "The URL must start with:"
        echo
        echo "  ws://"
        echo "  wss://"
        echo

        press_enter

    done

}

# ----------------------------------------------------------
# Relay Summary
# ----------------------------------------------------------

wizard_relay_summary() {

    clear_screen

    section "Relay Configuration"

    if [[ -z "$ACP_RELAY_URL" ]]; then

        printf " %-18s %s\n" "Relay:" "Default"

    else

        printf " %-18s %s\n" "Relay:" "$ACP_RELAY_URL"

    fi

    divider

    echo

    press_enter

}
# ----------------------------------------------------------
# Auto-start Configuration
# ----------------------------------------------------------

wizard_autostart() {

    while true; do

        clear_screen

        section "Auto-start"

        echo
        info "ACP can automatically start when you log in."
        echo
        echo "Recommended: Enable"
        echo

        echo "  1) Enable (Recommended)"
        echo "  2) Disable"
        echo

        read -rp "Select [1]: " choice

        case "$choice" in

            ""|"1")

                ACP_ENABLE_AUTOSTART=true
                break
                ;;

            "2")

                ACP_ENABLE_AUTOSTART=false
                break
                ;;

            *)

                error "Invalid selection."
                press_enter
                ;;

        esac

    done

}

# ----------------------------------------------------------
# Auto-start Summary
# ----------------------------------------------------------

wizard_autostart_summary() {

    clear_screen

    section "Auto-start"

    if [[ "$ACP_ENABLE_AUTOSTART" == true ]]; then

        success "Auto-start : Enabled"

    else

        warn "Auto-start : Disabled"

    fi

    divider

    echo

    press_enter

}
# ----------------------------------------------------------
# Confirmation Screen
# ----------------------------------------------------------

wizard_confirm() {

    while true; do

        clear_screen

        section "Review Configuration"

        echo

        printf " %-22s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

        printf " %-22s %s\n" "Install Directory:" "$ACP_INSTALL_DIR"

        if [[ -z "$ACP_RELAY_URL" ]]; then
            printf " %-22s %s\n" "Relay:" "Default"
        else
            printf " %-22s %s\n" "Relay:" "$ACP_RELAY_URL"
        fi

        if [[ "$ACP_ENABLE_AUTOSTART" == true ]]; then
            printf " %-22s %s\n" "Auto-start:" "Enabled"
        else
            printf " %-22s %s\n" "Auto-start:" "Disabled"
        fi

        echo
        divider
        echo

        echo "Choose an option:"
        echo
        echo "  1) Start Installation"
        echo "  2) Edit Device Name"
        echo "  3) Edit Relay"
        echo "  4) Edit Auto-start"
        echo "  5) Cancel"
        echo

        read -rp "Selection [1]: " choice

        case "$choice" in

            ""|"1")
                wizard_export
                return 0
                ;;

            "2")
                wizard_device_name
                ;;

            "3")
                wizard_relay
                ;;

            "4")
                wizard_autostart
                ;;

            "5")
                echo
                warn "Installation cancelled."
                exit 0
                ;;

            *)
                error "Invalid option."
                press_enter
                ;;

        esac

    done

}
# ----------------------------------------------------------
# Pairing Wizard
# ----------------------------------------------------------

wizard_pairing() {

    clear_screen

    section "Pair Your Device"

    echo
    info "ACP is now ready to pair with your mobile device."
    echo

    if ! command -v acp-remote >/dev/null 2>&1; then
        warn "ACP launcher not found."
        echo
        press_enter
        return 1
    fi

    echo "The daemon will now start and generate a pairing code."
    echo

    if confirm "Start daemon now?"; then

        echo

        run_task "Starting daemon" \
            bash -c "acp-remote start"

        echo

        run_task "Generating pairing code" \
            bash -c "acp-remote code"

    else

        warn "Pairing skipped."

        press_enter

        return 0

    fi

    echo

    info "Scan the QR code using the ACP Mobile App."

    echo

    info "Or enter the pairing code manually."

    echo

    press_enter

}
# ----------------------------------------------------------
# Waiting for Pairing
# ----------------------------------------------------------

wizard_wait_for_pairing() {

    clear_screen

    section "Waiting for Mobile Device"

    echo
    info "Waiting for your phone to complete pairing..."
    echo

    local timeout=120
    local elapsed=0
    local interval=2

    while (( elapsed < timeout )); do

        printf "\rWaiting... %3d seconds remaining " "$((timeout - elapsed))"

        #
        # TODO:
        # Replace this with your actual pairing check.
        #
        # Example:
        # if acp-remote status | grep -q "Paired"; then
        #
        if [[ -f "/tmp/acp-paired" ]]; then

            echo
            echo

            success "Phone paired successfully!"

            rm -f /tmp/acp-paired

            press_enter

            return 0

        fi

        sleep "$interval"

        ((elapsed+=interval))

    done

    echo
    echo

    warn "Pairing timed out."

    echo

    if confirm "Retry pairing?"; then

        wizard_pairing
        wizard_wait_for_pairing

    else

        warn "You can pair later using:"
        echo
        echo "    acp-remote pair"
        echo

        press_enter

    fi

}
# ----------------------------------------------------------
# Installation Complete
# ----------------------------------------------------------

wizard_install_complete() {

    clear_screen

    section "Installation Complete"

    echo

    success "ACP has been installed successfully."

    echo

    printf " %-20s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

    printf " %-20s %s\n" "Install Path:" "$ACP_INSTALL_DIR"

    if [[ -z "$ACP_RELAY_URL" ]]; then
        printf " %-20s %s\n" "Relay:" "Default"
    else
        printf " %-20s %s\n" "Relay:" "$ACP_RELAY_URL"
    fi

    if [[ "$ACP_ENABLE_AUTOSTART" == true ]]; then
        printf " %-20s %s\n" "Auto-start:" "Enabled"
    else
        printf " %-20s %s\n" "Auto-start:" "Disabled"
    fi

    echo

    divider

    echo

}
# ----------------------------------------------------------
# Installation Complete
# ----------------------------------------------------------

wizard_install_complete() {

    clear_screen

    section "Installation Complete"

    echo

    success "ACP has been installed successfully."

    echo

    printf " %-20s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

    printf " %-20s %s\n" "Install Path:" "$ACP_INSTALL_DIR"

    if [[ -z "$ACP_RELAY_URL" ]]; then
        printf " %-20s %s\n" "Relay:" "Default"
    else
        printf " %-20s %s\n" "Relay:" "$ACP_RELAY_URL"
    fi

    if [[ "$ACP_ENABLE_AUTOSTART" == true ]]; then
        printf " %-20s %s\n" "Auto-start:" "Enabled"
    else
        printf " %-20s %s\n" "Auto-start:" "Disabled"
    fi

    echo

    divider

    echo

}
# ----------------------------------------------------------
# Run Wizard
# ----------------------------------------------------------

run_wizard() {

    wizard_start

    wizard_device_name

    wizard_device_summary

    wizard_relay

    wizard_relay_summary

    wizard_autostart

    wizard_autostart_summary

    wizard_confirm

    #
    # Installation happens in installer.sh
    #

    wizard_pairing

    wizard_wait_for_pairing

    wizard_install_complete

    wizard_finish

}