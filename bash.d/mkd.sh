# mkdir and cd into it
mkd() { mkdir -p "$@" && eval cd "\"\$$#\""; }
