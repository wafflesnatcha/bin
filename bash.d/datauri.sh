# datauri FILE
datauri() {
	[ -z "$1" ] && return
	echo -n "data:$(file -b --mime-type "$1");base64," &&
		openssl base64 -in "$1" |
		awk '{ str1=str1 $0 }END{ print str1 }' |
		perl -pe 's/\s+$//'
}
