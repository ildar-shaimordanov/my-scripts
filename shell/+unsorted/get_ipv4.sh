# +++
#
# The function tries to gather an IPv4 address for a specified interface.
#
# Example:
#
#     $ get_ipv4 lo
#     127.0.0.1
#
# ---

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
