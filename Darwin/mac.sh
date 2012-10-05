#!/usr/bin/env bash
# `mac.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="mac.sh"
SCRIPT_VERSION="1.1.0 2012-10-04"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Do stuff with OS X like changing settings and shit.

Usage: ${0##*/} COMMAND

Commands:
 directory groups [NAME]  List groups of this machine
 directory members GROUP  List users belonging to GROUP
 directory users [NAME]   List users of this machine

 dock addspace          Add a spacer to the dock
 dock dimhidden [BOOL]  Hidden applications appear dimmer on the dock
 dock lock-size [BOOL]  Disallow changes to the dock size
 dock noglass [BOOL]    Toggle the 3d display of the dock
 dock restart           Reload the dock
 dock size [PIXELS]     Set the tile size of dock items

 expose anim-duration [FLOAT]  Expose (Mission Control) animation duration

 finder showfile FILE...      Make a file visible in Finder
 finder hidefile FILE...      Hide a file in Finder
 finder restart               Restart Finder
 finder fullpathview [BOOL]   Show the full path in the title of Finder windows
 finder seticon ICNS FILE...  Change the icon for a file using a .icns file
 finder showhidden [BOOL]     Toggle visibility of hidden files and folders

 itunes halfstars [BOOL]   Enable ratings with half stars
 itunes hideping [BOOL]    Hide the "Ping" arrows
 itunes status             Show current track and artist
 itunes storelinks [BOOL]  Toggle display of the store link arrows

 network flushdns  Flush system DNS cache
 network ports     Show open ports

 screencap disable-shadow [BOOL]  Disable window shadows when capturing windows
 screencap location [PATH]        Default save location for screen captures
 screencap type [TYPE]            File format of screen captures (BMP, GIF, JPG,
                                  PDF, PNG, TIFF)

 services rebuild  Rebuild the Services list

 wifi available   Show available wifi networks
 wifi disconnect  Disassociate from any network
 wifi info        Print current wireless status

 battery       Display battery charge (if applicable)
 help          Show this help
 lock          Lock the desktop
 updatedb      Update locate database
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 -gt -1 ]] && exit $2; }

# pref (TYPE) (DOMAIN&KEY) [VALUE]
# Set/get a preference item.
pref() {
	local v vartype="$1"
	shift

	# No value specified, output current value instead
	if [[ ! $2 ]]; then
		v=$(defaults read $1 2>/dev/null) || { echo "not set"; return 1; }
		if [[ $vartype = "bool" ]]; then
			[[ $v = 1 ]] && echo "true" || { echo "false"; return 1; }
		else
			echo "$v"
		fi
		return 100
	fi

	case "$vartype" in

	date|string)
		defaults write $1 -$vartype "$2"
		;;

	float|int)
		[[ $2 = "-delete" ]] && defaults delete $1 || defaults write $1 -$vartype $2
		;;

	array|array-add|dict|dict-add)
		local key=$1
		shift
		defaults write $key -array "$@"
		;;

	bool)
		case "$(echo "$2" | tr '[:upper:]' '[:lower:]')" in
		y|yes|1|true|on) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		-delete) defaults delete $1 ;;
		*) ERROR "invalid value '$2'" 2 ;;
		esac
		;;

	*)
		defaults write $1 $2
		;;

	esac
	return
}

