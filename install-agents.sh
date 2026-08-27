#!/usr/bin/env bash
# install-agents.sh - install and load the launchd agents in launchd/

# shellcheck disable=SC2016
# shellcheck source=bin/common.sh
source "$(dirname "$0")/bin/common.sh"

set -u

usage() {
  cat <<EOF
$(B NAME)
    $(B install-agents.sh) - Install the launchd agents in $(I launchd/)

$(B SYNOPSIS)
    $(B "install-agents.sh [-h] [-u] [-n]") [$(U label)...]

$(B DESCRIPTION)
    Copies each plist in $(I launchd/) to $(I ~/Library/LaunchAgents/) and loads
    it. An agent that is already installed is replaced, whether or not it is
    loaded or mid-run: the old job is unloaded first, then the new plist is
    copied over and bootstrapped.

    A plist that fails $(B plutil) validation stops the run before anything
    is unloaded or copied, so a broken definition cannot clobber a working
    agent.

    With no $(U label) given, every agent in $(I launchd/) is processed, after
    listing them and asking for confirmation. Naming a $(U label) skips the
    prompt.

$(B OPTIONS)
    $(B -h)          Show this help message

    $(B -u)          Unload and remove the agents instead of installing them

    $(B -n)          Install without loading, taking effect at next login

    [$(U label)]     Agent label, with or without the $(I .plist) suffix
                $(I '(default: all agents in launchd/)')

$(B EXAMPLES)
    Install and load every agent

        install-agents.sh

    Reinstall one agent, replacing the running version

        install-agents.sh local.netmon

    Remove an agent completely

        install-agents.sh -u local.netmon

EOF
}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLIST_DIR="$SCRIPT_DIR/launchd"
AGENT_DIR="$HOME/Library/LaunchAgents"
DOMAIN="gui/$UID"

remove=0
noload=0
labels=()

while (($#)); do
  case $1 in
    -h)
      usage
      exit 0
      ;;
    -u)
      remove=1
      shift
      ;;
    -n)
      noload=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*) warn "Unknown option: $1" ;;
    *) break ;;
  esac
done

labels=("$@")

[[ -d $PLIST_DIR ]] || warn "Error: no such directory: $PLIST_DIR"

if ((!${#labels[@]})); then
  for plist in "$PLIST_DIR"/*.plist; do
    [[ -e $plist ]] || warn "Error: no plists found in $PLIST_DIR"
    labels+=("$(basename "$plist" .plist)")
  done

  # no labels given means every agent, so confirm the list first
  if ((remove)); then
    info "Agents to remove:"
    printf '  %s\n' "${labels[@]}" >&2
    Q "Remove these agents?"
  else
    info "Agents to install:"
    printf '  %s\n' "${labels[@]}" >&2
    Q "Install these agents?"
  fi
fi

# describe when an agent runs, from the keys in its plist
schedule() {
  local plist=$1 secs desc=
  secs=$(plutil -extract StartInterval raw -o - "$plist" 2>/dev/null)
  [[ -n $secs ]] && desc="every ${secs}s"
  plutil -extract StartCalendarInterval raw -o - "$plist" &>/dev/null &&
    desc="${desc:+$desc, }at the times in StartCalendarInterval"
  [[ $(plutil -extract RunAtLoad raw -o - "$plist" 2>/dev/null) = true ]] &&
    desc="${desc:+$desc, }at login"
  echo "${desc:-on demand only}"
}

# bootout is asynchronous; bootstrap fails while the old job is still going
unload() {
  local label=$1
  launchctl print "$DOMAIN/$label" &>/dev/null || return 0
  launchctl bootout "$DOMAIN/$label" &>/dev/null
  local i
  for ((i = 0; i < 50; i++)); do
    launchctl print "$DOMAIN/$label" &>/dev/null || return 0
    sleep 0.1
  done
  return 1
}

for label in "${labels[@]}"; do
  label=${label%.plist}
  src="$PLIST_DIR/$label.plist"
  dst="$AGENT_DIR/$label.plist"

  if ((remove)); then
    unload "$label" || info "$label is still loaded, removing anyway"
    if [[ -e $dst ]]; then
      rm "$dst" && info "Removed $label"
    else
      info "$label was not installed"
    fi
    continue
  fi

  [[ -f $src ]] || warn "Error: no such agent: $label"
  plutil -lint "$src" >/dev/null || warn "Error: $label.plist is not a valid plist"

  unload "$label" || warn "Error: could not unload the running $label"

  mkdir -p "$AGENT_DIR" || warn "Error: cannot create $AGENT_DIR"
  cp "$src" "$dst" || warn "Error: cannot copy $label.plist to $AGENT_DIR"

  if ((noload)); then
    info "Installed $label, not loaded — runs $(schedule "$src")"
  else
    launchctl bootstrap "$DOMAIN" "$dst" 2>/dev/null ||
      warn "Error: could not load $label"
    info "Loaded $label — runs $(schedule "$src")"
  fi
  installed=1
done

((${installed:-0})) && cat >&2 <<EOF

$(B "How often an agent runs, and what it runs, is set in its plist:")
    $PLIST_DIR/<label>.plist

  $(I - StartInterval) is the seconds between runs.
  $(I - ProgramArguments) is the command and its options. 

After editing, re-run this script to reload the agent.

Checking, stopping and removing agents is covered in:
    $PLIST_DIR/README.md
EOF
