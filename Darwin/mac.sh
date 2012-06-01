#!/usr/bin/env bash
# mac.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="mac.sh"
SCRIPT_VERSION="r2 2012-05-31"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Do stuff with OS X like changing settings and shit.

Usage: ${0##*/} COMMAND

Commands:
 apache configtest  Run syntax check for config files
 apache restart     Restart the httpd daemon
 apache start       Start the Apache httpd daemon
 apache stop        Stop the Apache httpd daemon

 directory groups [NAME]  List groups of this machine
 directory members GROUP  List users belonging to GROUP
 directory users [NAME]   List users of this machine

 dock addspace          Add a spacer to the dock
 dock dimhidden [BOOL]  Hidden applications appear dimmer on the dock
 dock noglass [BOOL]    Toggle the 3d display of the dock
 dock restart           Reload the dock

 expose anim-duration [FLOAT/-]  Expose (Mission Control) animation duration

 finder showfile PATH...     Make a file visible in Finder
 finder hidefile PATH...     Hide a file in Finder
 finder restart              Restart Finder
 finder fullpathview [BOOL]  Show the full path in the title of Finder windows
 finder showhidden [BOOL]    Toggle visibility of hidden files and folders

 itunes halfstars [BOOL]   Enable ratings with half stars
 itunes hideping [BOOL]    Hide the "Ping" arrows
 itunes storelinks [BOOL]  Toggle display of the store link arrows

 screencap location [PATH]  Change the default save location for screenshots
                            taken using the global hotkeys

 wifi available   Show available wifi networks
 wifi disconnect  Disassociate from any network
 wifi info        Print current wireless status

 battery       Display battery charge (if applicable)
 flushdns      Flush system DNS cache
 help          Show this help
 lock          Lock the desktop
 updatedb      Update locate database
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

# Set/read a preference item
pref() {
	[[ $2 ]] && { defaults write $1 "$2"; return; }
	v=$(defaults read $1 2>&1) && { echo "$v"; return 3; } || { echo "not set" 1>&2; return 4; }
}

# Set/read a boolean preference item
pref_bool() {
	case "$(echo $2 | tr '[:upper:]' '[:lower:]')" in
		y|yes|1|true|on) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		*) [[ $(defaults read $1 2>/dev/null) = 1 ]] && { echo "yes"; return 3; } || { echo "no"; return 4; } ;;
	esac
}

pref_bool_inverse() {
	pref_bool $1 $2 1>/dev/null
	code=$?
	[[ $code = 3 ]] && echo "no" || [[ $code = 4 ]] && echo "yes"
	return $code
}

# Set/read a float preference item
pref_float() {
	if [[ ! $2 ]]; then v=$(defaults read $1 2>&1) && { echo $v; return 3; } || { echo "not set"; return 4; }
	elif [[ $2 = "-" ]]; then defaults delete $1
	else defaults write $1 -float $2
	fi
}

# runForEach COMMAND FILE...
# Runs COMMAND with FILE as it's argument for every FILE specified.
runForEach() {
	[[ ${#} < 2 ]] && return 1;
	local cmd=$1
	shift
	local f
	for f in "$@"; do
		[[ ! -e "$f" ]] && { ERROR "$f: No such file or directory"; continue; }
		$cmd "$f"
	done
}

mac() {
	local ARGS="$@"
	unknown_command() { [[ -n $1 ]] && ERROR "unknown command '$ARGS'" 1; mac help; return 1; }

	# Create a lowercase version of every argument
	for (( i = 0 ; i <= $# ; i++ )); do eval local arg${i}='$(echo "${!i}" | tr "[:upper:]" "[:lower:]")'; done

	case $arg1 in

	apache|a) shift
	case $arg2 in

		configtest) apachectl -t
		;;

		restart) sudo apachectl -k restart
		;;

		start) sudo apachectl -k start
		;;

		stop) sudo apachectl -k stop
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	directory) shift
	case $arg2 in

		groups) dscacheutil -q group $([[ "$2" ]] && echo "-a name $2")
		;;

		members) [[ ! $2 ]] && return 1; dscl . -list /Users | while read u; do [[ $(dsmemberutil checkmembership -U "$u" -G "$2" 2>/dev/null) =~ is\ a\ member ]] && echo $u; done; return
		;;

		users) result="$(dscacheutil -q user $([[ "$2" ]] && echo "-a name $2"))"; [[ $result ]] && echo "$result" || return 1
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

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

		showfile|sf) shift; which chflags &>/dev/null && runForEach "chflags nohidden" "$@" || runForEach "setfile -a v" "$@"
		;;

		hidefile|hf) shift; which chflags &>/dev/null && runForEach "chflags hidden" "$@" || runForEach "setfile -a V" "$@"
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	itunes|i) shift
	case $arg2 in

		halfstars) pref_bool "com.apple.iTunes allow-half-stars" $2
		;;

		hideping) pref_bool "com.apple.iTunes hide-ping-dropdown" $2
		;;

		storelinks) pref_bool "com.apple.iTunes show-store-link-arrows" $2
		;;

		*) unknown_command "$1"; return
		;;

	esac
	;;

	screencap|s) shift
	case $arg2 in

		location) pref "com.apple.screencapture location" $2 && killall SystemUIServer
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

	lock) /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
	;;

	updatedb) [ -e "/usr/libexec/locate.updatedb" ] && cd / && sudo /usr/libexec/locate.updatedb
	;;

	help|--help|-h) usage
	;;

	*) unknown_command "$1"; return
	;;

	esac
}

mac "$@"