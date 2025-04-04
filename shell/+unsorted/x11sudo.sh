# +++
#
# Enable X11 settings of the current user when `sudo`-ing to another one.
#
# Based on this thread:
# https://unix.stackexchange.com/questions/476290/x11-forwarding-does-not-work-if-su-to-another-user
#
# ---

x11sudo() {
	sudo -iu "$1" sh -c "xauth add $( xauth list $DISPLAY ); exec bash"
}
