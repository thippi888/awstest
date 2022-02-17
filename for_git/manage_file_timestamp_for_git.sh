#!/bin/bash
IFS=$'\n'
root_dir=$(git rev-parse --show-toplevel 2>tmp.txt)
rm tmp.txt
if [ -z "$root_dir" ]; then
    git init
fi
pushd "$root_dir" || exit
file_list=$(find "$(pwd)" -type f -not -path "*/.git/*")
is_first_commit=$(git branch)
if [ -z "$is_first_commit" ]; then
    # shellcheck disable=SC2086,2012
    oldest_file_name=$(ls -1atrd $file_list | head -1)
    date_info=$(date -r "$oldest_file_name" '+%Y-%m-%dT%H:%M:%S%:z') # iso 8601 format
    GIT_COMMITTER_DATE=\"$date_info\" git commit --allow-empty -m "first commit" --date "$date_info"
fi
# shellcheck disable=SC2086
old_file_list=$(ls -1atrd $file_list)
for file in ${old_file_list}; do
    echo "$file"
    base_name=$(basename "$file")
    dir_name=$(dirname "$file")
    is_ignore=$(
        cd "$dir_name" || exit
        git ls-files "$base_name" --other --ignored --exclude-standard
    )
    if [ -n "$is_ignore" ]; then
        continue
    fi
    pushd "$dir_name" || exit
    is_tracked=$(git ls-files "$base_name")
    is_change=$(git diff "$base_name")
    if [ -z "$is_tracked" ] || [ -n "$is_change" ]; then
        date_info=$(date -r "$base_name" '+%Y-%m-%dT%H:%M:%S%:z') # iso 8601 format
        printf '%s\t%s\n' "$date_info" "$file"
        git add "$base_name"
        git_relative_path=$(git ls-files "$base_name" --full-name)
        GIT_COMMITTER_DATE=\"$date_info\" git commit -m "feat: add $git_relative_path" --date "$date_info"
    fi
    popd || exit
done
popd || exit
