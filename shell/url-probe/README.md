
# DESCRIPTION

Investigate URL in easier way.

# REQUIREMENTS

* bash 4.3+
* curl
* awk


# EQUIPMENT


## Functions for handling with URL


### `probe_url [OPTIONS]`

Prepares and handle a request using curl.

Under the hood collects all parameters in the following order: two
options controlling verbosity, `PROBE_CURL_OPTS`, `PROBE_URL_HEADERS`
and options passed by a user. This order ensures in major of cases that
curl will send correct headers and data with a proper method. Otherwise,
it's possible to fix some values in the known variables.

Curl verbosity is kept in a temporary file. This provides possibility
to print raw headers (with the `-v` option, the same as `curl -v` itself
does) or print them in pretty formatted mode (with the `-h` option).

Also a full command of curl invocation is printed with the `-h` option.


### `probe_url_print_cookie`

Collects all `Set-Cookie` headers, join their values and prints as a
single line. Internally it uses `probe_url_expose_headers`. However
it is safe because the function is invoked in subshell and it doesn't
affect on current values in the variables `PROBE_URL_*_HEADERS`.


### `probe_url_expose_headers [print-only]`

Reads a raw verbosity of the last curl invocation stored in a temporary
file and populates `PROBE_URL_REQUEST_HEADERS` with sent headers and
`PROBE_URL_RESPONSE_HEADERS` with received headers. This file is
single so it keeps data of the latest curl invocation only. To not
lost some data of previous reuests - better is to run this function
between invocations and keep needed data.


## Additional functions to simplify work with array variables


### `array_pretty_print ARRAY`

Prints (associative) arrays pretty formatted. If some item is
multi-lined, each substring is printed separately.


### `array_def ARRAY`

Prints the variable definition. It's supposed that this function will
ease in full copying one associative array variable to another one.

Example:

```shell
declare -A var1=([k1]=1 [k2]='2 3' [k3]=4)
declare -A var2=$( array_def var1 )
```


## Additional functions for warnings and exiting


### `die [TEXT]`

Prints to STDERR the text or `Died in LINE FUNC FILE` and exits with
an error code = 1 or `$DIE` if specified.


### `warn [TEXT]`

Prints to STDERR the text or `Warning in LINE FUNC FILE`.


## Variables


### `PROBE_URL_HEADERS`

The associative array keeps the user-defined headers that are supposed
to be sent.


### `PROBE_URL_REQUEST_HEADERS`

The associative array keeps the request headers of the last
request. To actualize values with the most recent request invoke the
`probe_url_expose_headers` function.


### `PROBE_URL_RESPONSE_HEADERS`

The associative array keeps the response headers of the last
request. To actualize values with the most recent request invoke the
`probe_url_expose_headers` function.


### `PROBE_CURL_OPTS`

The list of additional options for curl.


# SEE ALSO

* Postman
* Newman
* HTTPie

