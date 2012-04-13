#!/usr/bin/env bash

input="$1"
output="${input%.*}.mp4"
shift

[[ ! -f "$input" ]] && { echo "invalid input file"; exit 1; }
[[ -e "$output" ]] && { echo "output file already exists: $output"; exit 1; }

#nohup nice HandBrakeCLI --preset "Normal" -i "$1" -o "${1%.*}.mp4" 2>&1
nice HandBrakeCLI --preset "Normal" "$@" -i "$input" -o "$output"

