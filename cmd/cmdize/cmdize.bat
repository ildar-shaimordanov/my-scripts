::U>Converts a script into a batch file.
::U>
::U># USAGE
::U>
::U>    cmdize /help | /help-more | /help-devel | /help-readme
::U>    cmdize /list
::U>    cmdize [/w] [/e ENGINE] [/x EXTENSION] [/p] FILE ...
::U>
::U># OPTIONS
::U>
::U>* `/help`        - Show this help and description.
::U>* `/help-more`   - Show more details.
::U>* `/help-devel`  - Show extremely detailed help including internal details.
::U>* `/help-readme` - Generate a text for a README file
::U>* `/list` - Show the list of supported file extensions and specific options.
::U>* `/p` - Display on standard output instead of creating a new file.
::U>* `/w` - Create the simple batch invoker.
::U>* `/e` - Set the engine for using as the script runner.
::U>* `/x` - Set another extension to consider another file type.
::U>

:: ========================================================================

::H># DESCRIPTION
::H>
::H>This tool takes an original script file and converts it to the
::H>polyglot script, the batch script consisting of two parts: the body
::H>of the original script and the special, sometimes tricky portion
::H>of the code that is recognizable and executable correctly by both
::H>languages. This portion is called prolog.
::H>
::H>There are two terms to distinguish some differences. The first one
::H>is hybrid, the polyglot completely based on the syntax of the batch
::H>and prticular language). Another one is chimera, the polyglot using
::H>some stuff like temporary files, pipes or environment variables
::H>(in the other words, requesting capabilities outside languages).
::H>
::H>Below is the example of javascript in batch applicable for Windows
::H>JScript only and not supporting other engines like NodeJS, Rhino etc.
::H>
::H>    @if (1 == 0) @end /*
::H>    @cscript //nologo //e:javascript "%~f0" %* & @goto :EOF
::H>    */
::H>    WScript.Echo("Hello");
::H>
::H>The order of the options is not fixed. Nevertheless, any specified
::H>option takes effect until another one is specified. It allows to
::H>set one option per each file declared after the option.
::H>

@echo off

if "%~1" == "" (
	call :print-info U
	goto :EOF
)

if /i "%~1" == "/help" (
	call :print-info UH
	goto :EOF
)

if /i "%~1" == "/help-more" (
	call :print-info UHD
	goto :EOF
)

if /i "%~1" == "/help-devel" (
	call :print-info UHDG
	goto :EOF
)

if /i "%~1" == "/help-readme" (
	call :print-info UHDGR
	goto :EOF
)

if /i "%~1" == "/list" (
	call :print-info "L"
	goto :EOF
)

setlocal

set "CMDIZE_ERROR=0"
set "CMDIZE_WRAP="
set "CMDIZE_ENGINE="
set "CMDIZE_MAYBE=>"
set "CMDIZE_EXT_ALT="
set "CMDIZE_EXT="

:cmdize_loop_begin
if "%~1" == "" exit /b %CMDIZE_ERROR%

::H>## `/p`
::H>
::H>Display on standard output instead of creating a new file.
::H>

if /i "%~1" == "/p" (
	set "CMDIZE_MAYBE=& rem "
	shift /1
	goto :cmdize_loop_begin
)

::H>## `/w`
::H>
::H>Create the separate batch file invoking the original script.
::H>

if /i "%~1" == "/w" (
	set "CMDIZE_WRAP=1"
	shift /1
	goto :cmdize_loop_begin
)

::H>## `/e ENGINE`
::H>
::H>Set the engine. It is used for running the script. You can alter
::H>the executor and its options (for example, Chakra, NodeJS or Rhino
::H>for javascript files).
::H>

if /i "%~1" == "/e" (
	set "CMDIZE_ENGINE=%~2"
	shift /1
	shift /1
	goto :cmdize_loop_begin
)

::H>## `/x EXTENSION`
::H>
::H>Set another extension. It can be useful to alter the file type when
::H>the original file has the extension not supported by this tool.
::H>

