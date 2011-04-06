#!/usr/bin/env bash

SCRIPT_NAME="zipup.sh"
SCRIPT_VERSION="1.0.1 [2011-04-05]"
SCRIPT_DESCRIPTION="Quickly make archives of files and directories"
SCRIPT_USAGE="${0##*/} [options] path ..."
SCRIPT_GETOPT_SHORT="7dh"
SCRIPT_GETOPT_LONG="7zip,append-date,help"

usage() {
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESCRIPTION\n\n$SCRIPT_USAGE\n\nOptions:"
	column -t -s '&' <<EOF
 -7, --7zip&compress with 7-zip (requires 7z)
 -d, --append-date&append the date to the end of the filename (%Y%m%d)
 -h, --help&show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

CONFIG_format="zip" # zip | 7z
CONFIG_append_date=

makeFilename() {
	local count=2
	local basename="`basename "$1"`"
	local extension="$CONFIG_format"
	
	[[ $CONFIG_append_date ]] && basename="${basename}-`date +%Y%m%d`"

	local archive="$basename"

	while [[ -e "$archive.$extension" ]]; do
		archive="$basename $count"
		count=$(($count+1))
	done

	echo "$archive.$extension"
}

zipup() {
	[[ ! -e "$1" ]] && continue
	local filename="`makeFilename "$1"`"
	
	if [[ ${CONFIG_format} == "7z" ]]; then
		7z a "$filename" "$1" || FAIL
	else
		zip -r "$filename" "$1" || FAIL
	fi
}

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-7|--7zip) CONFIG_format="7z" ;;
		-d|--append-date) CONFIG_append_date=1 ;;
		*) shift; break ;;
	esac
	shift
done

[[ ${#} < 1 ]] && ( usage; exit 0 )

for f in "$@"; do
	zipup "$f"
done
