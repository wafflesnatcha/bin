#!/usr/bin/env bash
SCRIPT_NAME="extract"
SCRIPT_VERSION="0.1.1 (2012-01-28)"
SCRIPT_GETOPT_SHORT="h"
SCRIPT_GETOPT_LONG="help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Automatically extract compressed files of various types.

Usage: ${0##*/} file ...
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		*) shift; break ;;
	esac
	shift
done

[[ ! "$1" ]] && { usage; exit 0; }

for f in "$@"; do
    [[ ! -f "$f" ]] && continue
    case "$(echo $f | tr '[A-Z]' '[a-z]')" in
		*.tar.bz2) tar -xjvpf "$f" ;;
        *.tar.gz|*.tgz) tar -xzvpf "$f" ;;
        *.7z) 7z x "$f" ;;
		*.bz2|*.bzip2|*.bz) bunzip2 "$f" ;;
        *.gz) gzip -d "$f" ;;
        *.rar) unrar x "$f" ;;
        *.zip|*.z01) unzip "$f" ;;
        *) FAIL "don't know how to handle '$f'" ;;
    esac
done