#!/usr/bin/env bash
SCRIPT_NAME="runclipboard"
SCRIPT_VERSION="1.0.0 (2012-02-14)"
SCRIPT_GETOPT_SHORT="i:h"
SCRIPT_GETOPT_LONG="interpreter:,help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Run the contents of the clipboard as a script.

WARNING: This script will run ANYTHING on the clipboard.

Usage: ${0##*/} [options] [ -- arguments ... ]

Options:
 -i, --interpreter=UTILITY  Specify an interpreter (bash, ruby, /bin/sh, ...)
 -h, --help                 Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

opt_interpreter=

tempfile() {
	for var in "$@"; do
		eval $var=$(mktemp -t "${0##*/}")
		tempfile_exit="$tempfile_exit rm -f '${!var}';"
	done	
	trap "{ $tempfile_exit }" EXIT
}

get_interpreter() {
	echo "$(which "$1")"
	return 0
}

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-i|--interpreter)
		opt_interpreter=$(get_interpreter "$2");
		[ $? -gt 0 ] && FAIL "${opt_interpreter}"
		shift
		;;
		*) shift; break ;;
	esac
	shift
done

tempfile tmpfile
pbpaste > "$tmpfile"

first_line="$(HEAD -n 1 "$tmpfile")"

if [[ $opt_interpreter ]]; then
	
	[[ "$first_line" =~ '^#!' ]] && tail -n +2 "$tmpfile" > "$tmpfile"
	prepend="#!${opt_interpreter}"
	
elif [[ ! "$first_line" =~ '^#!' ]]; then
	
	case "$first_line" in
		"<?php"*) prepend="#!$(get_interpreter "php")" ;;
		*) ;;
	esac
	
fi

[[ $prepend ]] && echo -e "${prepend}\n$(cat "$tmpfile")" > "$tmpfile"


chmod +x "$tmpfile"

"$tmpfile" $*
