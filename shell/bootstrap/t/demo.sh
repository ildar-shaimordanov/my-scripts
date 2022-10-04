#!/bin/bash

###########################################################################

# $ME refers to the name of the current file. Another value in $ME allows 
# to run the script with another instance name to prevent concurrent 
# execution. 
# Uncomment the following line to see changes.
#ME="$( basename "$0" .sh )"

# By default, the $LOGFILE refers to $LOGDIR/$ME.log. That means all log 
# entries will appear in the single logfile. To change this behavior 
# the $LOGFILE_NAMEAUGMENT variable provides the shell code to produce the 
# string that will be appended to the name of the logfile. 
# Uncomment the following line for logging to $LOGDIR/$ME_yymmdd.log. 
#LOGFILE_NAMEAUGMENT='date +_%y%m%d%H%M'

# The main goal of the sourced script is to clean up safely all the 
# temporary stuff by the script produced during its execution and log to 
# the logfile all the script activity on the background. Nevertheless, it 
# is possible to return all output to the terminal. 
# Just uncomment the following line. 
#SCRIPT_OUTPUT_STDOUT=1

# All temporary items under $TMPDIR will be removed automatically on 
# finishing the script. To keep them (in debugging purpose) in their place 
# uncomment the next line.
#DEBUG=1

###########################################################################

# This line should be the first statement in the script (excepting the 
# code above because it does control over the actual script). Other 
# scripts can be sourced after this one. Only in this case we are able to 
# keep control the script execution including other files. 
. "${0%/*}/../bootstrap.sh"

###########################################################################

# Let's customize the script.

# Register the code to be invoked before script execution finishing. This 
# code will be run any time when the script execution stops.
onExit 'showDirs'
function showDirs()
{
	warn "These files will be removed automatically."
	[ -d "$TMPDIR" ] && ls -lt "$TMPDIR"

	warn "These files will not be removed."
	[ -d "$VARDIR" ] && ls -lt "$VARDIR"
}

# $VARDIR is the directory for storing something on the persistent basis.
VARDIR="$MYDIR/var/$ME"
mkdir -p "$VARDIR" || die "Unable to create directory $VARDIR."

###########################################################################

# After starting the script we can log our current environment.
cat <<HEADER | info
ME:     $ME ($$)
VARDIR: $VARDIR
TMPDIR: $TMPDIR
LOGDIR: $LOGDIR
HEADER

# Starting the main loop.
count=5
sleep=2

while [ $count -gt 0 ]
do
	(( count-- ))

	dstname="$RANDOM"
	if [ $(( $dstname % 2 )) == 0 ]
	then
		dstname="$TMPDIR/$dstname"
	else
		dstname="$VARDIR/$dstname"
	fi

	info "Creating file $dstname."
	touch "$dstname" || die "Unable to create file $dstname."

	info "Sleeping for $sleep seconds."
	sleep $sleep
done

debug "The script is about to finish."

###########################################################################

# EOF
