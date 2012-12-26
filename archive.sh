#!/usr/bin/env bash
# `archive.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="archive.sh"
SCRIPT_VERSION="r1 2012-07-11"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Quickly make archives of files and directories.

Usage: ${0##*/} [OPTION]... PATH...

Options:
     --7z           Output a 7-zip archive [.7z] (requires 7z or 7zr)
     --tar          Output a tar archive [.tar]
     --tbz2         Output a bzip2 compressed tar archive [.tar.bz2]
     --tgz          Output a gzip compressed tar archive [.tar.gz]
     --zip          Output a Zip archive [.zip] (default)
 -d, --date         Append the current date to the end of the filename
 -o, --output PATH  Directory to place the archive in (default is current
                    working directory)
 -h, --help         Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

opt_format="zip"
opt_date=
opt_date_format="%Y-%m-%d"
opt_prefix_date="_"
opt_output="$PWD"

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

processFile() {
	[[ ! -e "$1" ]] && return
	local file="$(basename "$1")"
	[[ -d "$1" ]] && file="$(cd "$1" &>/dev/null; basename "$PWD")"
	local out=$(unique_file "${opt_output}/${file}${opt_date}.${opt_format}" " copy ")

	case "$opt_format" in

		7z)
		bin=$(which 7z 7zr 2>/dev/null | head -n1)
		[[ ! $bin ]] && ERROR "couldn't find path to 7z or 7zr" 2
		"$bin" a "$out" "$1"
		;;

		tar)
		tar -cvf "$out" "$1"
		;;

		tar.bz2)
		tar -cjvf "$out" "$1"
		;;

		tar.gz)
		tar -czvf "$out" "$1"
		;;

		zip)
		zip -r "$out" "$1"
		;;

		*) ERROR "invalid output format [$opt_format]" 3 ;;

	esac
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		--7z)   opt_format="7z" ;;
		--tar)  opt_format="tar" ;;
		--tbz2) opt_format="tar.bz2" ;;
		--tgz)  opt_format="tar.gz" ;;
		--zip)  opt_format="zip" ;;
		-d|--date) opt_date="${opt_prefix_date}$(date +$opt_date_format)" ;;
		-o*|--output) [[ $1 =~ ^\-[a-z].+$ ]] && opt_output="${1:2}" || { opt_output=$2; shift; } ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ${#} < 1 ]] && ( usage; exit 0 )

[[ ! -d "$opt_output" ]] && ERROR "output is not a directory [$opt_output]" 1
[[ ! -w "$opt_output" ]] && ERROR "output directory is not writable [$opt_output]" 1

for f in "$@"; do
	processFile "$f" || exit $?
done
