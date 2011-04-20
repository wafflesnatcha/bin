#!/usr/bin/env bash

SCRIPT_NAME="findstring.sh"
SCRIPT_VERSION="1.0.7 [2011-04-19]"
SCRIPT_DESCRIPTION="Recursively find strings in files"
SCRIPT_GETOPT_SHORT="bd:fip:h"
SCRIPT_GETOPT_LONG="binary,depth:,filenames,ignore-case,path:,help"

usage() {
    cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
$SCRIPT_DESCRIPTION

Usage: ${0##*/} [options] text ...

Options:
EOF
    cat <<EOF | column -s\& -t
 -b, --binary&Include binary files in the search
 -d, --depth=NUM&Maximum depth to search subdirectories
 -f, --filenames&just print out a list of the files that match, no context
 -i, --ignore-case&case insensitive search
 -p, --path=PATH&search for files in this path (default current directory)
 -h, --help&show this output
EOF
}

FAIL() { printf "${SCRIPT_NAME}: $1\n" >&2 && exit ${2:-1}; }

ARGS=$(getopt -s bash --options ${SCRIPT_GETOPT_SHORT} --longoptions ${SCRIPT_GETOPT_LONG} --name "$SCRIPT_NAME" -- "$@")
[ $? != 0 ] && exit 1; eval set -- "$ARGS"

CONFIG_binary=
CONFIG_depth=
CONFIG_filenames=
CONFIG_ignore_case=
CONFIG_path="$PWD"

runFind() {
    local grepopts="--no-messages --with-filename --line-number --color=auto"
	local findopts=""

    [[ $CONFIG_binary ]] && grepopts="${grepopts} --binary-files=text" || grepopts="${grepopts} --binary-files=without-match"
    [[ $CONFIG_filenames ]] && grepopts="${grepopts} -l"
    [[ $CONFIG_ignore_case ]] && grepopts="${grepopts} -i"
	[[ $CONFIG_depth ]] && findopts="${findopts} -maxdepth ${CONFIG_depth}"

	find "$CONFIG_path" -print0 -type f \
		-not -path '*/.Trash/*' \
		-not -path '*/.Trashes/*' \
		-not -path '*lost+found/' \
		$findopts \
		| xargs -0 -n 100 grep $grepopts "$@"
}

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
		-b|--binary) CONFIG_binary=1 ;;
        -d|--depth) CONFIG_depth="$2"; shift ;;
        -f|--filenames) CONFIG_filenames=1 ;;
        -i|--ignore-case) CONFIG_ignore_case=1 ;;
        -p|--path)			
            [[ ! -d "$2" ]] && FAIL "specified path doesn't exist" 
            CONFIG_path="$2"
            shift
        ;;
        *) shift; break ;;
    esac
    shift
done

if [[ ! $1 ]]; then usage; exit 0; fi

runFind "$@"
