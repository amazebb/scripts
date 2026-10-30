#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# curl fakes the zip, points and hourly forecast apis with two periods
fc_shims() {
  shim curl 'case "$*" in
  *alerts/active*) [ -e "$TMP/alert" ] && printf "{\"features\": [\n{\n\"properties\": {\n                \"areaDesc\": \"X\",\n                \"severity\": \"Severe\",\n                \"event\": \"Flood Watch\",\n                \"ends\": \"2026-10-30T20:00:00-04:00\",\n}}]}" || echo "{\"features\": []}" ;;
  *forecast/hourly*) printf "\"generatedAt\": \"2026-10-30T18:04:24+00:00\",\n\"updateTime\": \"2026-10-30T16:14:57+00:00\",\n"; for h in 13 14; do printf "{\n\"startTime\": \"2026-10-30T$h:00:00-04:00\",\n\"isDaytime\": true,\n\"temperature\": 70,\n\"probabilityOfPrecipitation\": {\n\"value\": 40\n},\n\"dewpoint\": {\n\"value\": 10\n},\n\"relativeHumidity\": {\n\"value\": 45\n},\n\"windSpeed\": \"13 mph\",\n\"windDirection\": \"NW\",\n\"shortForecast\": \"Sunny\",\n}\n"; done ;;
  */forecast) printf "\"generatedAt\": \"2026-10-30T18:04:24+00:00\",\n"; for d in true false; do printf "{\n\"startTime\": \"2026-10-30T0$([ $d = true ] && echo 6 || echo 8):00:00-04:00\",\n\"isDaytime\": $d,\n\"temperature\": $([ $d = true ] && echo 70 || echo 50),\n\"probabilityOfPrecipitation\": {\n\"value\": $([ $d = true ] && echo 20 || echo 40)\n},\n\"windSpeed\": \"5 to 10 mph\",\n\"windDirection\": \"NW\",\n\"shortForecast\": \"$([ $d = true ] && echo Sunny || echo Mostly Clear)\",\n}\n"; done ;;
  *gridpoints*) printf "        \"quantitativePrecipitation\": {\n\"values\": [\n{\n\"validTime\": \"2026-10-30T17:00:00+00:00/PT2H\",\n\"value\": 5.08\n}\n]\n},\n        \"windGust\": {\n\"values\": [\n{\n\"validTime\": \"2026-10-30T17:00:00+00:00/PT2H\",\n\"value\": 32.1869\n}\n]\n},\n        \"skyCover\": {\n\"values\": [\n{\n\"validTime\": \"2026-10-30T17:00:00+00:00/PT2H\",\n\"value\": 30\n}\n]\n},\n        \"apparentTemperature\": {\n\"values\": [\n{\n\"validTime\": \"2026-10-30T17:00:00+00:00/PT2H\",\n\"value\": 20\n}\n]\n},\n        \"snowfallAmount\": {\n" ;;
  *api.weather.gov*) printf "\"forecastHourly\": \"https://api.weather.gov/gridpoints/X/1,1/forecast/hourly\",\n\"forecastGridData\": \"https://api.weather.gov/gridpoints/X/1,1\",\n\"forecast\": \"https://api.weather.gov/gridpoints/X/1,1/forecast\",\n" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
esac'
}

# -r gives one row per hour with temp, rain, wind and conditions
fc_rows() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -r 10001 2>&1)
  [[ $out == *"30-Oct 13:00  70°F  68°F  50°F  45%  30%  40%     0.10   20  13 mph NW   Sunny"* && $out == *"30-Oct 14:00"* ]]
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

# the default chart is temperature and expected rainfall, -y picks one metric alone
fc_default_metrics() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $out == *"● Temperature (°F)   ◆ Expected rainfall (in/hr)"* ]] || return 1
  out=$("$BIN/wxforecast" -y temp 10001 2>&1)
  [[ $out == *"Temperature (°F)"* && $out != *"Expected rainfall"* ]]
}

# the default draws a dot per hour, an emoji per hour and the hour labels
fc_graph() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" 10001 2>&1 | sed 's/\x1b\[[0-9]*G/|/g')
  [[ $out == *"Temperature (°F)"* && $out == *"●"* && $out == *"|☀️"* && $out == *"13 14"* ]]
}

# the status line shows when the forecast was updated and generated
fc_stamps() {
  fc_shims
  local out
  out=$(TZ=UTC "$BIN/wxforecast" 10001 2>&1 | head -1)
  [[ $out == *"updated 30-Oct-2026 16:14, generated 30-Oct-2026 18:04"* ]]
}

