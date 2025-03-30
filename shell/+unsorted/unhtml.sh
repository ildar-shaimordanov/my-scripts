# +++
#
# Remove all styles, scripts and html comments totally, strip html tags
# and leave a naked text only.
#
# ---

unhtml() {
	sed '
		s/<!--</</g
		s/</\n</g
		s/>/>\n/g
	' \
	| sed '
		/<style[^<>]*>/,/<\/style>/d
		/<script[^<>]*>/,/<\/script>/d
		/<!--/,/-->/d
		/<[^<>]*>/d
		/^\s*$/d
		s/\(&nbsp;\)\1*/ /g
	'
}
