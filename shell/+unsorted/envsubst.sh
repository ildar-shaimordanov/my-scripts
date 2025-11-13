# +++
#
# This function covers and expands functionality of the original
# utility. With no options the function takes a current environment and
# passes all found variables to the utility.
#
# ---

envsubst() {
	command envsubst "${@:-$( env | sed 's/=.*//; s/^/$/' )}"
}
