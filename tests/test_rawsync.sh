#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"

JPG=/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0h//2Q==

# $1=dir, $2=extra exiftool args
make_src() {
  mkdir -p "$1"
  base64 -d <<<"$JPG" >"$1/p.jpg"
  exiftool -q -overwrite_original -DateTimeOriginal='2025:01:02 03:04:05' "${@:2}" "$1/p.jpg"
}

links() { find "$1" -type l | wc -l | tr -d ' '; }

# files with no OffsetTime tags still get a symlink
no_offset_still_linked() {
  make_src "$TMP/r1"
  echo y | "$BIN/rawsync" -e '*.jpg' "$TMP/r1" >/dev/null 2>&1
  [[ $(links "$TMP/r1") == 1 ]]
}

# a second run must not add _1 duplicates
rerun_is_idempotent() {
  make_src "$TMP/r2" -OffsetTimeOriginal=-07:00 -OffsetTime=-07:00
  echo y | "$BIN/rawsync" -e '*.jpg' "$TMP/r2" >/dev/null 2>&1
  echo y | "$BIN/rawsync" -e '*.jpg' "$TMP/r2" >/dev/null 2>&1
  [[ $(links "$TMP/r2") == 1 ]]
}

if need rawsync exiftool gdate grealpath base64; then
  t "rawsync links files without offset tags" no_offset_still_linked
  t "rawsync rerun adds no duplicate symlinks" rerun_is_idempotent
fi
exit $FAILED
