#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"

# an option missing its value must exit, not loop forever
missing_value_exits() {
  timeout 3 "$BIN/netmon" -o >/dev/null 2>&1
  (($? != 124))
}

if need netmon timeout; then
  t "netmon -o without a value exits" missing_value_exits
fi
exit $FAILED
