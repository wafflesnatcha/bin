# mkd PATH
# 
# Create a directory and change to it.
mkd() {
	[[ $1 ]] &&
		mkdir -p "$1" &&
		cd "$1" 1>/dev/null &&
		echo "$PWD"
}
