# +++
#
# Repeat the given string the particular number of times
#
# * `$1` - string
# * `$2` - number or repetition
#
# There are three implementations:
#
# * bash only, full of bashisms
# * POSIX-compliant
# * POSIX-compliant, safe and awful
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

rep() {
	printf "%${2}s" \
	| sed "s/ /${1}/g"
}

rep(){
	printf "%${2}s" \
	| sed "s/ /$(
		echo "$1" \
		| sed 's/[\\\/]/\\&/g'
	)/g"
}
