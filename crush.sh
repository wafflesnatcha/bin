#!/usr/bin/env bash
# crush.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="r4 2012-08-30"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
A quick interface to simplify the processing of images with any of:
  optipng, pngcrush, jpgcrush

Usage: ${0##*/} [OPTION]... FILE...

Options:
 -p, --percentage  Prefix output lines with overall percent completed (useful
                   when piping to CocoaDialog progressbar)
 -h, --help        Show this help
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

type optipng &>/dev/null && opt_optipng="optipng"
type pngcrush &>/dev/null && opt_pngcrush="pngcrush"
type jpgcrush &>/dev/null && opt_jpgcrush="jpgcrush"

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-p|--percentage) opt_percentage=1 ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

process() {
	fext=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')
	case "$fext" in
		png)
		if [[ $opt_optipng ]]; then
			"$opt_optipng" -quiet -preserve "$1"
		elif [[ $opt_pngcrush ]]; then
			temp_file tmpfile &&
				chmod $(stat -f%p "$1") "$tmpfile" &&
				"$opt_pngcrush" -rem gAMA -rem alla -rem text -oldtimestamp "$1" "$tmpfile" 2>/dev/null &&
				mv "$tmpfile" "$1"
		else
			return 1
		fi
		;;

		jpg|jpeg)
		[[ ! $opt_jpgcrush ]] && return 1
		"$opt_jpgcrush" "$1" 1>/dev/null
		;;

		*) return 1 ;;
	esac
}

count=0
for f in "$@"; do
	(( count++ ))
	percent=$(echo "$count/$#*100" | bc -l | xargs printf "%1.0f%%";)
	process "$f" || continue
	[[ $opt_percentage ]] && echo -n "$percent [$percent] "
	echo "$(basename "$f")"
done
