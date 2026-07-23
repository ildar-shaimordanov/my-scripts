# +++
#
# Count bits in an integer value.
#
# Examples
#
#     # result to 3
#     count_bits_u8 11
#
#     # result to 7, 15, 31 and 63, respectively
#     count_bits_u8  -2
#     count_bits_u16 -2
#     count_bits_u32 -2
#     count_bits_u64 -2
#
#     # result to 0 due to out of 8 bits
#     count_bits_u8  256
#
#     # result to 1
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

count_bits_u8 768

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
