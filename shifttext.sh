#!/usr/bin/env bash
# `shifttext.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="shifttext.sh"
SCRIPT_VERSION="1.1.0 2012-05-25"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Prepend text to the beginning of a file.

Usage: ${0##*/} FILE
EOF
}

temp_file() {
	local var
	for var in "$@"; do
		eval $var=\"$(mktemp -t "${0##*/}")\"
		temp_file__files="$temp_file__files '${!var}'"
	done
	trap "rm -f $temp_file__files" EXIT
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		*) break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

[[ ! -e "$1" ]] && touch "$1"

temp_file tmpfile

cat "$1" > "$tmpfile"
cat - "$tmpfile" > "$1"