if /i "%~1" == "/x" (
	set "CMDIZE_EXT_ALT=%~2"
	shift /1
	shift /1
	goto :cmdize_loop_begin
)

if defined CMDIZE_EXT_ALT if not "%CMDIZE_EXT_ALT:~0,1%" == "." (
	call :warn Replace "%CMDIZE_EXT_ALT%" with ".%CMDIZE_EXT_ALT%"
	set "CMDIZE_EXT_ALT=.%CMDIZE_EXT_ALT%"
)

if not exist "%~f1" (
	set "CMDIZE_ERROR=1"
	call :warn File not found: "%~1"
	shift /1
	goto :cmdize_loop_begin
)

if defined CMDIZE_EXT_ALT (
	set "CMDIZE_EXT=%CMDIZE_EXT_ALT%"
) else (
	set "CMDIZE_EXT=%~x1"
)

if not defined CMDIZE_EXT (
	set "CMDIZE_ERROR=1"
	call :warn Empty extension for "%~1"
	shift /1
	goto :cmdize_loop_begin
)

findstr /i /x /l ":cmdize%CMDIZE_EXT%" "%~f0" >nul || (
	set "CMDIZE_ERROR=1"
	call :warn Unsupported extension: "%CMDIZE_EXT%"
	shift /1
	goto :cmdize_loop_begin
)

setlocal
call :cmdize%CMDIZE_EXT% "%~1" %CMDIZE_MAYBE% "%~dpn1.bat"
endlocal
if errorlevel 1 set "CMDIZE_ERROR=1"

shift /1
goto :cmdize_loop_begin

:: ========================================================================

::D># DETAILS
::D>
::D>More description, more links, more details about implementation in
::D>this section.
::D>

:: ========================================================================

::L>.au3
::L>.a3x

::D>## .au3, .a3x
::D>
::D>* https://www.robvanderwoude.com/clevertricks.php
::D>

:cmdize.au3
:cmdize.a3x
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=AutoIt3"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.ahk

::D>## .ahk
::D>
::D>AutoHotKey is based on the AutoIt syntax. So its hybrid is the same.
::D>

:cmdize.ahk
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=AutoHotKey"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.hta
::L>.htm
::L>.html

::D>## .hta, .htm, .html
::D>
::D>* http://forum.script-coding.com/viewtopic.php?pid=79322#p79322
::D>

:cmdize.hta
:cmdize.htm
:cmdize.html
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=start mshta"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "<!-- :" ": -->"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.jl

::D>## .jl
::D>
::D>* https://github.com/JuliaLang/julia/blob/master/doc/src/base/punctuation.md
::D>* https://docs.julialang.org/en/v1/base/punctuation/
::D>* https://forum.script-coding.com/viewtopic.php?pid=150262#p150262
::D>

:cmdize.jl
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=julia"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "0<#= :" "=#0;"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.js	[/e :cscript|:wscript|:cchakra|:wchakra|...]

::D>## .js
::D>
::D>These engines are special to create js-bat hybrid:
::D>
::D>* `/e :cscript` for `cscript //nologo //e:javascript`
::D>* `/e :wscript` for `wscript //nologo //e:javascript`
::D>* `/e :cchakra` for `cscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>* `/e :wchakra` for `wscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>
::D>By these links you can find more discussions and examples:
::D>
::D>* http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
::D>* http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
::D>* https://gist.github.com/ildar-shaimordanov/88d7a5544c0eeacaa3bc
::D>
::D>The following two links show my first steps in direction to create
::D>this script.
::D>
::D>* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter.html
::D>* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter-2.html
::D>

:cmdize.js
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=:cscript"

for %%s in (
	":cscript cscript javascript"
	":wscript wscript javascript"
	":cchakra cscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
	":wchakra wscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo //e:%%~c"
)

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "0</*! ::" "*/0;"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.kix

::D>## .kix
::D>
::D>* https://www.robvanderwoude.com/clevertricks.php
::D>

:cmdize.kix
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=kix32"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.php

