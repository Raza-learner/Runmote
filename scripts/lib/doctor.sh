#!/usr/bin/env bash

# ==========================================================
# Runmote Doctor - Part 1
# System & Dependency Checks
# ==========================================================

[[ -n "${ACP_DOCTOR_LOADED:-}" ]] && return
ACP_DOCTOR_LOADED=1

# ui.sh and progress.sh must already be sourced.

DOCTOR_ERRORS=0
DOCTOR_WARNINGS=0

OS_NAME=""
DISTRO=""
ARCH=""
PYTHON_BIN=""
PYTHON_VERSION=""
INSTALL_DIR="${ACP_DIR:-$HOME/.local/share/runmote}"

# ----------------------------------------------------------
# Helpers
# ----------------------------------------------------------

doctor_ok() {
    success "$1"
}

doctor_warn() {
    ((DOCTOR_WARNINGS++))
    warn "$1"
}

doctor_fail() {
    ((DOCTOR_ERRORS++))
    error "$1"
}

doctor_info() {
    info "$1"
}

# ----------------------------------------------------------
# Operating System
# ----------------------------------------------------------

check_os() {

    section "Operating System"

    OS_NAME="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS_NAME" in
        Linux)
            doctor_ok "Operating System : Linux"
            ;;
        Darwin)
            doctor_ok "Operating System : macOS"
            ;;
        *)
            doctor_fail "Unsupported operating system: $OS_NAME"
            return
            ;;
    esac

    doctor_info "Architecture : $ARCH"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="$PRETTY_NAME"
        doctor_info "Distribution : $DISTRO"
    fi
}

# ----------------------------------------------------------
# Internet
# ----------------------------------------------------------

check_internet() {

    section "Internet Connectivity"

    if command -v curl >/dev/null 2>&1; then

        if curl -fsSL --connect-timeout 5 https://github.com >/dev/null 2>&1; then
            doctor_ok "Internet connection available"
        else
            doctor_fail "Unable to reach GitHub"
        fi

    elif command -v wget >/dev/null 2>&1; then

        if wget -q --spider --timeout=5 https://github.com; then
            doctor_ok "Internet connection available"
        else
            doctor_fail "Unable to reach GitHub"
        fi

    else
        doctor_warn "Neither curl nor wget is installed"
    fi
}

# ----------------------------------------------------------
# Python
# ----------------------------------------------------------

check_python() {

    section "Python"

    if command -v python3 >/dev/null 2>&1; then
        PYTHON_BIN="$(command -v python3)"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_BIN="$(command -v python)"
    else
        doctor_fail "Python not found"
        return
    fi

    PYTHON_VERSION="$("$PYTHON_BIN" -c 'import sys;print(".".join(map(str,sys.version_info[:3])))')"

    doctor_ok "Python : $PYTHON_VERSION"

    local major minor

    major=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    minor=$(echo "$PYTHON_VERSION" | cut -d. -f2)

    if (( major < 3 || (major == 3 && minor < 10) )); then
        doctor_fail "Python 3.10 or newer is required"
    fi
}

# ----------------------------------------------------------
# uv
# ----------------------------------------------------------

check_uv() {

    section "uv Package Manager"

    if command -v uv >/dev/null 2>&1; then

        local version
        version=$(uv --version)

        doctor_ok "$version"

    else

        doctor_warn "uv is not installed"

    fi
}

# ----------------------------------------------------------
# Git
# ----------------------------------------------------------

check_git() {

    section "Git"

    if command -v git >/dev/null 2>&1; then

        doctor_ok "$(git --version)"

    else

        doctor_warn "Git is not installed"

    fi
}

# ----------------------------------------------------------
# Install Directory
# ----------------------------------------------------------

check_install_directory() {

    section "Install Directory"

    doctor_info "$INSTALL_DIR"

    mkdir -p "$INSTALL_DIR" 2>/dev/null

    if [[ ! -d "$INSTALL_DIR" ]]; then
        doctor_fail "Unable to create install directory"
        return
    fi

    if [[ -w "$INSTALL_DIR" ]]; then
        doctor_ok "Directory is writable"
    else
        doctor_fail "Directory is not writable"
    fi
}

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------

doctor_summary() {

    section "Summary"

    if [[ $DOCTOR_ERRORS -eq 0 ]]; then
        doctor_ok "System ready for Runmote installation"
    else
        doctor_fail "$DOCTOR_ERRORS error(s) detected"
    fi

    if [[ $DOCTOR_WARNINGS -gt 0 ]]; then
        doctor_warn "$DOCTOR_WARNINGS warning(s)"
    fi

    echo
}

# ----------------------------------------------------------
# Main Entry
# ----------------------------------------------------------

run_system_checks() {

    check_os
    check_internet
    check_python
    check_uv
    check_git
    check_install_directory

    doctor_summary

    [[ $DOCTOR_ERRORS -eq 0 ]]
}

# ==========================================================
# Runmote Doctor - Part 2
# Runmote Installation Checks
# ==========================================================

SERVICE_NAME="runmoted"
ACP_BINARY="$HOME/.local/bin/runmote"

