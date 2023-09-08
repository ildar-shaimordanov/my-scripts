# Print the first line as header and execute the provided command
# Example: ps -ef | body grep $USER
body() {
	read -r HEAD
	echo "$HEAD"
	"$@"
}

# Execute any command silently
# Example: try sleep 10
try() {
	[ $# -gt 0 ] || return 0
	command -v "$1" >/dev/null || return 127
	"$@"
}
