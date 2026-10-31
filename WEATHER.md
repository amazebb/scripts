# Weather scripts: data sources and notes

Notes on where the `wx*` scripts get their data, what the terms require, and ideas for
keeping radar history. The scripts themselves are documented in the [TOC](TOC.md).

## Data sources and terms

| Source | Used for | Terms, as read from their pages |
|---|---|---|
| NWS API (`api.weather.gov`) | forecasts, observations, alerts | public domain, no attribution needed; do not imply NWS endorsement or pass modified data off as official; send a `User-Agent` with a contact URL or email |
| OpenStreetMap tiles | map under the radar | visible `© OpenStreetMap contributors` on the map; a real `User-Agent`; cache tiles for at least 7 days or per HTTP headers; no bulk download or prefetch |
| RainViewer | radar tiles | free for personal, educational and small-scale use; visible "Weather data by RainViewer" with a link to rainviewer.com; cache and do not hammer the API |
| zippopotam.us, ipinfo.io | zip code and IP location | none checked; both are called once per run |

`wxradar` draws the OpenStreetMap and RainViewer credit on the image, and prints it as a status
line when ffmpeg has no `drawtext`. The NWS gifs need no credit.

## Caching

Map and radar tiles are kept in `~/.cache/wx` (or `$XDG_CACHE_HOME/wx`) for 7 days, and older
files are deleted at the start of a run.

- **OpenStreetMap:** the tile server sends `max-age` of about 26 hours and
  `stale-while-revalidate` and `stale-if-error` of 7 days. The policy's "at least 7 days" reads as a
  floor, so 7 days is fine. Town and city names change slowly, so staleness is not a concern.
- **RainViewer:** tiles are keyed by frame id and never change, so a later run reuses most of its
  13 frames. Their `max-age` is 2 days, and frames leave the API after about 2 hours.
- **What is stored:** plain PNGs with no metadata. The zoom, x and y are in the path and the
  modification time is when we saved the file. The `ETag`, `Expires` and `Cache-Control`
  headers are not kept, so an expired tile is downloaded again rather than revalidated.

## Keeping radar history

RainViewer's tiles make a weak archive:

- they are rendered colour images, so intensity is squashed into a palette rather than kept as numbers
- the free tier stops at zoom 7, roughly 0.5 to 1 km per pixel
- only the last 2 hours (13 frames) are served, so history means polling at least every 2 hours
- the cache holds bare images, so timestamp and location would have to be recorded separately
- the free tier is for personal use, so any archive would stay private

Better sources, depending on the goal:

| Goal | Source | Notes |
|---|---|---|
| Replay past storms as images | Iowa Environmental Mesonet NEXRAD composite tiles | believed to take a timestamp and go back years, so nothing to collect; verify the URL format before building on it |
| How much rain fell | NOAA MRMS radar-based rainfall estimates, free on AWS, around 1 km | real numbers rather than colours; GRIB2 files need a decoder |
| Full-resolution radar data | NEXRAD Level II and III archive, free on AWS, per station | the real data, but heavy to parse |
| Rain at one place over time | NWS observations (`precipitationLastHour`), which `wxnow` already reads | tiny JSON, easy to log; poll every hour or so |

If building an archive from RainViewer anyway, a per-location log of the radar value at one point per
frame would be far smaller and more useful than the images. The images are only about 1 KB each.

The right choice depends on the goal: replaying storms, totalling rainfall, or checking how good the
forecasts were.

## Not verified

- the Iowa Environmental Mesonet tile URL format and its timestamp support
- whether RainViewer's black and white colour scheme can be decoded back to dBZ values
- RainViewer's terms on storing frames long term
