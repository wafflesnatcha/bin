# unicode2hex CHARACTER
# Convert a character to its unicode hexadecimal value. The output can be used
# directly with printf.
#
# Example:
# $ unicode2hex ã
# \xC3\xA3
#
# Example:
# $ lightning=$(unicode2hex ⚡)
# $ printf "$lightning $lightning $lightning\n"
# ⚡ ⚡ ⚡
unicode2hex() { echo -n "$1" | hexdump | head -n1 | tr a-z A-z | awk '{for (i=2; i<=NF; i++) printf "\\x%s", $i}'; }

# TESTS
# for v in A @ % ∂ à Ũ ŵ ￫ ☠; do echo $v $(unicode2hex "$v"); done
