#!/usr/bin/env bash
SCRIPT_NAME="geticons.sh"
SCRIPT_VERSION="1.1.1 (2012-01-30)"
SCRIPT_GETOPT_SHORT="d:o:h"
SCRIPT_GETOPT_LONG="depth:,output:,help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Save file icons recursively.

Usage: ${0##*/} [options] [path]

Options:
 -d, --depth=NUM    Maximum depth to search subdirectories
 -o, --output=PATH  Output directory
 -h, --help         Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

geticon=`which geticon 2>/dev/null | sed 1q`
[[ ! $geticon ]] && FAIL "geticon not found"

opt_output="$PWD"
fopts=

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d|--depth) fopts="$fopts -maxdepth $2"; shift ;;
		-o|--output) opt_output="${2%%/}"; shift ;;
		*) shift; break ;;
	esac
	shift
done

src="${1:-$PWD}"
[[ ! -d "$src" ]] && FAIL "invalid path"

[[ ! -a "${opt_output}" ]] && mkdir "${opt_output}"
[[ ! -d "${opt_output}" ]] && FAIL "invalid output directory ${opt_output}"


find "$src" ${fopts} \
	-not -path '*.Trash/*' \
	-not -path '*.Trashes/*' \
	-not -path '*.*/*' \
	-not -name '.*' \
	-not -name $'Icon\r' \
	| while read f; do
		[[ "$f" == "$src" || ! -r "$f" || "${f##*.}" == "icns" ]] && continue
		out="${opt_output}${f##$src}.icns"
		d="$(dirname "$out")"
		[[ ! -d "$d" ]] && mkdir "$d"
		echo "${out##$opt_output/}"
		"$geticon" -o "$out" "$f" || FAIL
	done

