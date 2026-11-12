#!/usr/bin/env bash

#NCurses would be overkill, unfortunately for me.

path="$0"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "$CURRENT_DIR/scripts/utilities.sh"
timer="$CURRENT_DIR/scripts/timer.sh"

storage="$CURRENT_DIR/scripts/storage.sh"

clear
print_table <("$storage" list-sessions)



# Main loop
while read -rsn1 key; do
    [[ "$key" == "q" ]] && exit

    if [[ "$key" == "p" ]]; then 
        launch_timer
    fi

    if [[ "$key" == "d" ]]; then 
        read -rp "DELETE:" opt
        prompt_delete "$opt"
    fi

    if [[ "$key" == "c" ]]; then 
        read -rp "CREATE:" opt
        prompt_create "$opt"
    fi
done
