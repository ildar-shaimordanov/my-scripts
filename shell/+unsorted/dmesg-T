#!/bin/sh

# +++
#
# Emulate `dmesg -T` to print human-readable timestamps.
#
# Answered in this thread
# https://stackoverflow.com/q/27503386/3627676
#
# ---

awk -v UPTIME="$( cut -d' ' -f1 /proc/uptime )" '
BEGIN {
	STARTTIME = systime() - UPTIME
}
match($0, /^\[[^\[\]]*\]/) {
	s = substr($0, 2, RLENGTH - 2) + STARTTIME;
	s = strftime("%a %b %d %H:%M:%S %Y", s);
	sub(/^\[[^\[\]]*\]/, "[" s "]", $0);
	print
}
'
