# hs [TEXT]
# List command history matching `TEXT`.
hs() { [ ${#} -lt 1 ] && history || history | grep -i "$@"; }
