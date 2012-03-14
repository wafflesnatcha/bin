path_append() { local f; for f in "$@"; do [ -d "$f" ] && PATH=$PATH:$f; done; export PATH; }
path_prepend() { local f; for f in "$@"; do [ -d "$f" ] && PATH=$f:$PATH; done; export PATH; }

path_append ~/bin ~/bin/"$(uname)" ~/lib

export CLICOLOR=1
export GREP_OPTIONS="--color=auto"
export HISTCONTROL=erasedups
export HISTIGNORE="&:cd:cd :cd ..:..:clear:exit:l:lr:pwd"
#export LC_CTYPE=en_US.UTF-8
export LESS='-R --LONG-PROMPT --hilite-unread --tabs=4 --tilde --window=-4 --prompt=M ?f"%f" ?m[%i/%m]. | .?lbLine %lb?L of %L..?PB (%PB\%).?e (END). '
export LS_COLORS='rs=0:di=00;34:ln=00;35:mh=00:pi=40;33:so=00;32:do=01;35:bd=40;33;01:cd=40;33;01:or=41;30;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=30;43:st=37;44:ex=1;31:';
export LSCOLORS=exfxcxdxbxegedabagacad

alias cd..='cd ..'
alias ..='cd ..'
alias e='echo'
alias h='history'
alias hs='historys'
alias l='ls -Ahlp --color=auto'
alias lr='l -R'

alias extract='extract.sh'
alias findn='findname'
alias finds='findstring.sh'
alias rmmr='rmmacres.sh --dsstore --forks'
alias zipup='zipup.sh'

alias gitclone='git clone --depth 1 --recursive'
alias gitupdate='git pull && git submodule update && git gc --auto'
alias giturl='git config --get remote.origin.url'

getvars() { set | grep -E '^[a-zA-Z0-9_]+='; }
export -f getvars
printvar() { local a; for a in "$@"; do echo -e "$a=${!a}"; done; }
export -f printvar

adddate() { local b="$(basename "$1")"; local d="$(dirname "$1")"; local f="$d/${b%.*}_$(date +%Y-%m-%d).${b##*.}"; [ ! -e "$f" ] && mv "$1" "$f" || echo "file already exists" >&2; }
countfiles() { local f; for f in "${@:-$PWD}"; do echo -e "$(find "$f" | wc -l) $f"; done; }
countlines() { find "${1:-$PWD}" -not -path '*/.svn/*' -not -path '*/.git/*' -type f -exec bash -c '[[ `file -b --mime-type {}` =~ ^text/ ]]' \; -print | xargs wc -l; }
datauri() { [ -z "$1" ] && return; echo -n "data:$(file -b --mime-type "$1");base64," && openssl base64 -in "$1" | awk '{ str1=str1 $0 }END{ print str1 }' | perl -pe 's/\s*$//';  }
findname() { local n="$1"; shift; find . -iname "*$n*" $@; }
findregex() { local n="$1"; shift; find . -regex "$n" $@; }
historys() { [ ${#} -lt 1 ] && history || history | grep -i "$*"; }
locatefile() { locate "$@" | grep -e "$@$"; }
mkd() { mkdir -p "$@" && eval cd "\"\$$#\""; }
pss() { [ -z "$@" ] && ps -lA || ( ps -lAww | grep -i "[${1:0:1}]${1:1}"; ) }
realpath() { readlink -f "$1" 2>/dev/null || type -p greadlink && greadlink -f "$1"; }

if [ -n "$PS1" ]; then
	case "$TERM" in
		xterm-color|xterm-256color)
		export PS1='\[\e[m\]\[\e]0;\h:\W\007\]\[\e[92m\]\h\[\e[37m\]:\[\e[33m\]\W \[\e[0;$([[ $? > 0 ]] && echo "31" || echo "32")m\]\$\[\e[m\] ' ;;
		*)
		export PS1='\h:\W \$ ' ;;
	esac
	tabs -4 2>/dev/null
	shopt -s cdspell
fi


##
## OS specific settings

## Mac
if [ "$(uname)" = "Darwin" ]; then

	path_append ~/lib/cocoaDialog.app/Contents/MacOS
	path_prepend /opt/local/{bin,sbin} # Macports

	# export COPY_EXTENDED_ATTRIBUTES_DISABLE=true
	export HISTIGNORE=$HISTIGNORE:gl:l@:fresh:freshe
	export INPUTRC=~/.inputrc

	alias cpath='/bin/echo -n "$PWD" | pbcopy'
	alias gl='gls -Ahlp --color=auto'
	alias l='ls -Abhlp'
	alias l@='l -@'
	alias mac='mac.sh'
	alias sshc='sshcolor.sh'

	fresh() {
		history -w && osascript <<-EOF | { while read a; do [ -z "$a" ]; return; done; }
		tell application "System Events"
			if not UI elements enabled then return
			tell application process "Terminal"
				if not frontmost then return 1
				click menu item "New Tab" of menu "Shell" of menu bar 1
				tell application "Terminal" to do script "cd '$PWD' && history -c && history -r" in front window
			end tell
		end tell
		return
		EOF
	}
	freshe() { fresh && exit; }
	lxattr() { local f; for f in "$@"; do xattr "$f" | { while read a; do xattr -vlp "$a" "$f"; done; } done; }
	rmxattr() { local f; for f in "$@"; do xattr "$f" | { while read a; do echo "$f: $a"; xattr -d "$a" "$f"; done; } done; }

fi


##
## Host specific settings

## lilpete.local
if [ "$HOSTNAME" = "lilpete.local" ]; then

	path_append /usr/local/mysql/bin ~/.pear/bin ~/lib/AdobeAIRSDK/bin ~/lib/phantomjs-1.4.1/bin

	export EDITOR='mate -w'
	export GIT_EDITOR='mate -wl1'
	export LESSEDIT='mate -l %lm %f'
	export VISUAL='mate -w'

	alias mate='mate -r'
	alias m='mate'

fi

## box
if [ "$HOSTNAME" == "box" ]; then

	path_append /usr/sbin /usr/local/sbin /usr/local/lib /sbin
	
	# change hostname color in bash prompt
	[ -n "$PS1" ] && PS1=$(echo -n $PS1 | sed 's/\([0-9]\{2\}\)\(m\\\]\\h\)/94\2/g') && export PS1

fi
