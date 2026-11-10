#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Access the sessiom time within TMUX
tmux set-option -g @project_time "#($CURRENT_DIR/scripts/project_time.sh)"

tmux bind T display-popup -E -w 50% -h 50% "$CURRENT_DIR/scripts/print_table.sh" 

tmux set-hook -g client-session-changed "run-shell '$CURRENT_DIR/scripts/start_timer.sh'"
tmux set-hook -g session-created "run-shell '$CURRENT_DIR/scripts/start_timer.sh'"
