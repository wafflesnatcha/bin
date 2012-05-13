# Show the end value of a symbolic link (like GNU `readlink -f`), works with just the filename if the file is executable and in $PATH. Usage: realpath "FILE"
rp() { local f="$@"; [ ! -e "$f" -a $(type -p "$f") ] && f="$(type -p "$f")"; readlink -f "$f" 2>/dev/null || type -p greadlink &>/dev/null && greadlink -f "$f"; }
