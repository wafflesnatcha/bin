#!/usr/bin/env bash
. colors.sh 2>/dev/null
for (( i=0; i<=$#; i++ )); do
	printf "${COLOR_MAGENTA}$i${COLOR_RESET}${COLOR_YELLOW}=${COLOR_RESET}${!i}\n"
done