::D>## .php
::D>
::D>PHP is supposed to be used as a scripting language in Web. So to
::D>avoid possible conflicts with paths to dynamic libraries and to
::D>suppress HTTP headers, we use two options `-n` and `-q`, respectively.
::D>
::D>* https://www.php.net/manual/en/features.commandline.options.php
::D>

:cmdize.php
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=php -n -q"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "<?php/* :" "*/ ?>"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.pl

::D>## .pl
::D>
::D>The document below gives more details about `pl2bat.bat` and
::D>`runperl.bat`. In fact, those scripts are full-featured prototypes
::D>for this script. By default it acts as the first one but without
::D>support to old DOSes.
::D>
::D>* https://perldoc.perl.org/perlwin32
::D>
::D>More alternatives for Perl.
::D>
::D>Using the Perl option:
::D>
::D>    @echo off
::D>    perl -x "%~f0" %*
::D>    goto :EOF
::D>    #!perl
::D>
::D>Using the Perl syntax:
::D>
::D>    @rem = <<'____CMD____';
::D>    @echo off
::D>    perl "%~f0" %*
::D>    goto :EOF
::D>    ____CMD____
::D>

:cmdize.pl
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=perl"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "@rem = '--*-Perl-*--" "@rem ';"
echo:#!perl
type "%~f1"
goto :EOF

:: ========================================================================

::L>.ps1

::D>## .ps1
::D>
::D>Very-very-very complicated case. It's too hard to implement a
::D>universal and pure hybrid. In fact it's chimera because it uses
::D>environment variables and can fail and can require additional
::D>movements from end user perspective. The resulting batch stores
::D>its filename and passed arguments in two environment variables
::D>`PS1_FILE` and `PS1_ARGS`, respectively. Then it invokes powershell
::D>which tries to restore arguments, reads the file and invokes it. Also
::D>it is powered to continue working with STDIN properly. Powershell
::D>has two (at least known for me) ways to invoke another code:
::D>Invoke-Expression and invoke ScriptBlock. Both have their advandages
::D>and disadvantages. By default, Invoke-Expression is used. To give
::D>the users a choice between both, non-empty value in `PS1_ISB`
::D>enables ScriptBlock invocation.
::D>
::D>* http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
::D>* http://stackoverflow.com/a/2611487/3627676
::D>

:cmdize.ps1
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=powershell -NoLogo -NoProfile -ExecutionPolicy Bypass"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE% -File" "" "" @ dpn0%~x1
	goto :EOF
)

echo:^<# :
echo:@echo off
echo:setlocal
echo:rem Any non-empty value changes the script invocation: the script is
echo:rem executed using ScriptBlock instead of Invoke-Expression as default.
echo:set "PS1_ISB="
echo:set "PS1_FILE=%%~f0"
echo:set "PS1_ARGS=%%*"
echo:%CMDIZE_ENGINE% -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;$a=@(@(if($a.count){$a})|%%%%{$_.value -Replace '^\"','' -Replace '\"$',''});$f=gc $Env:PS1_FILE -Raw;if($Env:PS1_ISB){$input|&{[ScriptBlock]::Create('rv f,a -Scope Script;'+$f).Invoke($a)}}else{$i=$input;iex $('$input=$i;$args=$a;rv i,f,a;'+$f)}"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF

:: ========================================================================

::L>.py

::D>## .py
::D>
::D>Below is example of the smaller version for the python's prolog. But
::D>it has less possibilities to extend the prolog with additional
::D>commands if need.
::D>
::D>    @python -x "%~f0" %* & @goto :EOF
::D>
::D>* http://stackoverflow.com/a/29881143/3627676
::D>* http://stackoverflow.com/a/17468811/3627676
::D>

:cmdize.py
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=python"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

echo:0^<0# : ^^
call :print-hybrid-prolog "%CMDIZE_ENGINE%" "'''" "'''"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.rb

::D>## .rb
::D>
::D>This solution is based on the following link:
::D>
::D>* https://stackoverflow.com/questions/35094778
::D>
::D>By this link yet another solution is provided as well:
::D>
::D>    @rem = %Q{
::D>    @echo off
::D>    ruby "%~f0" %*
::D>    goto :EOF
::D>    }
::D>
::D>Ruby supports one more way of hybridization:
::D>
::D>    @echo off
::D>    ruby -x "%~f0" %*
::D>    goto :EOF
::D>    #!ruby
::D>
::D>* https://ruby-doc.com/docs/ProgrammingRuby/html/rubyworld.html
::D>

