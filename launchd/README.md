# launchd agents

Scheduled jobs for macOS, run by `launchd`.

Job definitions (`.plist` files) live here and are **copied** into
`~/Library/LaunchAgents/` to be activated. The copy in this repo is the master;
the one in `~/Library/LaunchAgents` is the live one `launchd` reads.

## Agents

| Label          | Script   | Schedule                                                  |
| -------------- | -------- | --------------------------------------------------------- |
| `local.netmon` | `netmon` | every 60s and at login; TSV to `~/netmon/probes.csv`, errors to `~/netmon/netmon.err` |

## Install / start

`./install-agents.sh` copies every plist here into `~/Library/LaunchAgents/` and
loads it. An agent that is already installed is replaced even if it is loaded or
mid-run — the old job is unloaded first. Name a label to do just one, add `-n`
to install without loading, or `-u` to unload and delete:

```bash
./install-agents.sh                     # all agents
./install-agents.sh local.netmon        # just this one, replacing any running version
./install-agents.sh -u local.netmon     # unload and remove
```

To do it by hand:

```bash
cp launchd/local.netmon.plist ~/Library/LaunchAgents/
plutil -lint ~/Library/LaunchAgents/local.netmon.plist   # sanity check
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/local.netmon.plist
```

`RunAtLoad` makes it fire once immediately, so the first record appears right away.

## Status / run now

```bash
launchctl print gui/$UID/local.netmon      # state, last exit code, properties
launchctl kickstart -p gui/$UID/local.netmon   # run it right now
tail -f ~/netmon/probes.csv
cat ~/netmon/netmon.err
```

A `state = not running` with `last exit code = 0` is normal — the job is
short-lived and only wakes on its interval.

## Stop

```bash
launchctl bootout gui/$UID/local.netmon
```

This unloads the job but leaves the plist in place, so a reboot/login will not
restart it until you `bootstrap` again.

## Change the schedule or arguments

Edit the copy in this repo, then reinstall:

```bash
launchctl bootout gui/$UID/local.netmon
cp launchd/local.netmon.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/local.netmon.plist
```

`launchd` does not pick up edits to a loaded plist — it must be booted out and
back in.

- `StartInterval` — integer seconds between runs.
- `StartCalendarInterval` — a dict (or array of dicts) of `Minute`, `Hour`,
  `Day`, `Weekday`, `Month` for wall-clock scheduling. Missing keys are
  wildcards, so `<key>Hour</key><integer>3</integer>` plus
  `<key>Minute</key><integer>0</integer>` means 03:00 daily.

Use the two keys separately, not together.

## Remove completely

```bash
launchctl bootout gui/$UID/local.netmon
rm ~/Library/LaunchAgents/local.netmon.plist
```

Optionally drop the data it produced:

```bash
rm -rf ~/netmon
```

## Notes

- `ProgramArguments` needs **absolute** paths — agents run with a minimal
  environment and do not see your shell `$PATH`.
- Missed runs while the machine is asleep are not queued up; the job simply runs
  at the next interval after wake.
