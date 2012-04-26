#!/usr/bin/env bash
source colors.sh 2>/dev/null 

git_update() {
	for d in "$@"; do
		[[ ! -d "$d/.git" ]] && continue

		local name=$(basename "$d")
		echo -en "$name... "

		res="$({ cd "$d" 1>/dev/null && git pull | tail -n 1; } 2>&1)"
		res_code=$?
		if [[ $COLOR_SUPPORTED ]]; then
			if [[ $res_code != 0 ]]; then
				echo -en "\r${COLOR_RED}$name... ${COLOR_RESET}"
			elif [[ "$res" = "Already up-to-date." ]]; then
				echo -en "\r${COLOR_WHITE}$name... ${COLOR_RESET}"
			else
				echo -en "\r${COLOR_GREEN}$name... ${COLOR_RESET}"
			fi
		fi
				
		echo -e "$res"
	done
}

git_update /Library/"Application Support"/TextMate/Bundles/*
git_update $HOME/Library/"Application Support"/TextMate/"Pristine Copy"/Bundles/*

support_dir=$HOME/"Library/Application Support/TextMate/Pristine Copy/Support"

if [[ -d "$support_dir" && -d "$support_dir/.svn" ]]; then
	echo -en "updating support..."
	res=$(svn update "$support_dir")
	if [[ $? != 0 ]]; then
		echo -en "\r${COLOR_RED}updating support... ${COLOR_RESET}"
	else
		echo -en "\r${COLOR_GREEN}updating support... ${COLOR_RESET}"
	fi
	echo -e "$res"
fi
