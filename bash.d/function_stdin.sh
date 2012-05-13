# Allows you to accept STDIN to a function call. Example: fn() { echo "${@:-$(function_stdin)}"; }; fn "testing"; echo "testing" | fn
function_stdin() { local data; while read -r data; do echo -e "$data"; done; }
export -f function_stdin
