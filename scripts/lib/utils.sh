#!/usr/bin/env bash

# ==========================================================
# ACP Utilities
# Shared helper functions
# ==========================================================

[[ -n "${ACP_UTILS_LOADED:-}" ]] && return
ACP_UTILS_LOADED=1

# ----------------------------------------------------------
# Command Exists
# ----------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ----------------------------------------------------------
# Detect Operating System
# ----------------------------------------------------------

detect_os() {

    case "$(uname -s)" in
        Linux)  echo "linux" ;;
        Darwin) echo "darwin" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac

}

# ----------------------------------------------------------
# Detect Architecture
# ----------------------------------------------------------

detect_arch() {

    case "$(uname -m)" in
        x86_64|amd64)
            echo "amd64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        armv7*)
            echo "armv7"
            ;;
        *)
            uname -m
            ;;
    esac

}

# ----------------------------------------------------------
# Get Absolute Path
# ----------------------------------------------------------

real_path() {

    if command_exists realpath; then
        realpath "$1"
    else
        (
            cd "$(dirname "$1")" || exit 1
            echo "$PWD/$(basename "$1")"
        )
    fi

}

# ----------------------------------------------------------
# Version Compare
# returns:
#   0 = equal
#   1 = first > second
#   2 = first < second
# ----------------------------------------------------------

compare_versions() {

    local v1="$1"
    local v2="$2"

    if [[ "$v1" == "$v2" ]]; then
        return 0
    fi

    local first

    first=$(printf "%s\n%s\n" "$v1" "$v2" | sort -V | head -n1)

    if [[ "$first" == "$v1" ]]; then
        return 2
    fi

    return 1

}

# ----------------------------------------------------------
# Download File
# ----------------------------------------------------------

download_file() {

    local url="$1"
    local output="$2"

    if command_exists curl; then

        curl -fsSL "$url" -o "$output"

    elif command_exists wget; then

        wget -q "$url" -O "$output"

    else

        return 1

    fi

}

# ----------------------------------------------------------
# Writable Directory
# ----------------------------------------------------------

is_writable() {

    local dir="$1"

    mkdir -p "$dir" 2>/dev/null || return 1

    [[ -w "$dir" ]]

}

# ----------------------------------------------------------
# Temporary File
# ----------------------------------------------------------

create_temp_file() {

    mktemp -t acp.XXXXXX

}

# ----------------------------------------------------------
# Temporary Directory
# ----------------------------------------------------------

create_temp_dir() {

    mktemp -d -t acp.XXXXXX

}

# ----------------------------------------------------------
# Cleanup
# ----------------------------------------------------------

cleanup() {

    local target="$1"

    [[ -e "$target" ]] && rm -rf "$target"

}

# ----------------------------------------------------------
# Ensure Directory
# ----------------------------------------------------------

ensure_directory() {

    mkdir -p "$1"

}

# ----------------------------------------------------------
# Ensure Executable
# ----------------------------------------------------------

ensure_executable() {

    chmod +x "$1"

}

# ----------------------------------------------------------
# Timestamp
# ----------------------------------------------------------

timestamp() {

    date "+%Y-%m-%d %H:%M:%S"

}

# ----------------------------------------------------------
# Require Command
# ----------------------------------------------------------

require_command() {

    local cmd="$1"

    if ! command_exists "$cmd"; then

        echo "Missing dependency: $cmd"

        return 1

    fi

}

# ----------------------------------------------------------
# Add to PATH
# ----------------------------------------------------------

path_contains() {

    [[ ":$PATH:" == *":$1:"* ]]

}

# ----------------------------------------------------------
# Backup File
# ----------------------------------------------------------

backup_file() {

    local file="$1"

    [[ -f "$file" ]] || return 0

    cp "$file" "$file.bak"

}

# ----------------------------------------------------------
# Restore Backup
# ----------------------------------------------------------

restore_backup() {

    local file="$1"

    [[ -f "$file.bak" ]] || return 0

    mv "$file.bak" "$file"

}