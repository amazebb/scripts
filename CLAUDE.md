# Project: scripts

Personal shell script collection located in `bin/`.

Keep replies short. Do not narrate alternatives, tradeoffs, or why a check exists unless asked.

## Commit Messages

Use a conventional commit subject (`feat(scope): ...`, `fix`, `chore`, `docs`) followed by a blank line and a bullet point for each change. Do not write the body as prose paragraphs.

```
feat(netmon): add csv output

- add -f json|csv with -s to set the csv separator
- create the csv header when the log file is new
- append to the existing log on every run
```

## Bash Script Style Guide

When creating or modifying bash scripts in this project, follow these conventions:

### Supress ShellCheck warnings

Add `# shellcheck disable=SC2016` after the shebang to suppress warnings about the `$()` in the `usage()` heredoc.

Run ShellCheck with `-x` so it follows sourced files:

```bash
shellcheck -x bin/some-script
```

`.shellcheckrc` sets `source-path=SCRIPTDIR`, so `common.sh` is resolved relative to the script rather than the working directory. No `# shellcheck source=` directive is needed for the usual `common.sh` line — only when the path cannot be reduced to a filename next to the script, as in `install-agents.sh`.

### Utility Functions

All scripts source shared utility functions from [common.sh](bin/common.sh) in the same directory. Add this line after the shebang and shellcheck disable comment:

```bash
source "$(dirname "$0")/common.sh"
```

The available functions are:

- `U()` — Underline text
- `B()` — Bold text
- `I()` — Italic text
- `Q()` — Yes/no confirmation prompt, exits on no
- `ask()` — Prompt for free-form input, echoes reply
- `color()` — Wrap text in an ANSI color by name (`$1`=color name like `RED`, `BLUE`, `GREEN`, `YELLOW`, `CYAN`, `MAGENTA`; `$2..`=text)
- `msg()` — Print message to stderr in a given color (`$1`=message, `$2`=color name, e.g. `RED`)
- `info()` — Print message as blue notice to stderr (calls `msg` with `BLUE`)
- `warn()` — Print red error to stderr and exit (calls `msg` with `RED`)
- `argval()` — Validate that an option has a required argument
- `noargs()` — Checks if number of arguments is zero, prints usage and exits

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
    $(B -h)           Show this help message

    $(B -f) $(U val)      Description $(I '(default: something)')

    [$(U positional)]  Description $(I '(default: something)')

$(B EXAMPLES)
    Example description

        script-name -f foo /some/path

EOF
}
```

List every flag and every bare positional in OPTIONS. Wrap optional arguments in square brackets in both SYNOPSIS and OPTIONS (`[-h]`, `[$(U color)]`).

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
