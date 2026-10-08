#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# prints "proceeded" only if Q returns control to the caller
ask_q() { echo "$1" | bash -c "source '$BIN/common.sh'; Q go; echo proceeded" 2>&1; }

nay_aborts() { [[ $(ask_q nay) != *proceeded* ]]; }
yes_proceeds() { [[ $(ask_q y) == *proceeded* ]]; }

t "Q aborts on a reply that merely contains y" nay_aborts
t "Q proceeds on y" yes_proceeds
exit $FAILED
