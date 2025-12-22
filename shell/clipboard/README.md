<!-- toc-begin -->
# Table of Content
* [Clipboard processing](#clipboard-processing)
* [Usage](#usage)
* [History](#history)
* [Some tips](#some-tips)
  * [Reason for the `-O` option](#reason-for-the--o-option)
  * [clp and BusyBox](#clp-and-busybox)
* [See Also](#see-also)
<!-- toc-end -->

# Clipboard processing

This script is intended to copy text from and to clipboard. The main idea is to have a unified CLI and reduce all existing divergences between commands in most of popular environments.

I tried to develop it universal as much as possible and executable both on Linux, MacOS and Windows (with help of Cygwin, Busybox and perhaps something more).

The script is quite convenient in needs to transfer text data between GUI and TUI. For example, select some text in a GUI application to clipboard, then transform it in TUI with sed, awk etc, then copy again to clipboard and paste to the same or another GUI application. In fact, it is that use case which inspired me to write its first version.

# Usage

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
	-v	Display the invoked commands
	-V	Display information on tools used by the utility

```

# History

Initially (in far 2020) I wrote a simple bash function for Cygwin, my workhorse I am used to use for long time.

Later I reworked it and added support for dos2unix and unix2dos.

Later I revealed for myself BusyBox which is extremely lightweight but powerful and flexible suite despite it has some limitations in the functionality of some of its tools. Of course, I wrote the function with the same functionality for BusyBox.

Both scripts turned out almost similar each other. So I decided to combine them into the single script supposed to be running under both environments. Also I decided to make the script running under both Linux and MacOS and extended it with a set of convenient options for supporting more actions on the content.

# Some tips

## Reason for the `-O` option

Use the `-O` option in a some rare cases of a command substition like:

```shell
command1 | command <( clp -O )
```

Because of a pipe the utility assumes that it is invoked in the middle of pipe.

## clp and BusyBox

Under BusyBox to paste data to console or pipe by default `powershell` is used. To process non-Latin texts correctly use `iconv` options. For example for Russian text the following code works fine with the `-f866` option (convert from cp866):

```shell
echo по-русски | clp
clp -f866 | sed 's/.*/[[ & ]]/'
```

# See Also

There are few universal shell implementaions with copy, paste and transformation.

* https://github.com/niedzielski/cb
* https://github.com/NNBnh/clipb
* https://github.com/lambdalisue/circlip
* https://github.com/dluciv/cccp
* https://github.com/atweiden/nullclip
* https://github.com/orbit-online/clipboard-wrapper
