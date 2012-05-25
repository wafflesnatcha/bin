# vars VARIABLE_NAME...
# Pretty print variables, useful for debugging.
vars() {
	local a
	for a in "$@"; do
		echo $a="'${!a}'" 1>&2
	done
}
export -f vars