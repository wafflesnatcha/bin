#!/usr/bin/env bash
SCRIPT_NAME="mac.sh"
SCRIPT_VERSION="1.0.2 2012-04-03"
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; [[ ! $2 = -1 ]] && exit ${2:-1}; }

pref_bool() {
	case "$(echo $2 | tr '[A-Z]' '[a-z]')" in
		y|yes|1|true|on) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		*) [[ $(defaults read $1 2>/dev/null) = 1 ]] && { echo "on"; return 1; } || { echo "off"; return 2; } ;;
	esac
	return
}

pref_float() {
	if [[ ! $2 ]]; then
		v=$(defaults read $1 2>&1) && { echo $v; return 1; } || { echo "not set"; return 2; }
	elif [[ $2 = "-" ]]; then
		defaults delete $1
	else
		defaults write $1 -float $2
	fi
	return
}

finder_restart() {
	osascript -e 'tell application "Finder" to quit' -e 'try' -e 'tell application "Finder" to reopen' -e 'on error' -e 'tell application "Finder" to launch' -e 'end try'
	return
}

run() {
	case $1 in

	d|dock) shift
	case $1 in

		addspace)
		defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && killall Dock
		;;

		dimhidden)
		pref_bool "com.apple.dock showhidden" $2 && killall Dock
		;;
		
		noglass)
		pref_bool "com.apple.dock no-glass" $2 && killall Dock
		;;

		restart)
		killall Dock
		;;

		*)
		cat <<-EOF
		Usage: ${0##*/} dock ...
		 addspace            Add a spacer to the dock
		 dimhidden [on/off]  Hidden applications appear dimmer on the dock
		 noglass [on/off]    Toggle the 3d display of the dock
		 restart             Reload the dock
		EOF
		return 1
		;;

	esac
	;;

	e|expose) shift
	case $1 in

		anim-duration)
		pref_float "com.apple.dock expose-animation-duration" $2 && killall Dock
		;;

		*)
		cat <<-EOF
		Usage: ${0##*/} expose ...
		 anim-duration [FLOAT/-]  Expose (Mission Control) animation duration
		EOF
		return 1
		;;

	esac
	;;

	f|finder) shift
	case $1 in

		showhidden)
		pref_bool "com.apple.finder AppleShowAllFiles" $2 && finder_restart
		;;

		fullpathview)
		pref_bool "com.apple.finder _FXShowPosixPathInTitle" $2
		;;

		r|restart)
		finder_restart
		;;

		sf|showfile) shift
		[[ ! $(type -p setfile) && $(type -p chflags) ]] && cmd="chflags nohidden" || cmd="setfile -a v"
		for f in "$@"; do [[ -e "$f" ]] && $cmd "$f" || FAIL "file doesn't exist: $f" -1; done
		;;

		hf|hidefile) shift
		[[ ! $(type -p setfile) && $(type -p chflags) ]] && cmd="chflags hidden" || cmd="setfile -a V"
		for f in "$@"; do [[ -e "$f" ]] && $cmd "$f" || FAIL "file doesn't exist: $f" -1; done
		;;

		*)
		cat <<-EOF
		Usage: ${0##*/} finder ...
		 showfile PATH ...      Make a file visible in Finder
		 hidefile PATH ...      Hide a file in Finder
		 restart                Restart Finder
		 fullpathview [on/off]  Show the full path in the title of Finder windows
		 showhidden [on/off]    Toggle visibility of hidden files and folders
		EOF
		return 1
		;;

	esac
	;;

	i|itunes) shift
	case $1 in

		hideping) pref_bool "com.apple.iTunes hide-ping-dropdown" $2 ;;

		storelinks) pref_bool "com.apple.iTunes show-store-link-arrows" $2 ;;

		*)
		cat <<-EOF
		Usage: ${0##*/} itunes ...
		  hideping [on/off]    Hide the "Ping" arrows
		  storelinks [on/off]  Toggle display of the store link arrows
		EOF
		return 1
		;;

	esac
	;;

	w|wifi) shift
	local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
	[[ ! -e "$airport_path" ]] && return 1
	case $1 in

		available)
		"$airport_path" -s
		;;

		disconnect)
		sudo "$airport_path" -z
		;;

		info)
		"$airport_path" -i
		;;

		*)
		cat <<-EOF
		Usage: ${0##*/} wifi ...
		 available   Show available wifi networks
		 disconnect  Disassociate from any network
		 info        Print current wireless status
		EOF
		return 1
		;;

	esac
	;;

	battery)
	ioreg -w0 -c AppleSmartBattery | grep -E '(Max|Current)Capacity' | perl -pe 's/^[\s\|]*"(\w*)Capacity" = (.*?)[\s]*$/$2 /gi' | awk '{printf "%.1f%%\n", ($2 / $1 * 100)}'
	;;

	flushdns)
	dscacheutil -flushcache
	;;

	group)
	dscacheutil -q group $([[ "$2" ]] && echo "-a name $2")
	;;

	lockdesktop)
	/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
	;;

	updatedb)
	[ -e "/usr/libexec/locate.updatedb" ] && cd / && sudo /usr/libexec/locate.updatedb
	;;

	user)
	dscacheutil -q user $([[ "$2" ]] && echo "-a name $2")
	;;

	*)
	[[ $1 ]] && FAIL "unknown command $1" -1
	cat <<-EOF
	$SCRIPT_NAME $SCRIPT_VERSION
	Do stuff with OS X like changing settings and shit.

	$(run dock help)

	$(run expose help)

	$(run finder help)

	$(run itunes help)

	$(run wifi help)

	Usage: ${0##*/} ...
	 battery       Display battery charge (if applicable)
	 flushdns      Flush system DNS cache
	 group [NAME]  List a user (or all users) of this machine
	 lockdesktop   Lock the desktop
	 updatedb      Update locate database
	 user [NAME]   List a user (or all users) of this machine
	EOF
	exit 0
	;;

	esac
}

run "$@"
