# Clipboard processing

This script is intended to copy text from and to clipboard. The main idea is to have a unified CLI and reduce all existing divergences between commands in most of popular environments.

I tried to develop it universal as much as possible and executable both on Linux, MacOS and Windows (with help of Cygwin, Busybox and perhaps something more).

The script is quite convenient in needs to transfer text data between GUI and TUI. For example, select some text in a GUI application to clipboard, then transform it in TUI with sed, awk etc, then copy again to clipboard and paste to the same or another GUI application. In fact, it is that use case which inspired me to write its first version.

## Usage

```
Copy data from and/or to the clipboard

Usage:
	clp [OPTIONS]
	clp [OPTIONS] | ...
	... | clp [OPTIONS]

Formatting options
	-u	dos2unix
	-d	unix2dos

Encoding options
	-f encoding
	-t encoding
		Encodings for input and output, respectively
	-c	Discard silently unconvertible characters

Stream controlling options
	-I	Force to copy STDIN to clipboard
	-O	Force to paste from clipboard to STDOUT

Information options
	-h	Display this help message
	-v	Display the executable command
	-V	Display versions of tools

```

## History

Initially I wrote the shell function for Cygwin because the last one is being used as my workhorse for long time.

Later I revealed for myself BusyBox which is extremely lightweight but powerful and flexible suite despite it has some limitations in the functionality of some of its tools. Of course, I wrote the function with the same functionality for BusyBox.

Both scripts turned out almost similar each other. So I decided to combine them into the single script supposed to be running under both environments. Also I decided to make the script running under both Linux and MacOS and supporting a set of convenient options.
