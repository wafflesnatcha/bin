#!/usr/bin/env bash
# Usage: string-repeat MULTIPLIER [STRING]
#
# Repeat a string MULTIPLIER times.
#
# Example (courtesy of Dave Grohl): `string_repeat 7 "THE BEST "`
string-repeat() {
	[[ ! $1 || $1 = "-h" || $1 = "--help" || ! $1 =~ ^[0-9]+$ || $# -lt 1 ]] && cat <<-EOF 1>&2 && return 2
		Usage: string-repeat MULTIPLIER [STRING]

		Repeat a string MULTIPLIER times.
		EOF

	local c=$1
	shift
	local input=${@:-$(cat -)}
	while ((c--)); do echo -n "$input"; done
}
