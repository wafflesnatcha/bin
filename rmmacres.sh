#!/usr/bin/env bash
SCRIPT_NAME="rmmacres"
SCRIPT_VERSION="1.6.4 (2011-05-17)"
SCRIPT_DESCRIPTION="Find and remove Mac resource & junk files."
SCRIPT_GETOPT_SHORT="afismd:nh"
SCRIPT_GETOPT_LONG="all,forks,icons,dsstore,misc,depth:,dry-run,help"

usage() {
    cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
$SCRIPT_DESCRIPTION

Usage: ${0##*/} [options] [path ...]

Options:
 -a, --all        Same as -fism
 -f, --forks      Remove resource forks (._*)
 -i, --icons      Remove custom icons (Icon^M)
 -s, --dsstore    Remove Finder settings files (.DS_Store)
 -m, --misc       Remove other miscellaneous junk (.localized)
 -d, --depth=NUM  Maximum depth to search subdirectories
 -n, --dry-run    Just show what would be deleted
 -h, --help       Show this output
EOF
}

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

find_forks='-or -name ._\*'
find_dsstore='-or -name .DS_Store'
find_icons="-or -name "$'Icon\r'
find_misc='-or -name .localized'

fnames=
factions="-print -delete"
fopts=

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -n|--dry-run) factions="-print" ;;
        -d|--depth) fopts="$fopts -maxdepth $2"; shift ;;

        -s|--dsstore) fnames="$fnames $find_dsstore" ;;
        -f|--forks) fnames="$fnames $find_forks" ;;
        -i|--icons) fnames="$fnames $find_icons" ;;
        -m|--misc) fnames="$fnames $find_misc" ;;

        -a|--all) fnames="$fnames $find_dsstore $find_forks $find_icons $find_misc" ;;
        *) shift; break ;;
    esac
    shift
done

[[ ! $fnames ]] && { usage; exit 0; }

for arg in "${@:-$PWD}"; do
    [[ -d "$arg" ]] && find "$arg" ${fopts} \
        -not -path '*.Trash/*' \
        -not -path '*.Trashes/*' \
        \( -false ${fnames} \) \
        $factions
done
