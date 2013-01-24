#!/usr/bin/env bash
# Usage: env-functions [-x|-l]
#
# Pretty print all functions available to the current shell environment. The -x
# option limits display to exported functions only, while the -l option limits
# display to non-exported functions. The -n option limits display to function
# names only.
env-functions() {
	local c=()
	[[ ! -p /dev/stdout && "$TERM" =~ xterm-.*color ]] && c=( "\033[m" "\033[1;32m" "\033[1;33m" )
	declare -F | sed -E 's/declare \-f((x) |( ))/f\2\3 /' | {
		while read fn; do
			if [[ ${fn:0:2} = "fx" ]]; then
				[[ $1 = "-l" ]] && continue
				c[9]=${c[1]}
			else
				[[ $1 = "-x" ]] && continue
				c[9]=${c[2]}
			fi
			echo -e "${c[9]}${fn:3} ()\n{${c[0]}"
			type "${fn:3}" | sed '1d;2d;3d;$d'
			echo -e "${c[9]}}${c[0]}\n"
		done
	} | sed '$d'
}
