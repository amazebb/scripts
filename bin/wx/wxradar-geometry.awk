# Print "z x0 y0 cols rows cropx cropy size" for the 512px RainViewer radar tiles, then the
# same fields for the 256px map tiles at the zoom that fills 720px. Used by wxradar geometry.

function grid(z, t,    w, px, py, half) {
    w = t * 2 ^ z
    px = (lon + 180) / 360 * w
    py = (1 - log(sin(r) / cos(r) + 1 / cos(r)) / pi) / 2 * w
    half = mi * 1609.344 / (40075016.686 * cos(r) / w)
    x0 = int((px - half) / t); y0 = int((py - half) / t)
    printf "%d %d %d %d %d %d %d %d ", z, x0, y0, int((px + half) / t) - x0 + 1,
        int((py + half) / t) - y0 + 1, px - half - x0 * t, py - half - y0 * t, 2 * half
    return half
}
BEGIN {
    pi = atan2(0, -1); r = lat * pi / 180
    for (z = 7; z > 1; z--) {
        if (mi * 1609.344 / (40075016.686 * cos(r) / (512 * 2 ^ z)) <= 512) break
    }
    grid(z, 512)
    for (m = z + 1; m < 17; m++) {
        if (2 * mi * 1609.344 / (40075016.686 * cos(r) / (256 * 2 ^ m)) >= 720) break
    }
    grid(m, 256)
    print ""
}
