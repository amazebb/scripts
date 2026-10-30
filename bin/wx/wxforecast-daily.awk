# Print one row per day from the NWS 12 hour forecast periods json.
# Used by wxforecast daily_for, with wx-time.awk and wx-emoji.awk.

function val(l) { gsub(/^[^:]*: *"?|"?,? *$/, "", l); return l }
function mon(m) { return substr("JanFebMarAprMayJunJulAugSepOctNovDec", (m - 1) * 3 + 1, 3) }
function dow(d,    names) { split("Thu Fri Sat Sun Mon Tue Wed", names, " "); return names[(d % 7 + 7) % 7 + 1] }
function conv(f) { return si ? (f - 32) * 5 / 9 : f }
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
END {
    u = si ? "C" : "F"
    printf "\033[4G%-11s %5s %5s %5s  %-16s %s\n", "DAY", "HIGH", "LOW", "RAIN", "WIND", "SKY"
    for (i = 1; i <= n && i <= ndays; i++) {
        y = substr(key[i], 1, 4); m = substr(key[i], 6, 2); d = substr(key[i], 9, 2)
        label = dow(days(y + 0, m + 0, d + 0)) " " d "-" mon(m + 0)
        printf "%s\033[4G%-11s %5s %5s %4d%%  %-16s %s\n", em[i], label,
            hasday[i] ? sprintf("%.0f°%s", conv(hi[i]), u) : "-", haslo[i] ? sprintf("%.0f°%s", conv(lo[i]), u) : "-", rain[i], wnd[i], sky[i]
    }
}
