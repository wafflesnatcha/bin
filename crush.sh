#!/usr/bin/env bash
SCRIPT_NAME="crush"
SCRIPT_VERSION="0.5.9 (2012-02-29)"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Simple processing of images with pngcrush.

Usage: ${0##*/} [options] file ...

Options:
 -p, --percentage  Prefix output lines with overall percent completed (useful
                   when piping to CocoaDialog progressbar)
 -h, --help        Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

bin=$(which pngcrush 2>/dev/null) || FAIL "pngcrush not found"

opt_percentage=

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}


while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-p|--percentage) opt_percentage=1 ;;
		-*|--*) FAIL "unknown option ${1}" ;;
		*) break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

total_files=$#
count=0

for f in "$@"; do
	(( count++ ))
	[[ "${f##*.}" != "png" || ! -e "$f" ]] && continue

	[[ $opt_percentage ]] && { echo "$count/$total_files*100" | bc -l | xargs printf "%1.0f%% "; }
	echo "$(basename "$f")"

	tempfile tmpfile
	results="$("$bin" -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$tmpfile")"
	[[ $? > 0 ]] && FAIL "$results"

	mv "$tmpfile" "$f" || exit
done
