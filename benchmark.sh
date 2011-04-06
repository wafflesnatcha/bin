#!/usr/bin/env bash

SCRIPT_NAME="benchmark.sh"
SCRIPT_VERSION="0.3.1 [2011-04-05]"
SCRIPT_DESCRIPTION="Benchmark a shell script"
SCRIPT_USAGE="${0##*/} [options]"
SCRIPT_GETOPT_SHORT="c:i:d:o:h"
SCRIPT_GETOPT_LONG="command:iterations:,delay:,output:,help"

CONFIG_command=
CONFIG_delay=2
CONFIG_iterations=20
CONFIG_output=

usage() {
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESCRIPTION\n\n$SCRIPT_USAGE\n\nOptions:"
	column -t -s '&' <<EOF
 -c, --command&command to run (otherwise stdin)
 -i, --iterations&number of iterations to run (${CONFIG_iterations})
 -d, --delay&seconds to wait in between executions (${CONFIG_delay})
 -o, --output&file to write results to
 -h, --help&show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

tempFile() {
	local filename=`mktemp -t "${0##*/}"`
	trap "rm -f '$filename'" 0
	trap "rm -f '$filename'; exit 1" 2
	trap "rm -f '$filename'; exit 1" 1 15
	echo $filename
}

getStdIn() {
	local TMPCMD=`tempFile`
	cat - > "$TMPCMD"
	chmod +x "$TMPCMD"
	CONFIG_command="$TMPCMD"
}

execute() {
	{ $TIME_BIN $CONFIG_command >/dev/null
} 2>> $TMPFILE
}

TIME_BIN=`which time | sed 1q`
[[ ! $TIME_BIN ]] && FAIL "can't locate time program"

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-o|--output) CONFIG_output="$2"; shift ;;
		-i|--iterations) CONFIG_iterations=$2; shift ;;
		-d|--delay) CONFIG_delay=$2; shift ;;
		-c|--command) CONFIG_command="$2"; shift ;;
		*) shift; break ;;
	esac
	shift
done

[[ -z "$CONFIG_command" ]] && getStdIn

TMPFILE=`tempFile`

echo -n "benchmarking... "
tput sc
for (( i = 1; i <= $CONFIG_iterations; i++ )); do
	tput rc
	echo -n "$i"
	sleep $CONFIG_delay
	execute
done
tput rc 
# tput dl1
echo


if [[ "${CONFIG_output}" ]]; then
	mv "${TMPFILE}" "${CONFIG_output}"
else
	cat "${TMPFILE}"
fi

