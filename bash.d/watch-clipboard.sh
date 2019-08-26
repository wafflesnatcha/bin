#!/usr/bin/env bash
# Usage: watch-clipboard [INTERVAL]
#
# Watch the clipboard for changes and display them to stdout. INTERVAL is the 
# frequency (in seconds) to check the clipboard for changes.
watch-clipboard() {
	local cmd current last _i=0.25

	# determine clipboard command
	type xclip &>/dev/null && cmd="xclip -o"
	type pbpaste &>/dev/null && cmd="pbpaste"
	type getclip &>/dev/null && cmd="getclip"

	[[ -z "$cmd" ]] && { echo "watch-clipboard: requires \`xclip\`, \`pbcopy\`, or \`getclip\`" 1>&2; return 2; }

	[[ $1 && ! $1 =~ ^[0-9]?(\.?[0-9]+)$ ]] && cat <<-EOF 1>&2 && return 1
		Usage: watch-clipboard [INTERVAL]

		Watch the clipboard for changes and display them to stdout. INTERVAL
		(default $i) is the frequency (in seconds) to check the clipboard for
		changes.
		EOF

	_i=${1:-$_i}

	while true; do
		current="$($cmd)"
		[[ "$current" != "$last" ]] && echo "$current"
		last="$current"
		sleep $_i || return 2
	done
}
