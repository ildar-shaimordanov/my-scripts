# +++
#
# Repeat the given string the particular number of times
#
# * `$1` - string
# * `$2` - number or repetition
#
# This version uses a lot of bashisms
#
# Example: print 10 "#"
#
#     rep "#" 10
#
# ---

rep() {
	local s
	printf -v s "%${2}s"
	printf '%s' "${s// /$1}"
}
