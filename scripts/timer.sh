#!/usr/bin/env bash

path="$0"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
LOG_FILE="$CURRENT_DIR"/tmux-code-time-debug.log
storage="$CURRENT_DIR"/scripts/storage.sh

source "$CURRENT_DIR/scripts/utilities.sh"


if [[ -n "$TMUX" && "$("$storage" get-start)" == "1" ]]; then
    ## TODO: Clear logs every so often, to avoid clutter.
    echo "[$(date)] STARTING TIMER for session $(tmux display-message -p '#S')" >> "$LOG_FILE"

    # Session at the start
    visible_session_name=$(tmux display-message -p '#S')

    # Session currently
    session_name=$(tmux display -p '#{session_name}')
    INITIAL_SECONDS=$("$storage" get-session "$session_name" | cut -d';' -f1)
    SECONDS="$INITIAL_SECONDS"

    if [[ -z "$SECONDS" ]]; then
        SECONDS=0
    fi

    increment=0

    # There might be a better way to do this.
    while [[ "$visible_session_name" == "$(tmux display-message -p '#S')" && "$("$storage" get-start)" == "1" ]]; do
        ((increment++))

        sleep 1

        [[ "$increment" == "60" ]] && increment=0 && $storage set-session $session_name $SECONDS

    done

    on_display="$(seconds_to_readable $((SECONDS-INITIAL_SECONDS)))"
    echo "[$(date)] STOPPING TIMER for session $session_name, was on display for $on_display" >> "$LOG_FILE"
fi
