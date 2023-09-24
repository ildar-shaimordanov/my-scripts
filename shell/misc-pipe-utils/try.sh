# +++
#
# Execute any command silently.
#
# Example:
#
#     try sleep 10
#
# ---

try() {
	[ $# -gt 0 ] || return 0
	command -v "$1" >/dev/null || return 127
	"$@"
}
