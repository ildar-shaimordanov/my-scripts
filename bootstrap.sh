#!/bin/bash

###########################################################################
#
# bootstrap.sh
#
###########################################################################
#
# Script for trapping and processing errors and logging messages
#
# Usage
#
# . bootstrap.sh
# . "$(dirname "$0")/bootstrap.sh"
# . "${0%/*}/bootstrap.sh"
#
###########################################################################
#
# Exports
#
# Functions
#
# catecho
# logMsg
# debug
# info
# notice
# warn
# die
# error
# assert
# echoOut
# echoErr
# onExit
#
# The script identifying constants
#
# $ME
# $MYDIR
#
# Common variables
#
# $TMPDIR
# $TEMPDIR
# $LOGDIR
#
# Error code constants
#
# $E_SUCCESS
# $E_ERROR
# $E_DIED
#
###########################################################################
#
# Imports
#
# Controlling variables
#
# $LOGFILE_NAMEAUGMENT
# $SCRIPT_OUTPUT_STDOUT
# $SCRIPT_OUTPUT_PROLOG
#
###########################################################################
#
# Internally used definitions
#
# Functions
#
# __trapError
# __trapExit
#
# Variables
#
# $LOCKFILE
# $LOGFILE
# $ONEXIT
#
###########################################################################

# $ME refers to a script name or the custom defined name. 
readonly ME="${ME:-${0##*/}}"

# $MYDIR refers to a directory where the script is located. 
readonly MYDIR="${0%/*}"

# $TMPDIR refers to a directory for storing temporary results. All these 
# files will be deleted by the script automatically. $TEMPDIR is used as 
# a synonym for $TMPDIR. Avoid difference between both of them. 
if [ ! -z "$TMPDIR" ]
then
	TEMPDIR="$TMPDIR"
elif [ ! -z "$TEMPDIR" ]
then
	TMPDIR="$TEMPDIR"
else
	TMPDIR="$MYDIR/tmp/$ME"
	TEMPDIR="$TMPDIR"
fi
readonly TMPDIR
readonly TEMPDIR

# $LOGDIR refers to a directory where the script stores a log file
readonly LOGDIR="${LOGDIR:-$MYDIR/log}"

# $LOGFILE_NAMEAUGMENT is the command that will be eval'd to the string to 
# append to the file name (excluding the path and the extension).
readonly LOGFILE_NAMEAUGMENT="$( ${LOGFILE_NAMEAUGMENT} )"

# $LOGFILE refers to the location of the script's log file
readonly LOGFILE="${LOGFILE:-$LOGDIR/$ME$LOGFILE_NAMEAUGMENT.log}"


# Error codes
readonly E_SUCCESS=0	# The script is terminated successfully
readonly E_ERROR=1	# Some error has happened
readonly E_DIED=255	# The script died


# Logging control
readonly SCRIPT_OUTPUT_STDOUT
readonly SCRIPT_OUTPUT_PROLOG

###########################################################################

