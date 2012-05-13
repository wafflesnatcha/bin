# Search for running process (or list all if no parameters).
pss() { [ -z "$@" ] && ps -lA || ( ps -lAww | grep -i "[${1:0:1}]${1:1}"; ) }
