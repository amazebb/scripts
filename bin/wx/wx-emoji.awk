# emoji(SHORTFORECAST, ISDAYTIME): weather emoji for an NWS short forecast.
# Library for wxforecast and wxnow, load with -f.

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
