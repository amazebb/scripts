#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# -r takes a value that starts with a dash
r_accepts_dash_value() { [[ $(<"$TMP/prerg") == *--pre-glob=x* ]]; }

# the fzf query files live in a private dir that is removed on exit
tmp_dir_is_private_and_removed() {
  local d
  d=$(<"$TMP/fztmp")
  [[ -n $d && ! -d $d ]]
}

shim fzf 'printf "%s" "$_FZ_PRE_RG_STR" >"$TMP/prerg"; printf "%s" "$_FZ_TMP" >"$TMP/fztmp"'
"$BIN/fz" -r --pre-glob=x pattern "$TMP" >/dev/null 2>&1
t "fz -r accepts a value starting with a dash" r_accepts_dash_value
t "fz uses a private temp dir and removes it" tmp_dir_is_private_and_removed
exit $FAILED
