# Scripts

## Table of Contents

- [build-nvim-nightly](#build-nvim-nightly)
- [data-backup](#data-backup)
- [dedupe](#dedupe)
- [disk-useage](#disk-useage)
- [exifmv](#exifmv)
- [fext](#fext)
- [fix-symlinks](#fix-symlinks)
- [fz](#fz)
- [gitea-cli](#gitea-cli)
- [iplot](#iplot)
- [list-scripts](#list-scripts)
- [rawsync](#rawsync)
- [shtoc](#shtoc)
- [shtomd](#shtomd)

## build-nvim-nightly

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

## data-backup

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

## dedupe

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

## disk-useage

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

## exifmv

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

## fext

<pre>
<b>NAME</b>
    <b>fext</b> - Tally files by extension

<b>SYNOPSIS</b>
    <b>fext [-h] [-t type] [-s column]</b> [<u>path</u>]

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

## fix-symlinks

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

## fz

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

    Search for a literal '-g'

        fz -- -g

    List the default search folders

        fz -l
</pre>

## gitea-cli

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

## iplot

<pre>
<b>NAME</b>
    <b>iplot</b> - Plot functions in the Kitty terminal using gnuplot

<b>SYNOPSIS</b>
    <b>iplot [-h] [-s style] [-t title]</b> <u>expression</u> ...
    command | <b>iplot [-s style] [-t title]</b>

<b>DESCRIPTION</b>
    Renders gnuplot expressions inline in the Kitty terminal using
    kitten icat. Multiple expressions can be plotted together.

    When data is piped via stdin, plots it as a chart instead. Input
    should be whitespace or colon-separated <u>label value</u> pairs, one per line.

<b>OPTIONS</b>
    <b>-h</b>        Show this help message

    <b>-s</b> <u>style</u>  Plot style for data mode <i>(default: boxes)</i>

    <b>-t</b> <u>title</u>  Chart title

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

## list-scripts

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

    <b>-c</b> Check for any issues

<b>EXAMPLES</b>
    List all scripts and check for any issues

        list-scripts -c
</pre>

## rawsync

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

## shtoc

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

## shtomd

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

    The tput-helper calls are rewritten inline: <i>$(B x)</i> becomes
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

