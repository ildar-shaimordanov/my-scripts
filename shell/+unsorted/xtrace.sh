# +++
#
# Execution tracing for a specific command
#
# Example
#
#     # Commenting the next line turns debugging off
#     xtrace \
#     some-command --with --numerous --options and some parameters
#
# ---

xtrace() {
	[ $# -gt 0 ] && [ "$1" != "\\" ] || return 0
	set -x
	"$@"
	set +x
}
