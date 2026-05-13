#!/usr/bin/env bash
# Commonly used utility functions across all scripts

# shellcheck disable=SC2016

U() { printf '\e[4m%s\e[0m' "$*"; }

B() { printf '\e[1m%s\e[0m' "$*"; }

I() { printf '\e[3m%s\e[0m' "$*"; }

Q() {
  read -r -p "$1 [y/n]: "
  [[ ! $REPLY =~ [Yy] ]] && echo "Aborted." && exit 1
}

ask() {
  read -r -p "$1: "
  echo "$REPLY"
}

color() {
  local name=$1
  shift
  local code
  case $name in
    RED) code=31 ;;
    GREEN) code=32 ;;
    YELLOW) code=33 ;;
    BLUE) code=34 ;;
    MAGENTA) code=35 ;;
    CYAN) code=36 ;;
    *) code=0 ;;
  esac
  printf '\e[%sm%s\e[0m' "$code" "$*"
}

msg() { printf '%s\n' "$(color "$2" "$1")" >&2; }

info() { msg "$1" BLUE; }

warn() { msg "$1" RED && exit 1; }

argval() {
  (($# < 2)) || [[ $2 = -* ]] && warn "Error: $1 requires a valid argument" || echo "$2"
  # NOTE Because 'warn' is called in a sub-shell, the exit 1 does not
  # exit immediately. The parse arguments while loop will cycle
  # through all entered args.
}

noargs() { ((!$1)) && info "Error: no arguments provided" && usage && exit 1; }
