# busybox-runner

This script is intended to simplify BusyBox running in different ways.

# Installation

* Download from this repository the script `bb.bat`.
* Download the latest version of the BusyBox executable from https://frippery.org/busybox/ (either 64-bit or 32-bit, what you want).
* Place both somewhere in your operating system to be visible via `$PATH`.

_Or..._

* Download from this repository the script `bb.bat`.
* Place it in your operating system to be visible via `$PATH`.
* Run one of the command `bb --download win32` or `bb --download win64` to download the latest 32-bit or 64-bit build of BusyBox, respectively. The downloaded executable will be stored next to this script. This step requires PowerShell is available in your system.

That's it. Everything is ready. You can enjoy with the cool set of Unix tools and cute envelope for running them.

# Usage

```
Simplify running scripts and commands with BusyBox

USAGE
  Print BusyBox help pages
    bb --help
    bb --version
    bb --list[-full]

  Run a built-in BusyBox function
    bb function [function-options]

  Run an executable from $PATH or specified with DIR
    bb [shell-options] [DIR]command [command-options]

  Run a one-liner script
    bb [shell-options] -c "script"

  Download the latest 32-bit or 64-bit build of BusyBox
    bb --download win32
    bb --download win64

SEE ALSO
  Learn more about BusyBox following these links:

  https://busybox.net/
  https://frippery.org/busybox/
  https://github.com/rmyorston/busybox-w32
```

## 1. Run a built-in BusyBox function

Run the internal function and pass options, if necessary:

```
bb function [function-options]
```

In fact, it's the same what BusyBox does:

```
busybox function [function-options]
```

## 2. Run an external command or script

Run an external command or script found in `$PATH` or specified with a relative or absolute DIR. The following examples are identical:

```
bb [shell-options] [DIR]command [command-options]
```

```
busybox [sh [shell-options]] [DIR]command [command-options]
```

## 3. Run a one-liner script

Run a one-liner script:

```
bb [shell-options] -c "script"
```

```
busybox sh [shell-options] -c "script"
```

# See Also

* https://busybox.net/
* https://frippery.org/busybox/
* https://github.com/rmyorston/busybox-w32
