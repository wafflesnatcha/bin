# rp FILE
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

# cdrp FILE
# Change directory using path from `rp` command
cdrp() {
	local p="$(rp "$*")"
	[[ "$p" && ! -d "$p" ]] && p="$(dirname "$p")"
	[[ ! "$p" || ! -d "$p" ]] && return 1
	echo "$p" 1>&2
	cd "$p"
}
