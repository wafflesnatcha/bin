#!/usr/bin/env bash

SCRIPT_NAME="rmmacres.sh"
SCRIPT_VERSION="1.5.9 [2011-04-19]"
SCRIPT_DESCRIPTION="Find and remove Mac resource & junk files."
SCRIPT_USAGE="${0##*/} [options] path ..."
SCRIPT_GETOPT_SHORT="d:sfinh"
SCRIPT_GETOPT_LONG="depth:,dsstore,forks,icons,dry-run,help"

usage() {
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESCRIPTION\n\n$SCRIPT_USAGE\n\nOptions:"
	column -t -s '&' <<EOF
 -d, --depth=NUM&Maximum depth to search subdirectories
 -f, --forks&only remove resource forks (._*)
 -i, --icons&only remove custom icons (Icon^M)
 -n, --dry-run&don't actually delete anything, just show what would be deleted
 -s, --dsstore&only remove Finder settings files (.DS_Store)
 -h, --help&show this output
EOF
}

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

CONFIG_depth=
CONFIG_dryrun=
CONFIG_dsstore=
CONFIG_forks=
CONFIG_icons=

runFind() {
	local CR=`printf "\r"`
	local opts=
	local names=
	local actions="-print"
	
	[[ ! $CONFIG_dryrun ]] && actions="$actions -delete"
	
	[[ $CONFIG_depth ]] && opts="${opts} -maxdepth ${CONFIG_depth}"
	
	[[ $CONFIG_forks ]] && names="$names -or -name '._*'"
	[[ $CONFIG_dsstore ]] && names="$names -or -name .DS_Store"
	[[ $CONFIG_icons ]] && names="$names -or -name "$'Icon\r'
	
	[[ ! $names ]] && names=" -or -name '._*' -or -name .localized -or -name .DS_Store -or -name "$'Icon\r'
	
	find "$1" ${opts} \
		-not -path '*/.Trash/*' \
		-not -path '*/.Trashes/*' \
		-not -path '*lost+found/' \
		\( -false $names \) \
		$actions
}

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d|--depth) CONFIG_depth="$2"; shift ;;
		-f|--forks) CONFIG_forks=1 ;;
		-i|--icons) CONFIG_icons=1 ;;
		-n|--dry-run) CONFIG_dryrun=1 ;;
		-s|--dsstore) CONFIG_dsstore=1 ;;
		*) shift; break ;;
	esac
	shift
done

for arg in "${@:-$PWD}"; do
	[[ -d "$arg" ]] && runFind "$arg"
done