# -d -r prints a row per day with high, low, rain and wind
fc_daily() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -d -r 10001 2>&1 | sed 's/\x1b\[[0-9]*G/|/g')
  [[ $out == *"daily forecast (NWS)"* && $out == *"|Fri 30-Oct   70°F  50°F   40%  5 to 10 mph NW   Sunny"* ]] || return 1
  out=$("$BIN/wxforecast" -d -r -u si 10001 2>&1)
  [[ $out == *"21°C"*"10°C"*"8 to 16 km/h NW"* ]] &&
    ! "$BIN/wxforecast" -d -n 8 10001 >/dev/null 2>&1
}

# an active alert is printed first, -A hides it
fc_alert_banner() {
  fc_shims
  rm -f "$TMP/alert"
  [[ $("$BIN/wxforecast" -r 10001 2>&1 | head -1) != *"Flood Watch"* ]] || return 1
  touch "$TMP/alert"
  local out
  out=$("$BIN/wxforecast" -r 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ ${out%%$'\n'*} == "⚠ Flood Watch (Severe)"* ]] || return 1
  [[ $("$BIN/wxforecast" -A -r 10001 2>&1 | head -1) != *"Flood Watch"* ]]
}

# -d draws the high and low temperature with the chance of rain on a right axis
fc_daily_chart() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -d 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g; s/\x1b\[[0-9]*G/|/g')
  [[ $out == *"▲ High  ▼ Low (°F)   ◆ Chance of rain (%)"* && $out == *"70 │"*"▲"* && $out == *"50 │"*"▼"* ]] || return 1
  [[ $out == *"|Fri"* && $out == *"|30-Oct"* && $out == *"│ 100"* && $out == *"◆"* ]]
}

# -u si converts to C, km/h and mm
fc_si() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -r -u si 10001 2>&1)
  [[ $out == *"AMT(mm)"* && $out == *"30-Oct 13:00  21°C  20°C  10°C  45%  30%  40%      2.5   32  21 km/h NW"* ]] &&
    ! "$BIN/wxforecast" -u x 10001 >/dev/null 2>&1
}

# -y hum and -y dew chart the forecast humidity and dew point
fc_hum_dew() {
  fc_shims
  "$BIN/wxforecast" -y hum 10001 2>&1 | grep -q 'Relative humidity (%)' &&
    "$BIN/wxforecast" -y dew 10001 2>&1 | grep -q 'Dew point (°F)'
}

# -y gust, cloud and feels chart the grid data
fc_grid_metrics() {
  fc_shims
  "$BIN/wxforecast" -y gust 10001 2>&1 | grep -q 'Wind gust (mph)' &&
    "$BIN/wxforecast" -y cloud 10001 2>&1 | grep -q 'Cloud cover (%)' &&
    "$BIN/wxforecast" -y feels 10001 2>&1 | grep -q 'Feels like (°F)'
}

# -y with two metrics adds a right axis with its own marker, and wind gets direction arrows
fc_second_axis() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -y temp qpf 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $out == *"● Temperature (°F)   ◆ Expected rainfall (in/hr)"* && $out == *"◆"*"│ 0.10"* ]] || return 1
  out=$("$BIN/wxforecast" -y temp wind 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $out == *"↘"* ]] && ! "$BIN/wxforecast" -y temp x 10001 >/dev/null 2>&1
}

# -y qpf charts the expected rainfall spread over the grid block
fc_qpf() {
  fc_shims
  local out
  out=$("$BIN/wxforecast" -y qpf 10001 2>&1)
  [[ $out == *"Expected rainfall (in/hr)"* && $out == *"0.10 │ ●  ●"* ]]
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
t "wxforecast: default temp and qpf" fc_default_metrics
t "wxforecast: default chart" fc_graph
t "wxforecast: status line shows update times" fc_stamps
t "wxforecast: -d -r daily rows" fc_daily
t "wxforecast: -d daily chart" fc_daily_chart
t "wxforecast: alert banner and -A" fc_alert_banner
t "wxforecast: -u si" fc_si
t "wxforecast: -y hum and dew" fc_hum_dew
t "wxforecast: -y gust, cloud and feels" fc_grid_metrics
t "wxforecast: -y with a second metric" fc_second_axis
t "wxforecast: -y qpf" fc_qpf
t "wxforecast: -y metric" fc_graph_metric
t "wxforecast: rejects a station name" fc_needs_coords

exit $FAILED
