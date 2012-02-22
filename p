#!/usr/bin/env bash
# Runs any commands as entered, followed by a prowl notification when complete
# Requires prowlnotify, prowl.pl

$*
status=$?
condition=""
msg="$PWD # $*"

if [ $status -eq 0 ]; then
	condition="Finished"
	priority=0
else
	condition="Error"
	priority=1
fi

echo "$msg" | prowlnotify \
	--priority=$priority \
	--application="$HOSTNAME" \
	--event="$condition"
