# +++
#
# Print a terminal size in columns or lines.
#
# Don't rely on the variables `COLUMNS` and `LINES` because POSIX or
# minimalistic shells like dash don't update them automatically every
# time a terminal is resized.
#
# More details about these variables are given in this page:
# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
#
# ---

tty_cols() {
	command -v stty >/dev/null \
	&& stty size </dev/tty | ( read -r l c ; echo "$c" ) \
	&& return

	command -v tput >/dev/null && tput cols && return
	command -v ttysize >/dev/null && ttysize w && return
}

tty_lines() {
	command -v stty >/dev/null \
	&& stty size </dev/tty | ( read -r l c ; echo "$c" ) \
	&& return

	command -v tput >/dev/null && tput lines && return
	command -v ttysize >/dev/null && ttysize h && return
}
