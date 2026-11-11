#!/usr/bin/env bash

# Wrapper around the database to prevent race conditions
# Honestly, might as well use SQLite, but I want to learn a little.

path="$0"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
storage_file="$CURRENT_DIR/"tmux-timer.txt
LOG_FILE="$CURRENT_DIR/"tmux-code-time-debug.log
lock_file="$storage_file.lock"

init() {
    if [[ ! -f "$storage_file" ]]; then
        printf '0\n' > "$storage_file"
    fi
}

# Prevents multiple processes from corrupting the data using flock, then unlocks
# it when the process has finished.
with_lock() {
    exec 9>>"$lock_file"
    flock -x 9

    "$@"
    local status=$?

    flock -u 9
    return "$status"
}

# Writes into a temporary file first, then writes it in place. This is done to
# ensure that we write only complete data instead of incomplete ones.
atomic_write() {
    local tmp

    tmp=$(mktemp "${storage_file}.tmp.XXXXXX") || return 1

    if ! "$@" > "$tmp"; then
        rm -f "$tmp"
        return 1
    fi

    chmod --reference="$storage_file" "$tmp" 2>/dev/null || true

    if ! mv -f "$tmp" "$storage_file"; then
        rm -f "$tmp"
        return 1
    fi
}

_get_start() {
    IFS= read -r start < "$storage_file"
    printf '%s\n' "$start"
}

_set_start() {
    local value="$1"

    [[ "$value" =~ ^[01]$ ]] || return 1

    _write_start "$value"
}

_write_start() {
    local value="$1"

    atomic_write _replace_start "$value"
}

_replace_start() {
    local value="$1"

    {
        printf '%s\n' "$value"
        tail -n +2 "$storage_file"
    }
}

_toggle_start() {
    local start
    start=$(_get_start) || return 1

    [[ "$start" =~ ^[01]$ ]] || return 1

    start=$((1 - start))
    _write_start "$start" || return 1

    printf '%s\n' "$start"
}

_get_session() {
    local session="$1"

    awk -F '[=;]' -v name="$session" '
        $1 == name {
            print $2
            found = 1
            exit
        }
        END {
            if (!found) exit 1
        }
    ' "$storage_file"
}

_set_session() {
    local session="$1"
    local seconds="$2"
    local timestamp="${3:-$EPOCHSECONDS}"

    [[ -n "$session" && "$session" != *[=[:space:]\;]* ]] || return 1
    [[ "$seconds" =~ ^[0-9]+$ ]] || return 1
    [[ "$timestamp" =~ ^[0-9]+$ ]] || return 1

    atomic_write _replace_session "$session" "$seconds" "$timestamp"
}

_replace_session() {
    local session="$1"
    local seconds="$2"
    local timestamp="$3"

    awk -v name="$session" \
        -v seconds="$seconds" \
        -v timestamp="$timestamp" '
        BEGIN {
            prefix = name "="
        }

        NR == 1 {
            print
            next
        }

        index($0, prefix) == 1 {
            semi = index($0, ";")

            if (semi) {
                suffix = substr($0, semi)
            } else {
                suffix = ";" timestamp
            }

            print prefix seconds suffix
            found = 1
            next
        }

        {
            print
        }

        END {
            if (!found) {
                print prefix seconds ";" timestamp
            }
        }
    ' "$storage_file"
}

_delete_session() {
    local session="$1"

    atomic_write _remove_session "$session"
}

_remove_session() {
    local session="$1"

    awk -v name="$session" '
        NR == 1 {
            print
            next
        }

        {
            prefix = name "="

            if (index($0, prefix) != 1) {
                print
            }
        }
    ' "$storage_file"
}

_list_sessions() {
    tail -n +1 "$storage_file"
}

init

# Maybe increment time in here?

case "$1" in

    get-start)
        with_lock _get_start
        ;;

    set-start)
        with_lock _set_start "$2"
        ;;

    toggle-start)
        with_lock _toggle_start
        ;;

    get-session)
        with_lock _get_session "$2"
        ;;

    set-session)
        with_lock _set_session "$2" "$3" "$4"
        ;;

    delete-session)
        with_lock _delete_session "$2"
        ;;

    list-sessions)
        with_lock _list_sessions
        ;;

    *)
        echo "Usage: $0 {get-start|set-start|toggle-start|get-session|set-session|delete-session|list-sessions}"
        exit 1
        ;;

esac

