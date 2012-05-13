#!/usr/bin/env bash
# mac.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="mac.sh"
SCRIPT_DESC="Do stuff with OS X like changing settings and shit."
SCRIPT_VERSION="1.0.5 2012-05-13"

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; [[ $2 > -1 ]] && exit $2; }

pref_bool() {
	case "$(echo $2 | tr '[:upper:]' '[:lower:]')" in
		y|yes|1|true|on) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		*) [[ $(defaults read $1 2>/dev/null) = 1 ]] && { echo "on"; return 1; } || { echo "off"; return 2; } ;;
	esac
}

pref_float() {
	if [[ ! $2 ]]; then v=$(defaults read $1 2>&1) && { echo $v; return 1; } || { echo "not set"; return 2; }
	elif [[ $2 = "-" ]]; then defaults delete $1
	else defaults write $1 -float $2
	fi
}

mac() {
	local ARGS="$@"
	unknown_command() { [[ -n $1 ]] && ERROR "unknown command '$ARGS'" 1; mac help; return 1; }

	# Create a lowercase version of every argument
	for (( i = 0 ; i <= $# ; i++ )); do eval local arg${i}='$(echo "${!i}" | tr "[:upper:]" "[:lower:]")'; done

	case $arg1 in

	dock|d) shift
	case $arg2 in

		addspace) defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && killall Dock
		;;

		dimhidden) pref_bool "com.apple.dock showhidden" $2 && killall Dock
		;;

		noglass) pref_bool "com.apple.dock no-glass" $2 && killall Dock
		;;

		restart) killall Dock
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	expose|e) shift
	case $arg2 in

		anim-duration) pref_float "com.apple.dock expose-animation-duration" $2 && killall Dock
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	finder|f) shift
	case $arg2 in

		showhidden) pref_bool "com.apple.finder AppleShowAllFiles" $2 && mac finder restart
		;;

		fullpathview) pref_bool "com.apple.finder _FXShowPosixPathInTitle" $2
		;;

		restart|r) osascript -e 'tell application "Finder" to quit' -e 'try' -e 'tell application "Finder" to reopen' -e 'on error' -e 'tell application "Finder" to launch' -e 'end try'
		;;

		showfile|sf) shift
		[[ ! $(type -p setfile) && $(type -p chflags) ]] && finder_showfile_cmd="chflags nohidden" || finder_showfile_cmd="setfile -a v"
		for f in "$@"; do
			[[ ! -e "$f" ]] && ERROR "file doesn't exist: $f" 1
			$finder_showfile_cmd "$f"
		done
		;;

		hidefile|hf) shift
		[[ ! $(type -p setfile) && $(type -p chflags) ]] && finder_hidefile_cmd="chflags hidden" || finder_hidefile_cmd="setfile -a V"
		for f in "$@"; do
			[[ ! -e "$f" ]] && ERROR "file doesn't exist: $f" 1
			$finder_hidefile_cmd "$f"
		done
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	itunes|i) shift
	case $arg2 in

		hideping) pref_bool "com.apple.iTunes hide-ping-dropdown" $2
		;;

		storelinks) pref_bool "com.apple.iTunes show-store-link-arrows" $2
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	wifi|w) shift
	local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
	[[ ! -e "$airport_path" ]] && ERROR "\`airport\` not found in '$(dirname "$airport_path")'" 1

	case $arg2 in

		available) "$airport_path" -s
		;;

		disconnect) sudo "$airport_path" -z
		;;

		info) "$airport_path" -I
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	battery) ioreg -w0 -c AppleSmartBattery | grep -E '(Max|Current)Capacity' | perl -pe 's/^[\s\|]*"(\w*)Capacity" = (.*?)[\s]*$/$2 /gi' | awk '{printf "%.1f%%\n", ($2 / $1 * 100)}'
	;;
	
	flushdns) dscacheutil -flushcache
	;;

	group) dscacheutil -q group $([[ "$2" ]] && echo "-a name $2")
	;;

	lockdesktop) /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
	;;

	updatedb) [ -e "/usr/libexec/locate.updatedb" ] && cd / && sudo /usr/libexec/locate.updatedb
	;;

	user) dscacheutil -q user $([[ "$2" ]] && echo "-a name $2")
	;;

	help|--help|-h)
	echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESC\nUsage: ${0##*/} COMMAND\n\nCommands:"

	cat <<-EOF | sed 's/^/ /'
	dock addspace            Add a spacer to the dock
	dock dimhidden [on/off]  Hidden applications appear dimmer on the dock
	dock noglass [on/off]    Toggle the 3d display of the dock
	dock restart             Reload the dock
	
	expose anim-duration [FLOAT/-]  Expose (Mission Control) animation duration
	
	finder showfile PATH...       Make a file visible in Finder
	finder hidefile PATH...       Hide a file in Finder
	finder restart                Restart Finder
	finder fullpathview [on/off]  Show the full path in the title of Finder windows
	finder showhidden [on/off]    Toggle visibility of hidden files and folders
	
	itunes hideping [on/off]    Hide the "Ping" arrows
	itunes storelinks [on/off]  Toggle display of the store link arrows
	
	wifi available   Show available wifi networks
	wifi disconnect  Disassociate from any network
	wifi info        Print current wireless status
	
	battery         Display battery charge (if applicable)
	flushdns        Flush system DNS cache
	group [NAME]    List a user (or all users) of this machine
	help [COMMAND]  Show this help
	lockdesktop     Lock the desktop
	updatedb        Update locate database
	user [NAME]     List a user (or all users) of this machine
	EOF
	;;

	*) unknown_command "$1"; return
	;;

	esac
}

mac "$@"
