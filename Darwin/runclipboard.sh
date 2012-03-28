#!/usr/bin/env bash
SCRIPT_NAME="runclipboard.sh"
SCRIPT_VERSION="1.0.1 2012-02-29"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Run the contents of the clipboard as a script.

WARNING: This script will run ANYTHING on the clipboard.

Usage: ${0##*/} [options] [argument ...]

Options:
 -i, --interpreter UTILITY  Specify an interpreter (bash, ruby, /bin/sh, ...)
 -h, --help                 Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

opt_interpreter=

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

get_interpreter() {
	echo "$(which "$1")"
	return 0
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-i|--interpreter)
		opt_interpreter=$(get_interpreter "$2");
		[ $? -gt 0 ] && FAIL "${opt_interpreter}"
		shift
		;;
		-*|--*) FAIL "unknown option ${1}" ;;
		*) break ;;
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

"$tmpfile" "$@"
