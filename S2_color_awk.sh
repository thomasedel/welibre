#!/usr/bin/env bash

set -euo pipefail

# Couleurs
RED=$(printf '\033[0;31m')
YELLOW=$(printf '\033[1;33m')
GREEN=$(printf '\033[0;32m')
BLUE=$(printf '\033[0;34m')
CYAN=$(printf '\033[0;36m')
MAGENTA=$(printf '\033[0;35m')
WHITE=$(printf '\033[1;37m')
RESET=$(printf '\033[0m')

is_access_log_line() {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ .*\[.*\] ".*" [0-9]{3} [0-9]+'
}

colorize_access_line() {
    local line="$1"
    ip=$(echo "$line" | awk '{print $1}')
    date=$(echo "$line" | grep -o '\[.*\]' | sed 's/\[//;s/\]//')
    method=$(echo "$line" | sed -n 's/.*\"\([A-Z]*\) .*/\1/p')
    path=$(echo "$line" | sed -n 's/.*\"[A-Z]* \(\/[^ ]*\) .*/\1/p')
    code=$(echo "$line" | awk '{print $(NF-1)}')

    if [[ "$code" =~ ^2 ]]; then
        code_color=$GREEN
    elif [[ "$code" =~ ^3 ]]; then
        code_color=$YELLOW
    else
        code_color=$RED
    fi

    echo -e "${CYAN}${ip}${RESET} - [${YELLOW}${date}${RESET}] \"${MAGENTA}${method}${RESET} ${WHITE}${path}${RESET}\" ${code_color}${code}${RESET}"
}

colorize_error_line() {
    local line="$1"
    line=$(echo "$line" | sed -E "s/\[([A-Z][a-z]{2} [A-Z][a-z]{2} [0-9]{2} [0-9:.]+ [0-9]{4})\]/[${YELLOW}\1${RESET}]/")
    line=$(echo "$line" | sed -E "s/\[([a-z_]+:[a-z]+)\]/[${CYAN}\1${RESET}]/g")
    line=$(echo "$line" | sed -E "s/\[([eE]rror)\]/[${RED}\1${RESET}]/g")
    line=$(echo "$line" | sed -E "s/\[([wW]arn)\]/[${YELLOW}\1${RESET}]/g")
    line=$(echo "$line" | sed -E "s/\[([nN]otice)\]/[${GREEN}\1${RESET}]/g")
    line=$(echo "$line" | sed -E "s/\[([iI]nfo)\]/[${BLUE}\1${RESET}]/g")
    echo -e "$line"
}

main() {
    while IFS= read -r line; do
        if is_access_log_line "$line"; then
            colorize_access_line "$line"
        else
            colorize_error_line "$line"
        fi
    done
}

# Utilisation propre sans 'useless cat'
if [ -t 0 ]; then
    [ -z "${1:-}" ] && { echo "Usage: $0 <logfile> ou via pipe"; exit 1; }
    main < "$1"
else
    main
fi
