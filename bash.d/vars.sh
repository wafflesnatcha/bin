# vars [NAME]...
#
# Pretty print variables, useful for debugging.
#
# Example:
# $ some_variable=value
# $ vars some_variable
vars() {
	local __i __l
	[[ ! -p /dev/stdout && "$TERM" =~ ^xterm-.*color ]] &&
		o() { echo -ne "\033[34m$1\033[32m=\033[m"; echo "'${!1}'"; } ||
		o() { echo "$1='${!1}'"; }
	while (($#)); do
		__l=$(eval echo "\${#$1[@]}")
		[[ $__l -lt 2 ]] && o "$1" || for __i in $(eval echo {0..$(($__l-1))}); do o "$1[$__i]"; done
		shift
	done
}
export -f vars

# Tests
# var1="eleifend";var2="hendrerit";var3="urna";var4="vel.";var5="Ante";var6="consequat";array1=( Aliquet dui id "lectus luctus aliquam" aliquet );array2=( Congue conubia euismod 4432 5 21 facilisis iac"ulis nec odio posuere proin ri"sus suscipit ultrices );vars ${!var*} ${!array*}
