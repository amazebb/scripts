# Print an NWS latest observation json as labelled lines.
# Used by wxnow render, with wx-emoji.awk.

function val(l) { gsub(/^[^:]*: *"?|"?,? *$/, "", l); return l }
function num(k) { return (k in v) && v[k] != "null" && v[k] != "" }
function f(c) { return si ? c : c * 9 / 5 + 32 }
function compass(d,    names) { split("N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW", names, " "); return names[int(d / 22.5 + 0.5) % 16 + 1] }
function arrow(d,    ar) { split("↑ ↗ → ↘ ↓ ↙ ← ↖", ar, " "); return ar[int(((d + 180) % 360) / 45 + 0.5) % 8 + 1] }
/^        "[A-Za-z0-9]+": *[\{\[]/ { split($1, k, "\""); sec = k[2] }
/^        "[A-Za-z0-9]+": *[^{\[ ]/ { split($1, k, "\""); top[k[2]] = val($0); sec = "" }
/"value"/ && sec != "" { v[sec] = val($0) }
END {
    tu = si ? "C" : "F"
    desc = top["textDescription"]; day = top["icon"] ~ /\/day\//
    printf "%s\033[4G%s\n", emoji(desc, day), desc != "" ? desc : "No description"
    feels = num("heatIndex") ? v["heatIndex"] : num("windChill") ? v["windChill"] : v["temperature"]
    printf "Temperature   %.0f°%s    Feels like %.0f°%s\n", f(v["temperature"]), tu, f(feels), tu
    if (num("dewpoint") || num("relativeHumidity")) {
        printf "Dew point     "
        if (num("dewpoint")) printf "%.0f°%s", f(v["dewpoint"]), tu
        if (num("relativeHumidity")) printf "    Humidity %.0f%%", v["relativeHumidity"]
        printf "\n"
    }
    if (num("windSpeed")) {
        spd = v["windSpeed"] / (si ? 1 : 1.609344)
        if (spd < 0.5) wind = "calm"
        else wind = sprintf("%s %s %.0f %s", num("windDirection") ? compass(v["windDirection"]) : "", num("windDirection") ? arrow(v["windDirection"]) : "", spd, si ? "km/h" : "mph")
        if (num("windGust")) wind = wind sprintf(", gusts %.0f", v["windGust"] / (si ? 1 : 1.609344))
        printf "Wind          %s\n", wind
    } else printf "Wind          -\n"
    p = num("seaLevelPressure") ? v["seaLevelPressure"] : num("barometricPressure") ? v["barometricPressure"] : ""
    printf "Pressure      %s", p == "" ? "-" : si ? sprintf("%.0f hPa", p / 100) : sprintf("%.2f inHg", p / 3386.389)
    printf "    Visibility %s\n", num("visibility") ? (si ? sprintf("%.1f km", v["visibility"] / 1000) : sprintf("%.1f mi", v["visibility"] / 1609.344)) : "-"
    if (num("precipitationLastHour"))
        printf "Rain last hr  %s\n", si ? sprintf("%.1f mm", v["precipitationLastHour"]) : sprintf("%.2f in", v["precipitationLastHour"] / 25.4)
    if (age != "") printf "Observed      %s\n", age
}
