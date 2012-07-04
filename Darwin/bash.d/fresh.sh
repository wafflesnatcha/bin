# Save the command history and open a new tab at the current directory
fresh() {
	history -w && osascript <<-EOF
	tell application "System Events"
		if not UI elements enabled then return
		tell application process "Terminal"
			if not frontmost then return 1
			--click menu item "New Tab" of menu "Shell" of menu bar 1
			keystroke "t" using command down
			tell application "Terminal" to do script "cd '$PWD' && history -c && history -r" in front window
		end tell
	end tell
	return
	EOF
}

# Run `fresh` and exit
freshe() { fresh && exit; }
