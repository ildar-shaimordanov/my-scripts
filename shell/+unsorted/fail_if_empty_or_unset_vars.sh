# +++
#
# Check variables exist and fail if any is empty or unset
#
# Usage
#     fail_if_empty_or_unset_vars VARLIST
#
# Example
#     X=foo
#     fail_if_empty_or_unset_vars X Y Z
#
# Results
#     ./zzz: line 5: Y: Empty or unset variable
#
# ---

fail_if_empty_or_unset_vars() {
	# shellcheck disable=SC2016
	eval "$( printf ': "${%s:?Empty or unset variable}" ; ' "$@" )"
}
