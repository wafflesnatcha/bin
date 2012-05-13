# count_lines [PATH]
# Recursively count the total lines in all text files contained in specified PATH. 
count_lines() { find "${1:-$PWD}" -not -path '*/.svn/*' -not -path '*/.git/*' -type f -exec bash -c '[[ `file -b --mime-type {}` =~ ^text/ ]]' \; -print | xargs wc -l; }