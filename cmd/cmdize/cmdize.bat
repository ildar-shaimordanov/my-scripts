::U>Converts a script into a batch file.
::U>
::U># USAGE
::U>
::U>    cmdize /help | /help-more | /help-devel | /help-readme
::U>    cmdize /list
::U>    cmdize [/e ENGINE] [/p] FILE ...
::U>
::U># OPTIONS
::U>
::U>* `/help`        - Show this help and description.
::U>* `/help-more`   - Show more details.
::U>* `/help-devel`  - Show extremely detailed help including internal details.
::U>* `/help-readme` - Generate a text for a README file
::U>* `/list` - Show the list of supported file extensions and specific options.
::U>* `/e` - Set the engine for using as the script runner.
::U>* `/p` - Display on standard output instead of creating a new file.
::U>

:: ========================================================================

::H># DESCRIPTION
::H>
::H>This tool converts a script into a batch file allowing to use the
::H>script like regular programs and batch scripts without invoking
::H>an executable engine explicitly and just typing the script name
::H>without extension. The resulting batch file is placed next to the
::H>original script.
::H>
::H>The new file consist of the body of the script prepended with the
::H>special header (or prolog) being the *polyglot* and having some
::H>tricks to be a valid code both for the batch and original script.
::H>
::H>This tool is pure batch file. So there is limitation in processing
::H>files having Byte Order Mark (BOM). For example, it fail with high
::H>probability while processing a unicode encoded WSF-file with XML
::H>declaration.
::H>
::H>The *engine* term stands for the executable running the script. Not
::H>for all languages it's applicable. Depending the language, the engine
::H>can be set to any, none or one of predefined values. `/E DEFAULT`
::H>is the special engine that resets any previously set engines to the
::H>default value. The same result can be received with `/E ""`.
::H>
::H>For WSF-scripts the engine is one of `CSCRIPT` and `WSCRIPT`. If XML
::H>declaration is presented (in the form like `<?xml...?>`), it must
::H>be in the most beginning of the file. Otherwise error is reported
::H>and the script is not cmdized.
::H>
::H>For JavaScript/JScript it can be one of `CSCRIPT`, `WSCRIPT` (for
::H>JScript5+), `CCHAKRA`, `WCHAKRA` (for JScript9 or Chakra) or any
::H>valid command with options to enable running NodeJS, ChakraCore,
::H>Rhino and so on (for example, `node`, `ch`, `java -jar rhino.jar`,
::H>respectively).
::H>
::H>For VBScript there is choice from either `CSCRIPT` or `WSCRIPT`. If
::H>the script implements the statement `Option Explicit`, then it is
::H>commented to avoid the compilation error.
::H>
::H>For Perl `/E CMDONLY` is the only applicable value. It's fake engine
::H>that is used for creating the pure batch file for putting it with
::H>the original script in PATH.
::H>
::H>For Python `/E SHORT` specifies creation of a quite minimalistic
::H>runner file. Other values don't make sense.
::H>

@echo off

if "%~1" == "" (
	call :print-info-help U
	goto :EOF
)

if /i "%~1" == "/help" (
	call :print-info-help UH
	goto :EOF
)

if /i "%~1" == "/help-more" (
	call :print-info-help UHD
	goto :EOF
)

if /i "%~1" == "/help-devel" (
	call :print-info-help UHDG
	goto :EOF
)

if /i "%~1" == "/help-readme" (
	call :print-info-help UHDGR
	goto :EOF
)

if /i "%~1" == "/list" (
	call :print-info-extension-list
	goto :EOF
)

setlocal

set "CMDIZE_ERROR=0"
set "CMDIZE_WRAP="
set "CMDIZE_ENGINE="
set "CMDIZE_MAYBE=>"
set "CMDIZE_EXT="

:cmdize_loop_begin
if "%~1" == "" exit /b %CMDIZE_ERROR%

if /i "%~1" == "/e" (
	set "CMDIZE_ENGINE=%~2"
	shift /1
	shift /1
	goto :cmdize_loop_begin
)

if /i "%~1" == "/p" (
	set "CMDIZE_MAYBE=& rem "
	shift /1
	goto :cmdize_loop_begin
)

if not exist "%~f1" (
	set "CMDIZE_ERROR=1"
	call :warn File not found: "%~1"
	shift /1
	goto :cmdize_loop_begin
)

