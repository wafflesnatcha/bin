#!/usr/bin/env bash
# benchmark.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="benchmark.sh"
SCRIPT_VERSION="r2 2012-08-10"

opt_delay=0
opt_iterations=1

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Benchmark a shell script.

Usage: ${0##*/} [OPTION]...[COMMAND]

Options:
 -d, --delay SECONDS   Seconds to wait in between executions (default ${opt_delay})
 -i, --iterations NUM  Number of iterations to run (default ${opt_iterations})
 -h, --help            Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

temp_file() {
	local var
	for var in "$@"; do
		eval $var=\"$(mktemp -t "${0##*/}")\"
		temp_file__files="$temp_file__files '${!var}'"
	done
	trap "rm -f $temp_file__files" EXIT
}

make_cmd() {
	temp_file TMPCMD
	if [[ ! $1 ]]; then
		[[ ! -p /dev/stdin ]] && echo -e "Enter a command, followed by newline, followed by Ctrl-D (End of File).\nTo cancel, press Ctrl-C."
		cat - > "$TMPCMD"
	else
		echo "$@" > "$TMPCMD"
	fi
	chmod +x "$TMPCMD"
}

TIME_BIN=$(which time 2>/dev/null) || ERROR '`time` not found' 2

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d*|--delay)
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_delay="${1:2}" || { opt_delay=$2; shift; }
			{ echo -n "$opt_delay" | grep -E "^[0-9]{0,}\.?[0-9]{1,}$" &>/dev/null; } || ERROR "invalid delay" 1
		;;
		-i*|--iterations)
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_iterations="${1:2}" || { opt_iterations=$2; shift; }
			[[ ! $opt_iterations =~ ^[0-9]+$ || $opt_iterations < 1 ]] && ERROR "invalid iterations" 1
		;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

make_cmd "$@"
[[ ! -s "$TMPCMD" ]] && { usage; exit; } # command was empty

total_time=0
for (( i = 1; i <= $opt_iterations; i++ )); do
	[[ $i > 1 ]] && sleep $opt_delay
	seconds=$({ "$TIME_BIN" "$TMPCMD"; } 2>&1 | tail -n1 | sed -E 's/^[ ]*([^ ]*).*$/\1/')
	echo "$seconds"
	[[ $seconds ]] && total_time=$(echo $total_time $seconds | awk '{print $1+$2}')
done

average_time=$(echo $total_time $opt_iterations | awk '{printf "%.2f", $1/$2}')
echo "Average Time: $average_time seconds"
echo "Total Time:   $total_time seconds"
