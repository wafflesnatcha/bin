#!/usr/bin/env bash
# textmate.sh by Scott Buchanan <buchanan.sc@gmail.com> http://wafflesnatcha.github.com
# Handy functions to include in your TextMate commands

# regex_escape STRING
# Escape a string for use in perl regex
regex_escape() { echo "$@" | perl -pe 's/(.*)/\Q\1\E/'; }

# temp_file VARIABLE_NAME...
# Generate a temporary file, saving its path in a variable named `VARIABLE_NAME`.
#
# Automatically deletes the file when the current script/program ends.
#
# Example:
# $ temp_file temp1 temp2 temp3
# $ echo "temp1=$temp1"
# $ echo "temp2=$temp2"
# $ echo "temp3=$temp3"
# $ echo "but these files will be deleted as soon as this script ends..."
temp_file() {
	local _temp_file__var
	for _temp_file__var in "$@"; do
		eval $_temp_file__var=\"$(mktemp -t "${0##*/}")\"
		_temp_file__files="$_temp_file__files '${!_temp_file__var}'"
	done
	trap "rm -f $_temp_file__files" EXIT
}

# require COMMAND
# Output the path to COMMAND, if COMMAND is in the current $PATH and executable.
# Otherwise, shows an error tooltip and returns 1.
#
# Example:
# $ bin=$(require uglifyjs) || exit_discard
require() { type -p "$@" || { tooltip_error "Required command not found: $@"; return 1; }; }

# function_stdin
# Allows you to accept STDIN to a function call
#
# Example:
# $ fn() { echo "${@:-$(function_stdin)}"; }; fn "testing"; echo "testing" | fn
function_stdin() {
	local oldIFS=$IFS
	IFS="$(printf "\n")"
	local line
	while read -r line; do
		echo -e "$line"
	done
	IFS=$oldIFS
}

# textmate_open FILE [LINE, [COLUMN]]
# Open a file in textmate at a given LINE and COLUMN
textmate_open() { open "txmt://open?url=file://$1${2:+&line=$2}${3:+&column=$3}"; }

# textmate_goto [LINE, [COLUMN]]
# Alias to `textmate_open "${TM_FILEPATH}" LINE COLUMN`
textmate_goto() { textmate_open "${TM_FILEPATH}" $1 $2; }


#
# HTML functions
#

html_redirect() { . "$TM_SUPPORT_PATH/lib/html.sh" && redirect "$@" && exit_show_html; }

# HTML encode text <, >, &
#
# Examples:
# $ html_encode "<some text> you want to encode & stuff"
# $ cat "/some/file.html" | html_encode
html_encode() {
	echo -e "${@:-$(function_stdin)}" |
		perl -pe '$|=1; s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g;'
}

html_encode_br() {
	html_encode "${@:-$(function_stdin)}" | perl -pe 's/\n/<br>/g;'
}

# Open a nicely formatted HTML error message
#
# Examples:
# $ html_error "text"
# $ cat some/file.txt | html_error
html_error() {
	# [[ $TM_FILEPATH ]] && url_param="url=file:\/\/${TM_FILEPATH//\//\\/}\&"
	[[ $TM_FILEPATH ]] && url_param="$(regex_escape "url=file://${TM_FILEPATH}&")"
	. "$TM_SUPPORT_PATH/lib/webpreview.sh"
	html_header "${2:-Error}"
	echo '<pre class="viewport error" style="border:2px solid #f00;"><code>'
	html_encode "$@" |
		perl -pe 's/(^.*?)((?:line )?(\d+)(?: column |\:)?(\d+))(.*$)/$1<a href=\"txmt:\/\/open\/\?'${url_param}'line=$3\&column=$4\">$2<\/a>$5/mi'
	echo '</code></pre>'
	html_footer
	exit_show_html
}

#
# Tooltip functions
#

# Standard tooltip
tooltip() { tooltip_template default --text "$(html_encode_br "$@")"; }

# Standard tooltip, but don't HTML encode
tooltip_html() { tooltip_template default --text "${@:-$(function_stdin)}"; }

# Red tooltip with a ✘, used for a command has failed.
tooltip_error() {
	local input=$(html_encode_br "$@")
	tooltip_template \
		$([[ $input ]] && echo "styled" || echo "styled_notext") \
		--color 170,14,14 --glyph "&#x2718;" --text "$input"
}

# Green tooltip with a ✔, used for a command has successfully completed.
tooltip_success() {
	local input=$(html_encode_br "$@")
	tooltip_template \
		$([[ $input ]] && echo "styled" || echo "styled_notext") \
		--color 57,154,21 \
		--glyph "&#x2714;" \
		--text "$input"
}

# Orange tooltip with a ⚠, used for warnings and such.
tooltip_warning() {
	local input=$(html_encode_br "$@")
	tooltip_template \
		$([[ $input ]] && echo "styled" || echo "styled_notext") \
		--color 175,82,0 \
		--glyph '<span style="color:yellow">&#x26A0;</span>' \
		--text "$input"
}

# tooltip_template TEMPLATE [--VAR REPLACEMENT]...
# Show a custom tooltip using $TM_tooltip_template
#
# If your custom template has any %%words%% in it, simply pass them to this
# function as long arguments (i.e. tooltip_template --color 12,139,245).
# See the included templates for more information.
#
# Example:
# $ tooltip_template default --text "This is the tooltip text."
# $ tooltip_template default --color "12,139,245" --text "This is the tooltip text."
# $ tooltip_template default --color "12,139,245" --text "This is the tooltip text."
tooltip_template() {
	local template="TM_tooltip_template_$1"
	local replacement=
	local lookup=
	local html="$(echo "${!template}")"
	echo "$html"
	shift

	# Replace %%words%%
	while (($#)); do
		[[ ! "$1" =~ ^-- ]] && break
		lookup="${1:2}"
		replacement=$(regex_escape "$2")
		html=$(echo "$html" | perl -pe "s/%%${lookup}%([^%]*)%/${replacement}/g")
		shift 2
	done

	# Replace %%words%% that weren't specified (with their default values if possible)
	html=$(echo "$html" | perl -pe "s/%%([a-z0-9\-\_]+)%([^%]*)%/\$2/gi")

	"${DIALOG}" tooltip --transparent --html "$html" &>/dev/null &
}

#
# Extra exit functions
#

exit_tooltip() { tooltip "$@" && exit_discard; }
exit_tooltip_error() { tooltip_error "$@" && exit_discard; }
exit_tooltip_success() { tooltip_success "$@" && exit_discard; }
exit_tooltip_warning() { tooltip_warning "$@" && exit_discard; }

#
# Tooltip Templates
#

# Variables: text, [color]
TM_tooltip_template_default=$(cat <<'EOF'
<style>
html,body{background:0;border:0;margin:0;padding:0}
body{font:small-caption;padding:1px 10px 14px}
h1,h2,h3,h4,h5,h6{display:inline;margin:0;padding:0;}
pre,code,tt{font-family:Menlo,monaco,monospace;font-size:inherit;margin:0}
.tooltip{-webkit-animation:fadeIn .2s ease 0s;-webkit-animation-fill-mode:forwards;-webkit-box-shadow:0 0 0 1px rgba(0,0,0,.1),0 5px 9px 0 rgba(0,0,0,.4);background:rgba(%%color%255,255,185%,.95);color:#000;font:small-caption;opacity:0;padding:2px 3px 3px;position:relative}
@-webkit-keyframes fadeIn {	0% { opacity: 0 } 100% { opacity: .9999 } }
</style>
<div class="tooltip">%%text%%</div>
EOF)

# Variables: glyph, text, [color]
TM_tooltip_template_styled=$(cat <<'EOF'
<style>
html,body{background:0;border:0;margin:0;padding:0}
body{padding:1px 10px 14px}
pre,code,tt{font-family:Menlo,monaco,monospace;font-size:inherit;margin:0}
.tooltip{-webkit-animation:fadeIn .2s ease 0s;-webkit-animation-fill-mode:forwards;-webkit-border-radius:2px 0 0 2px;-webkit-box-shadow:0 0 0 1px rgba(0,0,0,.1),0 5px 9px 0 rgba(0,0,0,.4);background:rgba(%%color%255,255,185%,.95);color:#fff;font:small-caption;opacity:0;position:relative;text-shadow:0 1px 0 rgba(0,0,0,.2)}
.glyph{-webkit-border-radius:2px 0 0 2px;-webkit-box-shadow:-8px 0 8px -8px rgba(0,0,0,.3) inset;-webkit-box-sizing:border-box;-webkit-mask-image:-webkit-linear-gradient(top,rgba(0,0,0,1) 75%,rgba(0,0,0,.5));background-image:-webkit-linear-gradient(top,rgba(0,0,0,.2),rgba(0,0,0,.1));box-sizing:border-box;font-family:monospace,webdings;height:100%;padding:2px 0 0;position:absolute;text-align:center;text-shadow:0 -1px 0 rgba(0,0,0,.2);width:18px}
.text{margin-left:18px;padding:2px 3px 3px 4px}
@-webkit-keyframes fadeIn {	0% { opacity: 0 } 100% { opacity: .9999 } }
</style>
<div class="tooltip"><div class="glyph">%%glyph%%</div><div class="text">%%text%%</div></div>
EOF)

# Variables: glyph, [color]
TM_tooltip_template_styled_notext=$(cat <<'EOF'
<style>
html,body{background:0;border:0;margin:0;padding:0}
body{padding:1px 10px 14px}
.tooltip{-webkit-animation:fadeIn .2s ease 0s;-webkit-animation-fill-mode:forwards;-webkit-border-radius:5px;-webkit-box-shadow:0 0 0 1px rgba(0,0,0,.1),0 5px 9px 0 rgba(0,0,0,.4);background:rgba(%%color%255,255,185%,.95);color:#fff;font:16px/25px monospace,webdings;height:25px;opacity:0;padding:3px;position:relative;text-align:center;text-shadow:0 1px 0 rgba(0,0,0,.2);width:25px}
@-webkit-keyframes fadeIn {	0% { opacity: 0 } 100% { opacity: .9999 } }
</style>
<div class="tooltip">%%glyph%%</div>
EOF)


#
# Tests
#

# tooltip_error "Oh no an error!"
# tooltip_warning
# /usr/bin/php -v | tooltip_warning
# tooltip_success "This is a successful tooltip! :D ┌( ◔‿◔)┘ ʘ‿ʘ\nWow! Amazing! Zing!" && exit_discard
# tooltip_success
# tooltip "This is a successful tooltip! :D ┌( ◔‿◔)┘ ʘ‿ʘ\nWow! Amazing! Zing!"
