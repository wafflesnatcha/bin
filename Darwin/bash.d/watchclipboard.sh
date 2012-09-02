# watch_clipboard [INTERVAL]
#
# Watch the clipboard for changes and display them to stdout. INTERVAL is the
# time (in seconds) to wait after the clipboard is tested for a change (default
# is 0.25 seconds).
watch_clipboard() {
	local current last interval=${1:-0.25}
	while true; do
		current="$(pbpaste)"
		[[ "$current" != "$last" ]] && echo -en "$current\n"
		last="$current"
		sleep $interval || return 2
	done
}
