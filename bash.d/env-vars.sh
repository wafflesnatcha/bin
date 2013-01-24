#!/usr/bin/env bash
# Usage: env-vars [PATTERN]
#
# Pretty print all variables in the current shell environment (even those not
# exported).
env-vars() {
	local c output=$(set | perl -ne 'print if m/^[a-z0-9_]+=/i')
	[[ $1 =~ ^[a-zA-Z0-9\_]*$ ]] && output=$(echo "$output" | perl -ne 'print if m/^'"$1"'[^=]*?=/i')
	[[ ! -p /dev/stdout && "$TERM" =~ xterm-.*color ]] && c=("\033[m" "\033[34m" "\033[32m" "\033[93m")
	echo "$output" |
		perl -pe 's/:/'${c[3]}':'${c[0]}'\n     /gi if m/^PATH\=/' | # Pretty print the PATH
		perl -pe 'if(m/^[a-z0-9_]+\=\(\[0/i) { s/\[(\d+)\](=)(\".*?\")/\n  '${c[3]}'[$1]'${c[0]}${c[2]}'$2'${c[0]}'$3/g; s/\)$/\n\)/; }' | # Pretty print Arrays
		perl -pe 's/^([^\s\=]+)(\=)/'${c[1]}'$1'${c[0]}${c[2]}'$2'${c[0]}'/gi' # Add color
}
