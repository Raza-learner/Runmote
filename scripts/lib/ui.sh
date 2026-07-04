#!/usr/bin/env bash

# ==========================================================
# ACP UI Library
# ==========================================================

[[ -n "${ACP_UI_LOADED:-}" ]] && return
ACP_UI_LOADED=1

# ----------------------------------------------------------
# Detect terminal
# ----------------------------------------------------------

if [[ -t 0 && -t 1 ]]; then
    ACP_INTERACTIVE=1
else
    ACP_INTERACTIVE=0
fi

# ----------------------------------------------------------
# Unicode support
# ----------------------------------------------------------

case "${LANG:-}" in
    *UTF-8*) ACP_UNICODE=1 ;;
    *) ACP_UNICODE=0 ;;
esac

# ----------------------------------------------------------
# Colors
# ----------------------------------------------------------

if [[ $ACP_INTERACTIVE -eq 1 ]]; then

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[97m"

else

RESET=""
BOLD=""
DIM=""

BLACK=""
RED=""
GREEN=""
YELLOW=""
BLUE=""
MAGENTA=""
CYAN=""
WHITE=""

fi

# ----------------------------------------------------------
# Terminal size
# ----------------------------------------------------------

terminal_width() {

    local w

    w="${COLUMNS:-80}"

    if [[ "$w" -lt 70 ]]; then
        w=70
    fi

    echo "$w"

}

# ----------------------------------------------------------
# Center text
# ----------------------------------------------------------

center() {

    local width
    width=$(terminal_width)

    local text="$1"

    printf "%*s\n" $(((${#text}+width)/2)) "$text"

}

# ----------------------------------------------------------
# Divider
# ----------------------------------------------------------

divider() {

    local width
    width=$(terminal_width)

    printf '%*s\n' "$width" '' | if [[ $ACP_UNICODE -eq 1 ]]; then
    char="─"
else
    char="-"
fi

printf '%*s\n' "$width" '' | tr ' ' "$char"

}

# ----------------------------------------------------------
# Clear screen
# ----------------------------------------------------------

clear_screen() {

    [[ $ACP_INTERACTIVE -eq 1 ]] && clear

}

# ----------------------------------------------------------
# Logo
# ----------------------------------------------------------

show_logo() {

clear_screen

echo

echo -e "${CYAN}"

center " █████╗  ██████╗ ██████╗ "
center "██╔══██╗██╔════╝██╔══██╗"
center "███████║██║     ██████╔╝"
center "██╔══██║██║     ██╔═══╝ "
center "██║  ██║╚██████╗██║     "
center "╚═╝  ╚═╝ ╚═════╝╚═╝     "

echo -e "${RESET}"

center "ACP Remote"

echo

center "AI Agent Remote Platform"

echo

divider

}

# ----------------------------------------------------------
# Header
# ----------------------------------------------------------

section() {

echo

echo -e "${BOLD}${CYAN}$1${RESET}"

divider

}

# ----------------------------------------------------------
# Messages
# ----------------------------------------------------------

success() {

echo -e "${GREEN}✓${RESET} $1"

}

info() {

echo -e "${BLUE}➜${RESET} $1"

}

warn() {

echo -e "${YELLOW}!${RESET} $1"

}

error() {

echo -e "${RED}✗${RESET} $1"

}

# ----------------------------------------------------------
# Wait
# ----------------------------------------------------------

press_enter() {

echo

read -rp "Press ENTER to continue..."

}

# ----------------------------------------------------------
# Confirmation
# ----------------------------------------------------------

confirm() {

local prompt="${1:-Continue?}"

while true
do

read -rp "$prompt [Y/n]: " ans

case "${ans,,}" in

""|y|yes)

return 0

;;

n|no)

return 1

;;

*)

;;

esac

done

}

# ----------------------------------------------------------
# Spinner
# ----------------------------------------------------------

spinner() {

local pid=$1

local delay=0.09

local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

while kill -0 "$pid" 2>/dev/null
do

for ((i=0;i<${#spin};i++))
do

printf "\r${CYAN}%s${RESET}" "${spin:$i:1}"

sleep "$delay"

done

done

printf "\r\033[K"

}

# ----------------------------------------------------------
# Run command with spinner
# ----------------------------------------------------------





# ----------------------------------------------------------
# Simple menu
# ----------------------------------------------------------

menu() {

local title="$1"

shift

local items=("$@")

echo

echo -e "${BOLD}${title}${RESET}"

divider

local i=1

for item in "${items[@]}"
do

printf " %2d) %s\n" "$i" "$item"

((i++))

done

echo

read -rp "Choice: " choice

echo "$choice"

}

# ----------------------------------------------------------
# Box
# ----------------------------------------------------------

box() {

divider

echo

echo "$1"

echo

divider

}

# ----------------------------------------------------------
# Goodbye
# ----------------------------------------------------------

finish_screen() {

echo

divider

echo

echo -e "${GREEN}${BOLD}✓ ACP installation completed successfully.${RESET}"

echo

divider

}