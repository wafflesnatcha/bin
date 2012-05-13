#!/usr/bin/env bash
total=${1:-20}
osascript -e 'activate application "Google Chrome"'
for(( i=1; i<=total; i++ )); do
	echo -en "\r$i/$total"
	[[ $i > 1 ]] && sleep 0.2
	cliclick 238 162 && sleep 0.2
	cliclick 287 411 &&	sleep 0.2
	osascript -e 'tell application "System Events" to tell process "Google Chrome" to key code 125'
done
echo -en "\r"
