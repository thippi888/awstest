#!/bin/bash
IFS=$'\n'
root_dir=$(git rev-parse --show-toplevel)
pushd "$root_dir" || exit
git_files=$(git ls-files)

# for files
for FILE in ${git_files}; do
    is_change=$(git diff "$FILE")
    if [ -n "$is_change" ]; then
        continue
    fi
    TIME=$(git log --pretty=format:%cI -n1 "$FILE") # iso-8601 format commit date
    printf '%s\t%s\n' "$TIME" "$FILE"
    STAMP=$(date -d "$TIME" +"%y%m%d%H%M.%S")
    touch -t "$STAMP" "$FILE"
    # touch -d "$TIME" "$FILE"
done

# for directories
# shellcheck disable=SC2086
file_list=$(ls -1atrd $git_files)
for FILE in ${file_list}; do
    TIME=$(date -r "$FILE" '+%Y-%m-%dT%H:%M:%S%:z')
    printf '%s\t%s\n' "$TIME" "$(dirname "$FILE")"
    STAMP=$(date -d "$TIME" +"%y%m%d%H%M.%S")
    touch -t "$STAMP" "$(dirname "$FILE")"
    # touch -d "$TIME" "$FILE"
done

popd || exit
