# vars [NAME]...
#
# Pretty print variables, useful for debugging.
#
# Example:
# $ some_variable=value
# $ vars some_variable
vars() {
	o() { echo "$1='${!1}'" 1>&2; }
	local v i l
	for v in "$@"; do
		l=$(eval echo "\${#$v[@]}")
		[[ $l -lt 2 ]] && o "$v" || for i in $(eval echo {0..$(($l-1))}); do o "$v[$i]"; done
	done
}
export -f vars

# Tests
# var1="eleifend";var2="hendrerit";var3="urna";var4="vel.";var5="Ante";var6="consequat";array1=( Aliquet dui id "lectus luctus aliquam" aliquet );array2=( Congue conubia euismod 4432 5 21 facilisis iac"ulis nec odio posuere proin ri"sus suscipit ultrices );vars ${!var*} ${!array*}
