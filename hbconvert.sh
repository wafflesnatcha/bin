#!/usr/bin/env bash
[[ ! -f "$1" ]] && { echo "invalid input file"; exit 1; }
#nohup nice HandBrakeCLI --preset "Normal" -i "$1" -o "${1%.*}.mp4" 2>&1
HandBrakeCLI --preset "Normal" -i "$1" -o "${1%.*}.mp4" 2>&1

