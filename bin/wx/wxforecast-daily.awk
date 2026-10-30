# Print the NWS 12 hour forecast periods json as a chart of the daily high and low with the
# metric (rain, amt, snow, hl, hh, gust or wind) on a right axis, or one row per day when graph is 0.
# The first input is the grid data lines from wxforecast-grid.awk, used for the daily rainfall,
# snowfall, humidity low and high and peak gust. Used by wxforecast daily_for, with wx-time.awk and wx-emoji.awk.

FNR == NR { q[$1, $2] = $3; next }
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
    if (date != last) { n++; last = date; key[n] = date; off[n] = substr(t, 20, 6) }
    if (day) { hi[n] = temp; hasday[n] = 1; em[n] = emoji(sf, 1); sky[n] = sf; wnd[n] = wind(ws) " " wd }
    else {
        lo[n] = temp; haslo[n] = 1
        if (!hasday[n]) { em[n] = emoji(sf, 0); sky[n] = sf; wnd[n] = wind(ws) " " wd }
    }
    if (pop > rain[n]) rain[n] = pop
}
function row(v, a, b) { return int((v - a) / (b - a) * (H - 1) + 0.5) }
# maxnum(S): the largest number in S, such as 10 in "5 to 10 mph"
function maxnum(w,    mx) {
    mx = 0
    while (match(w, /[0-9]+/)) { if (substr(w, RSTART, RLENGTH) + 0 > mx) mx = substr(w, RSTART, RLENGTH) + 0; w = substr(w, RSTART + RLENGTH) }
    return mx
}
# dv(I): the value of the right axis metric for day I
function dv(i) {
    if (metric == "amt") return ra[i]
    if (metric == "snow") return sn[i]
    if (metric == "hl") return hlo[i]
    if (metric == "hh") return hhi[i]
    if (metric == "gust") return gu[i]
    if (metric == "wind") return maxnum(wnd[i])
    return rain[i]
}
END {
    u = si ? "C" : "F"
    m = n < ndays ? n : ndays
    for (i = 1; i <= m; i++) {
        y = substr(key[i], 1, 4); mo = substr(key[i], 6, 2); d = substr(key[i], 9, 2)
        wday[i] = dow(days(y + 0, mo + 0, d + 0)); dlab[i] = d "-" mon(mo + 0)
        # totals and extremes over the local calendar day, from the hourly grid values
        dstart = epochh(key[i] "T00:00:00" off[i])
        ra[i] = sn[i] = gu[i] = 0; hmin = 1e9; hmax = -1e9
        for (k = 0; k < 24; k++) {
            e = dstart + k
            if (("amt", e) in q) ra[i] += q["amt", e]
            if (("snow", e) in q) sn[i] += q["snow", e]
            if (("gust", e) in q && q["gust", e] + 0 > gu[i]) gu[i] = q["gust", e] + 0
            if (("hum", e) in q) { h = q["hum", e] + 0; if (h < hmin) hmin = h; if (h > hmax) hmax = h }
        }
        ra[i] /= si ? 1 : 25.4; sn[i] /= si ? 1 : 25.4; gu[i] /= si ? 1 : 1.609344
        hasdv[i] = 1
        if (hmin == 1e9) { hlo[i] = hhi[i] = 0; if (metric == "hl" || metric == "hh") hasdv[i] = 0; hl[i] = hh[i] = "-" }
        else { hlo[i] = hmin; hhi[i] = hmax; hl[i] = sprintf("%.0f%%", hmin); hh[i] = sprintf("%.0f%%", hmax) }
    }
    if (!graph) {
        printf "\033[4G%-11s %5s %5s %5s %8s %8s %4s %4s %4s  %-16s %s\n", "DAY", "HIGH", "LOW", "RAIN", si ? "AMT(mm)" : "AMT(in)", si ? "SNOW(mm)" : "SNOW(in)", "HL", "HH", "GUST", "WIND", "SKY"
        for (i = 1; i <= m; i++)
            printf "%s\033[4G%-11s %5s %5s %4d%% %8s %8s %4s %4s %4.0f  %-16s %s\n", em[i], wday[i] " " dlab[i],
                hasday[i] ? sprintf("%.0f°%s", conv(hi[i]), u) : "-", haslo[i] ? sprintf("%.0f°%s", conv(lo[i]), u) : "-", rain[i],
                sprintf(si ? "%.1f" : "%.2f", ra[i]), sn[i] >= (si ? 0.5 : 0.05) ? sprintf("%.1f", sn[i]) : "-", hl[i], hh[i], gu[i], wnd[i], sky[i]
        exit
    }
    # chart: high and low temperature on the left axis, the chosen daily metric on the right
    H = 10; W = 7
    ymin = 1e9; ymax = -1e9
    for (i = 1; i <= m; i++) {
        if (hasday[i]) { v = conv(hi[i]); if (v < ymin) ymin = v; if (v > ymax) ymax = v }
        if (haslo[i]) { v = conv(lo[i]); if (v < ymin) ymin = v; if (v > ymax) ymax = v }
    }
    if (ymax - ymin < H - 1) ymax = ymin + H - 1
    # right axis: 0 to 100 for percentages, else 0 to the largest value, at least a floor
    rmax = 0
    for (i = 1; i <= m; i++) if (hasdv[i] && dv(i) > rmax) rmax = dv(i)
    if (metric == "rain" || metric == "hl" || metric == "hh") { rmax = 100; title = metric == "rain" ? "Chance of rain (%)" : metric == "hl" ? "Humidity low (%)" : "Humidity high (%)"; rfmt = "%d" }
    else if (metric == "amt") { if (rmax < (si ? 10 : 0.5)) rmax = si ? 10 : 0.5; title = "Expected rainfall (" (si ? "mm" : "in") ")"; rfmt = si ? "%.1f" : "%.2f" }
    else if (metric == "snow") { if (rmax < (si ? 25 : 1)) rmax = si ? 25 : 1; title = "Expected snowfall (" (si ? "mm" : "in") ")"; rfmt = "%.1f" }
    else { if (rmax < (si ? 16 : 10)) rmax = si ? 16 : 10; title = (metric == "gust" ? "Peak gust" : "Wind") " (" (si ? "km/h" : "mph") ")"; rfmt = "%d" }
    orange = "\033[38;5;208m"; reset = "\033[0m"
    printf "▲ High  ▼ Low (°%s)   %s◆ %s%s\n", u, orange, title, reset
    for (r = H - 1; r >= 0; r--) {
        line = ""
        for (i = 1; i <= m; i++) {
            p = " "
            if (hasday[i] && row(conv(hi[i]), ymin, ymax) == r) p = "▲"
            else if (haslo[i] && row(conv(lo[i]), ymin, ymax) == r) p = "▼"
            mk = hasdv[i] && row(dv(i), 0, rmax) == r ? orange "◆" reset : " "
            line = line " " p mk "    "
        }
        printf "%4d │%s│ %s%-4s%s\n", ymin + (ymax - ymin) * r / (H - 1) + 0.5, line, orange, sprintf(rfmt, rmax * r / (H - 1) + (rfmt == "%d" ? 0.5 : 0)), reset
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
