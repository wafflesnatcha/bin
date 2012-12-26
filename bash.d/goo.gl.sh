#!/usr/bin/env bash
# Usage: goo.gl [URL]
#
# Shorten a URL using the Google URL Shortener service (http://goo.gl).
goo.gl() {
	[[ ! $1 ]] && { echo -e "Usage: goo.gl [URL]\n\nShorten a URL using the Google URL Shortener service (http://goo.gl)."; return; }
	curl -qsSL -m10 --connect-timeout 10 \
		'https://www.googleapis.com/urlshortener/v1/url' \
		-H 'Content-Type: application/json' \
		-d '{"longUrl":"'${1//\"/\\\"}'"}' |
		perl -ne 'if(m/^\s*"id":\s*"(.*)",?$/i) { print $1 }'
}
