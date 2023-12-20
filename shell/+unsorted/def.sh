# +++
#
# Description
#
# POSIX-compatible way to define a shell function called `name` with
# the ability to display the function declaration which is stored in
# the `$DEF_name` variable.
#
# Usage
#
# Use any character sequence except a single quote character for the
# heredoc identifier (`DEF` in the example). The mandatory condition
# for the right function definition is disabling the variable and
# command substitution in the funtion body. It is achieved by quoting
# the identifier within the single quotes as it's shown in the example.
#
#     def name <<'DEF'
#     ...
#     DEF
#
# See also
#
# The idea was borrowed from this answer and modified for prettier usage:
# https://unix.stackexchange.com/a/268309/440611
#
#     defn() { code=$(cat) ; eval "${1}_code=\$code; $1() { $code; }" ; }
#
# ---

def() {
	eval "DEF_$1=\"$1() {
\$( cat )
}\" ; eval \"\$DEF_$1\""
}

# # More examples

# def xxx <<'DEF'
# 	printf '# %d\n' $#
# 	printf '> %s\n' "$@"
# 	cat - <<-TEXT
# 	Hello, world!
# TEXT
# DEF
#
# def invoke <<'.'
# 	echo "==== $@"
# 	"$@"
# .
#
# invoke command -v xxx
# invoke command -V xxx
# invoke type xxx
# invoke echo "$DEF_xxx"
# invoke xxx 1 "2 3" 4
