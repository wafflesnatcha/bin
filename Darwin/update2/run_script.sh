#!/usr/bin/env bash
. colors.sh 2>/dev/null

SOURCE="$*"

task_start() {
	echo -ne "$@... "
}

task_end() {
	[[ $? == 0 ]] && task_done "$@" || task_fail "$@"
	return
}

task_done() {
	echo -e "${CLR_GREEN}${@:-done}${CLR_RESET}"
}

task_fail() {
	local msg="${0##*/}: $1"
	echo -e "${CLR_RED}${2:-failed}${CLR_RESET}"
	echo "$msg" >&2
	type on_fail &>/dev/null && onFail
	echo "$msg" | growlnotify -s -p2 --title "update2.sh"
	exit ${2:-1}
}

task_skip() {
	echo -e "${CLR_YELLOW}${@:-skipped}${CLR_RESET}"
}

git_update() {
	local dir="$1"
	task_start "updating $(basename "$dir")"
	
	if [[ ! -d "$dir/.git" ]]; then
		task_skip "not a git repository"
		return 1
	fi
	
	local res=$( cd "$dir" && (git pull && git submodule update && git gc --auto) 2>&1 )
	[[ $? != 0 ]] && task_fail "$res"
	if [[ "$res" != "Already up-to-date." ]]; then
		task_done "$(echo "$res" | tail -n1)"
	else
		task_skip "$res"
	fi
}

. "$SOURCE"

