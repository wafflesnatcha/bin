#!/usr/bin/env bash
. colors.sh 2>/dev/null

git_update() {
	local dir="$1"
	[[ ! -d "$dir/.git" ]] && return 1
	
 	echo -en "${CLR_CYAN}$(basename "$dir")${CLR_R}... "

	local res=$( cd "$dir" && ( git pull; git submodule update; git gc -q; ) 2>&1 )
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

support_dir=~/"Library/Application Support/TextMate/Pristine Copy/Support"
if [[ -d "$support_dir" && -d "$support_dir/.svn" ]]; then
	echo -en "${CLR_GREEN}Updating Support${CLR_R}... "
	svn update "$support_dir"
fi	
