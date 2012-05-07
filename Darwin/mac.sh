#!/usr/bin/env bash
SCRIPT_NAME="mac.sh"
SCRIPT_DESC="Do stuff with OS X like changing settings and shit."
SCRIPT_VERSION="1.0.3 2012-05-04"

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
	for (( i = 0 ; i <= ${#@} ; i++ )); do
		eval local ARG${i}=${!i}
		eval local lARG${i}="$(echo ${!i} | tr '[:upper:]' '[:lower:]')"
	done

	case $lARG1 in

	dock|d) shift
	case $lARG2 in

		--usage) cat <<-EOF
		addspace            Add a spacer to the dock
		dimhidden [on/off]  Hidden applications appear dimmer on the dock
		noglass [on/off]    Toggle the 3d display of the dock
		restart             Reload the dock
		EOF
		;;

		addspace) defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && killall Dock
		;;

		dimhidden) pref_bool "com.apple.dock showhidden" $2 && killall Dock
		;;

		noglass) pref_bool "com.apple.dock no-glass" $2 && killall Dock
		;;

		restart) killall Dock
		;;

		*) [[ $1 ]] && ERROR "unknown command $ARG1 $ARG2"; mac help $ARG1; return 1
		;;

	esac
	;;

	expose|e) shift
	case $lARG2 in

		--usage) cat <<-EOF
		anim-duration [FLOAT/-]  Expose (Mission Control) animation duration
		EOF
		;;

		anim-duration) pref_float "com.apple.dock expose-animation-duration" $2 && killall Dock
		;;

		*) [[ $1 ]] && ERROR "unknown command $ARG1 $ARG2"; mac help $ARG1; return 1
		;;

	esac
	;;

	finder|f) shift
	case $lARG2 in

		--usage) cat <<-EOF
		showfile PATH ...      Make a file visible in Finder
		hidefile PATH ...      Hide a file in Finder
		restart                Restart Finder
		fullpathview [on/off]  Show the full path in the title of Finder windows
		showhidden [on/off]    Toggle visibility of hidden files and folders
		EOF
		;;

		showhidden) pref_bool "com.apple.finder AppleShowAllFiles" $2 && mac finder restart
		;;

		fullpathview) pref_bool "com.apple.finder _FXShowPosixPathInTitle" $2
		;;

		restart|r) osascript -e 'tell application "Finder" to quit' -e 'try' -e 'tell application "Finder" to reopen' -e 'on error' -e 'tell application "Finder" to launch' -e 'end try'
		;;

		showfile|sf)
		shift
		if [[ ! $finder_showfile_cmd ]]; then
			[[ ! $(type -p setfile) && $(type -p chflags) ]] && finder_showfile_cmd="chflags nohidden" || finder_showfile_cmd="setfile -a v"
		fi
		for f in "$@"; do
			[[ ! -e "$f" ]] && ERROR "file doesn't exist: $f" 1
			$finder_showfile_cmd "$f"
		done
		;;

		hidefile|hf)
		shift
		if [[ ! $finder_hidefile_cmd ]]; then
			[[ ! $(type -p setfile) && $(type -p chflags) ]] && finder_hidefile_cmd="chflags hidden" || finder_hidefile_cmd="setfile -a V"
		fi
		for f in "$@"; do
			[[ ! -e "$f" ]] && ERROR "file doesn't exist: $f" 1
			$finder_hidefile_cmd "$f"
		done
		;;

		*) [[ $1 ]] && ERROR "unknown command $ARG1 $ARG2"; mac help $ARG1; return 1
		;;

	esac
	;;

	itunes|i) shift
	case $lARG2 in

		--usage) cat <<-EOF
		hideping [on/off]    Hide the "Ping" arrows
		storelinks [on/off]  Toggle display of the store link arrows
		EOF
		;;

		hideping) pref_bool "com.apple.iTunes hide-ping-dropdown" $2
		;;

		storelinks) pref_bool "com.apple.iTunes show-store-link-arrows" $2
		;;

		*) [[ $1 ]] && ERROR "unknown command $ARG1 $ARG2"; mac help $ARG1; return 1
		;;

	esac
	;;

	wifi|w) shift
	local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
	[[ ! -e "$airport_path" ]] && return 1
	
	case $lARG2 in

		--usage) cat <<-EOF
		available   Show available wifi networks
		disconnect  Disassociate from any network
		info        Print current wireless status
		EOF
		;;

		available) "$airport_path" -s
		;;

		disconnect) sudo "$airport_path" -z
		;;

		info) "$airport_path" -I
		;;

		*) [[ $1 ]] && ERROR "unknown command $ARG1 $ARG2"; mac help $ARG1; return 1
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

	help|h)
	[[ ! $2 ]] && echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESC\n"
	echo -e "Usage: ${0##*/} ${2:-<command>}${2:+ <action>}\n"
	if [[ $2 ]]; then
		echo "Actions:"
		mac $2 --usage 2>/dev/null | sed 's/^/ /'
	else
		echo "Commands:"
		cat <<-EOF | sed 's/^/ /'
		$(mac dock --usage | sed 's/^/dock /')
		
		$(mac expose --usage | sed 's/^/expose /')
		
		$(mac finder --usage | sed 's/^/finder /')
		
		$(mac itunes --usage | sed 's/^/itunes /')
		
		$(mac wifi --usage | sed 's/^/wifi /')
		
		battery       Display battery charge (if applicable)
		flushdns      Flush system DNS cache
		group [NAME]  List a user (or all users) of this machine
		help          Show this help
		lockdesktop   Lock the desktop
		updatedb      Update locate database
		user [NAME]   List a user (or all users) of this machine
		EOF
	fi
	;;

	*) [[ $1 ]] && ERROR "unknown command $ARG1"; mac help; return 1
	;;

	esac
}

mac "$@"
