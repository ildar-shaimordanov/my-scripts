# +++
#
# The function tries to gather an IPv4 address for a specified interface.
#
# Example:
#
#     $ get_ipv4 lo
#     127.0.0.1
#
# There are three implementations. See for details in source.
#
# ---

# Version 1
# It uses `ip link show`, `ip -o -4 addr show` and builtin `read`
# reading data in subshell.

get_ipv4() {
	ip link show "$1" >/dev/null \
	&& ip -o -4 addr show dev "$1" | {
		# shellcheck disable=SC2034
		IFS="$IFS/" read -r id name family ip rest || {
			>&2 echo "No IPv4 configured for \"$1\"."
			return 1
		}
		echo "$ip"
	}
}

# Version 2
# It uses `ip -o -4 addr show` only storing data to internal variable,
# and builtin `echo | read`. Everything is runing in subshell.

get_ipv4() (
	get_ipv4="$( ip -o -4 addr show dev "$1" )" || return 1

	[ ${#get_ipv4} -gt 0 ] || {
		>&2 echo "No IPv4 configured for \"$1\"."
		return 1
	}

	# shellcheck disable=SC2034
	echo "$get_ipv4" | {
		IFS="$IFS/" read -r id name family ip rest
		echo "$ip"
	}
)

# Version 2
# It uses `ip -o -4 addr show` only storing data to internal variable,
# and builtin `read` reading data from heredoc. Everything is runing
# in subshell.

get_ipv4_() (
	get_ipv4="$( ip -o -4 addr show dev "$1" )" || return 1

	[ ${#get_ipv4} -gt 0 ] || {
		>&2 echo "No IPv4 configured for \"$1\"."
		return 1
	}

	# shellcheck disable=SC2034
	IFS="$IFS/" read -r id name family ip rest <<-!
	$get_ipv4
	!

	echo "$ip"
)
