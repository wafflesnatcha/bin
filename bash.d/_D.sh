# _D ...
# 
# A little output console for debugging stuff.
_D() {
	[[ ! $COLOR_RED ]] && . colors.sh
	
	echo -en "${COLOR_RED}≫${COLOR_BRIGHT_YELLOW} " 1>&2
	[[ $# -lt 1 ]] && { echo "$(function_stdin)" 1>&2; echo -en "${COLOR_RESET}" 1>&2; return; }

	local i=1
	while [[ ! $i -gt $# ]]; do
		echo -n "${!i}" 1>&2
		[[ ! $((++i)) -gt $# ]] && echo -en "${COLOR_RED},${COLOR_BRIGHT_YELLOW} " 1>&2
	done
	echo -e "${COLOR_RESET}" 1>&2
}
export -f _D
