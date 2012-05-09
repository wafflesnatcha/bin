#!/usr/bin/env bash
source colors.sh 2>/dev/null

git_update() {
	for d in "$@"; do
		[[ ! -d "$d/.git" ]] && continue
		local name=$(basename "$d")
		echo -en "${COLOR_BLUE}$name...${COLOR_RESET} "
		
		local res="$({ cd "$d" 1>/dev/null && git pull; } 2>&1)"
		local code=$?
		
		if [[ $code != 0 ]]; then
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_RED}$name... ${COLOR_RESET}"
			echo -e "\n$res" >&2
			return $code
		elif [[ "$res" = "Already up-to-date." ]]; then
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_WHITE}$name... ${COLOR_RESET} "
			echo -e "$res"
		else
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_GREEN}$name... ${COLOR_RESET}\n"
			echo -e "$res" | sed 's/^/  /'
		fi
	done
}

svn_update() {	
	for d in "$@"; do
		[[ ! -d "$d/.svn" ]] && continue
		
		local name=$(basename "$d")
		local rev=$(svn info "$d" | grep -i "Revision:" | sed 's/Revision: //')
		
		echo -en "${COLOR_BLUE}$name ...${COLOR_RESET} ($rev) "
		
		local res=$(svn update "$d")
		local code=$?

		if [[ $? != 0 ]]; then
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_RED}$name ...${COLOR_RESET} ($rev) "
			echo -e "\n$res" >&2
			return $code
		elif [[ $res =~ ^At\ revision ]]; then
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_WHITE}$name... ${COLOR_RESET} "
			echo -e "$res"
		else
			[[ $COLOR_SUPPORTED ]] && echo -en "\r${COLOR_GREEN}$name... ${COLOR_RESET}\n"
			echo -e "$res" | sed 's/^/  /'
		fi
	done
}

git_update "/Library/Application Support/TextMate/Bundles"/*
git_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Bundles"/*

svn_update "/Library/Application Support/TextMate/Bundles"/*
svn_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Bundles"/*
svn_update "/Library/Application Support/TextMate/Pristine Copy/Support"
svn_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Support"
