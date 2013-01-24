#!/usr/bin/env bash
# `crush.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="crush.sh"
SCRIPT_VERSION="r8 2013-01-24"

type optipng &>/dev/null && P_optipng="optipng -quiet -preserve"
type pngcrush &>/dev/null && P_pngcrush="pngcrush -q -rem alla -rem gAMA -rem text -oldtimestamp -ow"
type jpgcrush &>/dev/null && P_jpgcrush="jpgcrush"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Optimize images with either optipng, pngcrush, or jpgcrush.

Usage: ${0##*/} [OPTION]... FILE...

Options:
 -w, --with CMD    Use only this image processor
 -p, --percentage  Prefix output lines with overall percent completed
 -h, --help        Show this help
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

while (($#)); do
	case $1 in
		-h|--help)
			usage; exit 0 ;;
		-p|--percentage)
			opt_percentage=1 ;;
		-w*|--with)
			[[ $opt_with ]] && { ERROR "$1 option already set to '${opt_with#P_}'"; }
			[[ $1 =~ ^\-[a-z].+$ ]] && opt_with="P_${1:2}" || { opt_with="P_$2"; shift; }
			[[ ! ${!opt_with} ]] && ERROR "image processor not supported '${opt_with#P_}'" 3
			
			# remove all the other processors
			for p in ${!P_*}; do [[ ! $opt_with = $p ]] && unset ${p}; done
			;;

		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! $1 ]] && { usage; exit 0; }

process() {
	local ext=$(echo "${1##*.}" | tr '[:upper:]' '[:lower:]')
	case "$ext" in
		png)
			[[ ! $P_pngcrush && ! $P_optipng ]] && return 2
			[[ $P_pngcrush ]] && $P_pngcrush "$1"
			[[ $P_optipng ]] && $P_optipng "$1"
			;;
		jpg|jpeg)
			[[ ! $P_jpgcrush ]] && return 2 || "$P_jpgcrush" "$1" 1>/dev/null
			;;
		*) return 2 ;;
	esac
	return 0
}

count=0
for f in "$@"; do
	[[ $opt_percentage ]] && echo -n "$(echo "$count/$#*100" | bc -l | xargs printf "%1.0f%%";) "
	echo "$f"
	(( count++ ))
	process "$f" || continue
done
