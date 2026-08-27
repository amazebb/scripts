# Shell Scripts

Contains a repository of useful, semi-useful and somewhat less useful scripts 

Most of these are bash scripts tested within the macOS environment.

See [TOC](TOC.md) for per-script usage

## Install

Clone into `~/.local/share` and run the install script to symlink all scripts into `~/.local/bin`:

```bash
mkdir -p ~/.local/share
git clone --depth 1 https://github.com/broeknbytes/scripts.git ~/.local/share/scripts
cd ~/.local/share/scripts
./install.sh
```

Make sure `~/.local/bin` is in your `$PATH`. Add this to your `~/.bashrc` or `~/.zshrc` if it isn't already:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

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
