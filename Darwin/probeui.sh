#!/usr/bin/env bash
# probeui.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="probeui.sh"
SCRIPT_VERSION="1.0.6 2012-05-08"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Profile the user interface of an open application.

Usage: ${0##*/} [OPTION]... APPLICATION

Options:
 -d, --depth NUM        Maximum depth to recurse
 -e, --exclude CLASSES  A comma separated list of UI Element child classes to
                        ignore (i.e. "menu bar, slider, grow area")
 -p, --pretty           Output in a more human friendly format
 -h, --help             Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

opt_depth=0

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d*|--depth) [[ $1 =~ ^\-[a-z].+$ ]] && opt_depth="${1:2}" || { opt_depth=$2; shift; } ;;
		-e*|--exclude)
		[[ $1 =~ ^\-[a-z].+$ ]] && opt_exclude="${1:2}" || { opt_exclude=$2; shift; }
		opt_exclude=$(echo "$opt_exclude" | tr ',' '\n' | xargs -I % echo -n '"'%'",')
		opt_exclude="${opt_exclude%,}"
		;;
		-p|--pretty) opt_pretty=1 ;;
		-*|--*) FAIL "unknown option ${1}" ;;
		*) break ;;
	esac
	shift
done

[[ ! "$1" ]] && { usage; exit 0; }
opt_app="$1"
tempfile tmpfile

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
				copy properties of i to the end of a
			end repeat
		end try
		if (count of a) is greater than 0 then set output to output & {|attributes|:a}
*)
		set a to {}
		try
			repeat with i in (actions of _element)
				copy properties of i to the end of a
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

[[ $? > 0 ]] && FAIL

[[ ! $opt_pretty ]] && { cat "$tmpfile"; exit 0; }

ruby <<'EOF' - "$tmpfile"
require 'strscan'
if ! ARGV[0] then exit end
input = StringScanner.new(File.read(ARGV[0]))
$indent_level = 0
$indent_string = "	"
def indent
	if $indent_level < 0 then $indent_level = 0 end
	$indent_string * $indent_level
end
def newline
	"\n" + indent.to_s
end
until input.eos?
	if input.scan(/"/m) then print "\"" + input.scan(/[^"]*"/).to_s
	elsif input.scan(/\s*:\s*/) then print ": "
	elsif input.scan(/\s*,\s*/m) then print "," + newline
	elsif input.scan(/\s*\{\s*\}\s*/) then print "{}"
	elsif input.scan(/\s*\{\s*/)
		$indent_level += 1
		print "{" + newline
	elsif input.scan(/\s*\}\s*/m)
		$indent_level -= 1
		print newline + "}"
	else
		print input.scan(/[^\{\},:"]+/m).to_s
	end
end
EOF

echo
