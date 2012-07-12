#!/usr/bin/env bash
# extract.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="extract.sh"
SCRIPT_VERSION="r1 2012-07-11"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Automatically extract compressed files of various types.

Usage: ${0##*/} FILE...
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
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
		[[ ! $bin ]] && ERROR "couldn't find path to 7z or 7zr" 3
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

		*) ERROR "don't know how to handle '$f'" 2 ;;
	esac
done
