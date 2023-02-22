<!-- toc-begin -->
# Table of Content
* [USAGE](#usage)
* [OPTIONS](#options)
* [DESCRIPTION](#description)
  * [`/p`](#p)
  * [`/w`](#w)
  * [`/e ENGINE`](#e-engine)
  * [`/x EXTENSION`](#x-extension)
* [DETAILS](#details)
  * [.au3, .a3x](#au3-a3x)
  * [.ahk](#ahk)
  * [.hta, .htm, .html](#hta-htm-html)
  * [.jl](#jl)
  * [.js](#js)
  * [.kix](#kix)
  * [.php](#php)
  * [.pl](#pl)
  * [.ps1](#ps1)
  * [.py](#py)
  * [.rb](#rb)
  * [.sh](#sh)
  * [.vbs](#vbs)
  * [.wsf](#wsf)
* [Hybridization internals](#hybridization-internals)
  * [`:print-hybrid-prolog`](#print-hybrid-prolog)
    * [Common case (tagged)](#common-case-tagged)
    * [Common case (prefixed)](#common-case-prefixed)
    * [Special case (`.wsf`)](#special-case-wsf)
    * [Special case (prefix = `@`)](#special-case-prefix--)
  * [`:print-info`](#print-info)
  * [`:warn`](#warn)
* [AUTHORS and CONTRIBUTORS](#authors-and-contributors)
* [SEE ALSO](#see-also)
* [ABOUT THIS PAGE](#about-this-page)
<!-- toc-end -->

Converts a script into a batch file.

# USAGE

    cmdize /help | /help-more | /help-devel | /help-readme
    cmdize /list
    cmdize [/w] [/e ENGINE] [/x EXTENSION] [/p] FILE ...

# OPTIONS

* `/help`        - Show this help and description.
* `/help-more`   - Show more details.
* `/help-devel`  - Show extremely detailed help including internal details.
* `/help-readme` - Generate a text for a README file
* `/list` - Show the list of supported file extensions and specific options.
* `/p` - Display on standard output instead of creating a new file.
* `/w` - Create the simple batch invoker.
* `/e` - Set the engine for using as the script runner.
* `/x` - Set another extension to consider another file type.

# DESCRIPTION

This tool takes an original script file and converts it to the
polyglot script, the batch script consisting of two parts: the body
of the original script and the special, sometimes tricky portion
of the code that is recognizable and executable correctly by both
parts. This portion is called prolog.

There are two terms to distinguish some differences. The first one
is hybrid, the polyglot completely based on the syntax of the batch
and prticular language). Another one is chimera, the polyglot using
some stuff like temporary files or environment variables (in the
other words, requesting capabilities outside languages).

Below is the example of javascript in batch applicable for Windows
JScript only and not supporting other engines like NodeJS, Rhino etc.

    @if (1 == 0) @end /*
    @cscript //nologo //e:javascript "%~f0" %* & @goto :EOF
    */
    WScript.Echo("Hello");

The order of the options is not fixed. Nevertheless, any specified
option takes effect until another one is specified. It allows to
set one option per each file declared after the option.

## `/p`

Display on standard output instead of creating a new file.

## `/w`

Create the separate batch file invoking the original script.

## `/e ENGINE`

Set the engine. It is used for running the script. You can alter
the executor and its options (for example, Chakra, NodeJS or Rhino
for javascript files).

## `/x EXTENSION`

Set another extension. It can be useful to alter the file type when
the original file has the extension not supported by this tool.

# DETAILS

More description, more links, more details about implementation in
this section.

## .au3, .a3x

* https://www.robvanderwoude.com/clevertricks.php

## .ahk

AutoHotKey is based on the AutoIt syntax. So its hybrid is the same.

## .hta, .htm, .html

* http://forum.script-coding.com/viewtopic.php?pid=79322#p79322

## .jl

* https://github.com/JuliaLang/julia/blob/master/doc/src/base/punctuation.md
* https://docs.julialang.org/en/v1/base/punctuation/
* https://forum.script-coding.com/viewtopic.php?pid=150262#p150262

## .js

These engines are special to create js-bat hybrid:

* `/e :cscript` for `cscript //nologo //e:javascript`
* `/e :wscript` for `wscript //nologo //e:javascript`
* `/e :cchakra` for `cscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
* `/e :wchakra` for `wscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`

By these links you can find more discussions and examples:

* http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
* http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
* https://gist.github.com/ildar-shaimordanov/88d7a5544c0eeacaa3bc

The following two links show my first steps in direction to create
this script.

* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter.html
* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter-2.html

## .kix

* https://www.robvanderwoude.com/clevertricks.php

## .php

PHP is supposed to be used as a scripting language in Web. So to
avoid possible conflicts with paths to dynamic libraries and to
suppress HTTP headers, we use two options `-n` and `-q`, respectively.

* https://www.php.net/manual/en/features.commandline.options.php

## .pl

The document below gives more details about `pl2bat.bat` and
`runperl.bat`. In fact, those scripts are full-featured prototypes
for this script. By default it acts as the first one but without
support to old DOSes.

* https://perldoc.perl.org/perlwin32

More alternatives for Perl.

Using the Perl option:

    @echo off
    perl -x "%~f0" %*
    goto :EOF
    #!perl

Using the Perl syntax:

    @rem = <<'____CMD____';
    @echo off
    perl "%~f0" %*
    goto :EOF
    ____CMD____

## .ps1

Very-very-very complicated case. It's too hard to implement a
universal and pure hybrid. In fact it's chimera because it uses
environment variables and can fail and can require additional
movements from end user perspective. The resulting batch stores
its filename and passed arguments in two environment variables
`PS1_FILE` and `PS1_ARGS`, respectively. Then it invokes powershell
which tries to restore arguments, reads the file and invokes it. Also
it is powered to continue working with STDIN properly. Powershell
has two (at least known for me) ways to invoke another code:
Invoke-Expression and invoke ScriptBlock. Both have their advandages
and disadvantages. By default, Invoke-Expression is used. To give
the users a choice between both, non-empty value in `PS1_ISB`
enables ScriptBlock invocation.

* http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
* http://stackoverflow.com/a/2611487/3627676

## .py

Below is example of the smaller version for the python's prolog. But
it has less possibilities to extend the prolog with additional
commands if need.

    @python -x "%~f0" %* & @goto :EOF

* http://stackoverflow.com/a/29881143/3627676
* http://stackoverflow.com/a/17468811/3627676

## .rb

This solution is based on the following link:

* https://stackoverflow.com/questions/35094778

By this link yet another solution is provided as well:

    @rem = %Q{
    @echo off
    ruby "%~f0" %*
    goto :EOF
    }

Ruby supports one more way of hybridization:

    @echo off
    ruby -x "%~f0" %*
    goto :EOF
    #!ruby

* https://ruby-doc.com/docs/ProgrammingRuby/html/rubyworld.html

## .sh

* http://forum.script-coding.com/viewtopic.php?id=11535
* http://www.dostips.com/forum/viewtopic.php?f=3&t=7110#p46654

## .vbs

These engines are special to create vbs-bat hybrid:

* `/e :cscript` for `cscript //nologo //e:vbscript`
* `/e :wscript` for `wscript //nologo //e:vbscript`

If the script contains the statement `Option Explicit`, the last
one is commented to avoid the compilation error.

By these links you can find more discussions:

* http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
* http://www.dostips.com/forum/viewtopic.php?p=32485#p32485

## .wsf

These engines are special to create wsf-bat hybrid:

* `/e :cscript` for `cscript //nologo`
* `/e :wscript` for `wscript //nologo`

Hybridizing WSF the script looks for the XML declaration and makes
it valid for running as batch. Also weird and undocumented trick with
file extensions (`%~f0?.wsf`) is used to insist WSH to recognize the
batch file as the WSF scenario. Honestly, the resulting file stops
being well-formed XML file. However WSH chews it silently.

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

# Hybridization internals

This section discovers all guts of the hybridization.

## `:print-hybrid-prolog`

This internal subroutine is a real workhorse. It creates
prologs. Depending on the passed arguments it produces different
prologs.

Arguments

* `%1` - engine (the executable invoking the script)
* `%2` - opening tag (to hide batch commands wrapping within tags)
* `%3` - closing tag (ditto)
* `%4` - prefix (used to hide batch commands in place)
* `%5` - pattern, usually `f0` or `dpn0.extension`or `?.wsf`

### Common case (tagged)

    call :print-hybrid-prolog engine
    call :print-hybrid-prolog engine tag1 tag2

Both `tag1` and `tag2` are optional:

    tag1
    @echo off
    engine %~f0 %*
    goto :EOF
    tag2

### Common case (prefixed)

    call :print-hybrid-prolog engine "" "" prefix

The above invocation produces the prolog similar to the pseudo-code
(the space after the prefix here is for readability reasons only):

    prefix @echo off
    prefix engine %~f0 %*
    prefix goto :EOF

### Special case (`.wsf`)

    call :print-hybrid-prolog engine tag1 tag2 "" "?.wsf"

It's almost the same as tagged common case:

    tag1
    @echo off
    engine %~f0?.wsf %*
    goto :EOF
    tag2

### Special case (prefix = `@`)

    call :print-hybrid-prolog engine "" "" @ pattern

It has higher priority and is processed prior others producing a
code similar to:

    @engine pattern %*

## `:print-info`

Extract and print different parts of the documentation.

Arguments

* `%1` - the marker

The markers used specifically by this tool:

* `U`     - to print usage only
* `UH`    - to print help with `/help`
* `UHD`   - to print help in details with `/help-more`
* `UHDG`  - to print all internals with `/help-devel`
* `UHDGR` - to print a text for a README file with `/help-readme`
* `L`     - to print a list of supported extensions with `/list`

## `:warn`

A common use subroutine for displaying warnings to STDERR.

Arguments

* `%*` - a text for printing

# AUTHORS and CONTRIBUTORS

Ildar Shaimordanov is the main author maintaining the tool since
2014. First steps in this direction were made in 2009, when he
created the `js2bat` script. Some stuff is invented by him, other
is collected from different sources in the Internet.

leo-liar (https://github.com/leo-liar) is the person who pointed
on the potential problem when some users who have UNIX tools in
their PATH might call a different FIND.EXE which will break this
script. Also he provided the fix.

greg zakharov (https://forum.script-coding.com/profile.php?id=27367)
disputes and throws interesting ideas time to time.

Residents of the forum https://www.dostips.com/forum/ with whom the
author has opportunity to discuss many aspects of batch scripting.

# SEE ALSO

Follow these links to learn more around polyglots:

* https://en.wikipedia.org/wiki/Polyglot_(computing)
* https://rosettacode.org/wiki/Multiline_shebang

Find this text and more details following by this link below.

* https://github.com/ildar-shaimordanov/my-scripts/blob/master/cmd/cmdize/README.md

# ABOUT THIS PAGE

This document is the part of the script and generated using the
following command:

    ./cmdize.bat /help-readme | git-md-toc -cut > README.md

Any changes in the script are supposed to be replicated to this
document file.

`git-md-toc` is the Perl script hosted here:
https://github.com/ildar-shaimordanov/git-markdown-toc

