#!/usr/bin/env bash
# `pixel_color.sh` by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
SCRIPT_NAME="pixel_color.sh"
SCRIPT_VERSION="r1 2012-09-12"

usage() { cat <<EOF
$SCRIPT_NAME $SCRIPT_VERSION
Color of the screen pixel at a given point.

Usage: ${0##*/} X Y

Point (x0, y0) corresponds to the top left of the first monitor.
EOF
}

[[ $# -lt 2 || $1 = "--help" || $1 = "-h" ]] && { usage; exit; }

temp_file() {
	local _temp_file_var
	for _temp_file_var in "$@"; do
		eval $_temp_file_var=\"$(mktemp -t "${0##*/}")\"
		_temp_file_files="$_temp_file_files '${!_temp_file_var}'"
	done
	trap "rm -f $_temp_file_files" EXIT
}

point=($(echo "$1" | sed 's/,/ /'))
temp_file tmpfile
screencapture -x -tpng "$tmpfile"

cat <<EOF | python -
import AppKit
img = AppKit.NSImage.alloc().initWithContentsOfFile_("$tmpfile")
img.lockFocus()
color = AppKit.NSReadPixel(AppKit.NSMakePoint(float($1), AppKit.NSScreen.mainScreen().frame().size.height - float($2)))
img.unlockFocus()
print color._.redComponent, color._.greenComponent, color._.blueComponent
EOF
