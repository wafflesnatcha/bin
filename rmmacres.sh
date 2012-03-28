#!/usr/bin/env bash
SCRIPT_NAME="rmmacres.sh"
SCRIPT_VERSION="1.7.2 2012-03-21"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Find and remove Mac resource & junk files.

Usage: ${0##*/} [options] [path ...]

Options:
 -a, --all        Same as -fism
 -f, --forks      Remove resource forks (._*)
 -i, --icons      Remove custom icons (Icon^M)
 -s, --dsstore    Remove Finder settings files (.DS_Store)
 -m, --misc       Remove other miscellaneous files (.localized)
 -d, --depth NUM  Maximum depth to search subdirectories
 -n, --dry-run    Show what would be deleted and exit
 -h, --help       Show this help
EOF
}
FAIL() { [ -n "$1" ] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

opt_dryrun=
opt_depth=

par_dsstore='-or -name .DS_Store'
par_forks='-or -name ._\*'
par_icons='-or -name '$'Icon\r'
par_misc='-or -name .localized'

fopts=
fparams=

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-n|--dry-run) opt_dryrun=1 ;;
		-d*|--depth)
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_depth="${1:2}" || { opt_depth=$2; shift; }
			[[ ! $opt_depth =~ ^[0-9]*$ ]] && FAIL "invalid depth"
			[[ $opt_depth ]] && fopts="$fopts -maxdepth $opt_depth"
		;;
		-s|--dsstore) fparams="$fparams $par_dsstore" ;;
		-f|--forks) fparams="$fparams $par_forks" ;;
		-i|--icons) fparams="$fparams $par_icons" ;;
		-m|--misc) fparams="$fparams $par_misc" ;;
		-a|--all) fparams="$fparams $par_dsstore $par_forks $par_icons $par_misc" ;;
		-*|--*) FAIL "unknown option ${1}" ;;
		*) break ;;
	esac
	shift
done

[[ ! $fparams ]] && { usage; exit 0; }


args=$(cat <<EOF
${fopts}
-not -path '*/.Trash/*'
-not -path '*/.Trashes/*'
(
	-false
	${fparams}
)
$( [[ ! ${opt_dryrun} ]] && echo "-delete" )
-print
EOF)

for path in "${@:-$PWD}"; do
	echo "$args" | xargs find -sd "$path"
done
