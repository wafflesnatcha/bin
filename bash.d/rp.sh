# rp FILE
# Show the end value of a symbolic link (like GNU `readlink -f`).
# 
# FILE can be either a path to an existing file, or any file that exists in the
# system $PATH.
rp() {
	local FILE="$1"
	[[ ! -e "$FILE" && $(type -p "$FILE") ]] && FILE="$(type -p "$FILE")"
	readlink -f "$FILE" 2>/dev/null || type -p greadlink &>/dev/null && greadlink -f "$FILE"
}
