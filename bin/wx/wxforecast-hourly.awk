# Draw the hourly forecast as a chart or raw rows. The first input is the grid data lines
# from wxforecast-grid.awk, the second the NWS hourly forecast json.
# Used by wxforecast forecast_for, with wx-time.awk and wx-emoji.awk.

FNR == NR { q[$1, $2] = $3; next }
function val(l) { gsub(/^[^:]*: *"?|"?,? *$/, "", l); return l }
function mon(m) { return substr("JanFebMarAprMayJunJulAugSepOctNovDec", (m - 1) * 3 + 1, 3) }
function grid(name, e) { return ((name, e) in q) ? q[name, e] : 0 }
function cdeg(c) { return si ? c : c * 9 / 5 + 32 }
function mv(m, i) {
    if (m == "feels") return feels[i]
    if (m == "dew") return dew[i]
    if (m == "hum") return hum[i]
    if (m == "cloud") return cloud[i]
    if (m == "rain") return rain[i]
    if (m == "amt") return amt[i]
    if (m == "snow") return snow[i]
    if (m == "wind") return wind[i]
    if (m == "gust") return gust[i]
    if (m == "vis") return vis[i]
    return temp[i]
}
/"startTime"/ {
    t = val($0); n++; e = epochh(t)
    amt[n] = grid("amt", e) / (si ? 1 : 25.4)
    snow[n] = grid("snow", e) / (si ? 1 : 25.4)
    gust[n] = grid("gust", e) / (si ? 1 : 1.609344)
    cloud[n] = grid("cloud", e)
    feels[n] = cdeg(grid("feels", e))
    vis[n] = grid("vis", e) / (si ? 1000 : 1609.344)
    hh[n] = substr(t, 12, 2); dd[n] = substr(t, 9, 2) "-" mon(substr(t, 6, 2)); tm[n] = substr(t, 12, 5)
}
/"isDaytime"/ { day = val($0) == "true" }
/"temperature"/ { temp[n] = si ? (val($0) - 32) * 5 / 9 : val($0) }
/"probabilityOfPrecipitation"/ { sec = "rain" }
/"dewpoint"/ { sec = "dew" }
/"relativeHumidity"/ { sec = "hum" }
/"value"/ && sec != "" {
    v = val($0); if (v == "null") v = 0
    if (sec == "rain") rain[n] = v
    else if (sec == "hum") hum[n] = v
    else dew[n] = cdeg(v)
    sec = ""
}
/"windSpeed"/ { wind[n] = val($0) * (si ? 1.609344 : 1); ws[n] = sprintf("%.0f %s", wind[n], si ? "km/h" : "mph") }
/"windDirection"/ { wd[n] = val($0) }
/"shortForecast"/ { sky[n] = val($0); em[n] = emoji(val($0), day) }
function isfrac(m) { return m == "amt" || m == "snow" || m == "vis" }
function iswind(m) { return m == "wind" || m == "gust" }
function ttl(m,    u) {
    u = si ? "C" : "F"
    if (m == "rain") return "Chance of rain (%)"
    if (m == "hum") return "Relative humidity (%)"
    if (m == "cloud") return "Cloud cover (%)"
    if (m == "dew") return "Dew point (°" u ")"
    if (m == "feels") return "Feels like (°" u ")"
    if (m == "amt") return "Expected rainfall (" (si ? "mm" : "in") ")"
    if (m == "snow") return "Expected snowfall (" (si ? "mm" : "in") ")"
    if (m == "wind") return "Wind speed (" (si ? "km/h" : "mph") ")"
    if (m == "gust") return "Wind gust (" (si ? "km/h" : "mph") ")"
    if (m == "vis") return "Visibility (" (si ? "km" : "mi") ")"
    return "Temperature (°" u ")"
}
# setup(AXIS, COUNT): fill ya[], lo[] and hi[] for the metric on AXIS
function setup(a, cnt,    i, l, h, mn, m) {
    m = met[a]
    for (i = 1; i <= cnt; i++) ya[a, i] = mv(m, i)
    l = h = ya[a, 1]
    for (i = 1; i <= cnt; i++) { if (ya[a, i] < l) l = ya[a, i]; if (ya[a, i] > h) h = ya[a, i] }
    if (m == "rain" || m == "hum" || m == "cloud") { l = 0; h = 100 }
    if (isfrac(m)) {
        l = 0; mn = m == "amt" ? (si ? 2 : 0.1) : m == "snow" ? (si ? 25 : 1) : (si ? 10 : 6)
        if (h < mn) h = mn
    } else if (h - l < H - 1) h = l + H - 1
    lo[a] = l; hi[a] = h
}
function row(a, i) { return int((ya[a, i] - lo[a]) / (hi[a] - lo[a]) * (H - 1) + 0.5) }
function lab(a, v,    m) {
    m = met[a]
    return m == "amt" ? sprintf(si ? "%.1f" : "%.2f", v) : isfrac(m) ? sprintf("%.1f", v) : sprintf("%d", v + 0.5)
}
# arrow(I): arrow pointing where the wind blows, from the 16 point direction wd[I]
function arrow(i,    k, names, ar, idx) {
    split("N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW", names, " ")
    split("↑ ↗ → ↘ ↓ ↙ ← ↖", ar, " ")
    for (k = 1; k <= 16; k++) if (names[k] == wd[i]) idx = k - 1
    return ar[int(((idx * 22.5 + 180) % 360) / 45 + 0.5) % 8 + 1]
}
function mark(a, i) { return iswind(met[a]) ? arrow(i) : (a == 1 ? "●" : "◆") }
function legend(a) { return iswind(met[a]) ? "↗" : (a == 1 ? "●" : "◆") }
END {
    u = si ? "C" : "F"
    if (!graph) {
        printf "%-12s %5s %5s %5s %4s %4s %4s %8s %4s  %-11s %s\n", "TIME", "TEMP", "FEEL", "DEW", "HUM", "CLD", "RAIN", si ? "AMT(mm)" : "AMT(in)", "GUST", "WIND", "SKY"
        for (i = 1; i <= n && i <= hours; i++)
            printf "%-12s %3.0f°%s %3.0f°%s %3.0f°%s %3s%% %3.0f%% %3s%% %8s %4.0f  %-11s %s\n", dd[i] " " tm[i], temp[i], u, feels[i], u, dew[i], u, hum[i], cloud[i], rain[i], sprintf(si ? "%.1f" : "%.2f", amt[i]), gust[i], ws[i] " " wd[i], sky[i]
        exit
    }
    sec = metric2 != ""
    w = int((cols - 6) / 3); if (w < 1) w = 1
    m = hours < w ? hours : w; if (m > n) m = n
    H = 10
    met[1] = metric; met[2] = metric2
    setup(1, m); if (sec) setup(2, m)
    orange = "\033[38;5;208m"; reset = "\033[0m"
    if (sec) printf "%s %s   %s%s %s%s\n", legend(1), ttl(metric), orange, legend(2), ttl(metric2), reset
    else printf "%s\n", ttl(metric)
    for (r = H - 1; r >= 0; r--) {
        line = ""
        for (i = 1; i <= m; i++) {
            pm = row(1, i) == r ? mark(1, i) : " "
            sm = sec && row(2, i) == r ? orange mark(2, i) reset : " "
            line = line " " pm sm
        }
        printf "%4s │%s", lab(1, lo[1] + (hi[1] - lo[1]) * r / (H - 1)), line
        if (sec) printf "│ %s%-4s%s", orange, lab(2, lo[2] + (hi[2] - lo[2]) * r / (H - 1)), reset
        printf "\n"
    }
    axis = ""
    for (i = 1; i <= m; i++) axis = axis "───"
    printf "     └%s%s\n", axis, sec ? "┘" : ""
    printf "      "
    for (i = 1; i <= m; i++) printf "\033[%dG%s", 7 + (i - 1) * 3 + 1, em[i]
    printf "\n       "
    for (i = 1; i <= m; i++) printf "%02d ", hh[i]
    printf "\n"
    for (i = 1; i <= m; i++) if (i == 1 || hh[i] == "00") printf "\033[%dG%s", 7 + (i - 1) * 3 + 1, dd[i]
    printf "\n"
}
