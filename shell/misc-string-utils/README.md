# `./prefixtrude.sh`

Extract the common leading substring from the input strings

Example: print "qwe"

    printf '%s\n' qwerty qweasd | prefixtrude

# `./rep.bash`

Repeat the given string the particular number of times

* `$1` - string
* `$2` - number or repetition

This version uses a lot of bashisms

Example: print 10 "#"

    rep "#" 10

# `./rep-posix-and-unsafe.sh`

Repeat the given string the particular number of times

* `$1` - string
* `$2` - number or repetition

POSIX-compliant version, unsafe

Example: print 10 "#"

    rep "#" 10

# `./rep-posix-safe-and-awful.sh`

Repeat the given string the particular number of times

* `$1` - string
* `$2` - number or repetition

POSIX-compliant version, safe and awful

Example: print 10 "#"

    rep "#" 10

