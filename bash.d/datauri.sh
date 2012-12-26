#!/usr/bin/env bash
# Usage: datauri FILE
#
# Convert a file to a `data:URI` string, suitable for embedding in web content.
# See <http://wikipedia.org/wiki/Data_URI_scheme> for more information.
datauri() {
	[[ ! $1 ]] && cat <<-EOF && return
		Usage: datauri FILE

		Convert a file to a `data:URI` string, suitable for embedding in web content.
		See <http://wikipedia.org/wiki/Data_URI_scheme> for more information.
		EOF

	echo -n "data:$(file -b --mime-type "$1");base64,"
	if type base64 &>/dev/null; then
		base64 -i "$1" | perl -pe 's/\s+$//'
	elif type openssl &>/dev/null; then
		openssl base64 -in "$1" | awk '{ str1=str1 $0 }END{ print str1 }' | perl -pe 's/\s+$//'
	fi
}
