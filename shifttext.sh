#!/usr/bin/env bash
# shifttext.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="shifttext.sh"
SCRIPT_VERSION="1.0.9 2012-05-08"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Prepend text to the beginning of a file.

Usage: ${0##*/} FILE
EOF
}

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
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

tempfile tmpfile

cat "$1" > "$tmpfile"
cat - "$tmpfile" > "$1"
