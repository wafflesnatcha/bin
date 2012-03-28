#!/usr/bin/env bash
SCRIPT_NAME="mac.sh"
SCRIPT_VERSION="1.0.1 2012-03-28"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Do stuff with OS X like changing settings and shit.

Usage: ${0##*/} command

Commands:
 dock addspace             Add a spacer to the dock
 dock noglass [on/off]     Toggle the 3d display of the dock
 dock showhidden [on/off]  Hidden applications appear dimmer on the dock
 dock restart              Reload the dock

 expose anim-duration [FLOAT/-]  Expose (Mission Control) animation duration

 finder showfile PATH ...      Make a file visible in Finder
 finder hidefile PATH ...      Hide a file in Finder
 finder restart                Restart Finder
 finder fullpathview [on/off]  Show the full path in the title of Finder windows
 finder showhidden [on/off]    Toggle visibility of hidden files and folders

 itunes hideping [on/off]    Hide the "Ping" arrows
 itunes storelinks [on/off]  Toggle display of the store link arrows

 wifi available   Show available wifi networks
 wifi disconnect  Disassociate from any network
 wifi info        Print current wireless status

 battery       Display battery charge (if applicable)
 flushdns      Flush system DNS cache
 group [NAME]  List a user (or all users) of this machine
 lockdesktop   Lock the desktop
 updatedb      Update locate database
 user [NAME]   List a user (or all users) of this machine
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; [[ ! $2 = -1 ]] && exit ${2:-1}; }

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		*) break ;;
	esac
	shift
done

case $1 in

	d|dock) shift
	case $1 in

		addspace) defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && killall Dock ;;

		noglass) pref_bool "com.apple.dock no-glass" $2 && killall Dock ;;

		showhidden) pref_bool "com.apple.dock showhidden" $2 && killall Dock ;;

		restart) killall Dock ;;

		*) usage; exit 0 ;;

	esac
	;;

	e|expose) shift
	case $1 in

		anim-duration) pref_float "com.apple.dock expose-animation-duration" $2 && killall Dock ;;

		*) usage; exit 0 ;;

	esac
	;;

	f|finder) shift
	case $1 in

		showhidden)
		pref_bool "com.apple.finder AppleShowAllFiles" && finder_restart
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

		*) usage; exit 0 ;;

	esac
	;;

	i|itunes) shift
	case $1 in

		hideping) pref_bool "com.apple.iTunes hide-ping-dropdown" $2 ;;

		storelinks) pref_bool "com.apple.iTunes show-store-link-arrows" $2 ;;

		*) usage; exit 0 ;;

	esac
	;;

	w|wifi) shift
	case $1 in

		available) /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s ;;

		disconnect) sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z ;;

		info) /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -i ;;

		*) usage; exit 0 ;;

	esac
	;;

	battery) ioreg -w0 -c AppleSmartBattery | grep -E '(Max|Current)Capacity' | perl -pe 's/^[\s\|]*"(\w*)Capacity" = (.*?)[\s]*$/$2 /gi' | awk '{printf "%.1f%%\n", ($2 / $1 * 100)}' ;;

	flushdns) dscacheutil -flushcache ;;

	group) dscacheutil -q group $([[ "$2" ]] && echo "-a name $2") ;;

	lockdesktop) /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend ;;

	updatedb) [ -e "/usr/libexec/locate.updatedb" ] && cd / && sudo /usr/libexec/locate.updatedb ;;

	user) dscacheutil -q user $([[ "$2" ]] && echo "-a name $2") ;;

	*) usage; exit 0 ;;
esac

##
## Functions
##

pref_bool() {
	case "$(echo $2 | tr '[A-Z]' '[a-z]')" in
		y|yes|1|true|on) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		*) [[ $(defaults read $1) = 1 ]] && { echo "on"; return 1; } || { echo "off"; return 2; } ;;
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
	osascript <<'EOF'
tell application "Finder" to quit
try
	tell application "Finder" to reopen
on error
	tell application "Finder" to launch
end try
EOF
}
