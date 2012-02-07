#!/usr/bin/env bash
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="0.5.8 (2012-02-07)"
SCRIPT_GETOPT_SHORT="hp"
SCRIPT_GETOPT_LONG="help,percentage"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Simple processing of images with pngcrush.

Usage: ${0##*/} [options] file ...

Options:
 -p, --percentage  Prefix output with percent completed (useful when piping to
                   CocoaDialog progressbar)
 -h, --help        Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(/usr/bin/getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

pngcrushbin="$(which pngcrush)"
[[ ! $pngcrushbin ]] && FAIL "pngcrush not found"

opt_percentage=

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-p|--percentage) opt_percentage=1 ;;
		*) shift; break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

total_files=$#
count=0

for f in "$@"; do
	(( count++ ))
	[[ "${f##*.}" != "png" ]] && continue

	[ $opt_percentage ] && echo "$count/$total_files*100" | bc -l | xargs printf "%1.0f%% "
	echo "$(basename "$f")"

	tempfile tmpfile
	results="$($pngcrushbin -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$tmpfile")"
	[[ $? > 0 ]] && FAIL "$results"

	mv "$tmpfile" "$f" || exit
done

