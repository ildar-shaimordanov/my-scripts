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

Compare two directories

Example:

    diff DIR1 DIR2

# `./trap_debug.bash`

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

* `trap_debug`

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
