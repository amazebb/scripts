#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# dedupe's preview pass must not create symlinks before the user confirms
preview_is_inert() {
  local d=$TMP/prev
  mkdir -p "$d/pref" "$d/other"
  echo hi >"$d/pref/a"
  echo hi >"$d/other/b"
  printf 'H\t%s\t3\nH\t%s\t3\n' "$d/pref/a" "$d/other/b" >"$d/h.tsv"
  echo n | "$BIN/dedupe" -f "$d/h.tsv" -s "$d/pref" >/dev/null 2>&1
  [[ ! -L $d/other/b ]]
}

# filenames are data: shell metacharacters must not run
no_injection() {
  local d=$TMP/inj name
  mkdir -p "$d/pref" "$d/other"
  name="q'\$(touch pwn)"
  echo x >"$d/pref/a"
  echo x >"$d/other/$name"
  printf 'H\t%s\t2\nH\t%s\t2\n' "$d/pref/a" "$d/other/$name" >"$d/h.tsv"
  (cd "$d" && gawk -F'\t' -v PREF_DUPE_DIR="$d/pref" -v DRY_RUN=y \
    -f "$BIN/process-dupes.awk" h.tsv >/dev/null 2>&1)
  [[ ! -e $d/pwn && -L $d/other/$name ]]
}

if need dedupe gawk; then
  shim awk 'exec gawk "$@"'
  t "dedupe preview creates no symlinks" preview_is_inert
  t "process-dupes.awk quotes filenames" no_injection
fi
exit $FAILED