set "CMDIZE_EXT=%~x1"

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

:cmdize.au3
:cmdize.a3x
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=AutoIt3"

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.ahk

::D>## .ahk
::D>

:cmdize.ahk
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=AutoHotKey"

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

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "0<#= :" "=#0;"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.js	[/e cscript|wscript|cchakra|wchakra|ch|node|...]

::D>## .js
::D>
::D>These engines create js-bat hybrid:
::D>
::D>* `/e cscript` for `cscript //nologo //e:javascript`
::D>* `/e wscript` for `wscript //nologo //e:javascript`
::D>* `/e cchakra` for `cscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>* `/e wchakra` for `wscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>
::D>Unfortunately, no easy way to wrap JScript9 (or Chakra) into WSF. So
::D>JScript9 is not supported in WSF.
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
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

for %%s in (
	"cscript cscript javascript"
	"wscript wscript javascript"
	"cchakra cscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
	"wchakra wscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo //e:%%~c"
)

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "0</*! ::" "*/0;"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.kix

::D>## .kix
::D>

:cmdize.kix
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=kix32"

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

:cmdize.php
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=php -n -q"

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
::D>supporting old DOSs.
::D>
::D>* https://perldoc.perl.org/perlwin32
::D>

:cmdize.pl
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=perl -x -S"

call :print-hybrid-prolog "%CMDIZE_ENGINE%" "@rem = '--*-Perl-*--" "@rem ';"
echo:#!perl
type "%~f1"
goto :EOF

:: ========================================================================

::L>.ps1

::D>## .ps1
::D>
::D>Very-very-very complicated case. It's too hard to implement a
::D>pure hybrid. And too hard to implement a chimera. The resulting
::D>batch stores its filename and passed arguments in two environment
::D>variables `PS1_FILE` and `PS1_ARGS`, respectively. Then it invokes
::D>powershell which tries to restore arguments, reads the file and
::D>invokes it. Also it is powered to continue working with STDIN
::D>properly. Powershell has two (at least known for me) ways to invoke
::D>another code: Invoke-Expression and invoke ScriptBlock. Both have
::D>their advandages and disadvantages. By default, Invoke-Expression
::D>is used. To give the users a choice between both, non-empty value in
::D>`PS1_ISB` enables ScriptBlock invocation.
::D>
::D>* http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
::D>* http://stackoverflow.com/a/2611487/3627676
::D>

:cmdize.ps1
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command"

echo:^<# :
echo:@echo off
echo:setlocal
echo:rem Any non-empty value changes the script invocation: the script is
echo:rem executed using ScriptBlock instead of Invoke-Expression as default.
echo:set "PS1_ISB="
echo:set "PS1_FILE=%%~f0"
echo:set "PS1_ARGS=%%*"
echo:%CMDIZE_ENGINE% "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;$a=@(@(if($a.count){$a})|%%%%{$_.value -Replace '^\"','' -Replace '\"$',''});$f=gc $Env:PS1_FILE -Raw;if($Env:PS1_ISB){$input|&{[ScriptBlock]::Create('rv f,a -Scope Script;'+$f).Invoke($a)}}else{$i=$input;iex $('$input=$i;$args=$a;rv i,f,a;'+$f)}"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF

:: ========================================================================

::L>.py	[/e short]

::D>## .py
::D>
::D>* http://stackoverflow.com/a/29881143/3627676
::D>* http://stackoverflow.com/a/17468811/3627676
::D>

:cmdize.py
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=python"

