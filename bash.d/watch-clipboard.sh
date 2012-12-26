#!/usr/bin/env bash
# Usage: watch-clipboard [INTERVAL]
#
# Watch the clipboard for changes and display them to stdout. INTERVAL is the
# time (in seconds) to wait after the clipboard is tested for a change (default
# is 0.25 seconds).
watch-clipboard() {
	type -a xclip pbpaste &>/dev/null ||
		{ echo "watch-clipboard: requires either \`xclip\` or \`pbcopy\`" 1>&2; return 2; }

	[[ $1 = "-h" || $1 = "--help" ]] && cat <<-EOF && return
		Usage: watch-clipboard [INTERVAL]

		Watch the clipboard for changes and display them to stdout. INTERVAL is the
		time (in seconds) to wait after scanning the clipboard for changes (default
		0.25 seconds).
		EOF

	local cmd current last interval=${1:-0.25}

	type xclip &>/dev/null && cmd="xclip -o" || cmd="pbpaste"

	while true; do
		current="$($cmd)"
		[[ "$current" != "$last" ]] && echo "$current"
		last="$current"
		sleep $interval || return 2
	done
}
