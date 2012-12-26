#!/usr/bin/env bash
# Usage: cdrp FILE
#
# Change directory to the path of the result of `rp`.
cdrp() {
	local p=$(rp "$*") || return
	[[ "$p" && ! -d "$p" ]] && p="$(dirname "$p")"
	[[ ! "$p" || ! -d "$p" ]] && return
	echo "$p" 1>&2
	cd "$p"
}
