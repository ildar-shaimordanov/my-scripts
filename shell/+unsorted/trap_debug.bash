# +++
#
# Debugging in bash
#
# Example:
#
# ```shell
# set -T # debug functions as well
# trap trap_debug DEBUG
# ```
#
# How to use it without function
#
# ```shell
# trap 'printf "# $LINENO: $BASH_COMMAND" >&2' DEBUG
# ```
#
# Based on the idea published here:
# https://www.cyberforum.ru/blogs/1976142/10017.html
#
# Almost the same version (with some ligfht modifications):
#
# ```shell
# trap 'echo "# $LINENO: $BASH_COMMAND" >&2 ; read' DEBUG
# ```
#
# ---

trap_debug() (
	# Run in subshell
	set +o xtrace verbose
	printf "# $( caller 0 ): $BASH_COMMAND" >&2
	read
)
