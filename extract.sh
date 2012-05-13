#!/usr/bin/env bash
# extract.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="extract.sh"
SCRIPT_VERSION="0.2.0 2012-04-13"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Automatically extract compressed files of various types.

Usage: ${0##*/} FILE...
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		*) break ;;
	esac
	shift
done

[[ ! "$1" ]] && { usage; exit 0; }

for f in "$@"; do
	[[ ! -f "$f" ]] && continue
	case "$(echo $f | tr '[A-Z]' '[a-z]')" in
		
		*.tar.bz2|*.tbz2|*.tbz)
		tar -xjvpf "$f"
		;;
		
		*.tar.gz|*.tgz)
		tar -xzvpf "$f"
		;;
		
		*.tar.xz|*.txz)
		tar -xvpf "$f"
		;;

		*.7z)
		bin=$(which 7z 7zr 2>/dev/null | head -n1)
		[[ ! $bin ]] && FAIL "couldn't find path to 7z or 7zr"
		"$bin" x "$f"
		;;

		*.bz2|*.bzip2|*.bz)
		bzip2 -dkv "$f"
		;;

		*.gz|*.gzip)
		gzip -d "$f"
		;;

		*.rar)
		unrar x "$f"
		;;

		*.xar)
		xar -d "$f"
		;;

		*.xz)
		xz -dv "$f"
		;;

		*.zip|*.z01)
		unzip "$f"
		;;
		
		*) FAIL "don't know how to handle '$f'" ;;
	esac
done

