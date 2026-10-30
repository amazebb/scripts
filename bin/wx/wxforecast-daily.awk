# Print the NWS 12 hour forecast periods json as a chart of the daily high and low with the
# chance of rain, or as one row per day when graph is 0.
# Used by wxforecast daily_for, with wx-time.awk and wx-emoji.awk.

function val(l) { gsub(/^[^:]*: *"?|"?,? *$/, "", l); return l }
function mon(m) { return substr("JanFebMarAprMayJunJulAugSepOctNovDec", (m - 1) * 3 + 1, 3) }
function dow(d,    names) { split("Thu Fri Sat Sun Mon Tue Wed", names, " "); return names[(d % 7 + 7) % 7 + 1] }
function conv(f) { return si ? (f - 32) * 5 / 9 : f + 0 }
# wind(S): convert every mph number in S to km/h for SI
function wind(w,    out, n) {
    if (!si) return w
    gsub(/mph/, "km/h", w)
    out = ""
    while (match(w, /[0-9]+/)) {
        out = out substr(w, 1, RSTART - 1) sprintf("%.0f", substr(w, RSTART, RLENGTH) * 1.609344)
        w = substr(w, RSTART + RLENGTH)
    }
    return out w
}
/"startTime"/ { t = val($0); date = substr(t, 1, 10) }
/"isDaytime"/ { day = val($0) == "true" }
/"temperature"/ { temp = val($0) }
/"probabilityOfPrecipitation"/ { sec = "pop" }
/"value"/ && sec == "pop" { pop = val($0) == "null" ? 0 : val($0); sec = "" }
/"windSpeed"/ { ws = val($0) }
/"windDirection"/ { wd = val($0) }
/"shortForecast"/ {
    sf = val($0)
    if (date != last) { n++; last = date; key[n] = date }
    if (day) { hi[n] = temp; hasday[n] = 1; em[n] = emoji(sf, 1); sky[n] = sf; wnd[n] = wind(ws) " " wd }
    else {
        lo[n] = temp; haslo[n] = 1
        if (!hasday[n]) { em[n] = emoji(sf, 0); sky[n] = sf; wnd[n] = wind(ws) " " wd }
    }
    if (pop > rain[n]) rain[n] = pop
}
function row(v, a, b) { return int((v - a) / (b - a) * (H - 1) + 0.5) }
END {
    u = si ? "C" : "F"
    m = n < ndays ? n : ndays
    for (i = 1; i <= m; i++) {
        y = substr(key[i], 1, 4); mo = substr(key[i], 6, 2); d = substr(key[i], 9, 2)
        wday[i] = dow(days(y + 0, mo + 0, d + 0)); dlab[i] = d "-" mon(mo + 0)
    }
    if (!graph) {
        printf "\033[4G%-11s %5s %5s %5s  %-16s %s\n", "DAY", "HIGH", "LOW", "RAIN", "WIND", "SKY"
        for (i = 1; i <= m; i++)
            printf "%s\033[4G%-11s %5s %5s %4d%%  %-16s %s\n", em[i], wday[i] " " dlab[i],
                hasday[i] ? sprintf("%.0f°%s", conv(hi[i]), u) : "-", haslo[i] ? sprintf("%.0f°%s", conv(lo[i]), u) : "-", rain[i], wnd[i], sky[i]
        exit
    }
    # chart: high and low temperature on the left axis, chance of rain on the right
    H = 10; W = 7
    ymin = 1e9; ymax = -1e9
    for (i = 1; i <= m; i++) {
        if (hasday[i]) { v = conv(hi[i]); if (v < ymin) ymin = v; if (v > ymax) ymax = v }
        if (haslo[i]) { v = conv(lo[i]); if (v < ymin) ymin = v; if (v > ymax) ymax = v }
    }
    if (ymax - ymin < H - 1) ymax = ymin + H - 1
    orange = "\033[38;5;208m"; reset = "\033[0m"
    printf "▲ High  ▼ Low (°%s)   %s◆ Chance of rain (%%)%s\n", u, orange, reset
    for (r = H - 1; r >= 0; r--) {
        line = ""
        for (i = 1; i <= m; i++) {
            p = " "
            if (hasday[i] && row(conv(hi[i]), ymin, ymax) == r) p = "▲"
            else if (haslo[i] && row(conv(lo[i]), ymin, ymax) == r) p = "▼"
            q = row(rain[i], 0, 100) == r ? orange "◆" reset : " "
            line = line " " p q "    "
        }
        printf "%4d │%s│ %s%-4d%s\n", ymin + (ymax - ymin) * r / (H - 1) + 0.5, line, orange, 100 * r / (H - 1) + 0.5, reset
    }
    axis = ""
    for (i = 1; i <= m * W; i++) axis = axis "─"
    printf "     └%s┘\n      ", axis
    for (i = 1; i <= m; i++) printf "\033[%dG%s", 8 + (i - 1) * W, em[i]
    printf "\n"
    for (i = 1; i <= m; i++) printf "\033[%dG%s", 8 + (i - 1) * W, wday[i]
    printf "\n"
    for (i = 1; i <= m; i++) printf "\033[%dG%s", 8 + (i - 1) * W, dlab[i]
    printf "\n"
}
