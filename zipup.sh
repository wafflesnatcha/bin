#!/usr/bin/env bash
SCRIPT_NAME="zipup.sh"
SCRIPT_VERSION="1.1.4 (2012-01-30)"
SCRIPT_GETOPT_SHORT="7do:h"
SCRIPT_GETOPT_LONG="7zip,date,output:,help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Quickly make archives of files and directories.

Usage: ${0##*/} [options] path ...

Options:
 -7, --7zip         Compress with 7-zip (requires 7z)
 -d, --date         Append the current date to the end of the filename
 -o, --output=PATH  Directory to place the archive in (default is current
                    working directory)
 -h, --help         Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

opt_format="zip"
opt_date=
opt_date_format=%Y-%m-%d
opt_prefix_date="-"
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

processFile() {
    [[ ! -e "$1" ]] && continue
    
    local file="$(basename "$1")"
    [[ -d "$1" ]] && file="$(cd "$1"; basename "$PWD")"

    local out="`uniquefile "${opt_output}/${file}${opt_date}.${opt_format}"`"

    if [[ ${opt_format} = "7z" ]]; then
        7z a "$out" "$1" || exit 1
    else
        zip -r "$out" "$1" || exit 1
    fi
}

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -7|--7zip) opt_format="7z" ;;
        -d|--date) opt_date="${opt_prefix_date}$(date +$opt_date_format)" ;;
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
    processFile "$f"
done
