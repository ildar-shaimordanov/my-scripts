# +++
#
# A colon separated lists of patterns used to decide which command lines
# should be shrinked until the length of the matched pattern or skipped
# completely while output. Each pattern is anchored to the beginning
# of the command line and assumed implicitly is followed by the space
# character.
#
# Variables
#
# * `$TRAP_IGNORE`
# * `$TRAP_SHRINK`
#
# These variables can be useful to prevent duplicates of those commands
# which usually echoing long texts. The predefined command are `echo`,
# `printf`, `cat -` `cat  `. The two last patterns match to the command
# usually used to output long texts in heredoc.
#
# Functions
#
# * `trap_debug`
#
# This function can be used at the beginning of the script or somewhere
# else to initialize DEBUG trap. It analyzes the $BASH_COMMAND variable,
# compares the invoked command with the patterns in the $TRAP_SHRINK
# and $TRAP_IGNORE and makes decision how to output the current shell
# command (shrink it or skip completely). Other commands mismatching to
# those patterns will be outputted after the `+` character. at the very
# beginning of the printed string.
#
# See also
#
# * https://unix.stackexchange.com/a/332639
# * https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fCOMMAND
# * https://www.gnu.org/software/bash/manual/bash.html#index-trap
#
# ---

TRAP_IGNORE="echo:printf:cat -:cat  "
TRAP_SHRINK="cat -:cat  "

trap_debug() (
	FRAME=0
	while caller $FRAME >/dev/null
	do
		((FRAME+=1))
	done

	printf -v INDENT "%${FRAME}s"
	INDENT="${INDENT// /+}"

	IFS=':'
	for n in $TRAP_SHRINK
	do
		[[ "$BASH_COMMAND" =~ ^$n" " ]] && {
			builtin echo "$INDENT $n..." >&2
			return
		}
	done

	for n in $TRAP_IGNORE
	do
		[[ "$BASH_COMMAND" =~ ^$n" " ]] && return
	done

	builtin echo "$INDENT $BASH_COMMAND $( caller 0 )" >&2
)

# trap trap_debug DEBUG
# 
# ps-grep() {
# 	ps -efW | grep "$1"
# }
# 
# call() {
# 	[ "$1" != "-" ] && title "$1"
# 	( set -x ; ${@:2} )
# }
# 
# title() {
# 	cat - <<HEADER
# 
# ========================
# $@
# 
# HEADER
# }
# 
# echos() (
# 	title "$@"
# )
# 
# set -T
# title "some text"
# 
# echos bla-bla
# echo "[$IFS]:[$INDENT]"
