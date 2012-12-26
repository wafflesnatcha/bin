#!/usr/bin/env bash
# `geticons.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="geticons.sh"
SCRIPT_VERSION="r1 2012-09-10"

opt_output="./icons"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Save file icons recursively.

Usage: ${0##*/} [OPTION]... [PATH]...

Options:
 -e, --extension FILEEXT  Only extract icons from files with this extension
 -o, --output PATH        Output directory ($opt_output)
 -r, --recursive          Extract icons from subdirectories as well
 -h, --help               Show this help

Note: Ignores extracting icons from .icns files by default.
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

geticon=$(which geticon 2>/dev/null) || ERROR "geticon not found" 1

unique_file() {
	local i=1
	local dirname="$(dirname "$1")"
	local basename="$(basename "$1")"
	local name="$basename"
	local ext=

	# File has an extension
	if [[ ! -d "$1" && "$name" =~ ^..*\...* ]]; then
		name="${basename%.*}"
		ext=".${basename##*.}"
	fi

	local try="$name"
	while [ -e "$dirname/$try$ext" ]; do
		((i++))
		try="${name}${2:- }${i}"
	done

	echo "$dirname/$try$ext"
}

opt_output="$(unique_file "$opt_output")"
opt_depth=1
fopts=

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-r|--recursive) opt_depth= ;;
		-e*|--extension) [[ $1 =~ ^\-[a-z].+$ ]] && opt_extension="${1:2}" || { opt_extension=$2; shift; } ;;
		-o*|--output) [[ $1 =~ ^\-[a-z].+$ ]] && opt_output="${1:2}" || { opt_output=$2; shift; } ;;
		-*|--*) [[ $1 = "--" ]] && break; ERROR "unknown option '${1}'" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ${opt_output} && ! -e "${opt_output}" ]] && mkdir -p "${opt_output}"
[[ ${opt_output} && ! -d "${opt_output}" ]] && ERROR "output is not a directory '${opt_output}'" 1
[[ ${opt_output} && ! -w "${opt_output}" ]] && ERROR "permission denied to output directory '${opt_output}'" 1

[[ $opt_depth ]] && fopts="$fopts -maxdepth $opt_depth"
[[ $opt_extension ]] && fopts="$fopts -name '*.$opt_extension'" 

args=$(cat <<EOF
$fopts
-not -path '*/.Trash/*'
-not -path '*/.Trashes/*'
-not -path '*/.*/*'
-not -name '.*'
-not -name $'Icon\r'
-flags +nohidden
EOF)

for src in "${@:-$PWD}"; do
	echo "$args" | xargs find -sd "$src" | while read f; do
 		[[ "$f" == "$src" || ! -r "$f" || "${f##*.}" == "icns" ]] && continue
 		out="${opt_output}${f##$src}.icns"
 		d="$(dirname "$out")"
 		[[ ! -d "$d" ]] && mkdir -p "$d"
 		echo "$out"
 		"$geticon" -t "icns" -o "$out" "$f" || ERROR "geticon failed" $?
 	done
done
