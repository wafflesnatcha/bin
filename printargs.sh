#!/usr/bin/env bash
. colors.sh 2>/dev/null
for(( i=1; i<=$#; i++)); do
	printf "${COLOR_YELLOW}$i${COLOR_GREEN}=${COLOR_RESET}${!i}\n"
done
