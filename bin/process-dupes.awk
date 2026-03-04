function summary() {
    total = 0
    num_files = 0
    total_dupes = 0
    no_link = 0

    for (i = 1; i <= length(count); i++) {
        if (count[i] > 1) {
            wasted = (count[i] - 1) * sizes[i]
            total += wasted
            num_files++
            total_dupes += count[i]

            num_dupes = split(files[i], arr, "\n")

            source = ""
            # pick preferred leader: first one that starts with PREF_DUPE_DIR
            if (PREF_DUPE_DIR != "") {
                for (j = 1; j <= num_dupes; j++) {
                    if (index(arr[j], PREF_DUPE_DIR) == 1) {
                        source = arr[j]
                        break
                    }
                }
            }

            printf(\
                "# dupes: %d  wasted: %.1f MiB\n",
                count[i] - 1,
                wasted / 1024 / 1024\
            )

            for (j = 1; j <= num_dupes; j++) {
                if (arr[j] != source && source != "") {
                    if (LINK_DRY_RUN == "yes") {
                        printf("ln -sf \"%s\" \"%s\"\n", source, arr[j])
                    }
                    else {
                        cmd = sprintf("ln -sf \"%s\" \"%s\"", source, arr[j])

                        if (system(cmd) != 0) {
                            print\
                                "Error: Failed to create symlink " arr[j]\
                                    " -> "\
                                    source > "/dev/stderr"
                        }
                    }
                }
                else if (source == "") {
                    no_link++
                    printf("%s\n", arr[j])
                }
            }
        }

        printf("\n")
    }

    printf("Total wasted: %.1f MiB\n", total / 1024 / 1024)
    printf("Duplicate files: %d\n", total_dupes)
    printf("Unique duplicates: %d\n", num_files)
    printf("Could symlink: %d\n", total_dupes - num_files)

    if (no_link && PREF_DUPE_DIR != "")
        printf("%d groups of files could not be symlinked\n", no_link)
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
