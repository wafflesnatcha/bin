#!/usr/bin/env bash
while [[ "$1" =~ ^- && ! -e "$1" ]]; do
	flags="$flags $1"
	shift
done

while (($#)); do
	input="$1"
	shift
	[[ ! -f "$input" ]] && continue
	output="${input%.*}.mp4"
	[[ -e "$output" ]] && { echo "$output: file exists" >&2; exit 1; }
	HandBrakeCLI --preset "Normal" -O -i "$input" -o "$output" $flags
done
