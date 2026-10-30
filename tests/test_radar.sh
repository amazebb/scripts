#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# curl logs its arguments and fakes the apis; ffmpeg makes an empty output; mpv logs that it ran
radar_shims() {
  shim curl 'echo "$@" >>"$TMP/urls"
case "$*" in
  *weather-maps.json*) echo "{\"host\":\"https://tiles.test\",\"radar\":{\"past\":[{\"time\":1,\"path\":\"/v2/radar/abc\"},{\"time\":2,\"path\":\"/v2/radar/def\"}]}}" ;;
  *api.weather.gov*) echo "\"radarStation\": \"KABC\"" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
  *radar.weather.gov*) printf GIF >"$3" ;;
esac'
  shim ffmpeg 'for a; do o=$a; done; : >"$o"'
  shim mpv 'echo played >>"$TMP/played"'
  rm -f "$TMP/urls"
  unset KITTY_WINDOW_ID TERM_PROGRAM
  export TERM=xterm
}

# a zip resolves to the radar and map tiles around it
radar_zip() {
  radar_shims
  "$BIN/radar" 10001 >/dev/null 2>&1
  grep -q 'https://tiles.test/v2/radar/abc/512/7/37/48/6/1_1.png' "$TMP/urls" &&
    grep -q 'tile.openstreetmap.org/10/' "$TMP/urls"
}

# lat,lon works like a zip
radar_latlon() {
  radar_shims
  "$BIN/radar" 40.7484,-73.9967 >/dev/null 2>&1
  grep -q '/512/7/37/48/' "$TMP/urls"
}

# no argument uses the ip location
radar_ip() {
  radar_shims
  "$BIN/radar" >/dev/null 2>&1
  grep -q '/512/7/37/48/' "$TMP/urls"
}

# a larger radius zooms out
radar_radius_zoom() {
  radar_shims
  "$BIN/radar" -r 400 10001 >/dev/null 2>&1
  grep -q '/512/5/' "$TMP/urls" && ! grep -q '/512/7/' "$TMP/urls"
}

# a radius outside 10-400 is rejected
radar_bad_radius() {
  radar_shims
  ! "$BIN/radar" -r 5 10001 >/dev/null 2>&1 && ! "$BIN/radar" -r x 10001 >/dev/null 2>&1
}

# -n plays the NWS loop of the nearest station
radar_nws() {
  radar_shims
  "$BIN/radar" -n 10001 >/dev/null 2>&1
  grep -q '/KABC_loop.gif' "$TMP/urls" && ! grep -q 'weather-maps' "$TMP/urls"
}

# -l fetches one frame, the NWS still image, and does not loop in mpv
radar_latest() {
  radar_shims
  shim mpv 'echo "$@" >"$TMP/played"'
  "$BIN/radar" -l northeast >/dev/null 2>&1
  grep -q '/NORTHEAST_0.gif' "$TMP/urls" && [[ $(cat "$TMP/played") != *--loop* ]] || return 1
  rm -f "$TMP/urls"
  "$BIN/radar" -l 10001 >/dev/null 2>&1
  grep -q '/v2/radar/def' "$TMP/urls" && ! grep -q '/v2/radar/abc' "$TMP/urls"
}

# -f asks chafa to scale up to the terminal
radar_fill() {
  radar_shims
  shim chafa 'echo "$@" >"$TMP/chafa"'
  TERM=xterm-ghostty "$BIN/radar" -f KOKX </dev/null >/dev/null 2>&1
  grep -q -- '--scale max' "$TMP/chafa"
}

# a region name plays the NWS loop, upper-cased
radar_region() {
  radar_shims
  "$BIN/radar" northeast >/dev/null 2>&1
  grep -q '/NORTHEAST_loop.gif' "$TMP/urls"
}

# with no kitty terminal the gif goes to mpv
radar_mpv_fallback() {
  radar_shims
  rm -f "$TMP/played"
  "$BIN/radar" KOKX >/dev/null 2>&1
  [[ -s $TMP/played ]]
}

# ghostty draws the gif with chafa, not mpv
radar_chafa() {
  radar_shims
  shim chafa 'echo chafa >>"$TMP/icat"'
  rm -f "$TMP/played" "$TMP/icat"
  TERM=xterm-ghostty "$BIN/radar" KOKX </dev/null >/dev/null 2>&1
  [[ -s $TMP/icat && ! -e $TMP/played ]]
}

# without chafa, ghostty uses kitten
radar_ghostty() {
  radar_shims
  shim kitten 'echo icat >>"$TMP/icat"'
  rm -f "$TMP/played" "$TMP/icat" "$TMP/shim/chafa"
  PATH="$TMP/shim:/usr/bin:/bin" TERM=xterm-ghostty "$BASH" "$BIN/radar" KOKX </dev/null >/dev/null 2>&1
  [[ -s $TMP/icat && ! -e $TMP/played ]]
}

# extra arguments are rejected
radar_extra_arg() {
  radar_shims
  ! "$BIN/radar" a b >/dev/null 2>&1
}

t "radar: zip resolves to tiles" radar_zip
t "radar: lat,lon" radar_latlon
t "radar: no argument uses ip location" radar_ip
t "radar: radius sets zoom" radar_radius_zoom
t "radar: rejects bad radius" radar_bad_radius
t "radar: -n uses the nearest NWS station" radar_nws
t "radar: -l shows the latest only" radar_latest
t "radar: -f fills the terminal" radar_fill
t "radar: region name" radar_region
t "radar: mpv fallback" radar_mpv_fallback
t "radar: ghostty uses chafa" radar_chafa
t "radar: ghostty falls back to kitten" radar_ghostty
t "radar: rejects extra argument" radar_extra_arg

exit $FAILED
