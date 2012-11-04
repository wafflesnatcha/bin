#!/usr/bin/env bash
while (($#)); do
	input="$1"
	shift
	[[ ! -f "$input" ]] && continue
	output="${input%.*}.mp4"
	[[ -e "$output" ]] && { echo "$output: file exists"; exit 1; }
	nice HandBrakeCLI --preset "Normal" -O -i "$input" -o "$output"
done
