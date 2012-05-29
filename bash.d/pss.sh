# pss [PATTERN]
# Search for running processes matching `PATTERN`.
pss() { [ ${#} -lt 1 ] && ps -A || ( ps -Aww | grep -i "[${1:0:1}]${1:1}"; ) }
