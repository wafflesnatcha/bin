#!/usr/bin/env bash
# `runclipboard.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="runclipboard.sh"
SCRIPT_VERSION="r1 2012-07-11"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Run the contents of the clipboard as a script.
$([[ "$TERM" =~ xterm-(256)?color ]]&&echo -e '\033[1;5;7;31m')
WARNING: This script will run ANYTHING on the clipboard!
$([[ "$TERM" =~ xterm-(256)?color ]]&&echo -e '\033[m')
Usage: ${0##*/} [OPTION]... [--] [ARGUMENT]...

Options:
 -i, --interpreter UTILITY  Specify an interpreter (bash, ruby, /bin/sh, ...)
 -h, --help                 Show this help
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

get_interpreter() { which "$1" 2>&1; }

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-i|--interpreter)
		opt_interpreter=$(get_interpreter "$2" 2>&1)
		[[ ! $? = 0 ]] && ERROR "bad interpreter" 1
		shift
		;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

temp_file tmpfile
pbpaste > "$tmpfile"

first_line="$(HEAD -n 1 "$tmpfile")"

if [[ $opt_interpreter ]]; then
	[[ "$first_line" =~ ^#\! ]] && tail -n +2 "$tmpfile" > "$tmpfile"
	prepend="#!${opt_interpreter}"
elif [[ ! "$first_line" =~ ^#\! ]]; then
	case "$first_line" in
		"<?php"*)
		prepend="#!$(get_interpreter "php")"
		[[ ! $? = 0 ]] && prepend=
		;;
		*)
		prepend="#!/usr/bin/env bash"
		;;
	esac
fi

if [[ $prepend ]]; then
	temp_file tmpfile2
	echo "${prepend}" > "$tmpfile2"
	cat "$tmpfile" >> "$tmpfile2"
	cp "$tmpfile2" "$tmpfile"
fi

chmod +x "$tmpfile"
"$tmpfile" "$@"
