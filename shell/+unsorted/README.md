# `./body.sh`

Print the first line of STDIN as an output header and continue executing
the provided command.

Example:

    ps -ef | body grep $USER

# `./bulkping`

Read hosts from stdin, file or command line and do ping towards them in
parallel. Print to stderr the hosts that return errors when ping them.

Examples:

    bulkping goo.gl goog.le
    bulkping -f FILENAME
    printf '%s\n' goo.gl goog.le | bulkping

Requirements:

* sh
* uname
* xargs
* ping

# `./cal-1-vertical`

Emulate `cal -1 -v` to print one month vertically.


        February 2024   
    Su     4 11 18 25   
    Mo     5 12 19 26   
    Tu     6 13 20 27   
    We     7 14 21 28   
    Th  1  8 15 22 29   
    Fr  2  9 16 23      
    Sa  3 10 17 24      


It doesn't work with BusyBox because of no support for the `-1` option there.

Based on this discussion
https://www.cyberforum.ru/shell/thread3153320.html

# `./cal-1-weekdays`

Count numbers of each weekdays in one month.


        February 2024   
    Su Mo Tu We Th Fr Sa
                 1  2  3
     4  5  6  7  8  9 10
    11 12 13 14 15 16 17
    18 19 20 21 22 23 24
    25 26 27 28 29      
                        
     4  4  4  4  5  4  4


It doesn't work with BusyBox because of no support for the `-1` option there.

Based on this discussion
https://www.cyberforum.ru/shell/thread3153320.html

# `./cap`

*cap* and *tee* are plumbing fitting. If the last one is used to change
direction of pipes, the first one is used to stop flows and seal end
of a pipe.

Here *cap* is used to stop flowing long lines out of a terminal
width. In the other words, everything wider will be cropped by the
terminal width.

# `./color.sh`

Use symbolic names of colors like COLOR to colorize the COMMAND output.
It expects the variables named as COLOR_*.

Usage

    color COLOR COMMAND [ARGUMENTS]

Example 1

    # Examples of colors
    COLOR_RED="\e[0;31m"
    COLOR_YELLOW="\e[0;33m"
    COLOR_GREEN="\e[0;32m"

    # Display colored texts using color names
    color RED    echo STOP
    color YELLOW echo WAIT
    color GREEN  echo WALK

Example 2

    # Display a colored text using a color code
    color "\e[0;34m" echo Blue sky

# `./ctrace.bash`

Print a stack of execution contexts

Usage:
    ctrace [EXPR]

Without EXPR, returns a full stacktrace. When EXPR is defined, it
means how many call frames to skip before printing a stacktrace.

# `./def.sh`

Description

POSIX-compatible way to define a shell function called `name` with
the ability to display the function declaration which is stored in
the `$DEF_name` variable.

Usage

Use any character sequence except a single quote character for the
heredoc identifier (`DEF` in the example). The mandatory condition
for the right function definition is disabling the variable and
command substitution in the funtion body. It is achieved by quoting
the identifier within the single quotes as it's shown in the example.

    def name <<'DEF'
    ...
    DEF

See also

The idea was borrowed from this answer and modified for prettier usage:
https://unix.stackexchange.com/a/268309/440611

    defn() { code=$(cat) ; eval "${1}_code=\$code; $1() { $code; }" ; }

# `./diff-ls`

Compare two sorted directories

Example:

    diff-ls DIR1 DIR2

# `./dmesg-T.sh`

Emulate `dmesg -T` to print human-readable timestamps.

Answered in this thread
https://stackoverflow.com/q/27503386/3627676

# `./envsubst.sh`

This function covers and expands functionality of the original
utility. With no options the function takes a current environment and
passes all found variables to the utility.

# `./fail_if_empty_or_unset_vars.sh`

Check variables exist and fail if any is empty or unset

Usage

    fail_if_empty_or_unset_vars VARLIST

Example

    X=foo
    fail_if_empty_or_unset_vars X Y Z

Results

    ./zzz: line 5: Y: Empty or unset variable

# `./get_ipv4.sh`

The function tries to gather an IPv4 address for a specified interface.

Example:

    $ get_ipv4 lo
    127.0.0.1

There are three implementations. See for details in source.

# `./prefixtrude.sh`

Extract the common leading substring from the input strings

Example: print "qwe"

    printf '%s\n' qwerty qweasd | prefixtrude

# `./rep.sh`

Repeat the given string the particular number of times

* `$1` - string
* `$2` - number or repetition

There are four implementations:

* bash only, full of bashisms
* POSIX-compliant
* POSIX-compliant, insane use of awk
* POSIX-compliant, awful

Example:

    $ rep '#' 5
    #####

# `./sponge`

