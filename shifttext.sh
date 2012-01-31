#!/usr/bin/env bash
SCRIPT_NAME="shifttext"
SCRIPT_VERSION="1.0.7 (2012-01-30)"
SCRIPT_GETOPT_SHORT="h"
SCRIPT_GETOPT_LONG="help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Insert text into the beginning of a file.

Usage: ${0##*/} file
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        *) shift; break ;;
    esac
    shift
done

[[ ! $1 ]] && { usage; exit 0; }

[[ ! -e "$1" ]] && touch "$1"

tempfile tmpfile

cat "$1" > "$tmpfile"
cat - "$tmpfile" > "$1"
