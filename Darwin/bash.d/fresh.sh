# fresh
# 
# Save the command history and open a new tab at the current directory
fresh() {
	history -w
	osascript <<-EOF
	tell application "System Events"
		if not UI elements enabled then return
		tell application process "Terminal"
			if not frontmost then return 1
			keystroke "t" using command down
		end tell
	end tell
	tell application "Terminal" to repeat with w in windows
		try
			if frontmost of w is true then do script " cd '$PWD'" in w
		end try
	end repeat
	return
	EOF
}