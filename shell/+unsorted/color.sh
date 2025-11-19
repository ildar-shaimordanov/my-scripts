# +++
#
# Use symbolic names of colors like COLOR to colorize the COMMAND output.
# It expects the variables named as COLOR_*.
#
# Usage
#
#     color COLOR COMMAND [ARGUMENTS]
#
# Example 1
#
#     # Examples of colors
#     COLOR_RED="\e[0;31m"
#     COLOR_YELLOW="\e[0;33m"
#     COLOR_GREEN="\e[0;32m"
#
#     # Display colored texts using color names
#     color RED    echo STOP
#     color YELLOW echo WAIT
#     color GREEN  echo WALK
#
# Example 2
#
#     # Display a colored text using a color code
#     color "\e[0;34m" echo Blue sky
#
# ---

color() (
	# run in subshell to keep the caller scope clean

	# suppress debug and immediate exit on error
	set +o xtrace
	set +o errexit

	[ $# -ge 2 ] || return 0

	unset color

	case "$1" in
	"\e["* | "\033["* | "\x1"[bB]"["* | "\u001"[bB]"["* | "$( printf "\033" )["* )
	# No any wants for insane support of the strings matching any of
	# \u0{0,2}1[bB], \U0{0,8}1[bB]
		color="$1"
		;;
	[A-Za-z0-9_]* )
		eval color="\${COLOR_$1:-}"
		;;
	esac

	# shellcheck disable=SC2059
	[ "${#color}" -gt 0 ] && printf -- "$color"

	shift
	"$@"
	result=$?

	# shellcheck disable=SC2059
	[ "${#color}" -gt 0 ] && printf -- "${COLOR_RESET:-\033[0m}"

	return $result
)
