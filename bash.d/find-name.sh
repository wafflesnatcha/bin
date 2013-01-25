#!/usr/bin/env bash
# Usage: find-name PATTERN
#
# Find files in the current directory matching PATTERN.s
find-name() {
	[[ ! $1 ]] && cat <<-EOF 1>&2 && return 1
		Usage: find-name PATTERN

		Find files in the current directory matching PATTERN.
		EOF
	find "$PWD" -iname "*$**" | sed -E "s/^${PWD//\//\\/}\/?//"
}