slurp a stuff and burp...

    ... | sponge [-a] file

# `./teem`

*teem* means *rain heavily*. Here *teem* stands for *tee modified*,
implying that action of the standard `tee` tool is modified, and keeps
also connection with the meaning of the word, that's every new running
leads to teeming with new file.


    Usage: ... | teem [OPTIONS] [LABEL]
    
    Copy standard input to a file named 'LABEL-YYYY-mm-dd-HH-MM-SS.log'.
    If no LABEL is specified, defaults to 'tee'.
    
    Options
    	-i	Ignore an interrupt signal
    	-h	Print this help and exit
    


# `./timer.sh`

Report time consumed by command execution.

Example:

```shell
timer watch sleep 10
```

# `./tmuxa.sh`

Create a new session named as "$1" if it doesn't exist and attach to it.
Additional options and commands are applicable.

Any other clients attached to this session will be detached, if the
`TMUX_DETACH` variable is set to any non-empty value.

Example: run the session "my_work"

    tmuxa my_work

# `./transpose`

Transpose a table

    $ printf '%s %s\n' 1 2 3 4 5 6 | ./transpose
    1 3 5
    2 4 6

# `./trap_debug.bash`

Debugging in bash

Example:

```shell
set -T # debug functions as well
trap trap_debug DEBUG
```

How to use it without function

```shell
trap 'printf "# $LINENO: $BASH_COMMAND" >&2 ; read' DEBUG
```

Based on the idea published here:
https://www.cyberforum.ru/blogs/1976142/10017.html

# `./trap_debug_print.bash`

Control output of debugging information

A colon separated lists of patterns used to decide which command lines
should be shrinked until the length of the matched pattern or skipped
completely while output. Each pattern is anchored to the beginning
of the command line and assumed implicitly is followed by the space
character.

Variables

* `$TRAP_IGNORE`
* `$TRAP_SHRINK`

These variables can be useful to prevent duplicates of those commands
which usually echoing long texts. The predefined command are `echo`,
`printf`, `cat -` `cat  `. The two last patterns match to the command
usually used to output long texts in heredoc.

Functions

* `trap_debug_print`

This function can be used at the beginning of the script or somewhere
else to initialize DEBUG trap. It analyzes the $BASH_COMMAND variable,
compares the invoked command with the patterns in the $TRAP_SHRINK
and $TRAP_IGNORE and makes decision how to output the current shell
command (shrink it or skip completely). Other commands mismatching to
those patterns will be outputted after the `+` character. at the very
beginning of the printed string.

See also

* https://unix.stackexchange.com/a/332639
* https://www.gnu.org/software/bash/manual/bash.html#index-BASH_005fCOMMAND
* https://www.gnu.org/software/bash/manual/bash.html#index-trap

# `./try.sh`

Execute any command silently.

Example:

    try sleep 10

# `./tty_size.sh`

Print a terminal size in columns or lines.

Don't rely on the variables `COLUMNS` and `LINES` because POSIX or
minimalistic shells like dash don't update them automatically every
time a terminal is resized.

More details about these variables are given in this page:
https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html

# `./unhtml.sh`

Remove all styles, scripts and html comments totally, strip html tags
and leave a naked text only.

# `./urlencode.sh`

Urlencode any string on pure POSIX shell with no grep/sed/jq.

Example:

    $ urlencode "P@ssw0rd"
    P%40ssw0rd

This implementation is based on these two brilliant ideas:
* https://stackoverflow.com/a/10660730
* https://blog.dnmfarrell.com/post/how-to-split-a-string-in-posix-shell/

# `./vdiff.sh`

A function for using in an interactive shell. It supports `diff`
options from command line and `less` options via the `LESS` variable.

There three versions:

* a simple wrapper around `diff` and `less`
* the same supporting the modern `--color` option
* an `eval`-command constructing one of two above
  (useful for `.bashrc` as an example)

# `./warn-die.sh`

Useful functions for writing to the standard error and exiting with
non-zero exit code. There are two versions per each function:

* basic, available in the major of shells
* bash-compatible, supporting the `caller` builtin

Examples:

    # to warn about something
    warn "Something happened but continue execution."

    # to stop execution when something goes wrong
    die "Something critical happened. Exiting."

    # stop execution with the exit code = 42
    DIE=42 die "what a question, what an answer."

# `./x11sudo.sh`

Enable X11 settings of the current user when `sudo`-ing to another one.

Based on this thread:
https://unix.stackexchange.com/questions/476290/x11-forwarding-does-not-work-if-su-to-another-user

# `./xtrace.sh`

Execution tracing for a specific command

Example

    # Commenting the next line turns debugging off
    xtrace \
    some-command --with --numerous --options and some parameters

