# +++
#
# Compare two files and and colorize the output
#
# Example:
#
#     cdiff DIR1 DIR2
#     vdiff DIR1 DIR2
#
# ---

# enable color support of diff
diff --color /dev/null /dev/null 2>/dev/null && {
	alias cdiff='diff --color=auto'
	vdiff() { diff --color=always "$@" | less -SR ; }
}
