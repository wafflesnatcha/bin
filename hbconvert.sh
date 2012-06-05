#!/usr/bin/env bash

input="$1"
[[ ! -f "$input" ]] && { echo "$1: not found"; exit 1; }

output="${input%.*}.mp4"
[[ -e "$output" ]] && { echo "$output: file exists"; exit 1; }

shift


#nohup \
nice HandBrakeCLI --preset "Normal" -O "$@" -i "$input" -o "$output"

