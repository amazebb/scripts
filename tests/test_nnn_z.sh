#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

pipe="$TMP/pipe"
mkfifo "$pipe"
shim zoxide 'case $2 in -i) echo /picked ;; *) shift 2; echo "/q/$*" ;; esac'

run() { NNN_PIPE=$pipe "$BIN/nnn-z" "$@" & cat "$pipe"; wait; }
run_stdin() { printf '%s\n' "$1" | { NNN_PIPE=$pipe "$BIN/nnn-z" 2>/dev/null & cat "$pipe"; wait; }; }

t "query words become a zoxide query" [ "$(run my path)" = "0c/q/my path" ]
t "empty prompt opens the interactive picker" [ "$(run_stdin '')" = "0c/picked" ]
t "prompt text is used as the query" [ "$(run_stdin 'foo bar')" = "0c/q/foo bar" ]
t "refuses to run outside nnn" bash -c '! env -u NNN_PIPE "$0/nnn-z" 2>/dev/null' "$BIN"
exit $FAILED
