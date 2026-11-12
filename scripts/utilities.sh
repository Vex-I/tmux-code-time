#!/usr/bin/env bash

seconds_to_readable() {
    local total=$1
    local days=$((total/86400))
    local hours=$(( total/3600 ))
    local mins=$(( (total%3600)/60 ))
    local secs=$((total%60))

    if (( days > 0 )); then
        printf "%dh %dm " $hours $mins
    elif (( hours > 0 )); then
        printf "%dh %dm " $hours $mins
    elif (( mins > 0 )); then
        printf "%dm " $mins
    else
        printf "0m "
    fi
}

print_table() {
    printf "\033[1;36mSESSION TIMERS\033[0m\n\n"
    printf '%-20s %12s %12s\n' "NAME" "TIME" "CREATED AT"
    printf '%-20s %12s %12s\n' "--------------------" "--------------" "--------------"

    {
        read -r #skips first line
        while IFS='=;' read -r session seconds timestamp; do
            printf '%-20s %12s %12s \n' "$session" "$(seconds_to_readable "$seconds")" "$(date -d @"$timestamp" +%F+%R)"
        done 
    } < "$1"

    printf "\n\n\033[1;36m<q> Close; <p> Pause/resume; <d> [SESSION] Delete session <c> [NAME] Create session;\033[0m\n\n"
}

launch_timer() {
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    storage="$CURRENT_DIR/scripts/storage.sh"
    timer="$CURRENT_DIR/scripts/timer.sh"
    "$storage" toggle-start 
    nohup "$timer" >/dev/null 2>&1 &
    clear
    print_table <("$storage" list-sessions) 
    echo "Toggled"
}

# TODO: Find a good way to handle edge cases for the following functions.

prompt_delete() {
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    storage="$CURRENT_DIR/scripts/storage.sh"
    timer="$CURRENT_DIR/scripts/timer.sh"
    clear
    $storage delete-session "$1"
    code=$?
    print_table <("$storage" list-sessions) 
    echo "$code"
}

prompt_create() {
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    storage="$CURRENT_DIR/scripts/storage.sh"
    timer="$CURRENT_DIR/scripts/timer.sh"
    clear
    $storage set-session "$1"
    code=$?
    print_table <("$storage" list-sessions) 
    echo "$code"
}
