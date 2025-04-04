# +++
#
# Report time consumed by command execution.
#
# Example:
#
# ```shell
# timer watch sleep 10
# ```
#
# ---

timer() (
	# run in subshell
	# disable error trace in functions
	set +o errtrace

	date -Ins
	time "$@"
	date -Ins
)
