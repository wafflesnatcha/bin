# ls -R replacement
lr() { while [[ "$1" =~ ^- && ! -e "$1" ]]; do local f="$f $1" && shift; done; find "${1:-.}" -print0 | perl -pe '$|=1; s/\x00\.\//\x00/gi;' | xargs -0 $(alias l | sed -E 's/^alias [^=]+='\''(.*)'\''$/\1/g') -d $f; }
