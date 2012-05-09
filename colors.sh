#!/usr/bin/env bash
# Bash color output
#
# Usage:
# $ . colors.sh
# $ echo -e "${COLOR_BLUE}Here is some blue text!${COLOR_RESET}"
#
# Display available colors:
# $ for c in ${!COLOR_*}; do echo -e "${!c}$c $COLOR_RESET"; done

if [ "$TERM" = "xterm-color" -o "$TERM" = "xterm-256color" ]; then
	COLOR_SUPPORTED=1

	COLOR_RESET='\033[m' # Reset all formatting

	# Text Styling
	COLOR_BOLD='\033[1m'
	COLOR_DIM='\033[2m'
	COLOR_UNDERLINE='\033[4m'
	COLOR_BLINK='\033[5m'
	COLOR_INVERT='\033[7m'

	COLOR_NAMES=(BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE "" DEFAULT)
	for i in {0..7} 9; do
		eval COLOR_${COLOR_NAMES[$i]}='\\033[3${i}m'
		eval COLOR_${COLOR_NAMES[$i]}_BRIGHT='\\033[9${i}m'
		eval COLOR_BG_${COLOR_NAMES[$i]}='\\033[4${i}m'
		eval COLOR_BG_${COLOR_NAMES[$i]}_BRIGHT='\\033[10${i}m'
	done
	unset COLOR_NAMES
	
	# Extra Aliases
	RESET=$COLOR_RESET
	BOLD=$COLOR_BOLD
	DIM=$COLOR_DIM
	UNDERLINE=$COLOR_UNDERLINE

fi
