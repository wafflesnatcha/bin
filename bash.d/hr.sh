#!/usr/bin/env bash
# Usage: hr
#
# Display a pretty horizontal rule.
hr() {
	local i x r c=${COLUMNS:-`tput cols`}

	# No color support
	if [[ -p /dev/stdout || ! "$TERM" =~ xterm-(256)?color ]]; then
		printf "%-72s" "" | tr " " "#"
		return
	fi

	if [[ "$TERM" =~ xterm-256color ]]; then
		# r=( $(echo "\033[38;5;"{17..21}m "\033[38;5;"{20..17}m) )		# Blue color scheme
		r=( $(echo "\033[38;5;"{125..129}m "\033[38;5;"{128..125}m) )	# Magenta color scheme
	elif [[ "$TERM" =~ xterm-color ]]; then
		r=( $(echo \033[{31..36}m \033[{36..31}m) )
	fi
	for i in ${r[@]}; do
		for ((x=1; x<=$(($c/${#r[@]})); x++)); do
			echo -en "${i}#\033[0m"
		done
	done
	printf "${i}%$(($c%${#r[@]}))s\033[0m\n" "" | tr " " "#"
}
