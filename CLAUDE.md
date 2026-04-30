# Project: scripts

Personal shell script collection located in `bin/`.

## Bash Script Style Guide

When creating or modifying bash scripts in this project, follow these conventions:

### Supress ShellCheck warnings

Add `# shellcheck disable=SC2016` after the shebang to suppress warnings about the `$()` in the `usage()` heredoc.

### Utility Functions

All scripts should include these standard utility functions at the top of the file
in this order.

- `U()` — Underline text
- `B()` — Bold text
- `I()` — Italic text
- `Q()` — Yes/no confirmation prompt, exits on no
- `ask()` — Prompt for free-form input, echoes reply
- `color()` — Wrap text in an ANSI color by name (`$1`=color name like `RED`, `BLUE`, `GREEN`, `YELLOW`, `CYAN`, `MAGENTA`; `$2..`=text)
- `msg()` — Print message to stderr in a given color (`$1`=message, `$2`=color name, e.g. `RED`)
- `info()` — Print message as blue notice to stderr (calls `msg` with `BLUE`)
- `warn()` — Print red error to stderr and exit (calls `msg` with `RED`; pass `-1` as second arg to return instead of exit)
- `argval()` — Validate that an option has a required argument
- `noargs()` — Checks if number of arguments is zero, prints usage and exits
- `usage()` — Prints how to use the shell script in man-page style

The functions are defined here:

```bash
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
    local name=$1; shift
    local code
    case $name in
        RED)     code=31 ;;
        GREEN)   code=32 ;;
        YELLOW)  code=33 ;;
        BLUE)    code=34 ;;
        MAGENTA) code=35 ;;
        CYAN)    code=36 ;;
        *)       code=0  ;;
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
```

### Usage Function

Write `usage()` in man-page style using `B()`, `U()`, `I()` for formatting inside a heredoc:

```bash
usage() {
    cat <<EOF
$(B NAME)
    $(B script-name) - Short description

$(B SYNOPSIS)
    $(B "script-name [-h] [-flag] [-o value]") [$(U positional)]

$(B DESCRIPTION)
    Longer description of what the script does.

$(B OPTIONS)
    $(B -h)        Show this help message

    $(B -f) $(U val)   Description $(I '(default: something)')

$(B EXAMPLES)
    Example description

        script-name -f foo /some/path

EOF
}
```

### Argument Parsing

- Use a manual `while (($#)); do case ... esac; shift; done` loop (not `getopts`)
- Optional flags/options come first
- Positional arguments come last and are optional when a sensible default exists
- Support `--` to end option parsing
- Handle unknown options with `warn "Unknown option: $1"`
- Use `argval "$@"` for options that take a value, followed by an extra `shift`
- When no arguments are passed when they are required insert `noargs $#`, usually after `usage`

### Error Handling

- Use `warn "message"` instead of `echo "error" && exit 1`
- Use `warn` for fatal validation checks (missing commands, bad directories, etc.)
- Use `info` for informational output that gets printed to stderr
