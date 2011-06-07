#!/usr/bin/env bash
SCRIPT_NAME="zipup.sh"
SCRIPT_VERSION="1.1.2 (2011-05-17)"
SCRIPT_DESCRIPTION="Quickly make archives of files and directories."
SCRIPT_GETOPT_SHORT="7do:h"
SCRIPT_GETOPT_LONG="7zip,date,output:,help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
$SCRIPT_DESCRIPTION

Usage: ${0##*/} [options] path ...

Options:
 -7, --7zip         Compress with 7-zip (requires 7z)
 -d, --date         Append the current date to the end of the filename
 -o, --output=PATH  Directory to place the archive in (default is current
                    working directory)
 -h, --help         Show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

opt_format="zip"
opt_date=
opt_date_format=%Y-%m-%d
opt_output="$PWD"

uniquefile() {
    local i=1
    local dir="$(dirname "$1")"
    local file="$(basename "$1")"
    local name="${file%.*}"
    local ext="${file##*.}"
    local try="$name"
    while [[ -e "$dir/$try.$ext" ]]; do
        i=$(($i+1)); try="${name}${2:-.}${i}";
    done
    echo "$dir/$try.$ext"
}

zipup() {
    [[ ! -e "$1" ]] && continue

    local file="$(basename "$1")"
    local out="`uniquefile "${opt_output}/${file}${opt_date}.${opt_format}"`"

    if [[ ${opt_format} == "7z" ]]; then
        7z a "$out" "$1" || FAIL
    else
        zip -r "$out" "$1" || FAIL
    fi
    echo "$out"
}

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -7|--7zip) opt_format="7z" ;;
        -d|--date) opt_date="-$(date +$opt_date_format)" ;;
        -o|--output)
            [[ ! -d "$2" ]] && FAIL "invalid output directory $2"
            opt_output="$2"; shift
        ;;
        *) shift; break ;;
    esac
    shift
done

[[ ${#} < 1 ]] && ( usage; exit 0 )

for f in "$@"; do
    zipup "$f"
done
