# count_files [PATH]
# Recursively count the total files PATH.
# 
# Skips files in .svn and .git directories, and skips non-text files (files
# whose mime-type doesn't start with "text/")
count_files() { find "${1:-$PWD}" -not -path "${1:-$PWD}" | wc -l | awk '{print $1}'; }