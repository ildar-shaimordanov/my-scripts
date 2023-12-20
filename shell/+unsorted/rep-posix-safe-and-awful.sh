# +++
#
# Repeat the given string the particular number of times
#
# * `$1` - string
# * `$2` - number or repetition
#
# POSIX-compliant version, safe and awful
#
# Example: print 10 "#"
#
#     rep "#" 10
#
# ---

rep(){
	printf "%${2}s" \
	| sed "s/ /$(
		echo "$1" \
		| sed 's/\\/\\\\/g; s/\//\\\//g'
	)/g"
}
