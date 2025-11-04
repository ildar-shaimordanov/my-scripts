# +++
#
# A function for using in an interactive shell. It supports `diff`
# options from command line and `less` options via the `LESS` variable.
#
# There three versions:
#
# * a simple wrapper around `diff` and `less`
# * the same supporting the modern `--color` option
# * an `eval`-command constructing one of two above
#   (useful for `.bashrc` as an example)
#
# ---

vdiff() {
	diff "$@" | less "${LESS:--SR}"
}

vdiff() {
	diff --color=always "$@" | less "${LESS:--SR}"
}

eval 'vdiff() { diff '"$(
	diff --color=lways /dev/null /dev/null 2>/dev/null \
	&& echo '--color=always'
)"' "$@" | less "${LESS:--SR}" ; }'
