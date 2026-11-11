#!/usr/bin/env bash

#NCurses would be overkill, unfortunately for me.

path="$0"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
storage_file="$CURRENT_DIR"/tmux-timer.txt

source "$CURRENT_DIR/scripts/utilities.sh"

clear

printf "\033[1;36mSESSION TIMERS\033[0m\n\n"
printf '%-20s %12s %12s\n' "NAME" "TIME" "CREATED AT"
printf '%-20s %12s %12s\n' "--------------------" "--------------" "--------------"

while IFS='=;' read -r session seconds timestamp; do
    printf '%-20s %12s %12s \n' "$session" "$(seconds_to_readable "$seconds")" "$(date -d @"$timestamp" +%F+%R)"
done < "$storage_file"

printf "\n\n\033[1;36m<q> Close; <p> Pause/resume; <d [SESSION]> Delete session;\033[0h\n\n"

# Main loop
while read -rsn1 key; do
    [[ "$key" == "q" ]] && break
    [[ "$key" == "a" ]] && echo "Nein"
done
