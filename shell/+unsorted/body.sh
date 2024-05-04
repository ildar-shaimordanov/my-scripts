# +++
#
# Print the first line of STDIN as an output header and continue executing
# the provided command.
#
# Example:
#
#     ps -ef | body grep $USER
#
# ---

body() {
	IFS= read -r HEAD
	printf '%s\n' "$HEAD"
	"$@"
}
