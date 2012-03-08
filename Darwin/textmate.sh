
tempfile() {
	eval $1=$(mktemp -t "${0##*/}")
	tempfile_exit="$tempfile_exit rm -f '${!1}';"
	trap "{ $tempfile_exit }" EXIT
}

require() {
	local c=$(type -p "$@")
	[ -z "$c" ] && { tooltip_error "Required command not found: $@"; return 1; }
	echo "$c"
	return 0
}

function_input() {
	while read -r data; do
		echo -e "$data"
	done
}

go_to() {
	ruby -e "require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'" -e "TextMate.go_to :line => ARGV[0], :column => ARGV[1]" "$1" "$2"
}

##
## HTML functions
##

html_encode() {
	{ [ -z "$1" ] && function_input || echo -e "${@}"; } |
		perl -pe '$| = 1; s/^[\s]*$//g; s/[ \t]*$//g; s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g;'
}

## same as html_encode, but also turns newlines into <br>
html_encode_pre() {
	{ [ -z "$1" ] && function_input || echo -e "${@}"; } |
		perl -pe '$| = 1; s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; s/$\\n/<br>/g;'
}

html_redirect() {
	exit_show_html "<script type=\"text/javascript\">window.location='${1//\'/\'}';</script>"
}

## Switch to a nicely formatted HTML error message
## usage: html_error "text"
## usage: cat some_file | html_error
html_error() {
	. "$TM_SUPPORT_PATH/lib/webpreview.sh"
	html_header "${2:-ERROR}"
	echo "<pre>"
	html_encode "$@" |
		php -r 'echo preg_replace("/(^.*?)((?:line )?(\d+)(?: column |\:)?(\d+))(.*$)[\n\r]+/mi", "<a href=\"txmt://open/?url=file://".$_SERVER["TM_FILEPATH"]."&line=$3&column=$4\" style=\"color:#f00\">$2</a>$5", file_get_contents("php://stdin"));'
	echo "</pre>"
	html_footer
	exit_show_html
}

##
## Tool Tip functions
##

tooltip_style='html,body{background:none;border:0;margin:0;padding:0}body{background:rgba(255,255,185,.75);color:#000;font:small-caption;padding:1px 2px 2px}pre,code,tt{font-family:Menlo,monaco,monospace;font-size:inherit;margin:0}'
tooltip_style_error='body{background:rgba(170,14,14,.75);color:#fff}'
tooltip_style_success='body{background:rgba(57,154,21,.75);color:#fff}'

## Standard tooltip
tooltip() {
	tooltip_html "<style>${tooltip_style}</style>$(html_encode_pre "$@")"
}

## Red tooltip
tooltip_error() {
	tooltip_html "<style>${tooltip_style}${tooltip_style_error}</style>$(html_encode_pre "$@")"
}

## Green tooltip
tooltip_success() {
	tooltip_html "<style>${tooltip_style}${tooltip_style_success}</style>$(html_encode_pre "$@")"
}

## Standard tooltip, but with HTML content
## (doesn't insert custom styles)
tooltip_html() {
	"${DIALOG}" tooltip --transparent --html "${@:-$(function_input)}"
}

## Green tooltip with a checkmark
## nice to display when a command has successfully completed
tooltip_tick() {
	local input="$(html_encode_pre "$@")"
	if [[ $input ]]; then 
		local html='<style>'${tooltip_style}'body{background:transparent;color:#fff}.tooltip{-webkit-animation:fadeIn .2s ease 0s;-webkit-animation-fill-mode:forwards;-webkit-border-radius:3px 0 0 3px;-webkit-box-shadow:0 1px 2px 0 rgba(0,0,0,.3);background:rgba(57,154,21,.95);opacity:0;text-shadow:0 1px 0 rgba(0,0,0,.4);position:relative}.tick{-webkit-border-radius:3px 0 0 3px;-webkit-box-shadow:-8px 0 8px -8px rgba(0,0,0,.3) inset;-webkit-box-sizing:border-box;box-sizing:border-box;-webkit-mask-image:-webkit-linear-gradient(top,rgba(0,0,0,1) 75%,rgba(0,0,0,.5));background-image:-webkit-linear-gradient(top,rgba(0,0,0,.2),rgba(0,0,0,.1));text-align:center;width:18px;height:100%;position:absolute;padding:1px 0 0}.content{padding:1px 2px 2px 3px;margin-left:18px}@-webkit-keyframes fadeIn{0%{opacity:0}100%{opacity:.9999}}</style><div class="tooltip"><div class="tick">&#x2714;</div><div class="content">'${input}'</div></div>'
	else
		local html='<style>html,body{background:transparent;border:0;margin:0;padding:0}div{-webkit-animation-delay:0s;-webkit-animation-duration:.1s;-webkit-animation-fill-mode:forwards;-webkit-animation-name:fadeIn;-webkit-border-radius:4px;background:rgba(57,154,21,.9);color:#fff;font:15px/25px monospace;height:25px;opacity:0;text-align:center;text-shadow:0 1px 1px rgba(0,0,0,.5);width:25px}div span{-webkit-animation-delay:.1s;-webkit-animation-duration:.5s;-webkit-animation-fill-mode:forwards;-webkit-animation-name:fadeIn;opacity:0}@-webkit-keyframes fadeIn{0%{opacity:0}100%{opacity:.9999}}</style><div><span>&#x2714;</span></div>'
	fi	
	tooltip_html "$html"
}

##
## Extra exit functions
##
exit_tooltip() { tooltip "$@" && exit_discard; }
exit_tooltip_error() { tooltip_error "$@" && exit_discard; }
exit_tooltip_success() { tooltip_success "$@" && exit_discard; }
exit_tooltip_tick() { tooltip_tick "$@" && exit_discard; }



##
## Tests
##

# /usr/bin/php -v | tooltip_error
# tooltip_success "This is a successful tooltip! :D ┌( ◔‿◔)┘ ʘ‿ʘ\nWow! Amazing! Zing!" && exit_discard
# tooltip "This is a successful tooltip! :D ┌( ◔‿◔)┘ ʘ‿ʘ\nWow! Amazing! Zing!"
# tooltip_tick && exit_discard
# /usr/bin/php -v | tooltip_tick
