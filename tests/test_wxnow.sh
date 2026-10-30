#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# obs_json TEMP: an observation with TEMP degC as the temperature
obs_json() {
  cat <<JSON
{
    "properties": {
        "stationName": "Test Park",
        "timestamp": "2026-10-30T19:51:00+00:00",
        "textDescription": "Clear",
        "icon": "https://api.weather.gov/icons/land/day/skc?size=medium",
        "temperature": {
            "unitCode": "wmoUnit:degC",
            "value": $1
        },
        "dewpoint": {
            "value": 3.9
        },
        "windDirection": {
            "value": 315
        },
        "windSpeed": {
            "value": 22.2
        },
        "windGust": {
            "value": 38.9
        },
        "seaLevelPressure": {
            "value": 101800
        },
        "visibility": {
            "value": 16090
        },
        "relativeHumidity": {
            "value": 38.4
        },
        "windChill": {
            "value": null
        },
        "heatIndex": {
            "value": null
        },
        "cloudLayers": [
            {
                "base": {
                    "value": 1190
                }
            }
        ]
    }
}
JSON
}

# the nearest station reports no temperature, the second one does
wn_shims() {
  obs_json null >"$TMP/obs_KAAA.json"
  obs_json 18.3 >"$TMP/obs_KNYC.json"
  shim curl 'case "$*" in
  */observations/latest*) for a; do u=$a; done; id=${u%/observations*}; cat "$TMP/obs_${id##*/}.json" ;;
  */stations) printf "\"stationIdentifier\": \"KAAA\",\n\"stationIdentifier\": \"KNYC\",\n" ;;
  *api.weather.gov/points*) printf "\"observationStations\": \"https://api.weather.gov/gridpoints/X/1,1/stations\",\n" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
esac'
}

# the first station with a temperature is used and its values are shown
wn_imperial() {
  wn_shims
  local out
  out=$(TZ=UTC "$BIN/wxnow" 10001 2>&1 | sed 's/\x1b\[[0-9;]*[mG]//g')
  [[ $out == *"Test Park (KNYC)"* && $out == *"Temperature   65°F    Feels like 65°F"* &&
    $out == *"Dew point     39°F    Humidity 38%"* && $out == *"Wind          NW ↘ 14 mph, gusts 24"* &&
    $out == *"Pressure      30.06 inHg    Visibility 10.0 mi"* && $out == *"Observed      30-Oct-2026 19:51"* ]]
}

# -u si converts to C, km/h, hPa and km
wn_si() {
  wn_shims
  local out
  out=$(TZ=UTC "$BIN/wxnow" -u si 2>&1)
  [[ $out == *"Temperature   18°C"* && $out == *"22 km/h"* && $out == *"1018 hPa"* && $out == *"16.1 km"* ]] &&
    ! "$BIN/wxnow" -u x >/dev/null 2>&1
}

# a station id is read directly, without the points lookup
wn_station_id() {
  wn_shims
  "$BIN/wxnow" knyc 2>&1 | grep -q 'Test Park (KNYC)'
}

# cloud layer heights do not leak into the heat index
wn_cloud_layers() {
  wn_shims
  "$BIN/wxnow" KNYC 2>&1 | sed 's/\x1b\[[0-9;]*[mG]//g' | grep -q 'Feels like 65°F'
}

t "wxnow: skips a station with no temperature" wn_imperial
t "wxnow: -u si" wn_si
t "wxnow: station id" wn_station_id
t "wxnow: cloud layers do not become feels-like" wn_cloud_layers

exit $FAILED
