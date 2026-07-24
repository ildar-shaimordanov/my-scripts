# +++
#
# Count bits in integer values of various widths.
#
# Examples
#
#     # returns 3 (42 = binary 0010 1010)
#     count_bits_u8 42
#
#     # negative number returns 5, 13, 29, 61 (binary 1101 0110 and so on)
#     count_bits_u8  -42
#     count_bits_u16 -42
#     count_bits_u32 -42
#     count_bits_u64 -42
#
#     # returns 0 due to 8-bit truncation (256 becomes 0)
#     count_bits_u8  256
#
#     # returns 1 (256 in 16-bit range)
#     count_bits_u16 256
#
# ---

count_bits_u8() {
	set -- $((  $1 & 0xff ))
	set -- $(( ($1 & 0x55) + (($1 >> 1) & 0x55) ))
	set -- $(( ($1 & 0x33) + (($1 >> 2) & 0x33) ))
	set -- $(( ($1 & 0x0f) + (($1 >> 4) & 0x0f) ))
	echo "$1"
}

count_bits_u16() {
	set -- $((  $1 & 0xffff ))
	set -- $(( ($1 & 0x5555) + (($1 >> 1) & 0x5555) ))
	set -- $(( ($1 & 0x3333) + (($1 >> 2) & 0x3333) ))
	set -- $(( ($1 & 0x0f0f) + (($1 >> 4) & 0x0f0f) ))
	set -- $(( ($1 & 0x00ff) + (($1 >> 8) & 0x00ff) ))
	echo "$1"
}

count_bits_u32() {
	set -- $((  $1 & 0xffffffff ))
	set -- $(( ($1 & 0x55555555) + (($1 >>  1) & 0x55555555) ))
	set -- $(( ($1 & 0x33333333) + (($1 >>  2) & 0x33333333) ))
	set -- $(( ($1 & 0x0f0f0f0f) + (($1 >>  4) & 0x0f0f0f0f) ))
	set -- $(( ($1 & 0x00ff00ff) + (($1 >>  8) & 0x00ff00ff) ))
	set -- $(( ($1 & 0x0000ffff) + (($1 >> 16) & 0x0000ffff) ))
	echo "$1"
}

count_bits_u64() {
	set -- $((  $1 & 0xffffffffffffffff ))
	set -- $(( ($1 & 0x5555555555555555) + (($1 >>  1) & 0x5555555555555555) ))
	set -- $(( ($1 & 0x3333333333333333) + (($1 >>  2) & 0x3333333333333333) ))
	set -- $(( ($1 & 0x0f0f0f0f0f0f0f0f) + (($1 >>  4) & 0x0f0f0f0f0f0f0f0f) ))
	set -- $(( ($1 & 0x00ff00ff00ff00ff) + (($1 >>  8) & 0x00ff00ff00ff00ff) ))
	set -- $(( ($1 & 0x0000ffff0000ffff) + (($1 >> 16) & 0x0000ffff0000ffff) ))
	set -- $(( ($1 & 0x00000000ffffffff) + (($1 >> 32) & 0x00000000ffffffff) ))
	echo "$1"
}
