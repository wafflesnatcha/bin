# count_lines [PATH]
# Recursively count the total lines in all text files contained in PATH.
# 
# Skips files in common version control directories, and files whose mime-type
# doesn't start with "text/"
count_lines() {
	find -s "${1:-$PWD}" \
		\( -name '.Trash' -o -name '.Trashes' -o -name 'lost+found' \) -prune -o \
		\( -name '.CVS' -o -name '.git' -o -name '.hg' -o -name '.svn' \) -prune -o \
		-type f \
		-exec bash -c '[[ `file -b --mime-type {}` =~ ^text/ ]]' \; \
		-print \
		| xargs wc -l
}