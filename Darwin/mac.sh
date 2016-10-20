#!/usr/bin/env bash
# `mac.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="mac.sh"
SCRIPT_VERSION="1.1.6 2012-11-29"
SCRIPT_DESC="Do stuff with OS X, like changing settings and junk."
SCRIPT_COMMANDS=(
	directory
	dock
	expose
	finder
	help
	itunes
	network
	screencap
	services
	system
	wifi
)

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
		[[ $2 = "--delete" ]] && defaults delete $1 || defaults write $1 -$vartype $2
		;;
	array|array-add|dict|dict-add)
		local key=$1
		shift
		defaults write $key -array "$@"
		;;
	bool)
		case "$(echo "$2" | tr '[:upper:]' '[:lower:]')" in
		y|yes|1|true|on|yay) defaults write $1 -bool TRUE ;;
		n|no|0|false|off|nay) defaults write $1 -bool FALSE ;;
		--delete) defaults delete $1 ;;
		*) ERROR "invalid value '$2'" 2 ;;
		esac
		;;
	*)
		defaults write $1 $2
		;;
	esac
	return
}

# OSVersion [-lt|-gt VERSION]
# Compare the system's OS version to an arbitrary version string.
OSVersion() {
	[[ ! $_OSVersion ]] && _OSVersion=( $(sw_vers | grep 'ProductVersion:' | perl -pe 's/^.*?([0-9]+)\.([0-9]+)(?:\.([0-9]+))?.*$/$1 $2 $3/i') )
	if [[ $1 =~ -(lt|gt) && $2 ]]; then
		local i vers=( $(echo "$2" | sed -E 's/([0-9]+)\./\1 /g') )
		for (( i=0 ; i < ${#_OSVersion[@]} ; i++ )); do
			case $1 in
				-lt) [[ ${_OSVersion[$i]} -lt ${vers[$i]:-0} ]] && return 0 ;;
				-gt) [[ ${_OSVersion[$i]} -gt ${vers[$i]:-0} ]] && return 0 ;;
			esac
		done
		return 1
	else
		echo "${_OSVersion[@]}" | sed -E 's/ /./g'
	fi
}

mac() {
	local ARGS="$@"

	# Create a copy and lowercase version of every argument
	for (( i = 0 ; i <= $# ; i++ )); do
		eval local arg${i}="${!i}" arg${i}_lower='$(echo "${!i}" | tr "[:upper:]" "[:lower:]")'
	done
	shift 2

	usage() {
		local indent="  "

		if [[ ! $1 ]]; then
			# Display list of commands
			echo -e "Usage: ${0##*/} COMMAND [ACTION]\n\nCommands:"
			for v in ${SCRIPT_COMMANDS[@]}; do
				echo "$indent$v"
			done
			echo -e "\nTry \`${0##*/} help COMMAND\` for ACTIONS available to a specific command." | fold -sw72
		else
			# Display specific command help
			echo -e "Usage: ${0##*/} COMMAND [ACTION]\n\nActions:" | sed -e "s/COMMAND/$1/"
			shift
			while (($#)); do
				echo "$indent$1"
				echo "$2" | fold -sw72 | sed "s/^/$indent$indent/"
				shift 2
				[[ $1 ]] && echo
			done
		fi
		return 0
	}

	unknown() {
		[[ -n "$arg1" ]] && ERROR "unknown command '$ARGS'" 1
		mac help
		return 1
	}

	case $arg1_lower in

	help|--help|-h|"")
		local out
		# echo
		if [[ $arg2 && ! $arg2_lower =~ ^(--all|help|--help|-h)$ ]]; then
			mac $arg2 -h
		else
			mac --version
			echo
			usage
		fi
		;;

	-v|--version) echo -e "$SCRIPT_NAME $SCRIPT_VERSION\n$SCRIPT_DESC" ;;

	directory|dir)
		case $arg2_lower in

		-h|"") usage "directory" \
			'groups [NAME]' "List groups of this machine" \
			'members GROUP' "List users belonging to GROUP" \
			'users [NAME]' "List users of this machine"
			;;

		groups) dscacheutil -q group $([[ "$1" ]] && echo "-a name $1") ;;

		members)
			[[ ! $1 ]] && return 1
			dscl . -list /Users | while read u; do
				[[ $(dsmemberutil checkmembership -U "$u" -G "$1" 2>/dev/null) =~ is\ a\ member ]] && echo $u
			done
			;;

		users)
			result="$(dscacheutil -q user $([[ $1 ]] && echo "-a name $1"))"
			[[ $result ]] && echo "$result" || return 1
			;;

		*) unknown; return ;;
		esac
		;;

	dock)
		case $arg2_lower in

		-h|"") usage "dock" \
			'addspace' "Add a spacer to the Dock" \
			'restart' "Reload the Dock" \
			'fadehidden [BOOL]' "Hidden applications appear dimmer on the Dock" \
			'lockcontent [BOOL]' "Disallow changing the icons in the Dock" \
			'locksize [BOOL]' "Disallow resizing the Dock" \
			'noglass [BOOL]' "Toggle the 3d display of the Dock" \
			'size [FLOAT]' "Set the tile size of Dock items (pixels)" \
			'size-magnified [FLOAT]' "Set the maximum tile size of magnified Dock items (pixels)"
			;;

		addspace) defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}' && mac dock restart ;;

		restart|r) killall Dock ;;

		fadehidden) pref bool "com.apple.dock showhidden" $1 && mac dock restart ;;

		lockcontent) pref bool "com.apple.dock contents-immutable" $1 && mac dock restart ;;

		locksize) pref bool "com.apple.dock size-immutable" $1 && mac dock restart ;;

		noglass) pref bool "com.apple.dock no-glass" $1 && mac dock restart ;;

		size) pref float "com.apple.dock tilesize" $1 && mac dock restart ;;

		size-magnified) pref float "com.apple.dock largesize" $1 && mac dock restart ;;

		*) unknown; return ;;
		esac
		;;

	expose)
		case $arg2_lower in

		-h|"") usage "expose" \
			'anim-duration [FLOAT]' "Expose (Mission Control) animation duration"
			;;

		anim-duration) pref float "com.apple.dock expose-animation-duration" $1 && mac dock restart ;;

		*) unknown; return ;;
		esac
		;;

	finder|f)
		case $arg2_lower in

		-h|"") usage "finder" \
			'hidefile FILE...' "Hide a file in Finder" \
			'showfile FILE...' "Make a file visible in Finder" \
			'restart' "Restart Finder" \
			'seticon ICNS FILE...' "Change the icon for a file using a .icns file" \
			'full-path [BOOL]' "Show the full path in the title of Finder windows" \
			'show-hidden [BOOL]' "Toggle visibility of hidden files and folders"
			;;

		hidefile|hf|hide) type chflags &>/dev/null && chflags -h hidden "$@" || setfile -P -a V "$@" ;;

		showfile|sf|show) type chflags &>/dev/null && chflags -h nohidden "$@" || setfile -P -a v "$@" ;;

		restart|r) osascript -e 'tell application "Finder" to quit' -e 'try' -e 'tell application "Finder" to reopen' -e 'on error' -e 'tell application "Finder" to launch' -e 'end try' ;;

		seticon)
			cat <<-EOF | python - "$1" "${@:2}"
			import sys
			from AppKit import *
			i=NSImage.alloc().initWithContentsOfFile_(sys.argv[1])
			for p in sys.argv[2:]:
				NSWorkspace.sharedWorkspace().setIcon_forFile_options_(i, p, 0)
			EOF
			;;

		full-path) pref bool "com.apple.finder _FXShowPosixPathInTitle" $1 ;;

		show-hidden|hidden) pref bool "com.apple.finder AppleShowAllFiles" $1 && mac finder restart ;;

		*) unknown; return ;;
		esac
		;;

	itunes)
		# itunes_running
		# Exit with error if iTunes isn't running
		itunes_running() { osascript -e 'if application id "com.apple.itunes" is not running then error' &>/dev/null || ERROR "iTunes is not running" 11; }

		case $arg2_lower in

		-h|"") usage "itunes" \
			'current' "List all information about the current track" \
			'lyrics' "Show lyrics saved with the current track" \
			'status' "Show player state and current track"
			'halfstars [BOOL]' "Enable ratings with half stars" \
			'hideping [BOOL]' "Hide the 'Ping' arrows" \
			'storelinks [BOOL]' "Toggle display of the store link arrows" \
			;;

		current)
			itunes_running && osascript -ss -e \
				'tell application id "com.apple.itunes" to tell current track to {album:album,album artist:album artist,album rating:album rating,album rating kind:album rating kind,artist:artist,bit rate:bit rate,bookmark:bookmark,bookmarkable:bookmarkable,bpm:bpm,category:category,comment:comment,compilation:compilation,composer:composer,database ID:database ID,date added:date added,description:description,disc count:disc count,disc number:disc number,duration:duration,enabled:enabled,episode ID:episode ID,episode number:episode number,EQ:EQ,finish:finish,gapless:gapless,genre:genre,grouping:grouping,kind:kind,long description:long description,modification date:modification date,played count:played count,played date:played date,podcast:podcast,rating:rating,rating kind:rating kind,release date:release date,sample rate:sample rate,season number:season number,shufflable:shufflable,skipped count:skipped count,skipped date:skipped date,show:show,sort album:sort album,sort artist:sort artist,sort album artist:sort album artist,sort name:sort name,sort composer:sort composer,sort show:sort show,size:size,start:start,time:time,track count:track count,track number:track number,unplayed:unplayed,video kind:video kind,volume adjustment:volume adjustment,year:year,container:container,id:id,index:index,name:name,persistent ID:persistent ID}' 2>/dev/null |
				perl -pe 's/^{|}$//g; s/\, ([a-z ]+\:)/\n$1/gi; s/^([a-z ]+)\:/$1 = /gmi'
			;;

		lyrics)
			itunes_running && osascript -e 'tell application id "com.apple.itunes" to tell current track to lyrics' | tr '\r' '\n'
			;;

		status)
			itunes_running
			echo -n "[$(osascript -e 'tell application id "com.apple.itunes" to player state as string')] "
			osascript <<-'EOF' 2>/dev/null || echo
			tell application id "com.apple.itunes" to tell current track
				set s to (round (duration as integer) mod 60)
				if s < 10 then set s to "0" & s
				return "\"" & name & "\" by " & artist & " (" & (round ((duration as integer) / 60) rounding down) & ":" & s & ")"
			end tell
			EOF
			;;

		halfstars) pref bool "com.apple.iTunes allow-half-stars" $1 ;;

		hideping) pref bool "com.apple.iTunes hide-ping-dropdown" $1 ;;

		storelinks) pref bool "com.apple.iTunes show-store-link-arrows" $1 ;;

		*) unknown; return ;;
		esac
		;;

	network|net)
		case $arg2_lower in

		-h|"") usage "network" \
			'flushdns' "Flush system DNS cache" \
			'ports' "Show open ports"
			;;

		flushdns) OSVersion -lt 10.7 && dscacheutil -flushcache || sudo killall -HUP mDNSResponder ;;

		ports) sudo lsof -iTCP -sTCP:LISTEN ;;

		*) unknown; return ;;
		esac
		;;

	screencap|sc)
		case $arg2_lower in

		-h|"") usage "screencap" \
			'noshadow [BOOL]' "Disable window shadows when capturing windows" \
			'location [PATH]' "Default save location for screen captures" \
			'type [TYPE]' "File format of screen captures (BMP, GIF, JPG, PDF, PNG, TIFF)"
			;;

		noshadow) pref bool "com.apple.screencapture disable-shadow" $1 && killall SystemUIServer ;;

		location) pref string "com.apple.screencapture location" $1 && killall SystemUIServer ;;

		type) pref string "com.apple.screencapture type" $1 && killall SystemUIServer ;;

		*) unknown; return ;;
		esac
		;;

	services)
		case $arg2_lower in

		-h|"") usage "services" \
			'rebuild' "Rebuild the Services list"
			;;

		rebuild)
			local bin="/System/Library/CoreServices/pbs"
			[[ ! -e "$bin" ]] && ERROR "\`$(basename "$bin")\` not found in '$(dirname "$bin")'" 10
			"$bin" -flush
			;;

		*) unknown; return ;;
		esac
		;;

	system|sys)
		case $arg2_lower in

		-h|"") usage "system" \
			'battery' "Display battery charge (if available)" \
			'lock' "Lock the desktop" \
			'purge' "Force disk cache to be purged"
			;;

		battery) ioreg -S -w0 -c AppleSmartBattery -r AppleSmartBattery | grep -Ei '(Max|Current)Capacity' | perl -pe 's/^[\s\|]*"(\w*)Capacity" = (.*?)[\s]*$/$2 /gi' | awk '{printf "%.1f%%\n",($2/$1*100)}' ;;

		lock) "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend ;;

		purge) sudo purge ;;

		*) unknown; return ;;
		esac
		;;

	wifi|w)
		local bin="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
		[[ ! -e "$bin" ]] && ERROR "\`$(basename "$bin")\` not found in '$(dirname "$bin")'" 10

		case $arg2 in

		-h|"") usage "wifi" \
			'available' "Show available wifi networks" \
			'disconnect' "Disassociate from any network" \
			'info' "Print current wireless status"
			;;

		available) "$bin" -s ;;

		disconnect) sudo "$bin" -z ;;

		info) "$bin" -I ;;

		*) unknown; return ;;
		esac
		;;

	*) unknown; return ;;

	esac
}

mac "$@"
retcode=$?

# Code 100 is for settings where no value was specified
[[ ! $retcode || $retcode = 100 ]] && exit 0 || exit $retcode
