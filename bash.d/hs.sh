# Search command history (or list all if no parameters). Usage: hs "TEXT"
hs() { [ ${#} -lt 1 ] && history || history | grep -i "$@"; }
