function summary() {
    total = 0
    num_files = 0
    total_dupes = 0
    no_link_group = 0
    no_link_files = 0
    no_link_wasted = 0

    for (i = 1; i <= length(count); i++) {
        if (count[i] <= 1) continue

        wasted = (count[i] - 1) * sizes[i]
        total += wasted
        num_files++
        total_dupes += count[i]

        num_dupes = split(files[i], dupe_files, "\n")

        target = ""
        # pick preferred leader: first one that starts with PREF_DUPE_DIR
        if (PREF_DUPE_DIR != "") {
            for (j = 1; j <= num_dupes; j++) {
                if (index(dupe_files[j], PREF_DUPE_DIR) == 1) {
                    target = dupe_files[j]
                    break
                }
            }
        }

        printf("# dupes: %d  ", count[i] - 1)
        pretty_bytes(wasted)

        if (target == "") {
            if (PREF_DUPE_DIR != "") {
                no_link_group++
                no_link_files += count[i]
                no_link_wasted += wasted
                printf("No target for symlink\n")
            }

            printf("%s\n\n", files[i])

            continue
        }

        for (j = 1; j <= num_dupes; j++) {
            if (dupe_files[j] != target) {
                printf("ln -sf \"%s\" \"%s\"\n", target, dupe_files[j])

                if (DRY_RUN == "d") continue

                cmd = sprintf("ln -sf \"%s\" \"%s\"", target, dupe_files[j])

                if (system(cmd) != 0) {
                    print\
                        "Error: Failed to create symlink " dupe_files[j] " -> "\
                            target > "/dev/stderr"
                }
            }
        }

        printf("\n")
    }

    if (total) {
        printf("Duplicate size: %.1f MiB\n", total / 1024 / 1024)
        printf("Duplicate files: %d\n", total_dupes)
        printf("Unique duplicates: %d\n", num_files)
        printf("Number of symlink: %d\n", total_dupes - num_files)

        if (no_link_group && PREF_DUPE_DIR != "") {
            printf(\
                "\nCould not symlink:\nGroups: %d\nFiles: %d\nWasted: ",
                no_link_group,
                no_link_files\
            )
            pretty_bytes(no_link_wasted)
        }
    }
    else print "No duplicates found"
}

function pretty_bytes(sz) {
    if (sz >= 1024 * 1024 * 1024) printf("%.1f GiB\n", sz / 1024 / 1024 / 1024)
    else if (sz >= 1024 * 1024) printf("%.1f MiB\n", sz / 1024 / 1024)
    else if (sz >= 1024) printf("%.1f KiB\n", sz / 1024)
    else printf("%d Bi\n", sz)
}

function sort_arrays(_sorted_count, _sorted_files, _sorted_sizes, i) {
    n = asorti(count, s, "@val_num_asc")

    # Sorted associative array:
    for (i = 1; i <= n; i++) {
        k = s[i]
        _sorted_files[i] = files[k]
        _sorted_sizes[i] = sizes[k]
        _sorted_count[i] = count[k]
    }

    delete files
    delete count
    delete sizes

    for (i = 1; i <= n; i++) {
        count[i] = _sorted_count[i]
        files[i] = _sorted_files[i]
        sizes[i] = _sorted_sizes[i]
    }
}

{
    hash = $1
    file = $2
    size = $3
    count[hash]++
    files[hash] = files[hash] (count[hash] == 1 ? "" : "\n") file
    sizes[hash] = size
}

END {
    sort_arrays()
    summary()
}
