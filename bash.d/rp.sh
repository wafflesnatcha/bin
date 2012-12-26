#!/usr/bin/env bash
# Usage: rp FILE
#
# Show the end value of a symbolic link (like GNU `readlink -f`).
#
# FILE can be either a path to an existing file, or any file that exists in the
# system $PATH.
rp() {
	local FILE="$*"
	[[ ! -e "$FILE" && "$(type -t "$FILE")" = "alias" ]] && FILE="$(alias "$FILE" | perl -pe 's/^alias .*='\''(.*?)(?: \-{1,2}.+)?'\''$/$1/')"
	[[ ! -e "$FILE" ]] && FILE="$(which "$FILE" 2>/dev/null)"
	readlink -f "$FILE" 2>/dev/null || type -p greadlink &>/dev/null && greadlink -f "$FILE"
}
