#!/usr/bin/env bash
SCRIPT_NAME="extract.sh"
SCRIPT_VERSION="0.1.4 2012-02-29"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Automatically extract compressed files of various types.

Usage: ${0##*/} file ...
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
		*.tar.bz2|*.tbz2) tar -xvpf "$f" ;;
		*.tar.gz|*.tgz) tar -xvpf "$f" ;;
		*.7z) 7z x "$f" ;;
		*.bz2|*.bzip2|*.bz) bunzip2 "$f" ;;
		*.gz) gzip -d "$f" ;;
		*.rar) unrar x "$f" ;;
		*.zip|*.z01) unzip "$f" ;;
		*) FAIL "don't know how to handle '$f'" ;;
	esac
done

