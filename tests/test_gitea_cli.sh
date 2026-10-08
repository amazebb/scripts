#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# pkill only signals, so stop must wait until gitea has really exited
stop_waits_for_exit() {
  touch "$TMP/alive"
  "$BIN/gitea-cli" stop >/dev/null 2>&1
  [[ ! -e $TMP/alive ]]
}

# start must give up when gitea dies instead of polling forever
start_gives_up_when_gitea_dies() {
  timeout 5 "$BIN/gitea-cli" start >/dev/null 2>&1
  (($? != 124))
}

if darwin gitea-cli && need gitea-cli timeout; then
  shim pgrep '[ -e "$TMP/alive" ]'
  shim pkill '(sleep 1; rm -f "$TMP/alive") >/dev/null 2>&1 &'
  t "gitea-cli stop waits for gitea to exit" stop_waits_for_exit

  # not running, curl never answers, gitea exits at once
  shim pgrep 'exit 1'
  shim curl 'exit 1'
  shim gitea 'exit 1'
  shim open 'exit 0'
  t "gitea-cli start gives up when gitea dies" start_gives_up_when_gitea_dies
fi
exit $FAILED
