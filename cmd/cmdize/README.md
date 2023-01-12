<!-- toc-begin -->
# Table of Content
* [USAGE](#usage)
* [OPTIONS](#options)
* [DESCRIPTION](#description)
* [AUTHORS and CONTRIBUTORS](#authors-and-contributors)
* [SEE ALSO](#see-also)
* [DETAILS](#details)
  * [.js](#js)
  * [.vbs](#vbs)
  * [.pl](#pl)
  * [.sh, .bash](#sh-bash)
  * [.ps1](#ps1)
  * [.py](#py)
  * [.rb](#rb)
  * [.hta, .htm, .html](#hta-htm-html)
  * [.wsf](#wsf)
  * [.kix](#kix)
  * [.au3, .a3x](#au3-a3x)
  * [.ahk](#ahk)
  * [.php](#php)
  * [.jl](#jl)
* [Hybridization internals](#hybridization-internals)
  * [`:print-usage`](#print-usage)
  * [`:warn`](#warn)
  * [`:print-extension-list`](#print-extension-list)
  * [`:print-script-wsf-bat`](#print-script-wsf-bat)
  * [`:print-script-wsf`](#print-script-wsf)
  * [`:print-prolog`](#print-prolog)
<!-- toc-end -->

Converts a script into a batch file.

# USAGE

    cmdize /HELP | /HELP-MORE | /HELP-DEVEL
    cmdize /L
    cmdize [/W] [/E engine] [/P] file ...

# OPTIONS

* `/HELP`        - Show this help and description.
* `/HELP-MORE`   - Show more details.
* `/HELP-DEVEL`  - Show extremely detailed help including internal details.
* `/HELP-README` - Generate a text for a README file
* `/L` - Show the list of supported file extensions and applicable options.
* `/E` - Set an engine for using as a the script runner.
* `/W` - Set the alternative engine (for VBScript only).
* `/P` - Display on standard output instead of creating a new file.

# DESCRIPTION

This tool converts a script into a batch file allowing to use the script like regular programs and batch scripts without invoking an executable engine explicitly and just typing the script name without extension. The resulting batch file is placed next to the original script.

The new file consist of the body of the script prepended with the special header (or prolog) being the *polyglot* and having some tricks to be a valid code both for the batch and original script.

This tool is pure batch file. So there is limitation in processing files having Byte Order Mark (BOM). For example, it fail with high probability while processing a unicode encoded WSF-file with XML declaration.

The *engine* term stands for the executable running the script. Not for all languages it's applicable. Depending the language, the engine can be set to any, none or one of predefined values. `/E DEFAULT` is the special engine that resets any previously set engines to the default value. The same result can be received with `/E ""`.

For WSF-scripts the engine is one of `CSCRIPT` and `WSCRIPT`. If XML declaration is presented (in the form like `<?xml...?>`), it must be in the most beginning of the file. Otherwise error is reported and the script is not cmdized.

For JavaScript/JScript it can be one of `CSCRIPT`, `WSCRIPT` (for JScript5+), `CCHAKRA`, `WCHAKRA` (for JScript9 or Chakra) or any valid command with options to enable running NodeJS, ChakraCore, Rhino and so on (for example, `node`, `ch`, `java -jar rhino.jar`, respectively).

For VBScript there is choice from either `CSCRIPT` or `WSCRIPT`. If the script implements the statement `Option Explicit`, then it is commented to avoid the compilation error. The `/W` option creates the alternative runner embedding the script into a WSF-file. In this case that statement is not commented and left as is.

For Perl `/E CMDONLY` is the only applicable value. It's fake engine that is used for creating the pure batch file for putting it with the original script in PATH.

For Python `/E SHORT` specifies creation of a quite minimalistic runner file. Other values don't make sense.

# AUTHORS and CONTRIBUTORS

Ildar Shaimordanov is the main author maintaining the tool since 2014. First steps in this direction were made in 2009, when he created the `js2bat` script. Some stuff is invented by him, other is collected from different sources in the Internet.

leo-liar (https://github.com/leo-liar) pointed on and provided the fix for the potential problem when some users who have UNIX tools in their PATH might call a different FIND.EXE which will break this script.

greg zakharov (https://forum.script-coding.com/profile.php?id=27367) disputes and throws interesting ideas time to time.

Residents of the forum https://www.dostips.com/forum/ with whom the author has opportunity to discuss many aspects of batch scripting.

# SEE ALSO

Find this text and more details following by this link below.

https://github.com/ildar-shaimordanov/my-scripts/blob/master/cmd/cmdize/README.md

Tests are here:

https://github.com/ildar-shaimordanov/my-scripts/tree/master/cmd/cmdize/t

# DETAILS

More description, more links, more details about implementation in this section.

## .js

* `/E CSCRIPT` for `cscript //nologo //e:javascript` (default)
* `/E WSCRIPT` for `wscript //nologo //e:javascript`
* `/E CCHAKRA` for `cscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
* `/E WCHAKRA` for `wscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`

Unfortunately, no easy way to wrap JScript9 into WSF.

* http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
* http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
* https://gist.github.com/ildar-shaimordanov/88d7a5544c0eeacaa3bc

The following two links show my first steps in direction to create this script.

* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter.html
* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter-2.html

## .vbs

Pure VBScript within a batch file:

* `/E CSCRIPT` for `cscript //nologo //e:vbscript` (default)
* `/E WSCRIPT` for `wscript //nologo //e:vbscript`

With `/W` it's WSF within a batch file (with some specialties for WSF):

* `/E CSCRIPT` for `cscript //nologo` (default)
* `/E WSCRIPT` for `wscript //nologo`

* http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
* http://www.dostips.com/forum/viewtopic.php?p=32485#p32485

## .pl

The document below gives more details about `pl2bat.bat` and `runperl.bat`. In fact, those scripts are full-featured prototypes for this script. By default it acts as the first one but without supporting old DOSs. With the `/E CMDONLY` option it creates the tiny batch acting similar to `runperl.bat`.

* https://perldoc.perl.org/perlwin32

## .sh, .bash

* http://forum.script-coding.com/viewtopic.php?id=11535
* http://www.dostips.com/forum/viewtopic.php?f=3&t=7110#p46654

## .ps1

Very-very-very complicated case. It's impossible to implement a pure hybrid. And too hard to implement a chimera. The resulting batch stores its filename and passed arguments in two environment variables `PS1_FILE` and `PS1_ARGS`, respectively. Then it invokes powershell which tries to restore arguments, reads the file and invokes it. Also it is powered to continue working with STDIN properly. Powershell has two (at least known for me) ways to invoke another code: Invoke-Expression and invoke ScriptBlock. Both have their advandages and disadvantages. By default, Invoke-Expression is used. To give the users a choice between both, non-empty value in `PS1_ISB` enables ScriptBlock invocation.

* http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
* http://stackoverflow.com/a/2611487/3627676

## .py

* http://stackoverflow.com/a/29881143/3627676
* http://stackoverflow.com/a/17468811/3627676

## .rb

* https://stackoverflow.com/questions/35094778

## .hta, .htm, .html

* http://forum.script-coding.com/viewtopic.php?pid=79322#p79322

## .wsf

Hybridizing WSF the script looks for the XML declaration and makes it valid for running as batch. Also weird and undocumented trick with file extensions (`%~f0?.wsf`) is used to insist WSH to recognize the batch file as the WSF scenario. Honestly, the resulting file stops being well-formed XML file. However WSH chews it silently.

BOM fails cmdizing.

Assuming the original XML declaration is as follows:

    <?xml...?>...

further it becomes:

    <?xml :
    ...?><!-- :
    prolog
    : -->...
    the rest of WSF

* http://www.dostips.com/forum/viewtopic.php?p=33963#p33963

## .kix

## .au3, .a3x

## .ahk

## .php

PHP is supposed to be used as a scripting language in Web. So to avoid possible conflicts with paths to dynamic libraries and to suppress HTTP headers, we use two options `-n` and `-q`, respectively.

## .jl

* https://github.com/JuliaLang/julia/blob/master/doc/src/base/punctuation.md
* https://docs.julialang.org/en/v1/base/punctuation/
* https://forum.script-coding.com/viewtopic.php?pid=150262#p150262

# Hybridization internals

This section discovers all guts of the hybridization.

## `:print-usage`

Prints different parts of the documentation.

Arguments

* `%1` - the marker

The markers used specifically by this tool:

* `U`     - to print usage only
* `UH`    - to print help (the `/HELP` option)
* `UHD`   - to print help in details (the `/HELP-MORE` option)
* `UHDG`  - to print full help including internals (the `/HELP-DEVEL` option)

## `:warn`

A common use subroutine for displaying warnings to STDERR.

Arguments

* `%*` - a text for printing

## `:print-extension-list`

Prints the list of supported extensions. It is invoked by the `/L` option.

## `:print-script-wsf-bat`

The purpose of this subroutine is to unify hybridizing a particular file as a WSF-file. It creates a temporary WSF-file with the content of the original file within and then hybridizes it.

To this moment it is used only once - for VBScript.

Arguments

* `%1` - filename
* `%2` - language

## `:print-script-wsf`

The companion for the above subroutine. It prints the original file surrounded with WSF markup.

Arguments

* `%1` - filename
* `%2` - language

## `:print-prolog`

This internal subroutine is a real workhorse. It creates prologs. Depending on the passed arguments it produces different prologs.

Arguments

* `%1` - engine (the executable invoking the script)
* `%2` - opening tag (used to hide batch commands wrapping them within tags)
* `%3` - closing tag (ditto)
* `%4` - prefix (used to hide batch commands in place)
* `%5` - pattern `f0` or `dpn0.extension` if `%4` == `@`; `?.wsf` for WSF-files only

Common case (tagged)

    call :print-prolog engine
    call :print-prolog engine tag1 tag2

Both `tag1` and `tag2` are optional:

    tag1
    @echo off
    engine %~f0 %*
    goto :EOF
    tag2

Common case (prefixed)

    call :print-prolog engine "" "" prefix

The above invocation produces the prolog similar to the pseudo-code (the space after the prefix is here for readability reasons only):

    prefix @echo off
    prefix engine %~f0 %*
    prefix goto :EOF

Special case (`.wsf`)

    call :print-prolog engine tag1 tag2 "" "?.wsf"

It's almost the same as tagged common case:

    tag1
    @echo off
    engine %~f0?.wsf %*
    goto :EOF
    tag2

Special case (prefix = `@`)

    call :print-prolog engine "" "" @ pattern

It has higher priority and is processed prior others producing a code similar to:

    @engine pattern %* & @goto :EOF

