#!/usr/bin/env bash
# Usage: lr [OPTION]... [FILE]...
#
# Replacement for `ls -R`.
#
# OPTION can be any options available to the `ls` command.
lr() {
	local f
	while [[ "$1" =~ ^- && ! -e "$1" ]]; do
		f="$f $1"
		shift
	done
	find "${1:-.}" -print |
		perl -pe 's/^(?:.\/)?(.*)$\\n/$1\x00/gim;' |
		xargs -0 $(alias l | sed -E 's/^alias [^=]+='\''(.*)'\''$/\1/g') $f -d
}