# runForEach COMMAND FILE...
# Runs COMMAND with FILE as it's argument for every FILE specified.
runForEach() {
	[[ ${#} -lt 2 ]] && return 1;
	local f cmd=$1
	shift
	for f in "$@"; do
		[[ ! -e "$f" ]] && { ERROR "$f: No such file or directory"; continue; }
		$cmd "$f"
	done
}

# systemVersion
# Return the system's OS X version as an array.
systemVersion() {
	[[ ! $__osx_version ]] && __osx_version=( $(sw_vers | grep 'ProductVersion:' | perl -pe 's/^.*?([0-9]+)\.([0-9]+)(?:\.([0-9]+))?.*$/$1.$2.$3/i') )
	echo "${__osx_version[@]}"
}

# systemVersionLessThan VERSION
# Returns 0 if the system's OS X version is less than `VERSION`.
systemVersionLessThan() {
	systemVersion &>/dev/null || return 2
	local x c=( $(echo "$1" | sed -E 's/([0-9]+)\./\1 /g') )
	for (( x=0 ; x < ${#c[@]} && x < ${#__osx_version[@]} ; x++ )); do
		[[ ${__osx_version[$x]} -lt ${c[$x]} ]] && return 0
	done
	return 1
}

mac() {
	local ARGS="$@"
	unknown_command() {
		[[ -n "$1" ]] && ERROR "unknown command '$ARGS'" 1
		mac help
		return 1
	}

	# Create a lowercase version of every argument
	for (( i = 0 ; i <= $# ; i++ )); do
		eval local arg${i}='$(echo "${!i}" | tr "[:upper:]" "[:lower:]")'
	done

	case $arg1 in

	directory|di|dir)
		shift
		case $arg2 in

		groups)
			dscacheutil -q group $([[ "$2" ]] && echo "-a name $2")
			;;

		members)
			[[ ! $2 ]] && return 1; dscl . -list /Users | while read u; do [[ $(dsmemberutil checkmembership -U "$u" -G "$2" 2>/dev/null) =~ is\ a\ member ]] && echo $u; done; return
			;;

		users)
			result="$(dscacheutil -q user $([[ "$2" ]] && echo "-a name $2"))"
			[[ $result ]] && echo "$result" || return 1
			;;

		*) unknown_command "$1"; return ;; esac ;;

	dock|d|do|doc)
		shift
		case $arg2 in

		addspace)
			defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && mac dock restart
			;;

		dimhidden)
			pref bool "com.apple.dock showhidden" $2 && mac dock restart
			;;

		lock-size)
			pref bool "com.apple.dock size-immutable" $2 && mac dock restart
			;;

		noglass)
			pref bool "com.apple.dock no-glass" $2 && mac dock restart
			;;

		restart|r)
			killall Dock
			;;

		size)
			pref int "com.apple.dock ama" $2 && mac dock restart
			;;

		*) unknown_command "$1"; return ;; esac ;;

	expose|e|ex|exp)
		shift
		case $arg2 in

		anim-duration)
			pref float "com.apple.dock expose-animation-duration" $2 && killall Dock
			;;

		*) unknown_command "$1"; return ;; esac ;;

	finder|f|fi|fin)
		shift
		case $arg2 in

		hidefile|hf)
			shift
			which chflags &>/dev/null && runForEach "chflags -h hidden" "$@" || runForEach "setfile -P -a V" "$@"
			;;

		showfile|sf)
			shift
			which chflags &>/dev/null && runForEach "chflags -h nohidden" "$@" || runForEach "setfile -P -a v" "$@"
			;;

		fullpathview)
			pref bool "com.apple.finder _FXShowPosixPathInTitle" $2
			;;

		restart|r)
			osascript -e 'tell application "Finder" to quit' -e 'try' -e 'tell application "Finder" to reopen' -e 'on error' -e 'tell application "Finder" to launch' -e 'end try'
			;;

		seticon|si)
			shift
			local icns="$1"
			shift
			cat <<-EOF | python - "$icns" "$@"
			import sys
			from AppKit import *
			i=NSImage.alloc().initWithContentsOfFile_(sys.argv[1])
			for p in sys.argv[2:]:
			    NSWorkspace.sharedWorkspace().setIcon_forFile_options_(i, p, 0)
			EOF
			;;

		showhidden|sh)
			pref bool "com.apple.finder AppleShowAllFiles" $2 && mac finder restart
			;;

		*) unknown_command "$1"; return ;; esac ;;

	itunes)
		shift
		case $arg2 in

		halfstars)
			pref bool "com.apple.iTunes allow-half-stars" $2
			;;

		hideping)
			pref bool "com.apple.iTunes hide-ping-dropdown" $2
			;;

		status)
			osascript <<-'EOF'
			tell application "iTunes"
				set s to (round (duration of current track as integer) mod 60)
				if s < 10 then set s to "0" & s
				return "[" & (player state as string) & "] \"" & name of current track & "\" by " & artist of current track & " (" & (round ((duration of current track as integer) / 60) rounding down) & ":" & s & ")"
			end tell
			EOF
			;;

		storelinks)
			pref bool "com.apple.iTunes show-store-link-arrows" $2
			;;

		*) unknown_command "$1"; return ;; esac ;;

	network|net)
		shift
		case $arg2 in

		flushdns)
			systemVersionLessThan 10.7 && dscacheutil -flushcache || sudo killall -HUP mDNSResponder
			;;

		ports)
			sudo lsof -i -P | grep -i "listen"
			;;

		*) unknown_command "$1"; return ;; esac ;;

	screencap|sc)
		shift
		case $arg2 in

		disable-shadow)
			pref bool "com.apple.screencapture disable-shadow" $2 && killall SystemUIServer
			;;

		location)
			pref string "com.apple.screencapture location" $2 && killall SystemUIServer
			;;

		type)
			pref string "com.apple.screencapture type" $2 && killall SystemUIServer
			;;

		*) unknown_command "$1"; return ;; esac ;;

	services)
		shift
		case $arg2 in

		rebuild)
			local bin="/System/Library/CoreServices/pbs"
			[[ ! -e "$bin" ]] && ERROR "\`$(basename "$bin")\` not found in '$(dirname "$bin")'" 10
			"$bin"
			;;

		*) unknown_command "$1"; return ;; esac ;;

	wifi|w)
		shift
		local bin="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
		[[ ! -e "$bin" ]] && ERROR "\`$(basename "$bin")\` not found in '$(dirname "$bin")'" 10
		case $arg2 in

		available)
			"$bin" -s
			;;

		disconnect)
			sudo "$bin" -z
			;;

		info)
			"$bin" -I
			;;

		*) unknown_command "$1"; return ;; esac ;;

	battery)
		ioreg -S -w0 -c AppleSmartBattery | grep -E '(Max|Current)Capacity' | perl -pe 's/^[\s\|]*"(\w*)Capacity" = (.*?)[\s]*$/$2 /gi' | awk '{printf "%.1f%%\n", ($2 / $1 * 100)}'
		;;

	lock)
		"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend
		;;

	help|--help|-h|"")
		usage
		;;

	*) unknown_command "$1"; return ;;

	esac
}

mac "$@"
retcode=$?

# Code 100 is for settings where no value was specified
[[ ! $retcode || $retcode = 100 ]] && exit 0 || exit $retcode
