#!/usr/bin/env bash
# Usage: hr [COLOR SCHEME]
#
# Display a pretty horizontal rule.
hr() {
	if [[ -p /dev/stdout || $(tput colors 2>/dev/null) -le 0 ]]; then
		# No color support
		printf "%-72s" "" | tr " " "#"
		return
	fi
	
	local i x c r=( "\033["{31,33,32,36,34,35,34,36,32,33,31}m )
	c=${COLUMNS:-`tput cols`} || c=72
	
	if [[ $(tput colors) -ge 256 ]]; then case "${1:-1}" in
		0|black)   r=( "\033[38;5;"2{{34..40},{39..34}}m ) ;;
		1|red)     r=( "\033[38;5;"{52,88,124,160,196,160,124,88,52}m ) ;;
		2|green)   r=( "\033[38;5;"{22,28,34,40,46,40,34,28,22}m ) ;;
		3|yellow)  r=( "\033[38;5;"{58,100,142,184,226,184,142,100,58}m ) ;;
		4|blue)    r=( "\033[38;5;"{{17..21},{20..17}}m ) ;;
		5|magenta) r=( "\033[38;5;"12{{5..9},{8..5}}m ) ;;
		6|cyan)    r=( "\033[38;5;"{39,45,81,87,123,87,81,45,39}m ) ;;
		7|white)   r=( "\033[38;5;"2{{47..53},{52..47}}m ) ;;
	esac; fi

	{
		for i in ${r[@]}; do printf "${i}%$(($c/${#r[@]}))s\033[0m" "#"; done
		printf "${r[$((${#r[@]}-1))]}%$(($c%${#r[@]}))s\033[0m\n" ""
	} | tr " " "#"
}
export -f hr
