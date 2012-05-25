# rp "FILE"
# Show the end value of a symbolic link (like GNU `readlink -f`).
# 
# Works with just the base file name if the file is executable and in the
# system $PATH.
rp() {
	local f="$@"
	[ ! -e "$f" -a $(type -p "$f") ] && f="$(type -p "$f")"
	readlink -f "$f" 2>/dev/null || type -p greadlink &>/dev/null && greadlink -f "$f"
}
