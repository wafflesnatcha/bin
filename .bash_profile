export PATH=$PATH:~/bin

export CLICOLOR=1
export GREP_OPTIONS="--color=auto"
export HISTCONTROL=erasedups
export HISTIGNORE="&:cd:cd :cd ..:..:clear:exit:h:history:l:lr:pwd"
export LC_CTYPE=en_US.UTF-8
export LESS='-R --LONG-PROMPT --hilite-unread --tabs=4 --tilde --window=-4 --prompt=M ?f"%f" ?m[%i/%m]. | .?lbLine %lb?L of %L..?PB (%PB\%).?e (END). '

alias cd..='cd ..'
alias ..='cd ..'
alias findn='findname'
alias h='history'
alias hs='historys'
alias l='ls -alph --color=auto'
alias lr='l -R'

alias extract='extract.sh'
alias finds='findstring.sh'
alias rmmr='rmmacres.sh --dsstore --forks'
alias ss='shiftsearch'
alias zipup='zipup.sh'

alias gitclone='git clone --depth 1 --recursive'
alias gitupdate='git pull && git submodule update && git gc --auto'
alias giturl='git config --get remote.origin.url'

alias japng='java -jar ~/bin/japng.jar'
alias yuicompressor='java -jar ~/bin/yuicompressor.jar'


getvars() { set | grep -E '^[a-zA-Z0-9_]+='; }
export -f getvars
printvar() { for a in "$@"; do echo -e "$a=${!a}" >&2; done; }
export -f printvar

adddate() { local b="$(basename "$1")"; local d="$(dirname "$1")"; local f="$d/${b%.*}_$(date +%Y-%m-%d).${b##*.}"; [[ ! -e "$f" ]] && mv "$1" "$f" || echo "file already exists" >&2; }
countfiles() { for a in "${@:-.}"; do echo -n "$a"; find "$a" | wc -l; done; }
countlines() { (find "${1:-$PWD}" -type f \! -regex ".*/\.svn/.*" -exec bash -c '[[ `file -b --mime-type {}` =~ ^text/ ]]' \; -print | while read f; do cat "$f"; done) | wc -l; }
findname() { local n="$1"; shift; find . -type f -iname "*$n*" $@; }
findregex() { local n="$1"; shift; find . -regex "$n" $@; }
historys() { [[ ${#} < 1 ]] && history || history | grep -i "$*"; }
locatefile() { locate "$@" | grep -e "$@$"; }
mkd() { mkdir -p "$@" && eval cd "\"\$$#\""; }
pss() { [[ ${#} < 1 ]] && ps -lAww || ps aux | grep -i "$*"; }

if [[ "$PS1" ]]; then
	export PS1='\[\e]0;\h:\W\007\]\[\e[0;92m\]\h\[\e[97m\]:\[\e[93m\]\W\[\e[m\] \[\e[32m\]\$\[\e[m\] '
	shopt -s cdspell
	tabs -4
fi


##
# OS specific settings

# Mac
if [[ $(uname) == "Darwin" ]]; then

	export PATH=$PATH:~/bin/Darwin:~/bin/Darwin/CocoaDialog.app/Contents/MacOS
	# Macports
	[ -d /opt/local/bin -a -d /opt/local/sbin ] && export PATH=/opt/local/bin:/opt/local/sbin:$PATH

	# export LSCOLORS=ExfxcxdxBxehbdabagacad
	export HISTIGNORE=$HISTIGNORE:l@:fresh:freshe
	# export COPY_EXTENDED_ATTRIBUTES_DISABLE=true

	alias cpath='/bin/echo -n "$PWD" | pbcopy'
	alias l='ls -alph'
	alias l@='ls -alph@'
	alias mac='mac.sh'
	alias ssh='sshcolor.sh'

	fresh() {
		history -w && osascript <<-EOF &>/dev/null
		tell application "System Events"
			if not UI elements enabled then return false
			tell application process "Terminal"
				if frontmost then
					click menu item "New Tab" of menu "Shell" of menu bar 1
					tell application "Terminal" to do script "cd '$PWD' && history -c && history -r" in front window
				end if
			end tell
		end tell
		EOF
	}
	freshe() { fresh && exit; }
	rmxattr() { for f in "$@"; do xattr "$f" | { while read a; do echo "$f: $a"; xattr -d "$a" "$f"; done; } done; }
	
fi

# Linux
if [[ $(uname) == "Linux" ]]; then

	export PATH=$PATH:~/bin/Linux

fi


##
# Host specific settings

if [[ "$HOSTNAME" == "lilpete.local" ]]; then

	export PATH=$PATH:/usr/local/mysql/bin:~/.pear/bin
	export EDITOR='mate -w'
	export GIT_EDITOR='mate -wl1'
	export LESSEDIT='mate -l %lm %f'
	export VISUAL='mate -w'


	alias mate='mate -r'
	alias updatedb='(cd / && sudo /usr/libexec/locate.updatedb)'

	battery() { ioreg -w0 -l | grep -E '(Max|Current)Capacity' | perl -pe 's/^[\s|\|]*"(\w*)Capacity" = (.*)/$1 $2/' | column -t; }

fi

if [[ "$HOSTNAME" == "box" ]]; then

	export PATH=$PATH:/usr/sbin:/usr/local/sbin:/usr/local/lib:/sbin
	export PS1='\[\e]0;\h:\W\007\]\[\e[0;94m\]\h\[\e[97m\]:\[\e[93m\]\W\[\e[m\] \[\e[32m\]\$\[\e[m\] '

fi

# Bash Completion
[ -f /opt/local/etc/bash_completion ] && . /opt/local/etc/bash_completion
