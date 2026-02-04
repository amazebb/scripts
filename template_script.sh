#!/usr/bin/env bash

# Template to use for writing scripts

# Version
VERSION="1.0.0"

# Help function
usage() {
  echo "template_script - Template script that shows some optionals and arguments"
  echo
  echo "Usage: template_script [options] <arg1> <arg2>"
  echo
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo "  --version     Show version information"
  echo "  -a  <value>   Optional A (default: 1)"
  echo "  -b  <value>   Optional B (default: true)"
  echo
  echo "Arguments:"
  echo "  arg1    First required Arg"
  echo "  arg2    Second required Arg"
  exit 0
}

# Version function
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
  echo "Error: Missing required positional inputs"
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
