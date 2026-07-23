# +++
#
# Convert a pre-validated netmask to a network prefix
#
# Examples
#
#     # result to 24
#     netmask_to_prefix 255.255.255.0
#
# ---

netmask_to_prefix() ( # run in subshell
	# netmask -> a b c d
	IFS=. read -r a b c d <<-!
	$1
	!

	# a b c d -> netmask_int (u32)
	set -- $(( ((a * 256 + b) * 256 + c) * 256 + d ))

	# count bits in u32 using bitwise operations
	set -- $(( ($1 & 0x55555555) + (($1 >>  1) & 0x55555555) ))
	set -- $(( ($1 & 0x33333333) + (($1 >>  2) & 0x33333333) ))
	set -- $(( ($1 & 0x0f0f0f0f) + (($1 >>  4) & 0x0f0f0f0f) ))
	set -- $(( ($1 & 0x00ff00ff) + (($1 >>  8) & 0x00ff00ff) ))
	set -- $(( ($1 & 0x0000ffff) + (($1 >> 16) & 0x0000ffff) ))
	echo "$1"
)

# +++
#
# Convert a network prefix to a netmask
#
# Examples
#
#     # result to 255.255.255.0
#     prefix_to_netmask 24
#
#     # result to 0.0.0.0
#     prefix_to_netmask 0
#
#     # result to 255.255.255.355
#     prefix_to_netmask 32
#
# ---

prefix_to_netmask() {
	# prefix -> netmask_int
	set -- $(( (0xffffffff >> $1) ^ 0xffffffff ))

	# netmask_int -> a b c d
	set -- \
		$(( ($1 >> 24) & 0xff )) \
		$(( ($1 >> 16) & 0xff )) \
		$(( ($1 >>  8) & 0xff )) \
		$((  $1        & 0xff ))

	echo "$1.$2.$3.$4"
}
