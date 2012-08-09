# env_vars
# Pretty print all variables in the current shell environment (even those not exported)
env_vars() {
	local output=$(set | grep -E '^[a-zA-Z0-9_]+=')
	local c
	[[ ! -p /dev/stdout && "$TERM" =~ xterm-(256)?color ]] && c=( "\033[m" "\033[35m" "\033[32m" )
	echo "$output" |
		perl -pe 'if(m/^PATH\=/) { s/:/\n     /gi; }' | # Pretty print the PATH
		perl -pe 's/^([^\s\=]+)(\=)/'${c[1]}'$1'${c[0]}${c[2]}'$2'${c[0]}'/gi' # Add color
}

# env_functions
# Same as `env_vars`, but for functions. Exported functions have their name and brackets colored if supported.
env_functions() {
	local c=()
	[[ ! -p /dev/stdout && "$TERM" =~ xterm-(256)?color ]] && c=( "\033[m" "\033[1;32m" "\033[1m" )

	# Use `pygmentize` if available
	# [[ ! -p /dev/stdout && "$TERM" =~ xterm-(256)?color ]] && type -p pygmentize &>/dev/null && { declare -f | pygmentize -l bash; return; }

	declare -F | sed -E 's/declare \-f((x) |( ))/f\2\3 /' | {
		while read fn; do
			# different color function name for exported functions
			[[ ${fn:0:2} = "fx" ]] && c[9]=${c[1]} || c[9]=${c[2]}
			
			echo -e "${c[9]}${fn:3} ()\n{${c[0]}"
			type "${fn:3}" | sed '1d;2d;3d;$d'
			echo -e "${c[9]}}${c[0]}\n"
		done
	} | sed '$d'
}

export -f env_vars env_functions