#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# curl logs its arguments and fakes the apis; ffmpeg makes an empty output; mpv logs that it ran
radar_shims() {
  shim curl 'echo "$@" >>"$TMP/urls"
case "$*" in
  *weather-maps.json*) echo "{\"host\":\"https://tiles.test\",\"radar\":{\"past\":[{\"time\":1,\"path\":\"/v2/radar/abc\"},{\"time\":2,\"path\":\"/v2/radar/def\"}]}}" ;;
  *gridpoints*) printf "{\n\"startTime\": \"2026-10-30T13:00:00-04:00\",\n\"temperature\": 70,\n\"probabilityOfPrecipitation\": {\n\"value\": 40\n},\n\"windSpeed\": \"13 mph\",\n\"windDirection\": \"NW\",\n\"shortForecast\": \"Sunny\",\n}\n" ;;
  *api.weather.gov*) echo "\"radarStation\": \"KABC\", \"forecastHourly\": \"https://api.weather.gov/gridpoints/X/1,1/forecast/hourly\"" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
  *radar.weather.gov*) printf GIF >"$3" ;;
esac'
  shim ffmpeg '[ "$1" = -hide_banner ] && exit 0; echo "$@" >>"$TMP/ffargs"; for a; do o=$a; done; : >"$o"'
  shim mpv 'echo played >>"$TMP/played"'
  rm -f "$TMP/urls"
  unset KITTY_WINDOW_ID TERM_PROGRAM
  export TERM=xterm
}

# a zip resolves to the radar and map tiles around it
radar_zip() {
  radar_shims
  "$BIN/wxradar" 10001 >/dev/null 2>&1
  grep -q 'https://tiles.test/v2/radar/abc/512/7/37/48/6/1_1.png' "$TMP/urls" &&
    grep -q 'tile.openstreetmap.org/10/' "$TMP/urls"
}

# lat,lon works like a zip
radar_latlon() {
  radar_shims
  "$BIN/wxradar" 40.7484,-73.9967 >/dev/null 2>&1
  grep -q '/512/7/37/48/' "$TMP/urls"
}

# no argument uses the ip location
radar_ip() {
  radar_shims
  "$BIN/wxradar" >/dev/null 2>&1
  grep -q '/512/7/37/48/' "$TMP/urls"
}

# a larger radius zooms out
radar_radius_zoom() {
  radar_shims
  "$BIN/wxradar" -r 400 10001 >/dev/null 2>&1
  grep -q '/512/5/' "$TMP/urls" && ! grep -q '/512/7/' "$TMP/urls"
}

# a radius outside 10-400 is rejected
radar_bad_radius() {
  radar_shims
  ! "$BIN/wxradar" -r 5 10001 >/dev/null 2>&1 && ! "$BIN/wxradar" -r x 10001 >/dev/null 2>&1
}

# -n plays the NWS loop of the nearest station
radar_nws() {
  radar_shims
  "$BIN/wxradar" -n 10001 >/dev/null 2>&1
  grep -q '/KABC_loop.gif' "$TMP/urls" && ! grep -q 'weather-maps' "$TMP/urls"
}

# -l fetches one frame, the NWS still image, and does not loop in mpv
radar_latest() {
  radar_shims
  shim mpv 'echo "$@" >"$TMP/played"'
  "$BIN/wxradar" -l northeast >/dev/null 2>&1
  grep -q '/NORTHEAST_0.gif' "$TMP/urls" && [[ $(cat "$TMP/played") != *--loop* ]] || return 1
  rm -f "$TMP/urls"
  "$BIN/wxradar" -l 10001 >/dev/null 2>&1
  grep -q '/v2/radar/def' "$TMP/urls" && ! grep -q '/v2/radar/abc' "$TMP/urls"
}

# -s asks chafa to scale up to the terminal
radar_fill() {
  radar_shims
  shim chafa 'echo "$@" >"$TMP/chafa"'
  TERM=xterm-ghostty "$BIN/wxradar" -s KOKX </dev/null >/dev/null 2>&1
  grep -q -- '--scale max' "$TMP/chafa"
}

