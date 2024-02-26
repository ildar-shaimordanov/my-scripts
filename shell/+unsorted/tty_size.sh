# +++
#
# Print a terminal size in columns or lines.
#
# Don't rely on the variables `COLUMNS` and `LINES` because POSIX
# or minimalistic shells like dash update them every time a terminal
# is resized.
#
# More details about these variables are given in this page:
# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
#
# ---

tty_cols() {
	command -v tput >/dev/null && tput cols && return
	command -v ttysize >/dev/null && ttysize w && return
	command -v stty >/dev/null && stty size | ( read -r l c ; echo "$c" ) && return
}

tty_lines() {
	command -v tput >/dev/null && tput lines && return
	command -v ttysize >/dev/null && ttysize h && return
	command -v stty >/dev/null && stty size | ( read -r l c ; echo "$l" ) && return
}
