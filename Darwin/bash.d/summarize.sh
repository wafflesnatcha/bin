#!/usr/bin/env bash
# Usage: summarize [SENTENCES]
#
# Use OS X summary service (via AppleScript) to summarize stdin. SENTENCES is
# an integer specifying the maximum number of sentences in the result.
summarize() {
	[[ $1 && ! $1 =~ ^[0-9]+$ ]] && cat <<-EOF 1>&2 && return 1
		Usage: summarize [SENTENCES]

		Use OS X summary service (via AppleScript) to summarize stdin. SENTENCES is
		an integer specifying the maximum number of sentences in the result.
		EOF
	osascript -e "summarize (\"$(cat)\" & return)${1:+ in $1}"
}
