#!/usr/bin/env bash
. colors.sh 2>/dev/null # color output support

SCRIPT_NAME="update2.sh"
SCRIPT_VERSION=1.1.1
SCRIPT_DESCRIPTION="Run updates for a variety of applications"
SCRIPT_USAGE="${0##*/} [options] [script] ..."
SCRIPT_GETOPT_SHORT="ae:d:lh"
SCRIPT_GETOPT_LONG="autoupdate,enable:,disable:,list,help"

usage() {
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESCRIPTION\n\n$SCRIPT_USAGE\nOptions:"
	cat <<EOF | column -s\& -t
 -a, --autoupdate&run autoupdate enabled scripts
 -l, --list&list available update scripts
 -e, --enable=SCRIPT&enable a script for autoupdating
 -d, --disable=SCRIPT&disable a script from autoupdating
 -h, --help&show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

PATH_ROOT="$(dirname "`greadlink -f "$0"`")"
PATH_RUNSCRIPT="$PATH_ROOT/run.sh"
PATH_SCRIPTS="$PATH_ROOT/scripts"
PATH_SETTINGS=~/".${SCRIPT_NAME}.cfg"

[[ -f "$PATH_SETTINGS" ]] && . "$PATH_SETTINGS"

EXECSCRIPT_COUNT=0
SCRIPTS_ALL=()
SCRIPTS_ENABLED=()

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

saveSettings() {
	IFS=$'\n'
	SCRIPTS_AUTOUPDATE=( $( printf "%s\n" "${SCRIPTS_ENABLED[@]}" | awk 'x[$0]++ == 0' ) )
	declare -p SCRIPTS_AUTOUPDATE > "${PATH_SETTINGS}"
}

runScript() {
	[[ ! -f "$PATH_SCRIPTS/$1" ]] && FAIL "script '$1' not found"

	scriptHeader ${2:-$1}
	# cd "$PATH_ROOT" &>/dev/null &&
	"$PATH_RUNSCRIPT" "$PATH_SCRIPTS/$1" && EXECSCRIPT_COUNT=$(($EXECSCRIPT_COUNT+1))
}

scriptHeader() {
	[[ -n "$@" ]] && printf "${CLR_BG_CYAN}${CLR_BLACK}${CLR_BOLD}$@${CLR_R}\n"
}

scriptExists() {
	for (( i = 0 ; i < ${#SCRIPTS_ALL[@]} ; i++ )); do
		[[ "$1" = "${SCRIPTS_ALL[$i]}" ]] && return 0
	done
	return 1
}

listScripts() {
	for (( i = 0 ; i < ${#SCRIPTS_ALL[@]} ; i++ )); do
		s="${SCRIPTS_ALL[$i]}"
		for (( x = 0 ; x < ${#SCRIPTS_ENABLED[@]} ; x++ )); do
			if [[ "${SCRIPTS_ENABLED[$x]}" == "$s" ]]; then
				# printf "${CLR_GREEN}$s${CLR_R}\n"
				printf "${CLR_GREEN}*${CLR_R} $s\n"
				continue 2
			fi
		done
		printf "  $s\n"
	done
}

loadScripts() {
	for f in ${PATH_SCRIPTS}/* ; do
		addScript "$f"
	done
}

addScript() {
	if [[ ! -x "$1" ]]; then return; fi

	name=`basename "$1"`
	SCRIPTS_ALL=( "${SCRIPTS_ALL[@]}" "$name" )

	for (( i = 0 ; i < ${#SCRIPTS_AUTOUPDATE[@]} ; i++ )); do
		if [[ "$name" = "${SCRIPTS_AUTOUPDATE[$i]}" ]]; then
			SCRIPTS_ENABLED=( "${SCRIPTS_ENABLED[@]}" "$name" )
			break
		fi
	done
	return
}

runAutoupdates() {
	for (( i = 0 ; i < ${#SCRIPTS_ENABLED[@]} ; i++ )); do
		runScript "${SCRIPTS_ENABLED[$i]}"
	done
}

scriptEnable() {
	scriptExists "$1" || FAIL "script '$1' not found"
	SCRIPTS_ENABLED=( "${SCRIPTS_ENABLED[@]}" "$1" )
	return
}

scriptDisable() {
	scriptExists "$1" || FAIL "script '$1' not found"
	sc=()
	for (( i = 0 ; i < ${#SCRIPTS_ENABLED[@]} ; i++ )); do
		[[ "$1" != "${SCRIPTS_ENABLED[$i]}" ]] && sc=( "${sc[@]}" "${SCRIPTS_ENABLED[$i]}" )
	done
	SCRIPTS_ENABLED=( "${sc[@]}" )
	return
}

if [[ "$@" ==  "--" ]]; then usage; exit 0; fi

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

saveSettings

if [[ $DO_LIST || $DO_AUTOUPDATES ]]; then
	[[ $DO_LIST ]] && listScripts
	[[ $DO_AUTOUPDATES ]] && runAutoupdates
fi

for arg in "$@"; do scriptExists "$arg" && runScript "$arg"; done