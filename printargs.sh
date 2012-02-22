#!/usr/bin/env bash
. colors.sh 2>/dev/null

c=1
for i in "$@"; do
	echo -e ${CLR_B}$c${CLR_R}=$i
	c=$(($c + 1))
done
