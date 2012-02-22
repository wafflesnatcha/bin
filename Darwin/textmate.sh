
tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

require() {
	local c=$(type -p $@ | sed 1q)
	[ -z "$c" ] && { tooltip_error "Required command not found: $@"; return 1; }
	echo "$c"
	return 0
}

function_input() {
	while read data; do
		echo -e "$data"
	done
}

html_encode() {
	echo "${@:-$(function_input)}" | perl -pe '$| = 1; s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; s/$\\n/<br>/'
}

html_redirect() {
	exit_show_html "<script type=\"text/javascript\">window.location='${1//\'/\'}';</script>"
}

html_error() {
	. "$TM_SUPPORT_PATH/lib/webpreview.sh"
	html_header "ERROR"
	echo "<pre>"
	echo "$@" | php -r 'echo htmlspecialchars(trim(file_get_contents("php://stdin")));'
	echo "</pre>"
	html_footer
	exit_show_html
}

##
# tooltip functions

tooltip_default_style='html,body{background:0;border:0;padding:0;margin:0}body{font:small-caption;color:#000;padding:1px 2px 2px;background:rgba(255,255,185,.75)}'

tooltip() {
	"${DIALOG}" tooltip --transparent --html "<style>${tooltip_default_style}</style>$(html_encode "$@")" &>/dev/null
}

tooltip_error() {
	"${DIALOG}" tooltip --transparent --html "<style>${tooltip_default_style}body{background:rgba(170,14,14,.75);color:#fff}</style>$(html_encode "$@")" &>/dev/null
}

tooltip_success() {
	"${DIALOG}" tooltip --transparent --html "<style>${tooltip_default_style}body{color:#fff;background:rgba(21,86,0,.75);}</style}</style>$(html_encode "$@")" &>/dev/null
}

tooltip_tick() {
	html="<style>html,body{background:transparent;border:0;margin:0;padding:0}div{-webkit-animation-delay:0s;-webkit-animation-duration:.1s;-webkit-animation-fill-mode:forwards;-webkit-animation-name:'fadeIn';-webkit-border-radius:4px;background:rgba(57,154,21,.9);color:#fff;font:15px/25px monospace;height:25px;opacity:0;text-align:center;text-shadow:0 1px 1px rgba(0,0,0,.5);width:25px}div span{-webkit-animation-delay:.1s;-webkit-animation-duration:.5s;-webkit-animation-fill-mode:forwards;-webkit-animation-name:'fadeIn';opacity:0}@-webkit-keyframes 'fadeIn'{0%{opacity:0}100%{opacity:.9999}}</style><div><span>&#x2714;</span></div>"
	"${DIALOG}" tooltip --transparent --html "$html" &>/dev/null
}

##
# Overloaded functions
exit_show_tool_tip() {
	tooltip "$@" && exit_discard
}


##
# Tests

# /usr/bin/php -v | tooltip_error
# tooltip_success "This is a successful tooltip! :D ┌( ◔‿◔)┘ ʘ‿ʘ " && exit_discard
# tooltip_tick && exit_discard