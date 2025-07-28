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
#     COLOR_RED="\e[0;31m"
#     COLOR_YELLOW="\e[0;33m"
#     COLOR_GREEN="\e[0;32m"
#     ...
#     # Display text in green (using color name)
#     color GREEN echo I am fine
#     ...
#     # display text in green (using color code)
#     color "\e[0;32m" echo I am fine too
#
# ---

color() (
	# run in subshell to keep the caller scope clean

	# suppress debug
	set +o xtrace

	[ $# -ge 2 ] || return 0

	case "$1" in
	"\e["* | "\033["* | "\x1b["* | "\x1B["* | "$( printf "\033" )["* )
		color="$1"
		;;
	* )
		eval color="\${COLOR_$1:-}"
		;;
	esac

	# shellcheck disable=SC2059
	if [ -n "$color" ] ; then printf "$color" ; fi

	shift
	"$@"
	result=$?

	# shellcheck disable=SC2059
	if [ -n "$color" ] ; then printf "${COLOR_RESET:-\033[0m}" ; fi

	return $result
)
