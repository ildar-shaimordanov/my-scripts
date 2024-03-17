# +++
#
# Create a new session named as "$1" if it doesn't exist and attach to it.
# Additional options and commands are applicable.
#
# Any other clients attached to this session will be detached, if the
# `TMUX_DETACH` variable is set to any non-empty value.
#
# Example: run the session "my_work"
#
#     tmuxa my_work
#
# ---

tmuxa() {
	tmux has-session -t "$1" 2>/dev/null \
	|| tmux new-session -s "$@"

	tmux attach-session -t "$1" "${TMUX_DETACH:+-d}"
}
