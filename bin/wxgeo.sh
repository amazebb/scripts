#!/usr/bin/env bash
# Location, time and chart metric helpers shared by wxradar and wxforecast

# shellcheck disable=SC2034
UA='wx (github.com/amazebb/scripts)'

# latlon LOCATION: print "lat lon" for a zip, "lat,lon" or the IP location
latlon() {
    local loc=$1 json lat lon
    case $loc in
        '')
            loc=$(curl -fsS https://ipinfo.io/loc) || warn "Could not determine your location"
            echo "${loc%%,*} ${loc##*,}"
            ;;
        [0-9][0-9][0-9][0-9][0-9])
            json=$(curl -fsSL "https://api.zippopotam.us/us/$loc") || warn "Unknown zip code: $loc"
            lat=$(sed -n 's/.*"latitude": *"\([^"]*\)".*/\1/p' <<<"$json")
            lon=$(sed -n 's/.*"longitude": *"\([^"]*\)".*/\1/p' <<<"$json")
            echo "$lat $lon"
            ;;
        [-0-9]*,[-0-9]*)
            echo "${loc%%,*} ${loc##*,}"
            ;;
        *) return 1 ;;
    esac
}

# stamp_fmt [EPOCH]: DD-MMM-YYYY HH:MM local time, now by default
stamp_fmt() {
    local f='+%d-%b-%Y %H:%M'
    if [[ -z $1 ]]; then date "$f"; else date -d "@$1" "$f" 2>/dev/null || date -r "$1" "$f"; fi
}

# iso_epoch TS: epoch seconds of an ISO 8601 UTC timestamp like 2026-10-30T18:04:24+00:00
iso_epoch() {
    local ts=${1%+00:00}Z
    date -d "$ts" +%s 2>/dev/null || date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$ts" +%s
}

# chart metrics shared by wxforecast -y and wxradar -f
METRICS='temp|feels|dew|hum|cloud|rain|qpf|snow|wind|gust|vis'

# is_metric NAME: true when NAME is a chart metric
is_metric() { [[ "|$METRICS|" == *"|$1|"* ]]; }

# awk helper: emoji(SHORTFORECAST, ISDAYTIME)
AWK_EMOJI='
function emoji(f, day) {
            f = tolower(f)
            if (f ~ /thunder/) return "⛈️"
            if (f ~ /snow|flurries|sleet|ice|freezing/) return "❄️"
            if (f ~ /rain|showers|drizzle/) return "🌧️"
            if (f ~ /fog|haze|smoke/) return "🌫️"
            if (f ~ /mostly cloudy|overcast|^cloudy/) return "☁️"
            if (f ~ /partly/) return day ? "⛅" : "☁️"
            if (f ~ /mostly (clear|sunny)/) return day ? "🌤️" : "🌙"
            return day ? "☀️" : "🌙"
        }
'
