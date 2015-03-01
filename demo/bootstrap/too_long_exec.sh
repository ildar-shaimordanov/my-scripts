#!/bin/bash

. ./bootstrap.sh

# Capture too long execution
(
	start="$( date "+%Y/%m/%d %H:%M:%S" )"
	sleep 3
	error "Too long running since $start"
	kill -TERM -$$
) &

onExit 'info "================" ; ps -ef | grep $$'

count=1000000
sleep=5

while [ $count -gt 0 ]
do
	(( count-- ))
	info "$count: sleeping for $sleep seconds"
	sleep $sleep
	#find / >/devnull
done

info "Finish!"

# EOF
