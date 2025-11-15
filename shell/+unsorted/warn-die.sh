# +++
#
# Useful functions for writing to the standard error and exiting with
# non-zero exit code. There are two versions per each function:
#
# * basic, available in the major of shells
# * bash-compatible, supporting the `caller` builtin
#
# Examples:
#
#     # to warn about something
#     warn "Something happened but continue execution."
#
#     # to stop execution when something goes wrong
#     die "Something critical happened. Exiting."
#
#     # stop execution with the exit code = 42
#     DIE=42 die "what a question, what an answer."
#
# ---

# basic

warn() {
	>&2 echo "$@"
}

die() {
	>&2 echo "$@"
	exit "${DIE:-1}"
}

# bash

warn() {
	>&2 echo "${@:-Warned at $( caller 0 )}"
}

die() {
	>&2 echo "${@:-Died at $( caller 0 )}"
	exit "${DIE:-1}"
}
