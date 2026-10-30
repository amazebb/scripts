#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# curl fakes the zip, points and hourly forecast apis with two periods
fc_shims() {
  shim curl 'case "$*" in
  *gridpoints*) for h in 13 14; do printf "{\n\"startTime\": \"2026-10-30T$h:00:00-04:00\",\n\"isDaytime\": true,\n\"temperature\": 70,\n\"probabilityOfPrecipitation\": {\n\"value\": 40\n},\n\"windSpeed\": \"13 mph\",\n\"windDirection\": \"NW\",\n\"shortForecast\": \"Sunny\",\n}\n"; done ;;
  *api.weather.gov*) echo "\"forecastHourly\": \"https://api.weather.gov/gridpoints/X/1,1/forecast/hourly\"" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
esac'
}

# -r gives one row per hour with temp, rain, wind and conditions
fc_rows() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -r 10001 2>&1)
  [[ $out == *"30-Oct 13:00   70°   40%  13 mph NW  Sunny"* && $out == *"30-Oct 14:00"* ]]
}

# -n limits the rows
fc_hours() {
  fc_shims
  [[ $("$BIN/wxforecast" -r -n 1 10001 2>&1 | grep -c '^30-Oct') -eq 1 ]]
}

# no argument uses the ip location
fc_ip() {
  fc_shims
  "$BIN/wxforecast" -r 2>&1 | grep -q '^30-Oct 13:00'
}

# hours outside 1-156 are rejected
fc_bad_hours() {
  fc_shims
  ! "$BIN/wxforecast" -n 0 10001 >/dev/null 2>&1 && ! "$BIN/wxforecast" -n 157 10001 >/dev/null 2>&1
}

# the default draws a dot per hour, an emoji per hour and the hour labels
fc_graph() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" 10001 2>&1 | sed 's/\x1b\[[0-9]*G/|/g')
  [[ $out == *"Temperature (°F)"* && $out == *"●"* && $out == *"|☀️"* && $out == *"13 14"* ]]
}

# -y picks the y metric
fc_graph_metric() {
  fc_shims
  "$BIN/wxforecast" -y rain 10001 2>&1 | grep -q 'Chance of rain (%)' &&
    ! "$BIN/wxforecast" -y x 10001 >/dev/null 2>&1
}

# a station name has no coordinates
fc_needs_coords() {
  fc_shims
  ! "$BIN/wxforecast" KOKX >/dev/null 2>&1
}

t "wxforecast: -r rows for a zip" fc_rows
t "wxforecast: -n limits the raw rows" fc_hours
t "wxforecast: no argument uses ip location (raw)" fc_ip
t "wxforecast: rejects bad hours" fc_bad_hours
t "wxforecast: default chart" fc_graph
t "wxforecast: -y metric" fc_graph_metric
t "wxforecast: rejects a station name" fc_needs_coords

exit $FAILED
