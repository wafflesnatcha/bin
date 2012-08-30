# summarize SENTENCES
# Use OS X summary service (via AppleScript) to summarize stdin.
summarize() {
	osascript \
	    -e "on run argv" \
	    -e "return summarize (do shell script \"cat\") in (item 1 of argv)" \
	    -e "end run" \
	    $*
}
