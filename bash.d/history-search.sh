#!/usr/bin/env bash
# Usage: history-search [PATTERN]
#
# List command history matching PATTERN.
history-search() {
	[ $# -lt 1 ] && history || history | grep -i --color=auto "$@"
}
