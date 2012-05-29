# hs [PATTERN]
# List command history matching PATTERN.
hs() { [ ${#} -lt 1 ] && history || history | grep -i "$@"; }
