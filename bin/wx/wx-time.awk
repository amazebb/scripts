# days(Y, M, D): days since 1970-01-01. epochh(TS): UTC hour count of an ISO 8601
# timestamp with a whole-hour offset. Library for wxforecast, load with -f.

function days(y, m, d,    era, yoe, doy) {
    if (m <= 2) y--
    era = int(y / 400); yoe = y - era * 400
    doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
    return era * 146097 + yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy - 719468
}
function epochh(ts,    sign) {
    sign = substr(ts, 20, 1) == "-" ? -1 : 1
    return days(substr(ts, 1, 4) + 0, substr(ts, 6, 2) + 0, substr(ts, 9, 2) + 0) * 24 + substr(ts, 12, 2) - sign * substr(ts, 21, 2)
}
