# shutterflow — a RAW image workflow

A practical end-to-end workflow for managing RAW (or any image) files using
four scripts from this repo: **rawsync**, **dedupe**, **fix-symlinks**, and
**exifmv**. Each step addresses a real problem you'll hit while shooting,
backing up, and archiving over time.

The scenario: you shoot a few hundred RAW frames on an outing, pull the card,
and want a predictable, safe way to get them into long-term storage without
losing a file, duplicating a file, or breaking your date-browsing folder.

**Prerequisite**: `dedupe` shells out to
[broeknbytes/rapidhash](https://github.com/broeknbytes/rapidhash) for the
actual hashing step. Install it first — see that repo's README. The rest of
the scripts rely on standard tools (`rsync`, `exiftool`, `gdate`).

---

## 1. Ingest: back up the card with `rawsync`

Straight after a shoot the camera card is the only copy. First priority is to
get the files onto the backup drive with a verifiable, resumable copy, and to
make them browsable by date without physically reorganising the originals.

`rawsync` wraps `rsync` for the copy, and then uses `exiftool` to build a
parallel `raw-by-day/YYYY/YYYYMMDD/` tree of symlinks that point back into the
flat rsync target. You keep the rsync-friendly flat structure for the real
files, and get a date-indexed browsing layer for free.

By default `rawsync` targets Sony `*.ARW` files — that's a deliberate default
matching the primary shooter this repo was built for, not a hard constraint.
Pass `-e` to process any other RAW extension (`*.CR3`, `*.NEF`, `*.RAF`,
`*.DNG`, etc.) or JPEGs.

```bash
rawsync /Volumes/SD1/DCIM /Volumes/PHOTOS/RAW
```

That copies everything from the card into `/Volumes/PHOTOS/RAW/` and creates
`/Volumes/PHOTOS/RAW/raw-by-day/2026/20260119/` (etc.) full of symlinks named
by EXIF capture time (`20260119_143022-0700.ARW`). You can now open the
by-day folder in Finder or an image viewer and scrub through the shoot in
chronological order.

Real-world variants:

- **Multiple cards in one outing**: run `rawsync` once per card with the
  same target; the rsync layer handles it, and the symlink layer gets
  rebuilt.
- **Only re-generate symlinks** (e.g. after importing files manually):
  pass just the target:

  ```bash
  rawsync /Volumes/PHOTOS/RAW
  ```

- **Long trip with a lot of frames** and you only want the last week
  symlinked for review:

  ```bash
  rawsync -d 2026-01-15 /Volumes/PHOTOS/RAW
  ```

- **Canon shooter** or mixed-format archive:

  ```bash
  rawsync -e '*.CR3' /Volumes/PHOTOS/RAW
  ```

At the end of this step you have a complete, resumable backup and a date-
indexed browsing layer. The card can safely be reformatted.

---

## 2. Deduplicate: find repeat frames with `dedupe`

Over time, duplicates creep in. You copy the same card twice. You pull a
rescue copy off an old backup drive. You import a session from a friend that
overlaps with yours. The files are byte-identical but sitting in two places,
each eating disk.

`dedupe` hashes every file matching an extension, groups by hash, and offers
to replace duplicates with symlinks pointing at a preferred source location —
so you keep one real copy and reclaim the space without breaking any
reference that expects the file to exist at its old path.

The hashing itself is done by
[broeknbytes/rapidhash](https://github.com/broeknbytes/rapidhash), chosen
because RAW files are large (often 40–80 MB each) and a RAW archive can run
to tens of thousands of them. rapidhash is throughput-oriented and
parallelised (`dedupe` invokes it with `-j 40`), so hashing a full archive
completes in a reasonable time instead of bottlenecking on a slower
cryptographic hash you don't need for duplicate detection.

```bash
dedupe -e arw /Volumes/PHOTOS/RAW
```

That scans the RAW tree for ARW files, writes a `files.hash` report, and
walks you through duplicate groups interactively.

Real-world variants:

- **Prefer the canonical archive as the source of truth** when collapsing
  duplicates:

  ```bash
  dedupe -e arw -s /Volumes/PHOTOS/RAW/Archive /Volumes/PHOTOS/RAW
  ```

- **Re-review an existing hash report** without re-hashing everything:

  ```bash
  dedupe -f /Volumes/PHOTOS/RAW/files.hash
  ```

- **Multi-format shooter**: run once per extension (`arw`, `cr3`, `nef`,
  `dng`, `jpg`) so each format's hash report is separate and interactive
  prompts stay focused.

Because `dedupe` replaces duplicates with symlinks rather than deleting them,
paths you may have baked into Lightroom catalogs, scripts, or backup
manifests keep working — but it also sets up the next problem.

---

## 3. Repair: relink broken symlinks with `fix-symlinks`

Symlinks break. You moved `/Volumes/PHOTOS/RAW/Archive` to a new drive. You
re-ingested a card and the rsync target path shifted. You pruned a staging
folder that a `dedupe` run had pointed into. Suddenly your `raw-by-day/`
tree — or any other symlink layer — is full of red links.

`fix-symlinks` scans a target directory for broken symlinks, looks up each
one's basename in a source directory, and relinks it to the match.

```bash
fix-symlinks -n /Volumes/PHOTOS/RAW /Volumes/PHOTOS/RAW/raw-by-day
```

The dry run (`-n`) shows you exactly what would be relinked before you
commit. Once you're happy:

```bash
fix-symlinks /Volumes/PHOTOS/RAW /Volumes/PHOTOS/RAW/raw-by-day
```

Real-world variants:

- **Migrated the archive to a new volume**, and `raw-by-day` still points
  at the old paths:

  ```bash
  fix-symlinks /Volumes/NEW_PHOTOS/RAW /Volumes/PHOTOS/RAW/raw-by-day
  ```

- **Cross-mount rescue**: a Lightroom-adjacent symlink tree lost its
  targets, and you want to repoint it at the master archive:

  ```bash
  fix-symlinks -n /Volumes/PHOTOS/RAW ~/Pictures/Lightroom/Smart\ Previews
  ```

This step pairs naturally with `dedupe` and with anything that moves real
files around — run it any time originals relocate.

---

## 4. Archive: organise with `exifmv`

`rawsync` gives you a symlink-based date view over a flat backup — great for
day-to-day browsing. But for long-term archival of keepers, exports, or JPEGs
delivered to clients, you often want the *real files* laid out by date, not
just a symlink layer.

`exifmv` moves files into a `YYYY/YYYYMMDD/` tree based on EXIF
DateTimeOriginal. That's your long-term, self-describing archive: every file
sits in a folder that says when it was taken.

```bash
exifmv -n /Volumes/PHOTOS/Exports /Volumes/PHOTOS/Archive
```

Dry-run first — `exifmv` actually moves files, so preview before commit.

```bash
exifmv /Volumes/PHOTOS/Exports /Volumes/PHOTOS/Archive
```

Real-world variants:

- **Client delivery pipeline**: you export selects to a staging folder
  during culling, then archive them in one move at the end of the session.
- **Legacy dump from a hard drive of forgotten JPEGs** with no folder
  structure:

  ```bash
  exifmv ~/Downloads/old-camera-dump ~/Pictures/Archive
  ```

- **Monthly rather than daily granularity** for a denser archive:

  ```bash
  exifmv -d '%Y/%Y-%m' /Volumes/PHOTOS/Exports /Volumes/PHOTOS/Archive
  ```

Files without DateTimeOriginal are skipped — that's a feature. It means a
stray `.DS_Store` or a screenshot won't land in your archive tree.

---

## Putting it together

A typical monthly rhythm:

1. After every shoot: `rawsync` card → backup drive.
2. At month end, across the RAW tree: `dedupe -e arw` to collapse repeats.
3. After any drive move or `dedupe` session: `fix-symlinks -n` on the
   `raw-by-day` tree, then commit.
4. For keepers and client deliverables: `exifmv` from staging into the
   archive.

The four scripts compose because they each respect one assumption: that
the real files live somewhere stable and that date-based views are symlink
layers over that reality. Back up flat, browse by date, dedupe conservatively,
repair when things move, and only promote to the dated archive when a file is
worth keeping.
