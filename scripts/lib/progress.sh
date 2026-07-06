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
# Build progress bar string
# ----------------------------------------------------------

progress_bar_str() {

    local current="$ACP_PROGRESS_CURRENT"
    local total="$ACP_PROGRESS_TOTAL"

    (( total == 0 )) && total=1

    local percent=$(( current * 100 / total ))
    local filled=$(( current * ACP_PROGRESS_WIDTH / total ))
    local empty=$(( ACP_PROGRESS_WIDTH - filled ))

    local bar="["

    for ((i=0;i<filled;i++)); do
        bar+="█"
    done

    for ((i=0;i<empty;i++)); do
        bar+="░"
    done

    bar+="]"

    printf "%s %3d%%" "$bar" "$percent"
}

# ----------------------------------------------------------
# Draw progress bar
# ----------------------------------------------------------

progress_draw() {

    progress_bar_str

}

# ----------------------------------------------------------
# Increment progress
# ----------------------------------------------------------

progress_step() {

    ((ACP_PROGRESS_CURRENT++))

    if (( ACP_PROGRESS_CURRENT > ACP_PROGRESS_TOTAL )); then
        ACP_PROGRESS_CURRENT="$ACP_PROGRESS_TOTAL"
    fi
}

# ----------------------------------------------------------
# Finish progress
# ----------------------------------------------------------

progress_finish() {

    ACP_PROGRESS_CURRENT="$ACP_PROGRESS_TOTAL"

    progress_bar_str

    echo
}

# ----------------------------------------------------------
# Execute a task with spinner (inline)
# ----------------------------------------------------------

run_task() {

    local title="$1"
    shift

    progress_bar_str
    printf "  %s " "$title"

    "$@" >/tmp/acp-install.log 2>&1 &
    local pid=$!

    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r%s  %s %s" "$(progress_bar_str)" "$title" "${spin:$i:1}"
        i=$(( (i + 1) % ${#spin} ))
        sleep 0.09
    done

    wait "$pid"
    local rc=$?

    if [[ $rc -eq 0 ]]; then
        progress_step
        printf "\r%s  %s ${GREEN}✓${RESET}\n" "$(progress_bar_str)" "$title"
    else
        printf "\r%s  %s ${RED}✗${RESET}\n" "$(progress_bar_str)" "$title"

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

