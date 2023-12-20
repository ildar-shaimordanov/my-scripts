# +++
#
# Extract the common leading substring from the input strings
#
# Example: print "qwe"
#
#     printf '%s\n' qwerty qweasd | prefixtrude
#
# ---

prefixtrude() {
	sed ':a; N; s/\(.*\).*\n\1.*/\1/; ta'
}
