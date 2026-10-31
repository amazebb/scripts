# Shell Scripts

Contains a repository of useful, semi-useful and somewhat less useful scripts 

Most of these are bash scripts tested within the macOS environment.

See [TOC](TOC.md) for per-script usage

## Install

Clone into `~/.local/share` and add `bin/` to your `$PATH`. Nothing is copied or linked, so the scripts
cannot overwrite, or be overwritten by, other tools in `~/.local/bin`:

```bash
mkdir -p ~/.local/share
git clone --depth 1 https://github.com/amazebb/scripts.git ~/.local/share/scripts
```

Add this to your `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$PATH:$HOME/.local/share/scripts/bin"
```

Appending means a tool of the same name found earlier on your `$PATH` wins. Prepend instead to make
these scripts win.

## Weather

Four scripts for US weather in the terminal, all taking a zip code, `lat,lon` or (by default) your
IP location. See the [TOC](TOC.md) for every option.

| Script | Shows |
|---|---|
| `wxforecast` | hourly forecast chart (temperature and expected rainfall by default, any two of eleven metrics), `-d` for the daily forecast, `-r` for raw rows |
| `wxradar` | animated radar loop over a map, `-r` for the radius, drawn in the terminal in kitty or ghostty, with the forecast chart above it |
| `wxnow` | what the nearest station is measuring now, including pressure |
| `wxalerts` | active watches, warnings and advisories, most severe first |

Active alerts are also printed above the `wxforecast` and `wxradar` output.

Data comes from the National Weather Service API (forecasts, observations, alerts), RainViewer (radar),
OpenStreetMap (map tiles), zippopotam.us (zip codes) and ipinfo.io (IP location). None need a key.
The radar image credits OpenStreetMap and RainViewer as their terms require, and map and radar tiles are
cached in `~/.cache/wx` for 7 days. See [WEATHER.md](WEATHER.md) for the data sources, their terms and
notes on keeping radar history.

Needs `curl` and `awk`. `wxradar` also needs `ffmpeg`, plus `chafa`, `kitten` or `mpv` to display the
loop. `wxradar` and `wxnow` use `mapfile`, so on macOS install a newer bash (`brew install bash`) and
put it first in your `$PATH`.

## Scheduled jobs

Some scripts are meant to run on a schedule. macOS uses `launchd` for this, and
the agent definitions live in [launchd/](launchd/).

They are opt-in, since installing one starts a recurring background job, so adding
`bin/` to your `$PATH` does not install them. Install and load them with:

```bash
./install-agents.sh
```

Re-running it replaces an agent even while it is loaded or mid-run. See
[launchd/README.md](launchd/README.md) for checking, stopping and removing them.

## Disclaimer

Usual disclaimer of no guarantees, that you kind of know what you're doing, and read the source
or get an LLM to do it for you if you need to know more.
