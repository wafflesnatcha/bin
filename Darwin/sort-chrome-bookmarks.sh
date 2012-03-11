#!/usr/bin/env bash

osascript -e 'activate application "Google Chrome"'
for(( i=0; i<20; i++ )); do
	cliclick 238 162
	sleep 0.3
	cliclick 287 411
	sleep 0.2
	osascript -e 'tell application "System Events" to tell process "Google Chrome" to key code 125'
	sleep 0.3
done