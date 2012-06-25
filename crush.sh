#!/usr/bin/env bash
# crush.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="r1 2012-06-25"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
A quick interface to simplify the processing of images with pngcrush
and/or jpgcrush.

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

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-p|--percentage) opt_percentage=1 ;;
		--) break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

count=0

for f in "$@"; do
	(( count++ ))
	percent=$(echo "$count/$#*100" | bc -l | xargs printf "%1.0f%%";)
	[[ $opt_percentage ]] && echo -n "$percent [$percent] "
	echo "$(basename "$f")"

	case "${f##*.}" in
		png)
			[[ ! $pngcrush ]] && { pngcrush=$(which pngcrush 2>/dev/null) || ERROR "pngcrush not found" 2; }
			temp_file tmpfile
			chmod $(stat -f%p "$f") "$tmpfile"
			"$pngcrush" -rem gAMA -rem alla -rem text -oldtimestamp "$f" "$tmpfile" 2>/dev/null &&
				mv "$tmpfile" "$f"
		;;
		jpg|jpeg)
			[[ ! $jpgcrush ]] && { jpgcrush=$(which jpgcrush 2>/dev/null) || ERROR "jpgcrush not found" 2; }
			"$jpgcrush" "$f"
		;;
	esac
done
