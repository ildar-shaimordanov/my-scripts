# +++
#
# Print the full stack of execution contexts
#
# ---

ctrace() {
	set -- 0 ; while caller $1 ; do set -- $(( $1+1 )) ; done
}

# Insane version working without loops
#
# ctrace() {
# 	set -- 0 'caller $1 || return 0; eval "set -- $(( $1+1 )) \"\$2\"; $2"'
# 	eval "$2"
# }
