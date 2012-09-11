# goo.gl URL
# 
# Shorten a URL using the Google URL Shortener service (http://goo.gl).
goo.gl() {
	curl -qsSL -m10 --connect-timeout 10 \
		https://www.googleapis.com/urlshortener/v1/url \
		-H 'Content-Type: application/json' \
		-d '{"longUrl": "'${1//\"/\\\"}'"}' |
		perl -ne 'if(m/^\s*"id":\s*"(.*)",?$/i) { print $1 }'
}