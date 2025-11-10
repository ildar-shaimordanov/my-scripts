# =========================================================================

# How to use:
#
# url-probe -f example.sh

# =========================================================================

# The better place for these variable is an ENV file which is loaded
# with the command line option `-F`.

username=''
password=''

base_url=''

# =========================================================================

# Connect to the `/api/v1/auth_service/token` endpoint with the username
# and password to gather a token. The token is stored in the variable
# which will be used further implicitly.

PROBE_URL_HEADERS['Authorization']="Bearer $(
	#PROBE_URL_HEADERS['Content-Type']='application/x-www-form-urlencoded'
	probe_url -X POST "$base_url/api/v1/auth_service/token" \
	-F "username=$username" -F "password=$password" \
	| jq -r '.authorization_token'
)"

# =========================================================================

# Using the token received on the previous step do the next request to
# receive or post data. We don't care about providing addition headers
# (auth.token in this case) because it has already been defined and will
# be used implicitly.

probe_url "$base_url/api/v1/computers/" \
| jq -r '.content[].hostname' \

# =========================================================================

# EOF
