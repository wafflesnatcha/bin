# mrp FILE
# 
# Run `mate` using result of `rp` as the first parameter.
mrp() {
	local p
	p=$(rp "$*") || return 1
	[[ ! "$p" || ! -e "$p" ]] && return 1
	echo "$p" 1>&2
	mate "$p"
}