# Prints a message or outputs a file content. it pretends to be working 
# similar to "cat" and "echo" depending on its arguments.
# 1. An empty message or the single string "-". It means to read from 
#    a standard input or a output of the previous command in a pipe. 
# 2. Two parameters exactly. The first one is the string "-" and the 
#    second one is a readable file. It means to display the content of 
#    the file. 
# 3. In other cases the function considers arguments "as is" and prints
#    out in usual way. 
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function catecho()
{
	if [ ! -t 0 -a \( $# -eq 0 -o $# -eq 1 -a "$1" == "-" \) ]
	then
		# command | catecho
		# command | catecho -
		cat -
	elif [ $# -eq 2 -a "$1" == "-" -a -r "$2" -a ! -d "$2" ]
	then
		# catecho - filename
		# catecho - <(command)
		cat "$2"
	else
		# catecho message
		# catecho "message"
		echo "$@"
	fi
}

# Displays a log message prepenting in the front of it a log level. 
# The first argument has the specific meaning considered as a log level. 
# The rest of arguments are considered as the message to be displayed but 
# there are a few features. 
#
# See the details description of the function "catecho"
#
# @param	{string}	A log level
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function logMsg()
{
	local level="$1"
	shift

	if [ "$SCRIPT_OUTPUT_STDOUT" == "1" ]
	then
		catecho "$@"
	else
		catecho "$@" \
		| sed "s|^|$(date '+%Y/%m/%d %H:%M:%S') ($$) ($level): |"
	fi
}

# Displays a DEBUG message
#
# See the details description of the function "logMsg"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function debug()
{
	logMsg "DEBUG" "$@"
}

# Displays a INFO message
#
# See the details description of the function "logMsg"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function info()
{
	logMsg "INFO" "$@"
}

# Displays a NOTICE message
#
# See the details description of the function "logMsg"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function notice()
{
	logMsg "NOTICE" "$@"
}

# Displays a WARNING message
#
# See the details description of the function "logMsg"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function warn()
{
	logMsg "WARNING" "$@"
}

###########################################################################

# Displays a message marked as CRITICAL and terminates a script with the 
# exit code=$E_DIED. 
#
# If the provided message is empty the string "Died" will be printed.
#
# If it is required to display an output of a previous command in a pipe 
# use the string "-" as the special parameter pointing to read from the pipe. 
#
# See the details description of the function "logMsg"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function die()
{
	# If a message is empty then assign it to the default value "Died"
	logMsg "CRITICAL" "${@:-Died}" >&2
	exit $E_DIED
}

# Displays a ERROR message and returns an error code of the last executed 
# command. This function is similar to "die" but doesn't exit the script. 
# This allows to output a log message and gives to the main script a 
# possibility to capture the error. 
#
# See the details description of the functions "logMsg", "die"
#
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function error()
{
	local ERRORCODE="$?"
	[ "$ERRORCODE" == "0" ] && ERRORCODE="$E_ERROR"

	logMsg "ERROR" "${@:-Error=$ERRORCODE}" >&2

	return $ERRORCODE
}

# Displays a message using a provided log level and terminates a script 
# with an exit code of the command that has led to an error or $E_ERROR. 
#
# If the message os empty the message "Error=$ERRORCODE" will be printed.
#
# If it is required to display an output of a previous command in a pipe 
# use the string "-" as the special parameter pointing to read from the pipe. 
#
# See the details description of the function "logMsg"
#
# @param	{function}	A function (debug, info, notice, warn)
# @param	{string}	A message, optional
# @param	{string}	A filename, optional
function assert()
{
	local ERRORCODE="$?"
	[ "$ERRORCODE" == "0" ] && ERRORCODE="$E_ERROR"

	case "$1" in
	debug|info|notice|warn)
		# The valid method has been provided
		# Do nothing, just continue
		;;
	*)
		die "Illegal assertion method: '$1'"
		;;
	esac

	# If a message is empty then assign it to the default value
	[ $# -eq 1 ] && set -- "$1" "Error=$ERRORCODE"

	# Invoke a printing function with a list of arguments, e.g.:
	# error "message"
	"$@"

	exit $ERRORCODE
}

###########################################################################

# Prints out a stack trace to STDOUT. 
# Use one of the logging function to redirect output to a log file. 
function stacktrace()
{
	local FRAME=0
	while caller $FRAME
	do
		((FRAME++))
	done
}

###########################################################################

# Writes arguments to the original STDOUT. 
#
# @param	{string}	A text
function echoOut()
{
	echo $@ >&11
}

# Writes arguments to the original STDERR. 
#
# @param	{string}	A text
function echoErr()
{
	echo $@ >&12
}

###########################################################################

# $ONEXIT is used internally to store s used-defined program code.
declare -a ONEXIT

# Adds a custom code to be executed on exit. 
#
# @param	{code}	A shell code
function onExit()
{
	[ $# -eq 0 ] && return

	local n="${#ONEXIT[@]}"
	ONEXIT[$n]="$@"
}

###########################################################################

mkdir -p "$LOGDIR" || die "Cannot create the directory $LOGFIR"
mkdir -p "$TMPDIR" || die "Cannot create the directory $TMPDIR"

[ "$SCRIPT_OUTPUT_STDOUT" == "1" ] || {
	# Assign new descriptors for STDOUT and STDERR respectively
	exec 11>&1 12>&2

	# Redirect STDOUT and STDERR to the $LOGFILE
	exec >>"$LOGFILE" 2>&1
}

# Traps the exit signals: HUP (1), INT (2), QUIT (3), TERM (15), ERR
# Prints out a diagnostic message and triggers an exit of a script.
# It is called by shell automatically when the specific signal arises. 
#
# @param	{number}	An exit code from the last command
# @param	{number}	A line number of the last command
function __trapError
{
	local ERRORCODE="${1:-$?}"
	local ERRORLINE="${2:-$LINENO}"

	[ "$SCRIPT_OUTPUT_STDOUT" == "1" ] || {
		# Reopen STDOUT and STDERR to point to the $LOGFILE
		exec 1>&- 2>&-
		exec >>"$LOGFILE" 2>&1

		[ "$ERRORCODE" != "0" ] \
		&& error "Error Code=$ERRORCODE at Line Number=$ERRORLINE"
	}

	exit $ERRORCODE
}

# Walks through all processes, children of provided PID(s). Terminates them 
# passing to each child the SIGTERM signal beginning from the deepest ones 
# in the process tree. The topmost process(es) are stopped at the very end. 
# The "-" character eliminates termination of the topmost process(es). 
function __killTree()
{
	local top="$1"
	[ "$top" == "-" ] && eval set -- ${@:2}

	[ $# -eq 0 ] && return

	local ppid="${@}"
	local chld="$( pgrep -P ${ppid// /,} )"

	$FUNCNAME $( echo "$chld" | grep -vwf <( echo $ppid | tr ' ' \\n ) )

	[ "$top" == "-" ] && return

	kill $ppid 2>/dev/null
}

# Traps exit signal EXIT (0) and cleans up on exit.
# Removes the lock file, the FIFO file and temporary files and directories. 
# Calls custom codes from $ONEXIT if it is not empty. 
function __trapExit()
{
	local ERRORCODE="$?"

	# Kill all child processes
	__killTree - $$

	# Call user-defined on-exit codes
	for i in "${ONEXIT[@]}"
	do
		# Execute a user-defined on-exit code
		eval "$i"
	done

	# Clean up before exiting
	# Be sure that we remove items created by ourselves
	[ "$(cat "$LOCKFILE" 2>/dev/null)" == "$$" ] \
	&& rm -rf "$LOCKFILE" "$TMPDIR"

	[ "$SCRIPT_OUTPUT_STDOUT" == "1" ] || {
		# Print the epilog
		info "Exit Code=$ERRORCODE"

		# Restore the original STDOUT and STDERR
		exec 1>&11 11>&-
		exec 2>&12 12>&-
	}
}

# trap the script termination
trap '__trapError $? $LINENO' HUP INT QUIT TERM ERR
trap '__trapExit' EXIT

[ "$SCRIPT_OUTPUT_STDOUT" == "1" ] || {
	# Print the prolog
	info "${SCRIPT_OUTPUT_PROLOG:-==== $ME Starting ====}"
}

# $LOCKFILE refers to the location of the script's lock file
readonly LOCKFILE="${LOCKFILE:-$TMPDIR/$ME.lock}"

# Check for parallel execution and exit if it's so
if ! ( set -o noclobber; echo "$$" >"$LOCKFILE" ) 2>/dev/null
then
	# Probably another instance of the script is about to remove
	# the lock file -- exit, we're still locked
	OTHERPID="$(cat "$LOCKFILE" 2>/dev/null)" \
	|| die "Script is still running: PID=$OTHERPID"

	# Lock is valid and the $OTHERPID process is active --
	# exit, we are locked
	kill -0 "$OTHERPID" >/dev/null 2>&1 \
	&& die "Script is already running: PID=$OTHERPID"

	# The lock file is stale
	# Remove it and restart ourselves
	debug "Removing stale lock of non-existant PID=$OTHERPID"
	rm -rf "$LOCKFILE" "$PIPEFILE"

	debug "Restarting myself"
	exec "$0" "$@"
fi

###########################################################################

# See the following links for examples how to trap signals
# http://www.fvue.nl/wiki/Bash:_Error_handling
# http://wiki.bash-hackers.org/howto/mutex
# http://www.linuxjournal.com/content/use-bash-trap-statement-cleanup-temporary-files
#
# See the following links for the description how to perform I/O redirections
# http://phaq.phunsites.net/2010/11/22/trap-errors-exit-codes-and-line-numbers-within-a-bash-script/
# http://www.catonmat.net/blog/bash-one-liners-explained-part-three/
# http://tldp.org/LDP/abs/html/io-redirection.html
# http://tldp.org/LDP/abs/html/ioredirintro.html

###########################################################################

#EOF
