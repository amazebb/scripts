#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

run_backup() {
  local d=$TMP/bk
  mkdir -p "$d/bundle" "$d/data"
  echo x >"$d/data/f"
  : >"$TMP/calls"
  printf -- '-n\n' | "$BIN/data-backup" -s "$d/bundle" -m "$d/mnt" "$d/data" >/dev/null 2>&1
}

# a password that looks like an echo flag must reach hdiutil intact
password_intact() { [[ $(<"$TMP/pw") == -n ]]; }

# a failed unmount must not leave gitea stopped
gitea_restarted() { grep -qx start "$TMP/calls"; }

if darwin data-backup; then
  shim hdiutil $'case $1 in\n  attach)\n    cat >"$TMP/pw"\n    while [ $# -gt 0 ]; do [ "$1" = -mountpoint ] && mkdir -p "$2"; shift; done ;;\n  detach) exit 1 ;;\nesac'
  shim gitea-cli 'echo "$1" >>"$TMP/calls"'
  shim 7z 'touch "$6"'
  shim rsync 'exit 0'
  run_backup
  t "data-backup passes a dash-leading password intact" password_intact
  t "data-backup restarts gitea after an unmount failure" gitea_restarted
fi
exit $FAILED
