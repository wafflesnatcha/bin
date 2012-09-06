# _D ...
# 
# A little output console for debugging stuff.
_D() {
	. colors.sh
	echo -en "${COLOR_RED}≫${COLOR_BRIGHT_YELLOW} " 1>&2
	[[ $# -lt 1 ]] && { cat 1>&2; echo -en "${COLOR_RESET}" 1>&2; return; }
	while [[ $# -gt 0 ]]; do
		echo -n "$1" 1>&2
		shift
		[[ $# -gt 0 ]] && echo -en "${COLOR_RED},${COLOR_BRIGHT_YELLOW} " 1>&2
	done
	echo -e "${COLOR_RESET}" 1>&2
}
export -f _D