:cmdize.rb
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=ruby"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

echo:@break #^^
call :print-hybrid-prolog "%CMDIZE_ENGINE%" "=begin" "=end"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.sh

::D>## .sh
::D>
::D>* http://forum.script-coding.com/viewtopic.php?id=11535
::D>* http://www.dostips.com/forum/viewtopic.php?f=3&t=7110#p46654
::D>

:cmdize.sh
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=sh"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" ": << '____CMD____'" "____CMD____"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.tcl

::D>## .tcl
::D>
::D>Tcl doesn't have block comments. Anything placed within `if 0 { ... }`
::D>is never executed. So tclers use it as the good way for doing block
::D>commenting.
::D>
::D>Be noticed: if you have needs to add into the prolog some text
::D>or code having curly brackets, you must keep them consistent -
::D>the number of opening brackets must equal to the number of closing
::D>brackets. Otherwise tcl fails to execute the hybrid.
::D>
::D>* https://www.tutorialspoint.com/tcl-tk/tcl_basic_syntax.htm
::D>* https://wiki.tcl-lang.org/page/if
::D>* https://wiki.tcl-lang.org/page/if+0+{
::D>

:cmdize.tcl
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=tclsh86t"

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "::if 0 {" "}"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.vbs	[/e :cscript|:wscript|...]

::D>## .vbs
::D>
::D>These engines are special to create vbs-bat hybrid:
::D>
::D>* `/e :cscript` for `cscript //nologo //e:vbscript`
::D>* `/e :wscript` for `wscript //nologo //e:vbscript`
::D>
::D>If the script contains the statement `Option Explicit`, the last
::D>one is commented to avoid the compilation error.
::D>
::D>By these links you can find more discussions:
::D>
::D>* http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
::D>* http://www.dostips.com/forum/viewtopic.php?p=32485#p32485
::D>

:cmdize.vbs
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=:cscript"

for %%s in (
	":cscript cscript vbscript"
	":wscript wscript vbscript"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo //e:%%~c"
)

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

copy /y nul + nul /a "%TEMP%\%~n0.$$" /a 1>nul
for /f "usebackq" %%s in ( "%TEMP%\%~n0.$$" ) do (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" "::'%%~s"
)
del /q "%TEMP%\%~n0.$$"

:: Filtering and commenting "Option Explicit".

:: Weird and insane attempt to implement it using capabilities of batch
:: scripting only.

:: This ugly code tries as much as it can to recognize and comment out
:: this directive. It's flexible enough to find the directive even the
:: string contains an arbitrary amount of whitespaces. It fails if both
:: "Option" and "Explicit" are located on different lines. But it's too
:: hard to imagine that someone practices such a strange coding style.

:: In the other hand, it still tries to recognize the rest of the line
:: after the directive and put it to the next line, if it contains an
:: executable code.

for /f "tokens=1,* delims=:" %%r in ( 'findstr /n /r "^" "%~f1"' ) do if "%%s" == "" (
	echo:%%s
) else for /f "tokens=1,*" %%a in ( "%%s" ) do if /i not "%%a" == "Option" (
	echo:%%s
) else for /f "tokens=1,* delims=':	 " %%i in ( "%%b" ) do if /i not "%%i" == "Explicit" (
	echo:%%s
) else (
	call :warn Commenting "Option Explicit" in "%~1"
	echo:rem To avoid compilation error due to embedding into a batch file,
	echo:rem the following line was commented out automatically.
	set /p "=rem " <nul

	if /i "%%b" == "Explicit" (
		rem Option Explicit
		echo:%%s
	) else for /f "tokens=1,* delims='" %%i in ( "%%b" ) do if /i "%%i" == "Explicit" (
		rem Option Explicit {QUOTE} ...
		echo:%%s
	) else for /f "tokens=1,* delims=:	 " %%i in ( "%%b" ) do if /i "%%i" == "Explicit" (
		rem Option Explicit {COLON|TAB|SPACE} ...
		echo:%%a %%i
		echo:%%j
	)
)
goto :EOF

