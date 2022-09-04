# Clipboard processing

This script is intended to copy from and paste to clipboard. I tried to develop it universal as much as possible and executable both on Linux, MacOS and Windows (with help of Cygwin, Busybox and perhaps something more).

## Usage

```
clp
clp | ...
... | clp
```

## History

Initially I wrote the shell function for Cygwin because the last one is being used as my workhorse for long time.

Later I revealed for myself BusyBox which is extremely lightweight but powerful and flexible suite despite it has some limitations in the functionality of some of its tools. Of course, I wrote the function with the same functionality for BusyBox.

Both scripts turned out almost similar each other. So I decided to combine them into the single script supposed to be running under both environments. Also I decided to make the script running under both Linux and MacOS and supporting a set of convenient options.
