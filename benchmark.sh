#!/usr/bin/env bash

SCRIPT_NAME="benchmark.sh"
SCRIPT_VERSION="0.3.2 (2011-04-28)"
SCRIPT_DESCRIPTION="Benchmark a shell script."
SCRIPT_USAGE="${0##*/} [options]"
SCRIPT_GETOPT_SHORT="c:i:d:o:h"
SCRIPT_GETOPT_LONG="command:iterations:,delay:,output:,help"

opt_command=
opt_delay=2
opt_iterations=20
opt_output=

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
$SCRIPT_DESCRIPTION

Usage: $SCRIPT_USAGE

Options:
 -c, --command     command to run (otherwise stdin)
 -i, --iterations  number of iterations to run (${opt_iterations})
 -d, --delay       seconds to wait in between executions (${opt_delay})
 -o, --output      file to write results to
 -h, --help        show this output
EOF
}
FAIL() { echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

ARGS=$(getopt -s bash -o "$SCRIPT_GETOPT_SHORT" -l "$SCRIPT_GETOPT_LONG" -n "$SCRIPT_NAME" -- "$@") || exit
eval set -- "$ARGS"

tempfile() {
	local filename=$(mktemp -t "${0##*/}")
	trap "rm -f '$filename'" 0
	trap "rm -f '$filename'; exit 1" 2
	trap "rm -f '$filename'; exit 1" 1 15
	echo "$filename"
}

getStdIn() {
	local TMPCMD=`tempfile`
	cat - > "$TMPCMD"
	chmod +x "$TMPCMD"
	opt_command="$TMPCMD"
}

execute() {
	{ $TIME_BIN $opt_command >/dev/null
} 2>> $TMPFILE
}

TIME_BIN=`which time | sed 1q`
[[ ! $TIME_BIN ]] && FAIL "can't locate time program"

while true; do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-o|--output) opt_output="$2"; shift ;;
		-i|--iterations) opt_iterations=$2; shift ;;
		-d|--delay) opt_delay=$2; shift ;;
		-c|--command) opt_command="$2"; shift ;;
		*) shift; break ;;
	esac
	shift
done

[[ -z "$opt_command" ]] && getStdIn

TMPFILE=`tempfile`

echo -n "benchmarking... "
tput sc
for (( i = 1; i <= $opt_iterations; i++ )); do
	tput rc
	echo -n "$i/$opt_iterations"
	sleep $opt_delay
	execute
done
tput rc 
echo


if [[ "${opt_output}" ]]; then
	mv "${TMPFILE}" "${opt_output}"
else
	cat "${TMPFILE}"
fi