:: ========================================================================

::L>.wsf	[/e :cscript|:wscript]

::D>## .wsf
::D>
::D>These engines are special to create wsf-bat hybrid:
::D>
::D>* `/e :cscript` for `cscript //nologo`
::D>* `/e :wscript` for `wscript //nologo`
::D>
::D>Hybridizing WSF the script looks for the XML declaration and makes
::D>it valid for running as batch. Also weird and undocumented trick with
::D>file extensions (`%~f0?.wsf`) is used to insist WSH to recognize the
::D>batch file as the WSF scenario. Honestly, the resulting file stops
::D>being well-formed XML file. However WSH chews it silently.
::D>
::D>BOM fails cmdizing.
::D>
::D>Assuming the original XML declaration is as follows:
::D>
::D>    <?xml...?>...
::D>
::D>further it becomes:
::D>
::D>    <?xml :
::D>    ...?><!-- :
::D>    prolog
::D>    : -->...
::D>    the rest of WSF
::D>
::D>* http://www.dostips.com/forum/viewtopic.php?p=33963#p33963
::D>

:cmdize.wsf
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=:cscript"

for %%s in (
	":cscript cscript"
	":wscript wscript"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo"
)

if defined CMDIZE_WRAP (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" @ dpn0%~x1
	goto :EOF
)

