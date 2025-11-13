# +++
#
# Print a stack of execution contexts
#
# Usage:
#     ctrace [EXPR]
#
# Without EXPR, returns a full stacktrace. When EXPR is defined, it
# means how many call frames to skip before printing a stacktrace.
#
# ---

ctrace() {
	set -- "${1:-0}" ; while caller "$1" ; do set -- $(( $1+1 )) ; done
}

# Insane version working without loops
#
# ctrace() {
# 	set -- "${1:-0}" 'caller $1 || return 0; eval "set -- $(( $1+1 )) \"\$2\"; $2"'
# 	eval "$2"
# }
