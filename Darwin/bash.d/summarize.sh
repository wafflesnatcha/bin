# summarize SENTENCES
#
# Use OS X summary service (via AppleScript) to summarize stdin.
summarize() {
	[[ ! $1 || $1 = "-h" || $1 = "--help" ]] && cat <<-EOF && return
		Usage: summarize SENTENCES

		Use the OS X summary service to summarize stdin.
		EOF
	osascript -e "summarize (do shell script \"cat\") in $1"
}
