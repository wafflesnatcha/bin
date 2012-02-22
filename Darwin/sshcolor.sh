#!/usr/bin/env bash

cleanup() {
	setSettings "$CONFIG_original_settings"
	# echo "cleaned up"
}

changeWindowName() {
	printf "\e]0;${CONFIG_window_name}\a"
}

setSettings() {
	# echo "setting settings"
	changeWindowName
	osascript <<EOF &>/dev/null
tell application "Terminal"
	set s to a reference to (first settings set whose name is "${1}")
	set w to first window whose name is "${CONFIG_window_name}"
	set t to (first tab whose selected is true) of w
	set current settings of t to s
end tell
EOF
	return
}

CONFIG_host=${!#}
[[ "$CONFIG_host" == "$0" ]] && CONFIG_host=${0##*/}

CONFIG_window_name="${CONFIG_host}_SSH_$$"
changeWindowName
CONFIG_original_settings=$(osascript <<EOF
tell application "Terminal"
	set w to first window whose name is "${CONFIG_window_name}"
	set t to (first tab whose selected is true) of w
	return name of current settings of t
end tell
EOF
)

CONFIG_new_settings="$CONFIG_original_settings $CONFIG_host"
setSettings "$CONFIG_new_settings"
[ $? = 0 ] && CONFIG_reset=1 && trap cleanup 1 2 3 6

ssh "$@"

[ $CONFIG_reset ] && cleanup