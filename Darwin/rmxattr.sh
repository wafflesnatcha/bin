#!/usr/bin/env bash
SCRIPT_NAME="rmxattr.sh"
SCRIPT_VERSION="0.0.2 2012-04-25"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Remove all extended attributes from a file

Usage: ${0##*/} [options] PATH ...

Options:
 -r, --recursive  Recursively search directories
 -n, --dry-run    Show what would be deleted and exit
 -h, --help       Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

while (($#)); do
	case $1 in
        -h|--help) usage; exit 0 ;;
		-n|--dry-run) opt_dryrun=1 ;;
		-r|--recursive) opt_recursive=1 ;;
		-*|--*) FAIL "unknown option $1" ;;
        *) break ;;
	esac
	shift
done

remove_xattr() {
	for attr in $(xattr "$1" 2>/dev/null); do
		echo "$1: $attr"
		[[ ! $opt_dryrun ]] && xattr -d "$attr" "$1"
	done
}

[[ ! $1 ]] && { usage; exit 0; }

for f in "${@:-$PWD}"; do
	if [[ $opt_recursive ]]; then
		find "$f" -xattr -print | { while read x; do remove_xattr "$x"; done; }
	else
		remove_xattr "$f"
	fi
done
