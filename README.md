# Shell Scripts

Contains a repository of useful, semi-useful and somewhat less useful scripts 

Most of these are bash scripts tested within the macOS environment.

See [TOC](TOC.md) for per-script usage

## Install

Clone into `~/.local/share` and run the install script to symlink all scripts into `~/.local/bin`:

```bash
mkdir -p ~/.local/share
git clone --depth 1 https://github.com/amazebb/scripts.git ~/.local/share/scripts
cd ~/.local/share/scripts
./install.sh
```

Make sure `~/.local/bin` is in your `$PATH`. Add this to your `~/.bashrc` or `~/.zshrc` if it isn't already:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

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

Needs `curl` and `awk`. `wxradar` also needs `ffmpeg`, plus `chafa`, `kitten` or `mpv` to display the
loop. `wxradar` and `wxnow` use `mapfile`, so on macOS install a newer bash (`brew install bash`) and
put it first in your `$PATH`. The helper files are in `bin/wx/`, so re-run `./install.sh` after pulling to
link that folder.

## Scheduled jobs

Some scripts are meant to run on a schedule. macOS uses `launchd` for this, and
the agent definitions live in [launchd/](launchd/).

They are opt-in, since installing one starts a recurring background job, so
`install.sh` leaves them alone. Install and load them with:

```bash
./install-agents.sh
```

Re-running it replaces an agent even while it is loaded or mid-run. See
[launchd/README.md](launchd/README.md) for checking, stopping and removing them.

## Disclaimer

Usual disclaimer of no guarantees, that you kind of know what you're doing, and read the source
or get an LLM to do it for you if you need to know more.