# -s leaves room for the -f forecast chart
radar_fill_minus_forecast() {
  radar_shims
  shim chafa 'echo "$@" >"$TMP/chafa"'
  local a b
  TERM=xterm-ghostty "$BIN/wxradar" -s 10001 </dev/null >/dev/null 2>&1
  a=$(sed -n 's/.*--size [0-9]*x\([0-9]*\).*/\1/p' "$TMP/chafa")
  TERM=xterm-ghostty "$BIN/wxradar" -f -s 10001 </dev/null >/dev/null 2>&1
  b=$(sed -n 's/.*--size [0-9]*x\([0-9]*\).*/\1/p' "$TMP/chafa")
  ((a > 0 && b > 0 && b < a))
}

# -F sets the loop frame rate, 1 fps by default
radar_fps() {
  radar_shims
  rm -f "$TMP/ffargs"
  "$BIN/wxradar" 10001 >/dev/null 2>&1
  grep filter_complex "$TMP/ffargs" | grep -q -- '-framerate 1 -i' || return 1
  rm -f "$TMP/ffargs"
  "$BIN/wxradar" -F 2.5 10001 >/dev/null 2>&1
  grep filter_complex "$TMP/ffargs" | grep -q -- '-framerate 2.5 -i' || return 1
  ! "$BIN/wxradar" -F 0 10001 >/dev/null 2>&1 && ! "$BIN/wxradar" -F fast 10001 >/dev/null 2>&1
}

# -f prints the forecast chart before the radar status line
radar_forecast() {
  radar_shims
  local out
  out=$("$BIN/wxradar" -f 10001 2>&1)
  [[ $out == *"Temperature (°F)"* ]] &&
    [[ ${out%%RainViewer*} == *"hourly forecast"* ]]
}

# -f needs coordinates, not a station name
radar_forecast_needs_coords() {
  radar_shims
  ! "$BIN/wxradar" -f KOKX >/dev/null 2>&1
}

# a region name plays the NWS loop, upper-cased
radar_region() {
  radar_shims
  "$BIN/wxradar" northeast >/dev/null 2>&1
  grep -q '/NORTHEAST_loop.gif' "$TMP/urls"
}

# with no kitty terminal the gif goes to mpv
radar_mpv_fallback() {
  radar_shims
  rm -f "$TMP/played"
  "$BIN/wxradar" KOKX >/dev/null 2>&1
  [[ -s $TMP/played ]]
}

# ghostty draws the gif with chafa, not mpv
radar_chafa() {
  radar_shims
  shim chafa 'echo chafa >>"$TMP/icat"'
  rm -f "$TMP/played" "$TMP/icat"
  TERM=xterm-ghostty "$BIN/wxradar" KOKX </dev/null >/dev/null 2>&1
  [[ -s $TMP/icat && ! -e $TMP/played ]]
}

# without chafa, ghostty uses kitten
radar_ghostty() {
  radar_shims
  shim kitten 'echo icat >>"$TMP/icat"'
  rm -f "$TMP/played" "$TMP/icat" "$TMP/shim/chafa"
  PATH="$TMP/shim:/usr/bin:/bin" TERM=xterm-ghostty "$BASH" "$BIN/wxradar" KOKX </dev/null >/dev/null 2>&1
  [[ -s $TMP/icat && ! -e $TMP/played ]]
}

# extra arguments are rejected
radar_extra_arg() {
  radar_shims
  ! "$BIN/wxradar" a b >/dev/null 2>&1
}

t "wxradar: zip resolves to tiles" radar_zip
t "wxradar: lat,lon" radar_latlon
t "wxradar: no argument uses ip location" radar_ip
t "wxradar: radius sets zoom" radar_radius_zoom
t "wxradar: rejects bad radius" radar_bad_radius
t "wxradar: -n uses the nearest NWS station" radar_nws
t "wxradar: -l shows the latest only" radar_latest
t "wxradar: -F frame rate" radar_fps
t "wxradar: -s fills the terminal" radar_fill
t "wxradar: -s leaves room for -f" radar_fill_minus_forecast
t "wxradar: -f prints the forecast above the radar" radar_forecast
t "wxradar: -f rejects a station name" radar_forecast_needs_coords
t "wxradar: region name" radar_region
t "wxradar: mpv fallback" radar_mpv_fallback
t "wxradar: ghostty uses chafa" radar_chafa
t "wxradar: ghostty falls back to kitten" radar_ghostty
t "wxradar: rejects extra argument" radar_extra_arg

exit $FAILED