if /i "%CMDIZE_ENGINE%" == "short" (
	call :print-hybrid-prolog "%CMDIZE_ENGINE% -x" "" "" "@" "f0"
	type "%~f1"
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
::D>* https://stackoverflow.com/questions/35094778
::D>

:cmdize.rb
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=ruby"

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

call :print-hybrid-prolog "%CMDIZE_ENGINE%" ": << '____CMD____'" "____CMD____"
type "%~f1"
goto :EOF

:: ========================================================================

::L>.vbs	[/e cscript|wscript|...]

::D>## .vbs
::D>
::D>Pure VBScript within a batch file (vbs-bat hybrid):
::D>
::D>* `/e cscript` for `cscript //nologo //e:vbscript`
::D>* `/e wscript` for `wscript //nologo //e:vbscript`
::D>
::D>* http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
::D>* http://www.dostips.com/forum/viewtopic.php?p=32485#p32485
::D>

:cmdize.vbs
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

for %%s in (
	"cscript cscript vbscript"
	"wscript wscript vbscript"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo //e:%%~c"
)

copy /y nul + nul /a "%TEMP%\%~n0.$$" /a 1>nul
for /f "usebackq" %%s in ( "%TEMP%\%~n0.$$" ) do (
	call :print-hybrid-prolog "%CMDIZE_ENGINE%" "" "" "::'%%~s"
)
del /q "%TEMP%\%~n0.$$"

for /f "tokens=1,* delims=:" %%r in ( 'findstr /n /r "^" "%~f1"' ) do (
	rem Filtering and commenting "Option Explicit".

	rem Weird and insane attempt to implement it using capabilities
	rem of batch scripting only.

	rem This ugly code tries as much as it can to recognize and
	rem comment out this directive. It's flexible enough to find
	rem the directive even the string contains an arbitrary amount
	rem of whitespaces. It fails if both "Option" and "Explicit"
	rem are located on different lines. But it's too hard to imagine
	rem that someone practices such a strange coding style.

	rem In the other hand, it still tries to recognize the rest of
	rem the line after the directive and put it to the next line,
	rem if it contains an executable code.

	if "%%s" == "" (
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
)
goto :EOF

:: ========================================================================

::L>.wsf	[/e cscript|wscript]

::D>## .wsf
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
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

for %%s in (
	"cscript cscript"
	"wscript wscript"
) do for /f "tokens=1-3" %%a in ( "%%~s" ) do if /i "%CMDIZE_ENGINE%" == "%%~a" (
	set "CMDIZE_ENGINE=%%~b //nologo"
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

::G>## `:print-info`
::G>
::G>Extract the marked data and print.
::G>
::G>Arguments
::G>
::G>* `%1` - the marker
::G>
::G>The markers used specifically by this tool:
::G>
::G>* `U`     - to print usage only
::G>* `UH`    - to print help, `/help`
::G>* `UHD`   - to print help in details, `/help-more`
::G>* `UHDG`  - to print full help including internals, `/help-devel`
::G>* `UHDGR` - to print a text for a README file, `/help-readme`
::G>* `L`     - to print a list of supported extensions, `/list`
::G>

:print-info
for /f "tokens=1,* delims=>" %%a in ( 'findstr /r "^::[%~1]>" "%~f0"' ) do echo:%%b
goto :EOF

:: ========================================================================

::G>## `:print-info-extension-list`
::G>
::G>Prints the list of supported extensions, `/list`.
::G>

:print-info-extension-list
call :print-info "L"
goto :EOF

:: ========================================================================

::G>## `:print-info-help`
::G>
::G>Prints different parts of the documentation.
::G>
::G>Arguments
::G>
::G>* `%1` - the marker
::G>
::G>The markers used specifically by this tool:
::G>
::G>* `U`     - to print usage only
::G>* `UH`    - to print help, `/help`
::G>* `UHD`   - to print help in details, `/help-more`
::G>* `UHDG`  - to print full help including internals, `/help-devel`
::G>* `UHDGR` - to print a text for a README file, `/help-readme`
::G>

:print-info-help
call :print-info "%~1"
goto :EOF

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
::G>* `%2` - opening tag (used to hide batch commands wrapping them
::G>within tags)
::G>* `%3` - closing tag (ditto)
::G>* `%4` - prefix (used to hide batch commands in place)
::G>* `%5` - pattern `f0` or `dpn0.extension` if `%4` == `@`; and `?.wsf`
::G>for WSF-files only
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
::G>    @engine pattern %* & @goto :EOF
::G>

:print-hybrid-prolog
if "%~4" == "@" (
	echo:@%~1 "%%~%~5" %%* ^& @goto :EOF
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
::H>Find this text and more details following by this link below.
::H>
::H>https://github.com/ildar-shaimordanov/my-scripts/blob/master/cmd/cmdize/README.md
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
::R>
::R>https://github.com/ildar-shaimordanov/git-markdown-toc
::R>

:: ========================================================================

:: EOF
