# env_vars
# Pretty print all variables in the current shell environment (even those not
# exported).
env_vars() {
	local output=$(set | grep -E '^[a-zA-Z0-9_]+=')
	local c
	[[ ! -p /dev/stdout && "$TERM" =~ xterm-(256)?color ]] && c=( "\033[m" "\033[35m" "\033[32m" )
	echo "$output" |
		perl -pe 'if(m/^PATH\=/) { s/:/\n     /gi; }' | # Pretty print the PATH
		perl -pe 's/^([^\s\=]+)(\=)/'${c[1]}'$1'${c[0]}${c[2]}'$2'${c[0]}'/gi' # Add color
}
export -f env_vars