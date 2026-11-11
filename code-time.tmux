#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux set-option -g @project_time "#($CURRENT_DIR/scripts/project_time.sh)"

tmux bind T display-popup -E -w 50% -h 80% "$CURRENT_DIR/scripts/control_panel.sh" 

tmux set-hook -g client-session-changed "run-shell '$CURRENT_DIR/scripts/timer.sh'"
tmux set-hook -g session-created "run-shell '$CURRENT_DIR/scripts/timer.sh'"
