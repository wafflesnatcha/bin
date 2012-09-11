# vars [NAME]...
#
# Pretty print variables, useful for debugging.
#
# Example:
# $ some_variable=value
# $ vars some_variable
vars() {
	vars_output() {
		echo "$1='${!1}'" 1>&2
	}

	local var i
	for var in "$@"; do
		local length=$(eval echo "\${#$var[@]}")

		# Not an array
		[[ $length -lt 2 ]] && { vars_output "$var"; continue; }

		# Variable is an array, display each element individually
		for i in $(bash -c "echo {0..$(($length-1))}"); do vars_output "$var[$i]"; done
	done
}
export -f vars

# Tests
# var1="eleifend";var2="hendrerit";var3="urna";var4="vel.";var5="Ante";var6="consequat"
# array1=( Aliquet dui id "lectus luctus aliquam" aliquet )
# array2=( Congue conubia euismod 4432 5 21 facilisis iac"ulis nec odio posuere proin ri"sus suscipit ultrices )
# vars ${!var*} ${!array*}
