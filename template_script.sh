#!/usr/bin/env bash

# Template to use for writing scripts

VERSION="1.0.0"

usage() {
  cat <<EOF
template_script - Template script that shows some optionals and arguments

Usage: template_script [options] <arg1> <arg2>
 
Options:
  -h, --help    Show this help message
  --version     Show version information
  -a  <value>   Optional A (default: 1)
  -b  <value>   Optional B (default: true)

Arguments:
  arg1    First required Arg
  arg2    Second required Arg
EOF
  exit 0
}

version() {
  echo "$VERSION"
  exit 0
}

A=1
B="true"
# Parse arguments
while (($#)); do
  case $1 in
    -h | --help) usage ;;
    --version) version ;;
    --)
      shift
      break
      ;;
    -a)
      if (($# < 2)); then
        echo "Error: -a requires an argument" >&2
        usage
      fi
      A="$2"
      shift
      ;;
    -b)
      if (($# < 2)); then
        echo "Error: -b requires an argument" >&2
        usage
      fi
      B="$2"
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *) break ;; # Non-option args (positionals)
  esac
  shift
done

# Check required positional inputs
if (($# < 2)); then
  printf "\033[1;31m%s\033[0m\n" "Error: Missing required positional arguments" >&2
  usage
fi

ARG1="$1"
shift
ARG2="$1"
shift

echo "template_script.sh running with the following:"
echo
echo "arg1: $ARG1"
echo "arg2: $ARG2"
echo "-a:$A (Optional A)"
echo "-b:$B (Optional B)"
