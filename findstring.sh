#!/usr/bin/env bash
# `findstring.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="findstring.sh"
SCRIPT_VERSION="r1 2012-07-11"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Recursively find strings in files.

Usage: ${0##*/} [OPTION]... PATTERN

Options:
 -b, --binary       Include binary files in the search
 -d, --depth NUM    Maximum depth to search subdirectories
 -f, --filenames    List matching files only
 -i, --ignore-case  Case-insensitive search
 -p, --path PATH    Search for files in this path (current working directory)
 -h, --help         Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

opt_binary=
opt_depth=
opt_filenames=
opt_ignore_case=
opt_path="."

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-b|--binary) opt_binary=1 ;;
		-d*|--depth)
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_depth="${1:2}" || { opt_depth=$2; shift; }
			[[ ! $opt_depth =~ ^[0-9]*$ ]] && ERROR "invalid depth" 1
		;;
		-f|--filenames) opt_filenames=1 ;;
		-i|--ignore-case) opt_ignore_case=1 ;;
		-p*|--path) [[ $1 =~ ^\-[a-z].+$ ]] && opt_path="${1:2}" || { opt_path=$2; shift; } ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! -d "$opt_path" ]] && ERROR "invalid path" 1

[[ ! $1 ]] && { usage; exit 0; }

grepopts="--with-filename --line-number --color=auto"
findopts=""

[[ $opt_binary ]] && grepopts="${grepopts} --binary-files=text" || grepopts="${grepopts} --binary-files=without-match"
[[ $opt_filenames ]] && grepopts="${grepopts} -l"
[[ $opt_ignore_case ]] && grepopts="${grepopts} -i"
[[ $opt_depth ]] && findopts="${findopts} -maxdepth ${opt_depth}"

find "$opt_path" -type f \
	-not -path '*/.Trash/*' \
	-not -path '*/.Trashes/*' \
	-not -path '*lost+found/' \
	$findopts \
	-print0 \
	| xargs -0 -n 100 grep $grepopts "$@" 2>/dev/null

exit 0
