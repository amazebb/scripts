# Scripts

## Table of Contents

- [build-nvim-nightly](#build-nvim-nightly)
- [convertaudio](#convertaudio)
- [data-backup](#data-backup)
- [dedupe](#dedupe)
- [disk-useage](#disk-useage)
- [exifmv](#exifmv)
- [fext](#fext)
- [fix-symlinks](#fix-symlinks)
- [fz](#fz)
- [ghostty-theme](#ghostty-theme)
- [gitea-cli](#gitea-cli)
- [iplot](#iplot)
- [list-scripts](#list-scripts)
- [n3](#n3)
- [netmon](#netmon)
- [rawsync](#rawsync)
- [shtoc](#shtoc)
- [shtomd](#shtomd)
- [vbrhist](#vbrhist)
- [wxalerts](#wxalerts)
- [wxforecast](#wxforecast)
- [wxnow](#wxnow)
- [wxradar](#wxradar)

## [build-nvim-nightly](https://github.com/amazebb/scripts/blob/master/bin/build-nvim-nightly)

<pre>
<b>NAME</b>
    <b>build-nvim-nightly</b> - Pull latest neovim commit and build

<b>SYNOPSIS</b>
    <b>build-nvim-nightly [-h]</b> [<b>-r</b> <u>repo</u>] [<b>-d</b> <u>dir</u>]

<b>DESCRIPTION</b>
    Pulls the latest neovim commit from the local repo and builds
    a nightly release, installing it to the specified directory.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-r</b> <u>repo</u>   Local neovim repo <i>(default: $HOME/Code/GitHub/neovim)</i>

    <b>-d</b> <u>dir</u>    Install folder for nvim-nightly build <i>(default: $HOME/.nvim-nightly)</i>

<b>EXAMPLES</b>
    Build using defaults

        build-nvim-nightly

    Build from a custom repo location

        build-nvim-nightly -r ~/src/neovim -d ~/.local/nvim-nightly
</pre>

## [convertaudio](https://github.com/amazebb/scripts/blob/master/bin/convertaudio)

<pre>
<b>NAME</b>
    <b>convertaudio</b> - Convert audio files to AAC (.m4a) using ffmpeg

<b>SYNOPSIS</b>
    <b>convertaudio [-h] [-t types] [-s name] [--no-subfolder] [-d]</b> [<u>dir</u>]

<b>DESCRIPTION</b>
    Recursively finds audio files of the given types under <u>dir</u> and encodes
    them with the Apple AudioToolbox AAC encoder (aac_at, macOS ffmpeg only),
    keeping metadata and embedded cover art. Output goes to a subfolder of
    <u>dir</u> that mirrors the source tree. Existing outputs are skipped.

    Runs jobs in parallel with GNU parallel when installed, otherwise with xargs -P.
    Input files are kept unless <b>-d</b> is given. Running with no arguments shows
    this help.

<b>OPTIONS</b>
    <b>-h</b>              Show this help message

    <b>-t</b> <u>types</u>        Comma separated file types, e.g. <i>flac</i>, <i>.flac</i>, <i>*.flac</i> or
                    <i>flac,wav</i>. Files ffmpeg cannot convert are reported and skipped <i>(default: all files)</i>

    <b>-s</b> <u>name</u>         Subfolder for the encoded files <i>(default: convert)</i>

    <b>--no-subfolder</b>  Write each output next to its source file

    <b>-d</b>              Delete each input file after it converts successfully

    [<u>dir</u>]           Folder holding the music <i>(default: current directory)</i>

<b>EXAMPLES</b>
    Convert every audio file in the current folder into ./convert

        convertaudio .

    Convert flac and wav files in another folder

        convertaudio -t flac,wav ~/Music/Album

    Convert only flac files into a custom subfolder

        convertaudio -t flac -s aac ~/Music

    Write next to the originals and delete them afterwards

        convertaudio --no-subfolder -d ~/Music
</pre>

## [data-backup](https://github.com/amazebb/scripts/blob/master/bin/data-backup)

<pre>
<b>NAME</b>
    <b>data-backup</b> - Backup folders to encrypted sparse bundle in iCloud

<b>SYNOPSIS</b>
    <b>data-backup [-h] [-s bundle] [-m mountpoint]</b> <u>folder</u> [<u>folder</u> ...]

<b>DESCRIPTION</b>
    Compress folders with 7z and rsync them into an encrypted APFS sparse
    bundle stored in iCloud. Stops Gitea before backup and restarts it after.

<b>OPTIONS</b>
    <b>-h</b>            Show this help message

    <b>-s</b> <u>bundle</u>     Sparse bundle path <i>(default: ~/Library/Mobile Documents/.../SPARSE.sparsebundle)</i>

    <b>-m</b> <u>mountpoint</u> Mount point <i>(default: /Volumes/SPARSE)</i>

<b>EXAMPLES</b>
    Backup two folders to the default sparse bundle

        data-backup ~/Documents ~/Projects

    Create the sparse bundle (one-time setup)

        hdiutil create -size 10g -type SPARSEBUNDLE -fs APFS \
            -encryption -stdinpass -volname SPARSE \
            ~/Library/Mobile\ Documents/com~apple~CloudDocs/SPARSE.sparsebundle
</pre>

## [dedupe](https://github.com/amazebb/scripts/blob/master/bin/dedupe)

<pre>
<b>NAME</b>
    <b>dedupe</b> - Find duplicate files and offer to create symlinks

<b>SYNOPSIS</b>
    <b>dedupe [-h] [-e | -s | -w]</b> <u>search_directory</u>
    <b>dedupe -f</b> <u>hash_file</u>

<b>DESCRIPTION</b>
    Find duplicate files and offer to create symlinks.
    The search results including hash, filename and size are written to file.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-e</b> [<u>ext</u>]  Extensions to process ignoring-case <i>(default: all files)</i>
    
    <b>-s</b> <u>sym</u>    Preferred folder source for symlinks (<i>default: none specified</i>)
    
    <b>-w</b> [<u>file</u>] Output of duplicate search results (<i>default: $PWD/files.hash)</i> 
    
    <b>-f</b> <u>file</u>   Analyze previously generated search results file

    Zero byte files are ignored in the search.

<b>EXAMPLES</b>
    Find all duplicate Sony RAW images (ARW) searching recursively from current directory

        dedupe -e arw .
</pre>

## [disk-useage](https://github.com/amazebb/scripts/blob/master/bin/disk-useage)

<pre>
<b>NAME</b>
    <b>disk-useage</b> - Analyze disk usage by folder size

<b>SYNOPSIS</b>
    <b>disk-useage [-h] [-d depth] [-e pattern ...] [-v]</b> [<u>path</u> ...]

<b>DESCRIPTION</b>
    Summarizes disk usage for directories with configurable depth,
    exclusion patterns, and color-coded size output.

<b>OPTIONS</b>
    <b>-h</b>              Show this help message

    <b>-d</b> <u>depth</u>        Depth to traverse <i>(default: 1)</i>

    <b>-e</b> <u>pattern</u> ...  Space-separated list of patterns to exclude
                    <i>(default: .Trash*)</i>

    <b>-v</b>              Show permission denied errors

<b>EXAMPLES</b>
    Analyze Desktop and Downloads at depth 1

        disk-useage -d 1 Desktop Downloads

    Current dir, depth 2, exclude Lib and Trash, verbose

        disk-useage -d 2 -e ./Lib* ./Trash* -v
</pre>

## [exifmv](https://github.com/amazebb/scripts/blob/master/bin/exifmv)

<pre>
<b>NAME</b>
    <b>exifmv</b> - Organise files into date-based directories using EXIF metadata

<b>SYNOPSIS</b>
    <b>exifmv [-h] [-n] [-d fmt]</b> <u>source_dir</u> [<u>dest</u>]

<b>DESCRIPTION</b>
    Scans <u>source_dir</u> recursively with exiftool, extracts DateTimeOriginal
    from each file, and moves (or previews) files into a <i>YYYY/YYYYMMDD</i>
    directory tree under <u>dest</u> <i>(default: ./by-date)</i>.

    Files without date metadata are skipped. Name collisions are resolved
    by appending a numeric suffix.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-n</b>        Dry run — show what would be moved without moving

    <b>-d</b> <u>fmt</u>    Date format for directory structure <i>(default: %Y/%Y%m%d)</i>

<b>EXAMPLES</b>
    Preview what would happen

        exifmv -n /Volumes/SD/DCIM

    Move files into a custom destination

        exifmv /Volumes/SD/DCIM /Photos/Sorted

    Use a flat year-month directory structure

        exifmv -d '%Y-%m' /Volumes/SD/DCIM
</pre>

## [fext](https://github.com/amazebb/scripts/blob/master/bin/fext)

<pre>
<b>NAME</b>
    <b>fext</b> - Tally files by extension

<b>SYNOPSIS</b>
    <b>fext [-h] [-b] [-t type] [-s column]</b> [<u>path</u>]

<b>DESCRIPTION</b>
    Recursively tally files by extension under <u>path</u> <i>(default: .)</i>,
    restricted to <b>find</b> <b>-type</b> <u>type</u>. Outputs three columns:
    file count, total size (human-readable, B/K/M/G/T), extension.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-b</b>        Report allocated block size instead of logical size

    <b>-t</b> <u>type</u>   <b>find</b> file type <i>(default: f)</i>

    <b>-s</b> <u>column</u> Sort column: 1=count, 2=size, 3=extension <i>(default: 1)</i>

<b>EXAMPLES</b>
    Sort by size descending under current directory

        fext -s 2

    Tally directories under /tmp

        fext -t d /tmp
</pre>

## [fix-symlinks](https://github.com/amazebb/scripts/blob/master/bin/fix-symlinks)

<pre>
<b>NAME</b>
    <b>fix-symlinks</b> - Find broken symlinks and relink them from a source folder

<b>SYNOPSIS</b>
    <b>fix-symlinks [-h] [-n]</b> <u>source</u> [<u>target_dir</u>]

<b>DESCRIPTION</b>
    Recursively scans <u>target_dir</u> <i>(default: .)</i> for broken symlinks.
    For each broken symlink, searches <u>source</u> for a file with the same
    basename and extension. If a match is found, the symlink is replaced.

    When multiple matches are found in <u>source</u>, the first match is used
    and a warning is printed.

<b>OPTIONS</b>
    <b>-h</b>            Show this help message

    <b>-n</b>            Dry run — list broken symlinks and proposed targets

<b>EXAMPLES</b>
    Preview what would be relinked

        fix-symlinks -n /Volumes/Photos/Originals ~/Photos

    Fix broken symlinks in the current directory

        fix-symlinks /Volumes/Backup
</pre>

## [fz](https://github.com/amazebb/scripts/blob/master/bin/fz)

<pre>
<b>NAME</b>
    <b>fz</b> - Search text interactively with ripgrep and fzf

<b>SYNOPSIS</b>
    <b>fz [-h] [-l] [-i] [-g [true|false]] [-o option] [-r option]</b> <u>pattern</u> [<u>path</u>]

<b>DESCRIPTION</b>
    Interactive text search across configured directories using ripgrep
    for searching and fzf for filtering. Supports switching between
    ripgrep and fzf filtering modes, opening results in nvim, and
    building quickfix lists from multiple selections.

    If <u>path</u> is given, the search is restricted to that directory;
    otherwise the built-in folder list is searched (see <b>-l</b>).

    Folders marked <b>Git</b> by <b>-l</b> are inside a git work tree; for those,
    only files tracked by the repo (git ls-files) are searched. All
    other folders are searched in full with ripgrep.

<b>OPTIONS</b>
    <b>-h</b>          Show this help message

    <b>-l</b>          List the default search folders, one per line, and exit

    <b>-g</b> [<u>bool</u>]   Restrict search to git-tracked files. Optional value
                <b>true</b> or <b>false</b>; a bare <b>-g</b> means <b>true</b>. Without the
                flag, defaults to <b>true</b> for the built-in folder list and
                <b>false</b> when a manual <u>path</u> is given.

    <b>-i</b>, <b>--ignore-git-dir</b>
                Skip <b>.git</b> directories. Shorthand for <b>-o '-g=!.git'</b>.

    <b>-o</b> <u>option</u>   Pass an arbitrary option through to ripgrep
                <i>(e.g., -o '-g=!.git' to skip .git folders)</i>. May be
                repeated.

    <b>-r</b> <u>option</u>   Extend the ripgrep <b>--pre</b> preprocessor setup. Use
                this to add more <b>--pre-glob</b> patterns so additional file
                types are routed through <b>_pre-rg</b> before being searched
                <i>(e.g., -r "--pre-glob=*.docx")</i>. Not a general passthrough
                for arbitrary ripgrep flags.

<b>KEYBINDINGS</b>
    <b>CTRL-T</b>      Switch between ripgrep and fzf filtering
    <b>ALT-A</b>       Select all results
    <b>ALT-D</b>       Deselect all results
    <b>CTRL-P</b>      Toggle preview pane
    <b>ENTER</b>       Open in nvim (single) or quickfix (multi); returns to fzf
    <b>CTRL-O</b>      Same as ENTER

<b>EXAMPLES</b>
    Search for 'pattern' in all configured directories

        fz pattern

    Search for 'pattern' under a specific directory

        fz pattern ~/projects/foo

    Also preprocess .docx files through _pre-rg

        fz -r "--pre-glob=*.docx" pattern

    Skip .git folders while searching

        fz -i pattern
        fz -o "-g=!.git" pattern

    Search for just Project.toml files with an empty pattern ''.
    Skipping .git(-i), .vscode, and .julia folders.

        fz -i -o "-g=Project.toml" -o "-g=\!.julia" -o "-g=\!.vscode" -o "--files" '' ~/

    Search for a literal '-g'

        fz -- -g

    List the default search folders

        fz -l
</pre>

## [ghostty-theme](https://github.com/amazebb/scripts/blob/master/bin/ghostty-theme)

<pre>
<b>NAME</b>
    <b>ghostty-theme</b> - Cycle Ghostty themes in the current session

<b>SYNOPSIS</b>
    <b>ghostty-theme [-h]</b> [<u>color</u>]

<b>DESCRIPTION</b>
    Lists Ghostty themes and cycles them live in the current terminal.
    Colors apply to this session only; nothing is written to the
    Ghostty config.

    Keys: <b>j</b> / <b>k</b> or arrows to cycle, <b>Enter</b> to keep,
    <b>q</b> to quit.

<b>OPTIONS</b>
    <b>-h</b>         Show this help message

    [<u>color</u>]    <b>all</b>, <b>dark</b>, or <b>light</b> <i>(default: all)</i>

<b>EXAMPLES</b>
    Cycle all themes

        ghostty-theme

    Cycle dark themes only

        ghostty-theme dark
</pre>

## [gitea-cli](https://github.com/amazebb/scripts/blob/master/bin/gitea-cli)

<pre>
<b>NAME</b>
    <b>gitea-cli</b> - Manage Gitea server operations

<b>SYNOPSIS</b>
    <b>gitea-cli [-h]</b> <u>command</u>

<b>DESCRIPTION</b>
    Start, stop, check status, and view logs for a local Gitea server.

<b>COMMANDS</b>
    <b>start</b>     Start the Gitea server and open in Safari
    <b>stop</b>      Stop the Gitea server
    <b>status</b>    Show the Gitea running status
    <b>log</b>       Show Gitea server logs

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

<b>EXAMPLES</b>
    Start the server

        gitea-cli start

    View live logs

        gitea-cli log
</pre>

## [iplot](https://github.com/amazebb/scripts/blob/master/bin/iplot)

<pre>
<b>NAME</b>
    <b>iplot</b> - Plot functions in the Kitty terminal using gnuplot

<b>SYNOPSIS</b>
    <b>iplot [-h] [-s style] [-t title] [-x label] [-y label]</b> <u>expression</u> ...
    command | <b>iplot [-s style] [-t title] [-x label] [-y label]</b>

<b>DESCRIPTION</b>
    Renders gnuplot expressions inline in the Kitty terminal using
    kitten icat. Multiple expressions can be plotted together.

    When data is piped via stdin, plots it as a chart instead. Input
    should be whitespace or colon-separated <u>label value</u> pairs, one per line.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-s</b> <u>style</u>  Plot style for data mode <i>(default: boxes)</i>

    <b>-t</b> <u>title</u>  Chart title

    <b>-x</b> <u>label</u>  Label for the x-axis

    <b>-y</b> <u>label</u>  Label for the y-axis

<b>EXAMPLES</b>
    Plot a sine wave

        iplot "sin(x)"

    Plot multiple functions

        iplot 'sin(x) title "sin"' , 'cos(x) title "cos"'

    Plot data from stdin as a bar chart

        rawsync -c /Volumes/PHOTOS/by-date | iplot

    Plot data with lines

        cat data.txt | iplot -s linespoints -t "My Data"
</pre>

## [list-scripts](https://github.com/amazebb/scripts/blob/master/bin/list-scripts)

<pre>
<b>NAME</b>
    <b>list-scripts</b> - List user scripts

<b>SYNOPSIS</b>
    <b>list-scripts [-h] [-c]</b> [<u>script_directory</u>]

<b>DESCRIPTION</b>
    List scripts with description and optionally warn if there are issues
    <u>script_directory</u> defaults to <i>$HOME/.local/share/scripts/bin</i>

<b>OPTIONS</b>
    <b>-h</b> Show this help message

    <b>-c</b> Check for any issues, marking a script <b>WARN</b> when its
       checker reports anything. The checker depends on the file type
       shown in the <b>SHELL</b> column, since one linter does not cover
       them all:

           bash, sh, dash, ksh   <b>shellcheck -x</b> <i>(-x follows sourced files)</i>
           zsh                   <b>zsh -n</b>, a syntax check only, as
                                 <b>shellcheck</b> cannot parse zsh
           awk                   <b>gawk --lint=no-ext</b>, filtered to
                                 warnings. <i>no-ext</i> permits gawk
                                 extensions, which the scripts here rely on

<b>EXAMPLES</b>
    List all scripts and check for any issues

        list-scripts -c
</pre>

## [n3](https://github.com/amazebb/scripts/blob/master/bin/n3)

<pre>
<b>NAME</b>
    <b>n3</b> - Launch nnn with preview-tui

<b>SYNOPSIS</b>
    <b>n3 [-h] [-t]</b> [<u>nnn-args</u>...]

<b>DESCRIPTION</b>
    Launches <b>nnn</b> with the preview-tui plugin.
    In Ghostty 1.3+, preview-tui opens a native split (Cmd+D /
    new_split:right) via a dedicated AppleScript. Kitty uses native
    splits. Pass <b>-t</b> or set <b>N3_TMUX=1</b> to wrap nnn in tmux
    instead. Refuses to run when already inside an nnn subshell.
    Extra arguments are forwarded to <b>nnn</b>.

    On quit, cds into the directory <b>nnn</b> was last in via <i>NNN_TMPFILE</i>.

<b>OPTIONS</b>
    <b>-h</b>    Show this help message
    <b>-t</b>    Use tmux for the preview split (also <b>N3_TMUX=1</b>)

<b>EXAMPLES</b>
    Open in current directory

        n3

    Open with a tmux preview split

        n3 -t

    Open at a specific path

        n3 ~/projects
</pre>

## [netmon](https://github.com/amazebb/scripts/blob/master/bin/netmon)

<pre>
<b>NAME</b>
    <b>netmon</b> - Probe gateway, WAN and DNS health and log the results

<b>SYNOPSIS</b>
    <b>netmon [-h] [-f fmt] [-s sep] [-o file] [-i secs] [-n count] [-r]</b>
    <b>       [-g gateway] [-w wan] [-d resolver] [-q name]</b>

<b>DESCRIPTION</b>
    Pings the LAN gateway and a public WAN address, then queries the
    local DNS resolver, and appends one record per run to a log file.

    Records are written as <i>NDJSON</i> (one JSON object per line) or as
    delimited text. Both formats append; the file and, for <b>csv</b>, its
    header row are created on first run.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-f</b> <u>fmt</u>      Output format, <b>json</b> or <b>csv</b> <i>(default: json)</i>

    <b>-s</b> <u>sep</u>      Field separator for <b>csv</b> <i>(default: TAB)</i>

    <b>-o</b> <u>file</u>     Log file <i>(default: ~/netmon/probes.ndjson, or probes.csv)</i>

    <b>-i</b> <u>secs</u>     Repeat every <u>secs</u> seconds instead of running once

    <b>-n</b> <u>count</u>    Stop after <u>count</u> runs <i>(default: unlimited)</i>

    <b>-r</b>           Reset the log first, keeping the <b>csv</b> header

    <b>-g</b> <u>gateway</u>  LAN gateway to ping <i>(default: 192.168.1.1)</i>

    <b>-w</b> <u>wan</u>      WAN address to ping <i>(default: 9.9.9.9)</i>

    <b>-d</b> <u>resolver</u> DNS resolver to query <i>(default: 192.168.1.21)</i>

    <b>-q</b> <u>name</u>     Name to resolve <i>(default: cloudflare.com)</i>

<b>EXAMPLES</b>
    Single JSON probe appended to the default log

        netmon

    Tab separated log, reset before starting

        netmon -f csv -r

    Comma separated, every 60 seconds, to a custom file

        netmon -f csv -s , -i 60 -o ~/netmon/probes.csv

    Ten probes, one every 5 seconds

        netmon -i 5 -n 10

<b>SCHEDULING</b>
    Use <b>-i</b> for an ad-hoc foreground loop.

    To run in the background on a schedule, install the <b>launchd</b> agent
    <b>local.netmon</b>. Its plist and the instructions for installing,
    checking, stopping and removing it live in
    <i>~/.local/share/scripts/launchd/</i>.
</pre>

## [rawsync](https://github.com/amazebb/scripts/blob/master/bin/rawsync)

<pre>
<b>NAME</b>
    <b>rawsync</b> - RAW image backups and organizer

<b>SYNOPSIS</b>
    <b>rawsync [-h] [-c] [-d date] [-e ext] [-f day|month|fmt] [-s path]</b> <u>source_directory</u> [<u>target_directory</u>]

<b>DESCRIPTION</b>
    Use <b>rsync</b> to copy files from the <u>source_directory</u> to a backup destination <u>target_directory</u>.
    Additionally a <i>raw-by-day</i> (or <i>raw-by-month</i>) folder is created with symlinks to the
    backups to make browsing for files by date easier. By default this folder is placed
    inside the RAW folder (the <u>target_directory</u>, or the <u>source_directory</u> if no target
    is given); use <b>-s</b> to override that location.
    If only the <u>source_directory</u> is given then only symlinks are created.
    The <b>exiftool</b> is used to extract date information from the files to create the symlinks.
    Symlinks are named <i>yyyymmdd_HHMMSS-TZ.ext</i> (e.g. <i>20260101_163523-0700.ARW</i>) using the
    EXIF timezone offset, with a fallback to the file modification date timezone when it
    matches DateTimeOriginal to the second.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-c</b>        Count symlinks and files in date folders and exit

    <b>-e</b> <u>ext</u>    Extensions to process <i>(default: *.ARW)</i>

    <b>-d</b> <u>date</u>   Create symlinks for files modified after <u>date</u> <i>(default: 1970-01-01)</i>

    <b>-f</b> <u>fmt</u>    Date grouping for symlinks: <b>day</b> creates <i>raw-by-day/%Y/%Y%m%d</i>,
              <b>month</b> creates <i>raw-by-month/%Y/%Y%m</i>, or pass any <b>gdate</b> format
              string (e.g. <i>%Y/%Y%m</i>) to use it directly — the parent folder is
              named <i>raw-by-</i><u>fmt</u> with % stripped and / replaced by _
              <i>(default: day)</i>

    <b>-s</b> <u>path</u>   Parent folder for the <i>raw-by-day</i>/<i>raw-by-month</i> folder
              <i>(default: inside the RAW folder)</i>

<b>EXAMPLES</b>
    Backup all files from attached camera volume SD1 to an external SSD,
    creating symlinks in /Volumes/PHOTOS/RAW/raw-by-day/

        rawsync "/Volumes/SD1/DCIM" "/Volumes/PHOTOS/RAW"

    Create only symlinks in /Volumes/PHOTOS/RAW/raw-by-day/ from the RAW folder

        rawsync "/Volumes/PHOTOS/RAW"

    Create only symlinks in /Volumes/PHOTOS/RAW/raw-by-month/ grouped by month

        rawsync -f month "/Volumes/PHOTOS/RAW"

    Place the <i>raw-by-day</i> folder at the volume root instead of inside the RAW folder

        rawsync -s /Volumes/PHOTOS "/Volumes/PHOTOS/RAW"

    Create only symlinks for files taken after 2025-12-01

        rawsync -d 2025-12-01 "/Volumes/SD1/DCIM" "/Volumes/PHOTOS/RAW"

    Create only symlinks for CR3 raw files

        rawsync -e '*.CR3' "/Volumes/PHOTOS/RAW"

    Count symlinks and files in date folders

        rawsync -c "/Volumes/PHOTOS/RAW/raw-by-day"
</pre>

## [shtoc](https://github.com/amazebb/scripts/blob/master/bin/shtoc)

<pre>
<b>NAME</b>
    <b>shtoc</b> - Summarize shell script usages as a single TOC-linked markdown

<b>SYNOPSIS</b>
    <b>shtoc [-h]</b> <u>dir</u>

<b>DESCRIPTION</b>
    Scans <u>dir</u> for bash shell scripts and emits a
    single markdown document to stdout. The document opens with a table
    of contents that links to one anchor per script, followed by each
    script's usage() body as produced by <b>shtomd</b>.

    A file is treated as a shell script when its first line contains a
    bash or sh shebang. Scripts without a <b>usage</b>() heredoc are
    skipped with a notice on stderr.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

<b>EXAMPLES</b>
    Summarize all scripts in bin/

        shtoc bin &gt; scripts.md

    Summarize scripts in the current directory

        shtoc . &gt; scripts.md
</pre>

## [shtomd](https://github.com/amazebb/scripts/blob/master/bin/shtomd)

<pre>
<b>NAME</b>
    <b>shtomd</b> - Convert a script's usage() heredoc to markdown

<b>SYNOPSIS</b>
    <b>shtomd [-h]</b> <u>script</u>

<b>DESCRIPTION</b>
    Reads <u>script</u>, locates the heredoc body inside its <b>usage</b>()
    function, and emits it wrapped in an HTML <i>&lt;pre&gt;</i> block so that the
    original indentation is preserved while still allowing inline formatting
    to render in markdown viewers.

    The formatting helper calls are rewritten inline: <i>$(B x)</i> becomes
    <i>&lt;b&gt;x&lt;/b&gt;</i>, <i>$(U x)</i> becomes <i>&lt;u&gt;x&lt;/u&gt;</i>, and
    <i>$(I x)</i> becomes <i>&lt;i&gt;x&lt;/i&gt;</i>. Surrounding single or double
    quotes around the argument are stripped.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

<b>EXAMPLES</b>
    Print the usage of a script as markdown

        shtomd bin/exifmv

    Write the usage to a file

        shtomd bin/exifmv &gt; exifmv.md
</pre>

## [vbrhist](https://github.com/amazebb/scripts/blob/master/bin/vbrhist)

<pre>
<b>NAME</b>
    <b>vbrhist</b> - Histogram of audio packet bitrates to show VBR behaviour

<b>SYNOPSIS</b>
    <b>vbrhist [-h] [-t] [-u unit] [-y axis] [-b bins]</b> <u>file</u>

<b>DESCRIPTION</b>
    Reads the packets of the first audio stream in <u>file</u> with ffprobe and
    buckets them by bitrate or by size. A wide spread means variable bitrate;
    one tall bar means constant bitrate. The first packet is skipped as it only
    primes the encoder.

    Draws a chart with <b>iplot</b> in Kitty or Ghostty, otherwise prints bars.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-t</b>           Print text bars even in a graphics terminal

    <b>-u</b> <u>unit</u>      <i>kbps</i> buckets packets by their bitrate, <i>bytes</i> by their size
                 <i>(default: kbps)</i>

    <b>-y</b> <u>axis</u>      <i>norm</i> shows each bucket as a percentage of all packets, <i>count</i> shows
                 packet counts <i>(default: norm)</i>

    <b>-b</b> <u>bins</u>      Number of buckets spanning the min to max value <i>(default: 20)</i>

    <u>file</u>         Audio file to inspect

<b>EXAMPLES</b>
    Check a converted file

        vbrhist convert/Album/01.m4a

    Packet sizes in bytes instead of bitrate

        vbrhist -u bytes song.m4a

    Raw packet counts on the y-axis

        vbrhist -y count song.m4a

    More buckets as text

        vbrhist -t -b 40 song.m4a
</pre>

## [wxalerts](https://github.com/amazebb/scripts/blob/master/bin/wxalerts)

<pre>
<b>NAME</b>
    <b>wxalerts</b> - Show the active weather alerts for a US location

<b>SYNOPSIS</b>
    <b>wxalerts [-h] [-b] [-l]</b> [<u>location</u>]

<b>DESCRIPTION</b>
    Lists the watches, warnings and advisories the National Weather Service has in
    effect for the point, most severe first, each with its severity, when it starts and ends,
    the headline and the affected area. Prints nothing special when there are none.
    With no <u>location</u> your IP address is used. US only.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-b</b>           Brief: one line per alert, and nothing at all when there are none

    <b>-l</b>           Long: also print the full description and instructions

    [<u>location</u>]    One of the following <i>(default: your IP location)</i>

                  <i>10001</i>               zip code
                  <i>40.71,-74.0</i>         latitude,longitude

<b>EXAMPLES</b>
    Alerts where you are

        wxalerts

    One line per alert for a zip code

        wxalerts -b 60601

    The full text of every alert

        wxalerts -l
</pre>

## [wxforecast](https://github.com/amazebb/scripts/blob/master/bin/wxforecast)

<pre>
<b>NAME</b>
    <b>wxforecast</b> - Print the hourly or daily weather forecast for a US location

<b>SYNOPSIS</b>
    <b>wxforecast [-h] [-A] [-d] [-r] [-y metric [metric2]] [-u units] [-n count]</b> [<u>location</u>]

<b>DESCRIPTION</b>
    Draws a chart of the National Weather Service hourly forecast (free, no key), with
    time along the x axis, the y metric as a dot per hour and a weather emoji for each
    hour under the axis. The chart shows as many hours as fit the terminal width.
    With <b>-r</b> it prints one raw line per hour instead, with the temperature, feels-like,
    dew point, humidity, cloud cover, chance of rain, expected rainfall, wind gust, wind and
    conditions. Snowfall and visibility are chart-only metrics. With <b>-d</b> it shows the daily forecast
    instead: a chart of the high and low with the chance of rain, or with <b>-r</b> one line per day
    with the high, low, chance of rain, wind and conditions.
    With no <u>location</u> your IP address is used. US only.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-A</b>           Do not show active weather alerts at the top. By default one line per
                  alert is printed first, from <b>wxalerts</b>

    <b>-d</b>           Print the daily forecast as a chart of the high and low temperature with
                  the chance of rain on a right hand axis, or one line per day with <b>-r</b>.
                  <b>-y</b> does not apply

    <b>-r</b>           Print raw rows, one line per hour, instead of the chart

    <b>-y</b> <u>metric</u> [<u>metric2</u>]  Value for the chart y axis <i>(default: temp qpf)</i>. A second metric
                  goes on a right hand axis with its own scale, drawn as orange <i>◆</i>
                  markers and labels. Wind and gust use an arrow pointing the way the wind blows

                  <i>temp</i>    temperature          <i>rain</i>   chance of rain
                  <i>feels</i>   feels-like           <i>qpf</i>    expected rainfall
                  <i>dew</i>     dew point            <i>snow</i>   expected snowfall
                  <i>hum</i>     relative humidity    <i>wind</i>   wind speed
                  <i>cloud</i>   cloud cover          <i>gust</i>   wind gust
                                                <i>vis</i>    visibility

    <b>-u</b> <u>units</u>    <i>imperial</i> (°F, mph, in) or <i>si</i> (°C, km/h, mm) <i>(default: imperial)</i>

    <b>-n</b> <u>count</u>    Number of hours to show, 1 to 156, or days with <b>-d</b>, 1 to 7
                  <i>(default: 24 hours, 7 days)</i>

    [<u>location</u>]    One of the following <i>(default: your IP location)</i>

                  <i>10001</i>               zip code
                  <i>40.71,-74.0</i>         latitude,longitude

<b>EXAMPLES</b>
    Temperature and expected rainfall chart with weather emoji for where you are

        wxforecast

    Expected rainfall chart for a zip code

        wxforecast -y qpf 60601

    Relative humidity chart

        wxforecast -y hum

    The week ahead

        wxforecast -d

    Temperature only

        wxforecast -y temp

    Temperature with wind direction arrows

        wxforecast -y temp wind

    Raw rows for the next 48 hours

        wxforecast -r -n 48 60601
</pre>

## [wxnow](https://github.com/amazebb/scripts/blob/master/bin/wxnow)

<pre>
<b>NAME</b>
    <b>wxnow</b> - Show the current weather observed at the nearest station

<b>SYNOPSIS</b>
    <b>wxnow [-h] [-u units]</b> [<u>location</u>]

<b>DESCRIPTION</b>
    Prints what the nearest National Weather Service observation station is measuring
    now: temperature, feels-like, dew point, humidity, wind, pressure, visibility and
    recent rainfall, with the station name and when it was observed. These are
    measurements, not a forecast. Stations that report nothing are skipped and the next
    nearest is used. With no <u>location</u> your IP address is used. US only.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-u</b> <u>units</u>    <i>imperial</i> (°F, mph, inHg, mi, in) or <i>si</i> (°C, km/h, hPa, km, mm) <i>(default: imperial)</i>

    [<u>location</u>]    One of the following <i>(default: your IP location)</i>

                  <i>10001</i>               zip code
                  <i>40.71,-74.0</i>         latitude,longitude
                  <i>KNYC</i>                observation station id

<b>EXAMPLES</b>
    Conditions where you are

        wxnow

    Conditions at a station in SI units

        wxnow -u si KNYC
</pre>

## [wxradar](https://github.com/amazebb/scripts/blob/master/bin/wxradar)

<pre>
<b>NAME</b>
    <b>wxradar</b> - Show an animated weather radar loop around a US location

<b>SYNOPSIS</b>
    <b>wxradar [-h] [-m] [-n] [-l] [-s] [-R] [-f [metric [metric2]]] [-r miles] [-F fps]</b> [<u>location</u>]

<b>DESCRIPTION</b>
    Builds a radar loop centred on <u>location</u> from RainViewer radar tiles over a
    map, covering <b>-r</b> miles in every direction. With no <u>location</u> your IP address
    is used. With <b>-n</b>, or for a radar station or region name, the fixed NWS loop from
    radar.weather.gov is played instead (nearest station, about 140 miles) and
    <b>-r</b> and <b>-F</b> are ignored. Only the RainViewer loop needs ffmpeg.
    Map data is from OpenStreetMap, radar from RainViewer.

    In kitty or ghostty the gif is drawn directly in the terminal with <b>chafa</b>
    (<i>Ctrl-C</i> to quit) or <b>kitten</b> if installed, otherwise it is played with mpv.

<b>OPTIONS</b>
    <b>-h</b>           Show this help message

    <b>-m</b>           Play with mpv even when the terminal can show the gif itself

    <b>-n</b>           Play the NWS loop of the nearest radar station

    <b>-l</b>           Show only the latest radar image instead of the loop

    <b>-s</b>           Scale the image up to fill the terminal height, less the height of
                  the <b>-f</b> forecast <i>(fullscreen with mpv)</i>

    <b>-f</b> [<u>metric</u> [<u>metric2</u>]]
                  Choose the <b>wxforecast</b> y axis metrics for the chart shown above the
                  radar <i>(default: temp qpf)</i>. The chart is shown by default for a zip,
                  latitude,longitude or your IP location, and is skipped for station and
                  region names. Giving <b>-f</b> with a name is an error

    <b>-R</b>           Radar only, no forecast chart

    <b>-r</b> <u>miles</u>    Radius to show, about 10 to 400 <i>(default: 50)</i>

    <b>-F</b> <u>fps</u>      Frames per second of the RainViewer loop, 0.1 to 30 <i>(default: 1)</i>

    [<u>location</u>]    One of the following <i>(default: your IP location)</i>

                  <i>10001</i>               zip code
                  <i>40.71,-74.0</i>         latitude,longitude
                  <i>KOKX</i>                NWS radar station, e.g. KOKX, KDIX, KLOT
                  <i>northeast</i>           NWS region loop:
                                      northeast southeast southmissvly southplains
                                      northrockies uppermissvly centgrlakes conus
                                      alaska hawaii carib guam

<b>EXAMPLES</b>
    Radar within 50 miles of where you are

        wxradar

    Radar within 100 miles of a zip code

        wxradar -r 100 60601

    The forecast chart above a radar filling the rest of the terminal

        wxradar -s 60601

    Radar only

        wxradar -R 60601

    The forecast chart with humidity and wind gusts

        wxradar -f hum gust 60601

    The latest image only

        wxradar -l

    The whole northeast

        wxradar northeast
</pre>

