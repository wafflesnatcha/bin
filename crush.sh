#!/usr/bin/env bash
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="0.6.0 (2012-03-07)"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Simple processing of images with pngcrush and/or jpgcrush.

Usage: ${0##*/} [options] file ...

Options:
 -p, --percentage  Prefix output lines with overall percent completed (useful
                   when piping to CocoaDialog progressbar)
 -h, --help        Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }
or_fail() { [[ ! $? = 0 ]] && FAIL "$@"; }

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

count=0

for f in "$@"; do
	(( count++ ))
	percent=$(echo "$count/$#*100" | bc -l | xargs printf "%1.0f%%";)
	[[ $opt_percentage ]] && echo -n "$percent [$percent] "
	echo "$(basename "$f")"
	
	case "${f##*.}" in
		png)
			[[ ! $pngcrush ]] && { pngcrush=$(which pngcrush 2>/dev/null) || FAIL "pngcrush not found"; }
			tempfile tmpfile
			chmod $(stat -f%p "$f") "$tmpfile"
			or_fail "$("$pngcrush" -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$tmpfile")"
			or_fail "$(mv "$tmpfile" "$f")"
		;;
		jpg|jpeg)
			[[ ! $jpgcrush ]] && { jpgcrush=$(which jpgcrush 2>/dev/null) || FAIL "jpgcrush not found"; }
			or_fail "$("$jpgcrush" "$f")"
		;;
	esac
done
