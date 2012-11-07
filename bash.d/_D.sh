# _D ...
# 
# A little output console for debugging stuff.
_D() {
	[[ ! $1 && ! -p /dev/stdin ]] && return
	{
		. colors.sh
		local c0="$COLOR_RESET" c1="$COLOR_RED" c2="$COLOR_BRIGHT_YELLOW"
		echo -en "${c1}≫$c2 "
		[[ ! $1 ]] && echo -n "$(cat)" 
		while (($#)); do
			echo -n "$1"
			shift
			[[ $1 ]] && echo -en "$c1,$c2 "
		done
		echo -e "$c0"
	} 1>&2
}
export -f _D
