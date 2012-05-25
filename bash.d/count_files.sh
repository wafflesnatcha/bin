# count_files [PATH]
# Recursively count the total lines in all text files contained in `PATH`.
# 
# Skips files in .svn and .git directories, and skips non-text files (files
# whose mime-type doesn't start with "text/")
count_files() { find "${1:-$PWD}" -type f | wc -l | awk '{print $1}'; }