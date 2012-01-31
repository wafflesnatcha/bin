#!/usr/bin/env bash
SCRIPT_NAME="crush"
SCRIPT_VERSION="0.5.6 (2012-01-30)"
SCRIPT_GETOPT_SHORT="h"
SCRIPT_GETOPT_LONG="help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Simple processing of images with pngcrush.

Usage: ${0##*/} file ...
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

pngcrushbin=`which pngcrush`
[[ ! $pngcrushbin ]] && FAIL "pngcrush not found"

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


for f in "$@"; do
    [[ "${f##*.}" != "png" ]] && continue

    echo $(basename "$f")

    tempfile tmpfile
    results="$($pngcrushbin -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$tmpfile")"
    [[ $? > 0 ]] && FAIL "$results"

    mv "$tmpfile" "$f" || exit
done

