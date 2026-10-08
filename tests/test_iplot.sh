#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# stdin is data: a label of "e" ends gnuplot's inline block, and later lines run as commands
stdin_cannot_inject() {
  printf 'e 1\n`touch${IFS}%s`\n' "$TMP/pwn" | "$BIN/iplot" >/dev/null 2>&1
  [[ ! -e $TMP/pwn ]]
}

# labels starting with "e" must plot, not break the data block
e_labels_plot() {
  ! printf 'east 3\nwest 4\n' | "$BIN/iplot" 2>&1 | grep -qi 'invalid command'
}

if need iplot gnuplot; then
  shim kitten 'cat >/dev/null'
  t "iplot stdin cannot inject commands" stdin_cannot_inject
  t "iplot accepts labels starting with e" e_labels_plot
fi
exit $FAILED
