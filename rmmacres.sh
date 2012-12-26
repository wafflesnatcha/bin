#!/usr/bin/env bash
# `rmmacres.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="rmmacres.sh"
SCRIPT_VERSION="r4 2012-08-09"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Find and delete various Mac-related resource & junk files.

Usage: ${0##*/} [OPTION]... [PATH]...

Options:
 -a, --all        Same as -fism
 -s, --dsstore    Remove Finder settings files (.DS_Store)
 -f, --forks      Remove resource forks (._*)
 -i, --icons      Remove custom icons (Icon\r)
 -m, --misc       Remove other miscellaneous files (.localized)
 -d, --depth NUM  Maximum depth to search in subdirectories
 -n, --dry-run    Show what would be deleted and exit (overrides -q)
 -q, --quiet      Supress listing deleted files
 -h, --help       Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

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
		-q|--quiet) opt_quiet=1 ;;
		-d*|--depth)
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_depth="${1:2}" || { opt_depth=$2; shift; }
			[[ ! $opt_depth =~ ^[0-9]*$ ]] && ERROR "invalid depth" 1
			[[ $opt_depth ]] && fopts="$fopts -maxdepth $opt_depth"
		;;
		-s|--dsstore) fparams="$fparams $par_dsstore" ;;
		-f|--forks) fparams="$fparams $par_forks" ;;
		-i|--icons) fparams="$fparams $par_icons" ;;
		-m|--misc) fparams="$fparams $par_misc" ;;
		-a|--all) fparams="$fparams $par_dsstore $par_forks $par_icons $par_misc" ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! $fparams ]] && { usage; exit 0; }

args=$(cat <<EOF
$fopts
(
	-name .Trash -o
	-name .Trashes -o
	-name 'lost+found'
) -prune -o
(
	-false
	$fparams
)
-print
$( [[ ! $opt_dryrun ]] && echo '-exec rm \{\} \;' )
EOF)

for path in "${@:-$PWD}"; do
	[[ $opt_quiet ]] &&
		echo "$args" | xargs find -s "$path" 1>/dev/null ||
		echo "$args" | xargs find -s "$path"
done
