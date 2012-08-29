# env_functions
# Same as `env_vars`, but for functions. Exported functions have their name and
# brackets colored if supported.
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
export -f env_functions