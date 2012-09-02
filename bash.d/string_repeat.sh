# string_repeat STRING [MULTIPLIER]
# Output a string multiple times.
#
# Example (courtesy of Dave Grohl):
# $ string_repeat "THE BEST " 7
# THE BEST THE BEST THE BEST THE BEST THE BEST THE BEST THE BEST
string_repeat() { local c; for (( c=1; c<=${2:-1}; c++)); do printf "$1"; done; }
