#!/usr/bin/env bash
SCRIPT_NAME="probeui.sh"
SCRIPT_VERSION="1.0.4 (2012-02-29)"

usage() {
cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Profile the user interface of an open application.

Usage: ${0##*/} [options] APPLICATION_NAME

Options:
 -d, --depth NUM  Maximum depth to recurse
 -p, --pretty     Nicely format the output
 -h, --help       Show this help
EOF
}
FAIL() { [[ $1 ]] && echo "$SCRIPT_NAME: $1" >&2; exit ${2:-1}; }

opt_depth=0
opt_pretty=

tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

while (($#)); do
	case $1 in
		-h|--help) usage; exit 0 ;;
		-d|--depth) opt_depth="$2"; shift ;;
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
using terms from application "System Events"
	property config : {max_depth:${opt_depth}, exclude_classes:{}}
end using terms from
on run argv
	set _app to "${opt_app}"
	if _app is false then return false
	tell application "System Events" to get application process _app
	return my probeUIElement(result, 0)
end process
on probeUIElement(_element, _depth)
	set _depth to _depth + 1
	if (max_depth of config) > 0 and _depth is greater than (max_depth of config) then return null
	tell application "System Events"
		set r to properties of _element
		if (count of (actions of _element)) is greater than 0 then
			set r to r & {|actions|:{}}
			repeat with i in (actions of _element)
				--copy (name of i & " - " & description of i) to the end of (|actions| of r)
				copy properties of i to the end of (|actions| of r)
			end repeat
		end if
		-- Children
		set _children to every UI element of _element
		if (count of _children) is greater than 0 then
			set r to r & {children:{}}
			repeat with c in _children
				get my indexOf(exclude_classes of config, class of c)
				-- make sure its not an excluded class
				if result < 0 then copy my probeUIElement(c, _depth) to the end of (children of r)
			end repeat
		end if
		return r
	end tell
	return null
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
	if input.scan(/"/m) then
		print "\"" + input.scan(/[^"]*"/).to_s
	elsif input.scan(/\s*:\s*/)
		print ": "
	elsif input.scan(/\s*,\s*/m)
		print "," + newline
	elsif input.scan(/\s*\{\s*\}\s*/)
		print "{}"
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
