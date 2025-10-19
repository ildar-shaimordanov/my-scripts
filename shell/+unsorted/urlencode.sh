# +++
#
# Urlencode any string on pure POSIX shell with no grep/sed/jq.
#
# urlencode "P@ssw0rd" # results to "P%40ssw0rd"
#
# This implementation is based on these two brilliant ideas:
# * https://stackoverflow.com/a/10660730
# * https://blog.dnmfarrell.com/post/how-to-split-a-string-in-posix-shell/
#
# ---

urlencode() (
	LANG=C
	OPTIND=1
	while getopts ':' arg "-$1"
	do
		case "$OPTARG" in
		[-_.~a-zA-Z0-9]	) printf '%s' "$OPTARG" ;;
		*		) printf '%%%02x' "'${OPTARG:-:}" ;;
		esac
	done
)
