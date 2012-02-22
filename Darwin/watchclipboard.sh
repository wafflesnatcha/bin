#!/usr/bin/env bash

current="$(pbpaste)"
last="$current"

while true; do
	current="$(pbpaste)"
	[[ "$current" != "$last" ]] && echo -en "$current\n"
	last="$current"
	sleep .3
done