# ----------------------------------------------------------
# Existing installation
# ----------------------------------------------------------

check_existing_installation() {

    section "Runmote Installation"

    if [[ -d "$INSTALL_DIR" ]]; then
        doctor_ok "Installation directory exists"

        if [[ -f "$INSTALL_DIR/pyproject.toml" ]]; then
            doctor_ok "Runmote project detected"
        else
            doctor_warn "Installation directory exists but project files are missing"
        fi

    else
        doctor_info "Runmote is not installed"
    fi
}

# ----------------------------------------------------------
# Virtual Environment
# ----------------------------------------------------------

check_virtualenv() {

    section "Python Environment"

    if [[ -f "$INSTALL_DIR/.venv/bin/python" ]]; then

        doctor_ok "Virtual environment found"

    elif [[ -f "$INSTALL_DIR/.venv/Scripts/python.exe" ]]; then

        doctor_ok "Virtual environment found"

    else

        doctor_warn "Virtual environment not found"

    fi
}

# ----------------------------------------------------------
# Launcher
# ----------------------------------------------------------

check_launcher() {

    section "Runmote Launcher"

    if [[ -x "$ACP_BINARY" ]]; then

        doctor_ok "Launcher installed"

    else

        doctor_warn "runmote launcher missing"

    fi
}

# ----------------------------------------------------------
# Relay Configuration
# ----------------------------------------------------------

check_relay() {

    section "Relay Configuration"

    if [[ -n "${ACP_RELAY_URL:-}" ]]; then

        doctor_ok "Relay URL configured"

        doctor_info "$ACP_RELAY_URL"

    else

        doctor_warn "ACP_RELAY_URL not configured"

    fi

    if [[ -n "${ACP_DAEMON_ID:-}" ]]; then

        doctor_ok "Daemon ID : $ACP_DAEMON_ID"

    else

        doctor_warn "ACP_DAEMON_ID not configured"

    fi
}

# ----------------------------------------------------------
# Auto Start
# ----------------------------------------------------------

check_autostart() {

    section "Auto Start"

    case "$(uname -s)" in

        Linux)

            if command -v systemctl >/dev/null 2>&1; then

                if systemctl --user is-enabled "$SERVICE_NAME" >/dev/null 2>&1; then

                    doctor_ok "systemd user service enabled"

                else

                    doctor_warn "systemd service not installed"

                fi

            else

                doctor_warn "systemctl unavailable"

            fi

            ;;

        Darwin)

            if [[ -f "$HOME/Library/LaunchAgents/com.acp.daemon.plist" ]]; then

                doctor_ok "LaunchAgent installed"

            else

                doctor_warn "LaunchAgent missing"

            fi

            ;;

    esac
}

# ----------------------------------------------------------
# Daemon Running
# ----------------------------------------------------------

check_daemon() {

    section "Daemon Status"

    case "$(uname -s)" in

        Linux)

            if systemctl --user is-active "$SERVICE_NAME" >/dev/null 2>&1; then

                doctor_ok "Daemon running"

            else

                doctor_warn "Daemon not running"

            fi

            ;;

        Darwin)

            if pgrep -f "src.daemon.main" >/dev/null; then

                doctor_ok "Daemon running"

            else

                doctor_warn "Daemon not running"

            fi

            ;;

    esac
}

# ----------------------------------------------------------
# PATH
# ----------------------------------------------------------

check_path() {

    section "PATH"

    if command -v runmote >/dev/null 2>&1; then

        doctor_ok "runmote available"

    else

        doctor_warn "~/.local/bin not in PATH"

    fi
}

# ----------------------------------------------------------
# Final Health Score
# ----------------------------------------------------------

doctor_health() {

    section "Health Report"

    local total

    total=$((DOCTOR_ERRORS + DOCTOR_WARNINGS))

    if [[ $DOCTOR_ERRORS -eq 0 && $DOCTOR_WARNINGS -eq 0 ]]; then

        doctor_ok "Perfect"

        echo

        echo "Health Score : 100%"

        return

    fi

    local score

    score=$((100 - DOCTOR_ERRORS*25 - DOCTOR_WARNINGS*5))

    ((score<0)) && score=0

    if ((score>=90)); then

        doctor_ok "Excellent"

    elif ((score>=75)); then

        doctor_ok "Good"

    elif ((score>=50)); then

        doctor_warn "Needs attention"

    else

        doctor_fail "System not ready"

    fi

    echo

    echo "Health Score : ${score}%"

}

# ----------------------------------------------------------
# Doctor Checks
# ----------------------------------------------------------

DOCTOR_CHECKS=(
    check_os
    check_internet
    check_python
    check_uv
    check_git
    check_install_directory
)

# ----------------------------------------------------------
# Run Check
# ----------------------------------------------------------

run_check() {
    local check="$1"

    if declare -f "$check" >/dev/null; then

        "$check"

    fi
}

# ----------------------------------------------------------
# Complete Doctor
# ----------------------------------------------------------

run_doctor() {

for check in "${DOCTOR_CHECKS[@]}"; do
    run_check "$check"
done

}