#!/usr/bin/env bash
. colors.sh

url="http://browsers.garykeith.com/stream.asp?PHP_BrowsCapINI"

echo -en "finding browscap directory... "
browscap=$(php -r 'echo ini_get("browscap");')
[[ ! ${browscap} ]] && { echo "${CLR_RED}php browscap path not set${CLR_R}"; exit 1; }
echo -e "$browscap"

echo -e "downloading... "
curl -qSL# "${url}" -o "${browscap}"
