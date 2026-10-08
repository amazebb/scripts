#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2016
source "$(dirname "$0")/lib.sh"

# disk-useage -e takes several patterns and excludes each
du_excludes_all() {
  local d=$TMP/du i
  for i in a b c; do
    mkdir -p "$d/$i"
    head -c 1000000 /dev/zero >"$d/$i/f"
  done
  local out
  out=$("$BIN/disk-useage" -d 1 -e a b -- "$d" 2>&1)
  [[ $out == *"/c"* ]] && ! grep -qE '/(a|b)$' <<<"$out"
}

# the -d value must not leak onto stdout
du_no_stray_value() {
  mkdir -p "$TMP/du2"
  [[ $("$BIN/disk-useage" -d 2 -- "$TMP/du2" 2>&1 | head -1) != 2 ]]
}

# a file merely named like zstd output is searched as plain text
pre_rg_uses_content_type() {
  echo plain >"$TMP/x-Zstandard.txt"
  [[ $(echo plain | "$BIN/_pre-rg" "$TMP/x-Zstandard.txt" 2>&1) == plain ]]
}

# the link name is a literal, not a glob
fix_symlinks_literal_name() {
  local d=$TMP/fs
  mkdir -p "$d/src" "$d/tgt"
  echo z >"$d/src/a1.txt"
  ln -s /nonexistent/'a[1].txt' "$d/tgt/a[1].txt"
  [[ $("$BIN/fix-symlinks" -n "$d/src" "$d/tgt" </dev/null 2>&1) == *"[no match]"* ]]
}

# closed stdin must end the loop, not spin
ghostty_theme_eof_exits() {
  timeout 3 "$BIN/ghostty-theme" </dev/null >/dev/null 2>&1
  (($? != 124))
}

# only a .awk suffix marks an awk script, not a .awk-named parent dir
list_scripts_awk_suffix() {
  local d=$TMP/.awk-tools/bin
  mkdir -p "$d"
  printf '#!/usr/bin/env bash\n# demo\n' >"$d/demo"
  local out
  out=$("$BIN/list-scripts" "$d" 2>&1)
  [[ $out == *bash* && $out != *awk* ]]
}

t "disk-useage -e excludes every pattern" du_excludes_all
t "disk-useage -d prints no stray value" du_no_stray_value
t "_pre-rg ignores the filename when sniffing" pre_rg_uses_content_type
t "fix-symlinks matches names literally" fix_symlinks_literal_name
if need ghostty-theme timeout; then
  shim ghostty 'echo Foo'
  t "ghostty-theme exits on stdin EOF" ghostty_theme_eof_exits
fi
# list-scripts uses BSD find -depth 1
if darwin list-scripts && need list-scripts column; then
  t "list-scripts matches .awk only as a suffix" list_scripts_awk_suffix
fi
exit $FAILED
