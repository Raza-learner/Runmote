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

    section "Welcome to ACP Remote"

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

    press_enter
}

# ----------------------------------------------------------
# Introduction
# ----------------------------------------------------------

wizard_intro() {

    screen_header

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

    screen_header

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

        screen_header

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

    screen_header

    section "Device"

    printf " %-18s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

    divider

    echo

    press_enter

}
# ----------------------------------------------------------
# Auto-start Configuration
# ----------------------------------------------------------

wizard_autostart() {

    while true; do

        screen_header

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

    screen_header

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
# Relay status check
# ----------------------------------------------------------

relay_status() {

    if (command -v nc >/dev/null 2>&1 && nc -z localhost 8000 2>/dev/null) || \
       (command -v ss >/dev/null 2>&1 && ss -tln 2>/dev/null | grep -q ':8000'); then
        echo "Connected"
    else
        echo "Disconnected"
    fi

}

# ----------------------------------------------------------
# Confirmation Screen
# ----------------------------------------------------------

wizard_confirm() {

    while true; do

        screen_header

        section "Review Configuration"

        echo

        printf " %-22s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

        printf " %-22s %s\n" "Install Directory:" "$ACP_INSTALL_DIR"

        printf " %-22s %s\n" "Relay:" "$(relay_status)"

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
        echo "  3) Edit Auto-start"
        echo "  4) Cancel"
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
                wizard_autostart
                ;;

            "4")
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

    local paired_file="$HOME/.config/acp/paired"

    # Already paired — skip
    if [[ -f "$paired_file" ]]; then
        screen_header
        section "Pair Your Device"
        echo
        info "Phone is already paired."
        echo
        press_enter
        return 0
    fi

    screen_header

    section "Pair Your Device"

    echo
    info "ACP is now ready to pair with your mobile device."
    echo

    echo "The daemon will now start and generate a pairing code."
    echo

    if confirm "Start daemon now?"; then

        echo

        echo "  ${DIM}Starting daemon...${RESET}"
        systemctl --user start acp-daemon.service 2>/dev/null || true
        sleep 1

        echo
        echo "  ${DIM}Fetching pairing code...${RESET}"

        local code=""
        for i in $(seq 1 12); do
            code=$(journalctl --user -u acp-daemon.service -n 100 --no-pager 2>/dev/null | grep -oP 'pairing code:\s+\K\S+' | tail -1 || true)
            [[ -n "$code" ]] && break
            sleep 1
        done

        if [[ -z "$code" ]]; then
            echo "  ${YELLOW}Pairing code not available yet.${RESET}"
        else
            local qr_code
            local python="python3"
            [[ -x "${ACP_PROJECT_DIR:-.}/.venv/bin/python3" ]] && python="${ACP_PROJECT_DIR:-.}/.venv/bin/python3"
            [[ -x "${ACP_PROJECT_DIR:-.}/.venv/bin/python" ]] && python="${ACP_PROJECT_DIR:-.}/.venv/bin/python"
            qr_code=$("$python" -c "
import sys
sys.path.insert(0, '${ACP_PROJECT_DIR:-.}/src')
from daemon.main import _pairing_banner
print(_pairing_banner('$code'))
" 2>/dev/null) && echo "$qr_code" || {
                local formatted="${code:0:4}-${code:4}"
                echo ""
                echo "  ${BOLD}┌─────────────────────────────┐${RESET}"
                printf "  ${BOLD}│${RESET}  ${CYAN}Pairing Code:${RESET} ${GREEN}${BOLD}%-12s${RESET}  ${BOLD}│${RESET}\n" "$formatted"
                echo "  ${BOLD}│${RESET}                             ${BOLD}│${RESET}"
                echo "  ${BOLD}│${RESET}  ${DIM}Enter this in the app${RESET}      ${BOLD}│${RESET}"
                echo "  ${BOLD}└─────────────────────────────┘${RESET}"
                echo ""
            }
        fi

    else

        warn "Pairing skipped."

        press_enter

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

    local paired_file="$HOME/.config/acp/paired"

    # Already paired — skip
    if [[ -f "$paired_file" ]]; then
        return 0
    fi

    screen_header

    section "Waiting for Mobile Device"

    echo
    info "Waiting for your phone to complete pairing..."
    echo

    local timeout=120
    local elapsed=0
    local interval=2

    while (( elapsed < timeout )); do

        printf "\rWaiting... %3d seconds remaining " "$((timeout - elapsed))"

        if [[ -f "/tmp/acp-paired" ]]; then

            printf "\r%*s\r" 40 " "
            success "Phone paired successfully!"
            echo

            rm -f /tmp/acp-paired
            mkdir -p "$HOME/.config/acp"
            : > "$HOME/.config/acp/paired"

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

    screen_header

    section "Installation Complete"

    echo

    success "ACP has been installed successfully."

    echo

    printf " %-20s %s\n" "Device Name:" "$ACP_DEVICE_NAME"

    if [[ "${ACP_IS_LOCAL:-0}" -eq 1 && -n "${ACP_PROJECT_DIR:-}" ]]; then
        printf " %-20s %s\n" "Install Path:" "$ACP_PROJECT_DIR (live)"
    else
        printf " %-20s %s\n" "Install Path:" "$ACP_INSTALL_DIR"
    fi

    printf " %-20s %s\n" "Relay:" "$(relay_status)"

    if [[ "$ACP_ENABLE_AUTOSTART" == true ]]; then
        printf " %-20s %s\n" "Auto-start:" "Enabled"
    else
        printf " %-20s %s\n" "Auto-start:" "Disabled"
    fi

    echo

    divider

    echo

    section "Available Commands"

    echo

    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote" "Interactive menu"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote start" "Start the daemon"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote stop" "Stop the daemon"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote status" "Show daemon status"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote code" "Display QR pairing code"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote text" "Display text pairing code"
    printf "  ${BOLD}%-20s${RESET}  %s\n" "acp-remote uninstall" "Uninstall ACP daemon"

    echo

    success "Installer finished."

}
# ----------------------------------------------------------
# Run Wizard
# ----------------------------------------------------------

run_wizard() {

    wizard_device_name

    wizard_device_summary

    # Auto-detect local relay silently
    local default_relay="ws://localhost:8000/daemon"
    if (command -v nc >/dev/null 2>&1 && nc -z localhost 8000 2>/dev/null) || \
       (command -v ss >/dev/null 2>&1 && ss -tln 2>/dev/null | grep -q ':8000'); then
        ACP_RELAY_URL="$default_relay"
    fi

    wizard_autostart

    wizard_autostart_summary

    wizard_confirm

    #
    # Installation happens in installer.sh
    # Pairing happens after installation in install.sh (wizard_pairing + wizard_wait_for_pairing)
    # wizard_install_complete shown after pairing in install.sh
    #

}
