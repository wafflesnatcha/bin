#!/usr/bin/env bash
# `browser.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="browser.sh"
SCRIPT_VERSION="r1 2012-11-03"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Pipe HTML into the default browser.

Usage: ${0##*/} [OPTION]...

Options:
 -b, --body  Wrap input in a proper HTML document. Use this if the input
             contains only the HTML body. 
 -h, --help  Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

while (($#)); do
	case $1 in
		-h|--help)
			usage; exit 0 ;;
		-f|--body)
			opt_body=1 ;;

		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

tmpfile=$(mktemp -t "${0##*/}")
mv "$tmpfile" "$tmpfile.html"
tmpfile="$tmpfile.html"

[[ $opt_body ]] && echo "<!DOCTYPE html><html><head><title>$(basename "$tmpfile")</title></head><body>" >> "$tmpfile"
cat >> "$tmpfile"
[[ $opt_body ]] && echo "</body></html>" >> "$tmpfile"
open $tmpfile
