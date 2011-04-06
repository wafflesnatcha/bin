#!/usr/bin/env bash
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="0.5.2 [2011-04-05]"
SCRIPT_DESCRIPTION="Simple processing of images with pngcrush"
SCRIPT_USAGE="${0##*/} file ..."
SCRIPT_GETOPT_SHORT="h"
SCRIPT_GETOPT_LONG="help"

usage() {
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESCRIPTION\n\n$SCRIPT_USAGE"
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

CONFIG_pngcrushbin=`which pngcrush`
[[ ! $CONFIG_pngcrushbin ]] && FAIL "pngcrush not found"

tempFile() {
	local filename=`mktemp -t ${0##*/}`
	trap "rm -f '$filename'" 0
	trap "rm -f '$filename'; exit 1" 2
	trap "rm -f '$filename'; exit 1" 1 15
	echo $filename
}

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		*) shift; break ;;
	esac
	shift
done

[[ ! $1 ]] && (usage; exit 0)


for f in "$@"; do
	[[ "${f##*.}" != "png" ]] && continue

	echo $(basename "$f")
	
	TMPFILE="$(tempFile)"
	results="$($CONFIG_pngcrushbin -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$TMPFILE")"
	[[ $? > 0 ]] && FAIL "$results"

	mv "$TMPFILE" "$f" || ERROR "Couldn't move the crushed file $TMPFILE"
done

