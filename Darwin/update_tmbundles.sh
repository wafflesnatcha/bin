#!/usr/bin/env bash
. colors.sh 2>/dev/null

git_update() {
	local dir="$1"
	[[ ! -d "$dir/.git" ]] && return 1
	
 	echo -en "${CLR_CYAN}updating${CLR_R} $(basename "$dir")... "

	local res=$( cd "$dir" && (git pull && git submodule update && git gc --auto) 2>&1 )
	[[ $? != 0 ]] && { echo -e "${CLR_RED}ERROR${CLR_R}"; return 1; }
	
	[[ "$res" != "Already up-to-date." ]] && echo

	echo -e "$res"
}

updateBundles() {
	[[ ! -d "$1" ]] && return 1
	for i in "$1"/*; do
		git_update "$i"
	done
}

updateBundles "/Library/Application Support/TextMate/Bundles"
updateBundles ~/"Library/Application Support/TextMate/Pristine Copy/Bundles"