#!/bin/bash
SCRIPT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)
IFS=$'\n'
tar_dir="$(pwd)"
if [ "$#" -gt 0 ]; then
    tar_dir="$1"
fi
under_git_dirs=$(find "$tar_dir" -name ".git")
if [ -z "$under_git_dirs" ]; then
    bash "$SCRIPT_DIR"/manage_file_timestamp_for_git.sh
else
    for root_dir in ${under_git_dirs}; do
        temp_dir=$(dirname "$root_dir")
        pushd "$temp_dir" || exit
        bash "$SCRIPT_DIR"/restore_timestamp.sh
        bash "$SCRIPT_DIR"/manage_file_timestamp_for_git.sh
        popd || exit
    done
fi
