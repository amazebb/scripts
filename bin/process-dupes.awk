function summary(hash, count, files, sizes) {
    total = 0
    num_files = 0
    total_dupes = 0

    for (hash in count) {
        if (count[hash] > 1) {
            wasted = (count[hash] - 1) * sizes[hash]
            total += wasted
            num_files++
            total_dupes += count[hash]

            # split files into array
            n = split(files[hash], arr, "\n")

            # pick preferred leader: first one that starts with prefer path
            source = arr[1]

            for (i = 1; i <= n; i++) {
                if (index(arr[i], prefer) == 1) {
                    source = arr[i]
                    break
                }
            }

            printf(\
                "# dupes: %d  wasted: %.1f MiB\n",
                count[hash],
                wasted / 1024 / 1024\
            )
            printf("# leader: %s\n", source)

            for (i = 1; i <= n; i++) {
                if (arr[i] != source) {
                    printf("ln -sf %s %s\n", source, arr[i])
                }
            }

            printf("\n")
        }
    }

    printf("# Total wasted: %.1f MiB\n", total / 1024 / 1024)
    printf("# Unique duplicates: %d\n", num_files)
    printf("# Duplicate files: %d\n", total_dupes)
    printf("# Could symlink %d files\n", total_dupes - num_files)
}

function sort_arrays(nums, a) {
    for (k in a) temp[k] = nums[k]

    asorti(temp, sorted_keys)

    # Now sorted associative array:
    for (i = 1; i <= n; i++) {
        key = sorted_keys[i]
        sorted_a[key] = a[key]
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

END { summary(hash, count, files, sizes) }
