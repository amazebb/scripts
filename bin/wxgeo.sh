#!/usr/bin/env bash
# Location helpers shared by wxradar and wxforecast

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
