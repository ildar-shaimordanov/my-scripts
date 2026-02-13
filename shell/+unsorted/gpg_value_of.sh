gpg_value_of() {
	gpg --with-colons --list-public-keys "$2" 2>/dev/null \
	| awk -v rec_type="$1" -F: '$1 == rec_type { print $10; exit }'
}

# +++
#
# Extract some gpg values
#
#     # if the gpg key exists, it should return 'John Doe' as the same value
#     gpg_value_of uid 'John Doe'
#
#     # print a fingerprint for this gpg key
#     gpg_value_of fpr 'John Doe'
#
# ---
