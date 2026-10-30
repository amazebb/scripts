# Read NWS grid data json and print "name UTC-hour value" for every hour of each block.
# Rainfall and snow are block totals spread evenly over the block, the rest are repeated.
# Used by wxforecast grid_hours, with wx-time.awk.

BEGIN {
    f["quantitativePrecipitation"] = "qpf"; f["snowfallAmount"] = "snow"; f["windGust"] = "gust"
    f["skyCover"] = "cloud"; f["apparentTemperature"] = "feels"; f["visibility"] = "vis"; f["relativeHumidity"] = "hum"
    total["qpf"] = total["snow"] = 1
}
/^        "[A-Za-z]+": *\{/ { split($1, kk, "\""); name = (kk[2] in f) ? f[kk[2]] : "" }
name != "" && /"validTime"/ {
    split($0, a, "\"")
    split(a[4], v, "/")
    h = 0
    if (match(v[2], /[0-9]+D/)) h += substr(v[2], RSTART, RLENGTH - 1) * 24
    if (match(v[2], /[0-9]+H/)) h += substr(v[2], RSTART, RLENGTH - 1)
    start = epochh(v[1])
}
name != "" && /"value"/ && h > 0 {
    x = $0; gsub(/[^0-9.-]/, "", x)
    for (k = 0; k < h; k++) printf "%s %d %.4f\n", name, start + k, total[name] ? x / h : x
    h = 0
}
