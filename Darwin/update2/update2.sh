#!/usr/bin/env bash
. colors.sh 2>/dev/null # color output support
SCRIPT_NAME="update2"
SCRIPT_VERSION="1.1.4 (2011-05-19)"
SCRIPT_GETOPT_SHORT="ad:e:lh"
SCRIPT_GETOPT_LONG="autoupdate,disable:,enable:,list,help"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Consolidate, manage, and run update scripts for a variety of applications.

Usage: ${0##*/} [options] [script] ...

Options:
 -a, --autoupdate      Update enabled scripts
 -d, --disable=SCRIPT  Remove a script from autoupdate
 -e, --enable=SCRIPT   Enable a script in autoupdate
 -l, --list            List available scripts
 -h, --help            Show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

PATH_UPDATE2="$(readlink -f "$0" 2>/dev/null || greadlink -f "$0")"
PATH_ROOT="$(dirname "$PATH_UPDATE2")"
PATH_RUNSCRIPT="$PATH_ROOT/run_script.sh"
PATH_SCRIPTS="$PATH_ROOT/scripts"
PATH_SETTINGS=~/".${SCRIPT_NAME}"

[[ -f "$PATH_SETTINGS" ]] && . "$PATH_SETTINGS"

EXECSCRIPT_COUNT=0
SCRIPTS_ALL=()
SCRIPTS_ENABLED=()

save_settings() {
    IFS=$'\n'
    SCRIPTS_AUTOUPDATE=( $( printf "%s\n" "${SCRIPTS_ENABLED[@]}" | awk 'x[$0]++ == 0' ) )
    declare -p SCRIPTS_AUTOUPDATE > "${PATH_SETTINGS}"
}

script_run() {
    script_header ${2:-$1}
    "$PATH_RUNSCRIPT" "$PATH_SCRIPTS/$1" && EXECSCRIPT_COUNT=$(($EXECSCRIPT_COUNT+1))
}

script_header() { [[ "$@" ]] && echo -e ${CLR_BG_CYAN}${CLR_BLACK}${CLR_BOLD}$@${CLR_R}; }

script_exists() {
    for (( i = 0 ; i < ${#SCRIPTS_ALL[@]} ; i++ )); do
        [[ "$1" == "${SCRIPTS_ALL[$i]}" ]] && return 0
    done
    return 1
}

listScripts() {
    for (( i = 0 ; i < ${#SCRIPTS_ALL[@]} ; i++ )); do
        s="${SCRIPTS_ALL[$i]}"
        for (( x = 0 ; x < ${#SCRIPTS_ENABLED[@]} ; x++ )); do
            [[ "${SCRIPTS_ENABLED[$x]}" == "$s" ]] &&
                { printf "${CLR_GREEN}*${CLR_R} $s\n"; continue 2; }
        done
        printf "  $s\n"
    done
}

loadScripts() {
    for f in ${PATH_SCRIPTS}/* ; do
        [[ ! -x "$f" ]] && return 1
        name="$(basename "$f")"
        SCRIPTS_ALL=( "${SCRIPTS_ALL[@]}" "$name" )
        for (( i = 0 ; i < ${#SCRIPTS_AUTOUPDATE[@]} ; i++ )); do
            [[ "$name" == "${SCRIPTS_AUTOUPDATE[$i]}" ]] && 
                { SCRIPTS_ENABLED=( "${SCRIPTS_ENABLED[@]}" "$name" ); break; }
        done
    done
}

runAutoupdates() {
    for (( i = 0 ; i < ${#SCRIPTS_ENABLED[@]} ; i++ )); do
        script_run "${SCRIPTS_ENABLED[$i]}"
    done
}

scriptEnable() {
    script_exists "$1" || FAIL "script '$1' not found"
    SCRIPTS_ENABLED=( "${SCRIPTS_ENABLED[@]}" "$1" )
    return
}

scriptDisable() {
    script_exists "$1" || FAIL "script '$1' not found"
    sc=()
    for (( i = 0 ; i < ${#SCRIPTS_ENABLED[@]} ; i++ )); do
        [[ "$1" != "${SCRIPTS_ENABLED[$i]}" ]] && sc=( "${sc[@]}" "${SCRIPTS_ENABLED[$i]}" )
    done
    SCRIPTS_ENABLED=( "${sc[@]}" )
    return
}

[[ "$@" ==  "--" ]] && { usage; exit 1; }

loadScripts

while true; do
    case $1 in
        -h|--help) usage; exit 0 ;;
        -l|--list) DO_LIST=1 ;;
        -a|--autoupdate) DO_AUTOUPDATES=1 ;;
        -e|--enable) scriptEnable "$2"; shift ;;
        -d|--disable) scriptDisable "$2"; shift ;;
        *) shift; break ;;
    esac
    shift
done

save_settings

if [[ $DO_LIST || $DO_AUTOUPDATES ]]; then
    [[ $DO_LIST ]] && listScripts
    [[ $DO_AUTOUPDATES ]] && runAutoupdates
fi

for arg in "$@"; do
    script_exists "$arg" || FAIL "script '$1' not found"
    script_run "$arg"
done
