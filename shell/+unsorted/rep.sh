# +++
#
# Repeat the given string the particular number of times
#
# * `$1` - string
# * `$2` - number or repetition
#
# There are four implementations:
#
# * bash only, full of bashisms
# * POSIX-compliant
# * POSIX-compliant, insane use of awk
# * POSIX-compliant, awful
#
# Example:
#
#     $ rep '#' 5
#     #####
#
# ---

# bash only

rep() {
	local s
	printf -v s "%${2}s"
	printf '%s' "${s// /$1}"
}

# POSIX-compliant

rep() {
	printf "%${2}s" \
	| awk -v s="$1" -v RS='' -v ORS='' '{ gsub(" ", s) } 1'
}

# POSIX-compliant, insane use of awk

rep() {
	awk \
	-v char="$1" \
	-v width="$2" \
	-v RS='' \
	-v ORS='' \
	'BEGIN { s = sprintf("%" width "s", ""); gsub(" ", char, s); print s }'
}

# POSIX-compliant, awful

rep() {
	printf "%${2}s" \
	| sed "s/ /$(
		echo "$1" \
		| sed 's/[\\\/]/\\&/g'
	)/g"
}
