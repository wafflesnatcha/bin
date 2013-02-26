#!/usr/bin/env bash
# `colors.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
# 
# Bash color output.
#
# Basic Usage:
# $ . colors.sh
# $ echo -e "${COLOR_BLUE}Here is some blue text.${COLOR_RESET}"
#
# Display available colors:
# $ for c in ${!COLOR_*}; do echo -e "${!c}$c$COLOR_RESET"; done

if [[ ! -p /dev/stdout && $(tput colors 2>/dev/null) -gt 0 ]]; then
	COLOR_SUPPORTED=1         # Are colors available?
	COLOR_RESET='\033[m'      # Reset all formatting
	COLOR_BOLD='\033[1m'      # Bold text
	COLOR_DIM='\033[2m'       # Faded text
	COLOR_UNDERLINE='\033[4m' # Underlined
	COLOR_BLINK='\033[5m'     # Blinking
	COLOR_INVERT='\033[7m'    # Invert current colors
	__colors=( BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE "" DEFAULT )
	for i in {0..7} 9; do
		eval COLOR_${__colors[$i]}='\\033[3${i}m'
		eval COLOR_BRIGHT_${__colors[$i]}='\\033[9${i}m'
		eval COLOR_BG_${__colors[$i]}='\\033[4${i}m'
		eval COLOR_BG_BRIGHT_${__colors[$i]}='\\033[10${i}m'
	done
	unset __colors
fi