for /f "tokens=1,* delims=:" %%n in ( 'findstr /i /n /r "<?xml.*?>" "%~f1"' ) do for /f "tokens=1,2,* delims=?" %%a in ( "%%~o" ) do for /f "tokens=1,*" %%d in ( "%%b" ) do (
	set "CMDIZE_ERROR_WSF="
	if %%n neq 1 set "CMDIZE_ERROR_WSF=1"
	if not "%%a" == "<" set "CMDIZE_ERROR_WSF=1"
	if defined CMDIZE_ERROR_WSF (
		call :warn Incorrect XML declaration: it must be at the beginning of the script
		exit /b 1
	)

	rem We sure that the XML declaration is located on the first
	rem line of the script. Now we can transform it to the "polyglot"
	rem form acceptable by the batch file also.

	echo:%%a?%%d :
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" ": %%e?><!-- :" ": --%%c" "" "?.wsf"

	for /f "tokens=1,* delims=:" %%a in ( 'findstr /n /r "^" "%~f1"' ) do (
		if %%a gtr 1 echo:%%b
	)
	goto :EOF
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "<!-- :" ": -->" "" "?.wsf"
type "%~f1"
goto :EOF

:: ========================================================================

::G># Hybridization internals
::G>
::G>This section discovers all guts of the hybridization.
::G>

:: ========================================================================

::G>## `:print-hybrid-prolog`
::G>
::G>This internal subroutine is a real workhorse. It creates
::G>prologs. Depending on the passed arguments it produces different
::G>prologs.
::G>
::G>Arguments
::G>
::G>* `%1` - engine (the executable invoking the script)
::G>* `%2` - opening tag (to hide batch commands wrapping within tags)
::G>* `%3` - closing tag (ditto)
::G>* `%4` - prefix (used to hide batch commands in place)
::G>* `%5` - pattern, usually `f0` or `dpn0.extension`or `?.wsf`
::G>
::G>### Common case (tagged)
::G>
::G>    call :print-hybrid-prolog engine
::G>    call :print-hybrid-prolog engine tag1 tag2
::G>
::G>Both `tag1` and `tag2` are optional:
::G>
::G>    tag1
::G>    @echo off
::G>    engine %~f0 %*
::G>    goto :EOF
::G>    tag2
::G>
::G>### Common case (prefixed)
::G>
::G>    call :print-hybrid-prolog engine "" "" prefix
::G>
::G>The above invocation produces the prolog similar to the pseudo-code
::G>(the space after the prefix here is for readability reasons only):
::G>
::G>    prefix @echo off
::G>    prefix engine %~f0 %*
::G>    prefix goto :EOF
::G>
::G>### Special case (`.wsf`)
::G>
::G>    call :print-hybrid-prolog engine tag1 tag2 "" "?.wsf"
::G>
::G>It's almost the same as tagged common case:
::G>
::G>    tag1
::G>    @echo off
::G>    engine %~f0?.wsf %*
::G>    goto :EOF
::G>    tag2
::G>
::G>### Special case (prefix = `@`)
::G>
::G>    call :print-hybrid-prolog engine "" "" @ pattern
::G>
::G>It has higher priority and is processed prior others producing a
::G>code similar to:
::G>
::G>    @engine pattern %*
::G>

:print-hybrid-prolog
if "%~4" == "@" (
	echo:@%~1 "%%~%~5" %%*
	goto :EOF
)

set "tag=%~2"
if defined tag (
	setlocal enabledelayedexpansion
	echo:!tag!
	setlocal
)

echo:%~4@echo off
echo:%~4%~1 "%%~f0%~5" %%*
echo:%~4goto :EOF

set "tag=%~3"
if defined tag (
	setlocal enabledelayedexpansion
	echo:!tag!
	setlocal
)

goto :EOF

:: ========================================================================

::G>## `:print-info`
::G>
::G>Extract and print different parts of the documentation.
::G>
::G>Arguments
::G>
::G>* `%1` - the marker
::G>
::G>The markers used specifically by this tool:
::G>
::G>* `U`     - to print usage only
::G>* `UH`    - to print help with `/help`
::G>* `UHD`   - to print help in details with `/help-more`
::G>* `UHDG`  - to print all internals with `/help-devel`
::G>* `UHDGR` - to print a text for a README file with `/help-readme`
::G>* `L`     - to print a list of supported extensions with `/list`
::G>

:print-info
for /f "tokens=1,* delims=>" %%a in ( 'findstr /r "^::[%~1]>" "%~f0"' ) do echo:%%b
goto :EOF

:: ========================================================================

::G>## `:warn`
::G>
::G>A common use subroutine for displaying warnings to STDERR.
::G>
::G>Arguments
::G>
::G>* `%*` - a text for printing
::G>

:warn
>&2 echo:%~n0: %*
goto :EOF

:: ========================================================================

::H># AUTHORS and CONTRIBUTORS
::H>
::H>Ildar Shaimordanov is the main author maintaining the tool since
::H>2014. First steps in this direction were made in 2009, when he
::H>created the `js2bat` script. Some stuff is invented by him, other
::H>is collected from different sources in the Internet.
::H>
::H>leo-liar (https://github.com/leo-liar) is the person who pointed
::H>on the potential problem when some users who have UNIX tools in
::H>their PATH might call a different FIND.EXE which will break this
::H>script. Also he provided the fix.
::H>
::H>greg zakharov (https://forum.script-coding.com/profile.php?id=27367)
::H>disputes and throws interesting ideas time to time.
::H>
::H>Residents of the forum https://www.dostips.com/forum/ with whom the
::H>author has opportunity to discuss many aspects of batch scripting.
::H>
::H># SEE ALSO
::H>
::H>Follow these links to learn more around polyglots:
::H>
::H>* https://en.wikipedia.org/wiki/Polyglot_(computing)
::H>* https://rosettacode.org/wiki/Multiline_shebang
::H>
::H>Find this text and more details following by this link below.
::H>
::H>* https://github.com/ildar-shaimordanov/my-scripts/blob/master/cmd/cmdize/README.md
::H>

:: ========================================================================

::R># ABOUT THIS PAGE
::R>
::R>This document is the part of the script and generated using the
::R>following command:
::R>
::R>    ./cmdize.bat /help-readme | git-md-toc -cut > README.md
::R>
::R>Any changes in the script are supposed to be replicated to this
::R>document file.
::R>
::R>`git-md-toc` is the Perl script hosted here:
::R>https://github.com/ildar-shaimordanov/git-markdown-toc
::R>

:: ========================================================================

:: EOF
