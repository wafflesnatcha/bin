# mrp FILE
# Run `mate` using result of `rp` as the first parameter.
mrp() {
	local p=$(rp "$*") || return
	[[ ! "$p" || ! -e "$p" ]] && return 
	echo "$p" 1>&2
	mate "$p"
}
