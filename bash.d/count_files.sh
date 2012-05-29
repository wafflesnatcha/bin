# count_files [PATH]
# Count the total number of items.
count_files() {
	find "${1:-$PWD}" \
		-not -path "${1:-$PWD}" \
		| wc -l \
		| awk '{print $1}'
}