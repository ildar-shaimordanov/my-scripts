# +++
#
# Use symbolic names of colors like COLOR to colorize the COMMAND output.
# It expects the variables named as COLOR_*.
#
# Usage
#
#     color COLOR COMMAND [ARGUMENTS]
#
# Example
#
#     # Examples of colors
#     COLOR_RED="\e[0;31m'
#     COLOR_YELLOW="\e[0;33m'
#     COLOR_GREEN="\e[0;32m'
#     ...
#     # Display text in green
#     color GREEN echo I am fine
#
# ---

color() (
	# run in subshell to keep the caller scope clean

	# suppress debug
	set +o xtrace

	[ $# -ge 2 ] || return 0

	eval color="\${COLOR_$1:-}"

	if [ -n "$color" ] ; then printf "$color" ; fi

	shift
	"$@"
	result=$?

	if [ -n "$color" ] ; then printf "${COLOR_RESET:-\033[0m}" ; fi

	return $result
)
