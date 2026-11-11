#!/usr/bin/env bash

path="$0"
CURRENT_DIR="${path%/scripts/*}/"
storage="$CURRENT_DIR/scripts/storage.sh"
source "$CURRENT_DIR/scripts/utilities.sh"

session_name=$(tmux display -p '#{session_name}')
seconds_to_readable $("$storage" get-session "$session_name")
[[ "$("$storage" get-start)" == "0" ]] && printf "%s" "PAUSED "
