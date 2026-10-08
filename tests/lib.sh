#!/usr/bin/env bash
# shellcheck disable=SC2034
# Tiny test harness: t NAME CMD... passes when CMD exits 0

BIN=${BIN:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)}
TMP=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$TMP"' EXIT
FAILED=0

ok() { printf 'ok    %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; FAILED=1; }
skip() { printf 'skip  %s (needs %s)\n' "$1" "$2"; }

# need NAME CMD...: print a skip and return 1 when a command is missing
need() {
  local n=$1 c
  shift
  for c; do command -v "$c" >/dev/null || { skip "$n" "$c"; return 1; }; done
}

# darwin NAME: print a skip and return 1 anywhere but macOS
darwin() { [[ $(uname) == Darwin ]] || { skip "$1" macOS; return 1; }; }

t() {
  local n=$1
  shift
  if "$@"; then ok "$n"; else bad "$n"; fi
}

# shim NAME BODY: put an executable NAME on PATH that runs BODY
shim() {
  mkdir -p "$TMP/shim"
  printf '#!/bin/sh\n%s\n' "$2" >"$TMP/shim/$1"
  chmod +x "$TMP/shim/$1"
  PATH="$TMP/shim:$PATH"
}
