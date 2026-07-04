#!/usr/bin/env bash
# Temporary log file for installer
ACP_TMP_LOG="$(mktemp -t acp-install.XXXXXX.log)"

# Remove it when the installer exits
trap 'rm -f "$ACP_TMP_LOG"' EXIT
# ==========================================================
# ACP Progress Library
# ==========================================================

[[ -n "${ACP_PROGRESS_LOADED:-}" ]] && return
ACP_PROGRESS_LOADED=1

# ui.sh must be loaded first
if [[ -z "${ACP_UI_LOADED:-}" ]]; then
    echo "progress.sh requires ui.sh"
    return 1
fi

ACP_PROGRESS_TOTAL=0
ACP_PROGRESS_CURRENT=0
ACP_PROGRESS_WIDTH=40

# ----------------------------------------------------------
# Initialize progress
# ----------------------------------------------------------

progress_init() {
    ACP_PROGRESS_TOTAL="$1"
    ACP_PROGRESS_CURRENT=0
}

# ----------------------------------------------------------
# Draw progress bar
# ----------------------------------------------------------

progress_draw() {

    local current="$ACP_PROGRESS_CURRENT"
    local total="$ACP_PROGRESS_TOTAL"

    (( total == 0 )) && total=1

    local percent=$(( current * 100 / total ))
    local filled=$(( current * ACP_PROGRESS_WIDTH / total ))
    local empty=$(( ACP_PROGRESS_WIDTH - filled ))

    printf "\r["

    for ((i=0;i<filled;i++)); do
        printf "█"
    done

    for ((i=0;i<empty;i++)); do
        printf " "
    done

    printf "] %3d%%" "$percent"
}

# ----------------------------------------------------------
# Increment progress
# ----------------------------------------------------------

progress_step() {

    ((ACP_PROGRESS_CURRENT++))

    if (( ACP_PROGRESS_CURRENT > ACP_PROGRESS_TOTAL )); then
        ACP_PROGRESS_CURRENT="$ACP_PROGRESS_TOTAL"
    fi

    progress_draw
}

# ----------------------------------------------------------
# Finish progress
# ----------------------------------------------------------

progress_finish() {

    ACP_PROGRESS_CURRENT="$ACP_PROGRESS_TOTAL"

    progress_draw

    echo
}

# ----------------------------------------------------------
# Execute a task with spinner
# ----------------------------------------------------------

run_task() {

    local title="$1"
    shift

    printf "\n"

    info "$title"

    "$@" >/tmp/acp-install.log 2>&1 &
    local pid=$!

    spinner "$pid"

    wait "$pid"
    local rc=$?

    if [[ $rc -eq 0 ]]; then
        success "$title"
        progress_step
    else
        error "$title"

        echo
        echo "────────────────────────────────────────────"
        cat /tmp/acp-install.log
        echo "────────────────────────────────────────────"

        return "$rc"
    fi
}

# ----------------------------------------------------------
# Execute shell command
# ----------------------------------------------------------

run_cmd() {

    local title="$1"
    shift

    run_task "$title" bash -c "$*"
}

# ----------------------------------------------------------
# Execute command silently
# ----------------------------------------------------------

run_quiet() {

    "$@" >/dev/null 2>&1
}

# ----------------------------------------------------------
# Progress section
# ----------------------------------------------------------

progress_section() {

    echo
    section "$1"

    progress_draw

    echo
}

# ----------------------------------------------------------
# Success summary
# ----------------------------------------------------------

progress_summary() {

    echo

    divider

    echo

    success "Installation completed"

    echo

    divider
}


# ----------------------------------------------------------
# Example
# ----------------------------------------------------------
#
# progress_init 5
#
# progress_section "Installing ACP"
#
# run_cmd "Creating directories" "mkdir -p ~/.local/share/acp"
#
# run_cmd "Installing dependencies" "uv sync"
#
# run_cmd "Creating launcher" "./setup.sh"
#
# run_cmd "Starting daemon" "systemctl --user start acp-daemon"
#
# run_cmd "Checking installation" "acp-remote doctor"
#
# progress_finish
#
# progress_summary
#