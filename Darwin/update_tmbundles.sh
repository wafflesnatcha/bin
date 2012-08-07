#!/usr/bin/env bash
. colors.sh 2>/dev/null

clear_line() { [[ ! $COLOR_SUPPORTED ]] && return 1; [[ ! $cols ]] && cols=${COLUMNS:-$(tput cols)}; printf "\r%${cols}s\r" ""; [[ $1 ]] && echo -en "$*"; }

git_update() {
	for d in "$@"; do
		[[ ! -d "$d/.git" ]] && continue
		local name=$(basename "$d")
		echo -en "${COLOR_RESET}  $name...${COLOR_RESET} "
		local res="$({ cd "$d" 1>/dev/null && git pull; } 2>&1)"
		local code=$?
		
		if [[ $code -gt 0 ]]; then
			clear_line "${COLOR_RED}✘ $name...${COLOR_RESET}\n" || echo "ERROR"
			echo "$res" >&2
			return $code
		elif [[ "$res" = "Already up-to-date." ]]; then
			clear_line "${COLOR_WHITE}✔ $name...${COLOR_RESET}\n" || echo "$res"
		else
			clear_line "${COLOR_GREEN}✔ $name...${COLOR_RESET}\n"
			echo "$res" | sed 's/^/  /'
		fi
	done
}

svn_update() {	
	for d in "$@"; do
		[[ ! -d "$d/.svn" ]] && continue		
		local rev=$(svn info "$d" | grep -i "Revision:" | sed 's/Revision: //')
		local name="$(basename "$d") (r$rev)"
		echo -en "${COLOR_RESET}  $name...${COLOR_RESET} "
		local res=$(svn update "$d")
		local code=$?

		if [[ $code -gt 0 ]]; then
			clear_line "${COLOR_RED}✘ $name...${COLOR_RESET}\n" || echo "ERROR"
			echo "$res" >&2
			return $code
		elif [[ $res =~ ^At\ revision ]]; then
			clear_line "${COLOR_WHITE}✔ $name...${COLOR_RESET}\n" || echo "$res"
		else
			clear_line "${COLOR_GREEN}✔ $name...${COLOR_RESET}\n"
			echo "$res"
		fi
	done
}

git_update "/Library/Application Support/TextMate/Bundles"/*
git_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Bundles"/*

svn_update "/Library/Application Support/TextMate/Bundles"/*
svn_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Bundles"/*
svn_update "/Library/Application Support/TextMate/Pristine Copy/Support"
svn_update "$HOME/Library/Application Support/TextMate/Pristine Copy/Support"
