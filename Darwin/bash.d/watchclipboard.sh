#!/usr/bin/env bash

watch_clipboard() {
	local interval=${1:-0.3}
	local current
	local last
	while true; do
		current="$(pbpaste)"
		[[ "$current" != "$last" ]] && echo -en "$current\n"
		last="$current"
		sleep $interval || return 2
	done
}
