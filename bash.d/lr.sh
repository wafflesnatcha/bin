# lr [OPTION]... [FILE]...
# Replacement for `ls -R`
# 
# OPTIONS includes any options specified by the system's ls command
lr() {
	while [[ "$1" =~ ^- && ! -e "$1" ]]; do
		local f="$f $1" && shift
	done
	
	find "${1:-.}" -print |
		perl -pe 's/^(?:.\/)?(.*)$\\n/$1\x00/gim;' |
		xargs -0 $(alias l | sed -E 's/^alias [^=]+='\''(.*)'\''$/\1/g') -d $f
}
