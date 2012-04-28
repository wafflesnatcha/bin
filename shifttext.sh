#!/usr/bin/env bash
SCRIPT_NAME="shifttext.sh"
SCRIPT_VERSION="1.0.8 2012-02-29"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Prepend text to the beginning of a file.

Usage: ${0##*/} FILE
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

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
