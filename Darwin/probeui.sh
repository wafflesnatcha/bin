#!/usr/bin/env bash
# `probeui.sh` by Scott Buchanan <http://wafflesnatcha.github.com>
SCRIPT_NAME="probeui.sh"
SCRIPT_VERSION="r1 2012-07-06"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Profile the user interface of an open application.

Usage: ${0##*/} [OPTION]... APPLICATION

Options:
 -d, --depth NUM        Maximum depth to recurse
 -e, --exclude CLASSES  UI Element child classes to ignore
 -p, --pretty           Output in a more human friendly format
 -h, --help             Show this help

Example:
    ${0##*/} -d2 -p -e "menu bar, slider, grow area" Finder
EOF
}

ERROR() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" 1>&2; [[ $2 > -1 ]] && exit $2; }

opt_depth=0

temp_file() {
	local var
	for var in "$@"; do
		eval $var=\"$(mktemp -t "${0##*/}")\"
		temp_file__files="$temp_file__files '${!var}'"
	done
	trap "rm -f $temp_file__files" EXIT
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d*|--depth) [[ $1 =~ ^\-[a-z].+$ ]] && opt_depth="${1:2}" || { opt_depth=$2; shift; } ;;
		-e*|--exclude)
		[[ $1 =~ ^\-[a-z].+$ ]] && v="${1:2}" || { v="$2"; shift; }
		v=$(echo "$v" | tr ',' '\n' | xargs -I % echo -n '"'%'",')
		opt_exclude="${v%,}"
		;;
		-p|--pretty) opt_pretty=1 ;;
		--) shift; break ;;
		-*|--*) ERROR "unknown option ${1}" 1 ;;
		*) break ;;
	esac
	shift
done

[[ ! "$1" ]] && { usage; exit 0; }
opt_app="$1"
temp_file tmpfile

osascript -s s <<EOF > "$tmpfile"
property config : missing value
tell application "System Events"
	set config to {max_depth:${opt_depth}, exclude_classes:{${opt_exclude}}}
	return my probeUIElement(application process "${opt_app}", 0)
end tell
on probeUIElement(_element, _depth)
	set _depth to _depth + 1
	if (max_depth of config) > 0 and _depth is greater than (max_depth of config) then return null
	set output to {}
	tell application "System Events"
		try
			set output to output & properties of _element
		end try
(*
		set a to {}
		try
			repeat with i in (attributes of _element)
				if (name of i) is not "AXChildren" then copy { name: name of i, value: value of i, settable: settable of i} to the end of a
			end repeat
		end try
		if (count of a) is greater than 0 then set output to output & {|attributes|:a}
*)
		set a to {}
		try
			repeat with i in (actions of _element)
				copy { name: name of i, description: description of i} to the end of a
			end repeat
		end try
		if (count of a) is greater than 0 then set output to output & {|actions|:a}

		set a to {}
		try
			repeat with i in (UI elements of _element)
				if my indexOf(exclude_classes of config, class of i as string) < 0 then
					set res to my probeUIElement(i, _depth)
					if res is not null then copy res to the end of a
				end if
			end repeat
		end try
		if (count of a) is greater than 0 then set output to output & {children:a}
	end tell
	if output is {} then return null
	return output
end probeUIElement
on indexOf(_l, _e)
	repeat with i from 1 to length of _l
		if item i of _l = _e then return i
	end repeat
	return -1
end indexOf
EOF

[[ $? > 0 ]] && ERROR "$(tail -n1 "$tmpfile")" 1

[[ ! $opt_pretty ]] && { cat "$tmpfile"; exit 0; }

ruby <<'EOF' - "$tmpfile"
if ! ARGV[0] then exit end
require 'strscan'
$level = 0
$indent_string = "    "
def indent
	$level = 0 if $level < 0
	$indent_string * $level
end
def newline
	"\n" + indent.to_s
end
input = StringScanner.new(File.read(ARGV[0]))
until input.eos?
	if input.scan(/"([^"]*)"/) then print '"' + input[1] + '"'
	elsif input.scan(/\s*:\s*/) then print ": "
	elsif input.scan(/\s*,\s*/) then print "," + newline
	elsif input.scan(/\s*\{\s*([\d,\s]+)\s*\}\s*/)
		print "{ " + input[1].gsub(/\s/, '').gsub(/,/, ', ').chomp() + " }"
		input.scan(/\s*\}\s*/)
	elsif input.scan(/\s*\{\s*\}\s*/) then print "{}"
	elsif input.scan(/\s*\{\s*/)
		$level += 1
		print "{" + newline
	elsif input.scan(/\s*\}\s*/)
		$level -= 1
		print newline + "}"
	else print input.scan(/.{1}/).to_s
	end
end
EOF

echo
