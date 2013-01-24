#!/usr/bin/env bash
# Usage: watch-clipboard [INTERVAL]
#
# Watch the clipboard for changes and display them to stdout. INTERVAL is the 
# frequency (in seconds) to check the clipboard for changes.
watch-clipboard() {
	type -a xclip pbpaste &>/dev/null ||
		{ echo "watch-clipboard: requires either \`xclip\` or \`pbcopy\`" 1>&2; return 2; }

	local cmd current last _i=0.25

	[[ $1 && ! $1 =~ ^[0-9]?(\.?[0-9]+)$ ]] && cat <<-EOF 1>&2 && return 1
		Usage: watch-clipboard [INTERVAL]

		Watch the clipboard for changes and display them to stdout. INTERVAL
		(default $i) is the frequency (in seconds) to check the clipboard for
		changes.
		EOF

	_i=${1:-$_i}
	type xclip &>/dev/null && cmd="xclip -o" || cmd="pbpaste"

	while true; do
		current="$($cmd)"
		[[ "$current" != "$last" ]] && echo "$current"
		last="$current"
		sleep $_i || return 2
	done
}
