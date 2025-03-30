# +++
#
# Sudo and forward X11 settings from the current user to another one.
#
# Based on this thread:
# https://unix.stackexchange.com/questions/476290/x11-forwarding-does-not-work-if-su-to-another-user
#
# ---

sudo_x11() {
	sudo -iu "$1" sh -c "xauth add $( xauth list $DISPLAY ); exec bash"
}
