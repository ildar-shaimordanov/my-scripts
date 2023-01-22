::U>Converts a script into a batch file.
::U>
::U># USAGE
::U>
::U>    cmdize /HELP | /HELP-MORE | /HELP-DEVEL | /HELP-README
::U>    cmdize /L
::U>    cmdize [/W] [/E engine] [/P] file ...
::U>
::U># OPTIONS
::U>
::U>* `/HELP`        - Show this help and description.
::U>* `/HELP-MORE`   - Show more details.
::U>* `/HELP-DEVEL`  - Show extremely detailed help including internal details.
::U>* `/HELP-README` - Generate a text for a README file
::U>* `/L` - Show the list of supported file extensions and applicable options.
::U>* `/E` - Set an engine for using as a the script runner.
::U>* `/W` - Set the alternative engine (for VBScript only).
::U>* `/P` - Display on standard output instead of creating a new file.
::U>

:: ========================================================================

::H># DESCRIPTION
::H>
::H>This tool converts a script into a batch file allowing to use the script like regular programs and batch scripts without invoking an executable engine explicitly and just typing the script name without extension. The resulting batch file is placed next to the original script.
::H>
::H>The new file consist of the body of the script prepended with the special header (or prolog) being the *polyglot* and having some tricks to be a valid code both for the batch and original script.
::H>
::H>This tool is pure batch file. So there is limitation in processing files having Byte Order Mark (BOM). For example, it fail with high probability while processing a unicode encoded WSF-file with XML declaration.
::H>
::H>The *engine* term stands for the executable running the script. Not for all languages it's applicable. Depending the language, the engine can be set to any, none or one of predefined values. `/E DEFAULT` is the special engine that resets any previously set engines to the default value. The same result can be received with `/E ""`.
::H>
::H>For WSF-scripts the engine is one of `CSCRIPT` and `WSCRIPT`. If XML declaration is presented (in the form like `<?xml...?>`), it must be in the most beginning of the file. Otherwise error is reported and the script is not cmdized.
::H>
::H>For JavaScript/JScript it can be one of `CSCRIPT`, `WSCRIPT` (for JScript5+), `CCHAKRA`, `WCHAKRA` (for JScript9 or Chakra) or any valid command with options to enable running NodeJS, ChakraCore, Rhino and so on (for example, `node`, `ch`, `java -jar rhino.jar`, respectively).
::H>
::H>For VBScript there is choice from either `CSCRIPT` or `WSCRIPT`. If the script implements the statement `Option Explicit`, then it is commented to avoid the compilation error. The `/W` option creates the alternative runner embedding the script into a WSF-file. In this case that statement is not commented and left as is.
::H>
::H>For Perl `/E CMDONLY` is the only applicable value. It's fake engine that is used for creating the pure batch file for putting it with the original script in PATH.
::H>
::H>For Python `/E SHORT` specifies creation of a quite minimalistic runner file. Other values don't make sense.
::H>

@echo off

if "%~1" == "" (
	call :print-usage U
	goto :EOF
)

if /i "%~1" == "/HELP" (
	call :print-usage UH
	goto :EOF
)

if /i "%~1" == "/HELP-MORE" (
	call :print-usage UHD
	goto :EOF
)

if /i "%~1" == "/HELP-DEVEL" (
	call :print-usage UHDG
	goto :EOF
)

if /i "%~1" == "/HELP-README" (
	call :print-usage UHDGR
	goto :EOF
)

if /i "%~1" == "/L" (
	call :print-extension-list
	goto :EOF
)

setlocal

set "CMDIZE_ERROR=0"
set "CMDIZE_WRAP="
set "CMDIZE_ENGINE="
set "CMDIZE_MAYBE=>"

:cmdize_loop_begin
if "%~1" == "" exit /b %CMDIZE_ERROR%

if /i "%~1" == "/W" (
	set "CMDIZE_WRAP=1"
	shift /1
	goto :cmdize_loop_begin
)

if /i "%~1" == "/E" (
	if /i "%~2" == "default" (
		set "CMDIZE_ENGINE="
	) else (
		set "CMDIZE_ENGINE=%~2"
	)
	shift /1
	shift /1
	goto :cmdize_loop_begin
)

if /i "%~1" == "/P" (
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

findstr /i /b /l ":cmdize%~x1" "%~f0" >nul || (
	set "CMDIZE_ERROR=1"
	call :warn Unsupported extension: "%~1"
	shift /1
	goto :cmdize_loop_begin
)

call :cmdize%~x1 "%~1" %CMDIZE_MAYBE% "%~dpn1.bat"
if errorlevel 1 set "CMDIZE_ERROR=1"
shift /1
goto :cmdize_loop_begin

:: ========================================================================

::D># DETAILS
::D>
::D>More description, more links, more details about implementation in this section.
::D>

:: ========================================================================

::D>## .au3, .a3x
::D>
:cmdize.au3
:cmdize.a3x
call :print-prolog AutoIt3 "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .ahk
::D>
:cmdize.ahk
call :print-prolog AutoHotKey "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .hta, .htm, .html
::D>
::D>* http://forum.script-coding.com/viewtopic.php?pid=79322#p79322
::D>
:cmdize.hta
:cmdize.htm
:cmdize.html
call :print-prolog "start mshta" "<!-- :" ": -->"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .jl
::D>
::D>* https://github.com/JuliaLang/julia/blob/master/doc/src/base/punctuation.md
::D>* https://docs.julialang.org/en/v1/base/punctuation/
::D>* https://forum.script-coding.com/viewtopic.php?pid=150262#p150262
::D>
:cmdize.jl
call :print-prolog julia "0<#= :" "=#0;"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .js
::D>
::D>* `/E CSCRIPT` for `cscript //nologo //e:javascript` (default)
::D>* `/E WSCRIPT` for `wscript //nologo //e:javascript`
::D>* `/E CCHAKRA` for `cscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>* `/E WCHAKRA` for `wscript //nologo //e:{16d51579-a30b-4c8b-a276-0ff4dc41e755}`
::D>
::D>With `/W` it's WSF within a batch file (with some specialties for WSF):
::D>
::D>* `/E CSCRIPT` for `cscript //nologo` (default)
::D>* `/E WSCRIPT` for `wscript //nologo`
::D>
::D>Unfortunately, no easy way to wrap JScript9 (or Chakra) into WSF. So JScript9 is not supported in WSF.
::D>
::D>* http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
::D>* http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
::D>* https://gist.github.com/ildar-shaimordanov/88d7a5544c0eeacaa3bc
::D>
::D>The following two links show my first steps in direction to create this script.
::D>
::D>* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter.html
::D>* https://with-love-from-siberia.blogspot.com/2009/07/js2bat-converter-2.html
::D>
:cmdize.js	[/w] [/e cscript|wscript|cchakra|wchakra|ch|node|...]
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

if defined CMDIZE_WRAP (
	call :print-script-wsf-bat "%~f1" javascript
	goto :EOF
)

for %%e in ( "%CMDIZE_ENGINE%" ) do for %%s in (
	"cscript cscript javascript"
	"wscript wscript javascript"
	"cchakra cscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
	"wchakra wscript {16d51579-a30b-4c8b-a276-0ff4dc41e755}"
) do for /f "tokens=1,2,3" %%a in ( "%%~s" ) do if "%%~e" == "%%~a" (
	call :print-prolog "%%~b //nologo //e:%%~c" "0</*! ::" "*/0;"
	type "%~f1"
)

goto :EOF

:: ========================================================================

::D>## .kix
::D>
:cmdize.kix
call :print-prolog kix32 "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .php
::D>
::D>PHP is supposed to be used as a scripting language in Web. So to avoid possible conflicts with paths to dynamic libraries and to suppress HTTP headers, we use two options `-n` and `-q`, respectively.
::D>
:cmdize.php
call :print-prolog "php -n -q" "<?php/* :" "*/ ?>"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .pl
::D>
::D>The document below gives more details about `pl2bat.bat` and `runperl.bat`. In fact, those scripts are full-featured prototypes for this script. By default it acts as the first one but without supporting old DOSs. With the `/E CMDONLY` option it creates the tiny batch acting similar to `runperl.bat`.
::D>
::D>* https://perldoc.perl.org/perlwin32
::D>
:cmdize.pl	[/e cmdonly]
if /i "%CMDIZE_ENGINE%" == "cmdonly" (
	call :print-prolog "perl -x -S" "" "" "@" "dpn0.pl"
	goto :EOF
)

call :print-prolog "perl -x -S" "@rem = '--*-Perl-*--" "@rem ';"
echo:#!perl
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .ps1
::D>
::D>Very-very-very complicated case. It's impossible to implement a pure hybrid. And too hard to implement a chimera. The resulting batch stores its filename and passed arguments in two environment variables `PS1_FILE` and `PS1_ARGS`, respectively. Then it invokes powershell which tries to restore arguments, reads the file and invokes it. Also it is powered to continue working with STDIN properly. Powershell has two (at least known for me) ways to invoke another code: Invoke-Expression and invoke ScriptBlock. Both have their advandages and disadvantages. By default, Invoke-Expression is used. To give the users a choice between both, non-empty value in `PS1_ISB` enables ScriptBlock invocation.
::D>
::D>* http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
::D>* http://stackoverflow.com/a/2611487/3627676
::D>
:cmdize.ps1
echo:^<# :
echo:@echo off
echo:setlocal
echo:rem Any non-empty value changes the script invocation: the script is
echo:rem executed using ScriptBlock instead of Invoke-Expression as default.
echo:set "PS1_ISB="
echo:set "PS1_FILE=%%~f0"
echo:set "PS1_ARGS=%%*"
echo:powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;$a=@(@(if($a.count){$a})|%%%%{$_.value -Replace '^\"','' -Replace '\"$',''});$f=gc $Env:PS1_FILE -Raw;if($Env:PS1_ISB){$input|&{[ScriptBlock]::Create('rv f,a -Scope Script;'+$f).Invoke($a)}}else{$i=$input;iex $('$input=$i;$args=$a;rv i,f,a;'+$f)}"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .py
::D>
::D>* http://stackoverflow.com/a/29881143/3627676
::D>* http://stackoverflow.com/a/17468811/3627676
::D>
:cmdize.py	[/e short]
if /i "%CMDIZE_ENGINE%" == "short" (
	call :print-prolog "python -x" "" "" "@" "f0"
	type "%~f1"
	goto :EOF
)
echo:0^<0# : ^^
call :print-prolog python "'''" "'''"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .rb
::D>
::D>* https://stackoverflow.com/questions/35094778
::D>
:cmdize.rb
echo:@break #^^
call :print-prolog ruby "=begin" "=end"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .sh, .bash
::D>
::D>* http://forum.script-coding.com/viewtopic.php?id=11535
::D>* http://www.dostips.com/forum/viewtopic.php?f=3&t=7110#p46654
::D>
:cmdize.sh
:cmdize.bash
call :print-prolog bash ": << '____CMD____'" "____CMD____"
type "%~f1"
goto :EOF

:: ========================================================================

::D>## .vbs
::D>
::D>Pure VBScript within a batch file:
::D>
::D>* `/E CSCRIPT` for `cscript //nologo //e:vbscript` (default)
::D>* `/E WSCRIPT` for `wscript //nologo //e:vbscript`
::D>
::D>With `/W` it's WSF within a batch file (with some specialties for WSF):
::D>
::D>* `/E CSCRIPT` for `cscript //nologo` (default)
::D>* `/E WSCRIPT` for `wscript //nologo`
::D>
::D>* http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
::D>* http://www.dostips.com/forum/viewtopic.php?p=32485#p32485
::D>
:cmdize.vbs	[/w] [/e cscript|wscript]
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

if defined CMDIZE_WRAP (
	call :print-script-wsf-bat "%~f1" vbscript
	goto :EOF
)

copy /y nul + nul /a "%TEMP%\%~n0.$$" /a 1>nul
for /f "usebackq" %%s in ( "%TEMP%\%~n0.$$" ) do (
	call :print-prolog "%CMDIZE_ENGINE% //nologo //e:vbscript" "" "" "::'%%~s"
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

::D>## .wsf
::D>
::D>Hybridizing WSF the script looks for the XML declaration and makes it valid for running as batch. Also weird and undocumented trick with file extensions (`%~f0?.wsf`) is used to insist WSH to recognize the batch file as the WSF scenario. Honestly, the resulting file stops being well-formed XML file. However WSH chews it silently.
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
:cmdize.wsf	[/e cscript|wscript]
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

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
	call :print-prolog "%CMDIZE_ENGINE% //nologo" ": %%e?><!-- :" ": --%%c" "" "?.wsf"

	for /f "tokens=1,* delims=:" %%a in ( 'findstr /n /r "^" "%~f1"' ) do (
		if %%a gtr 1 echo:%%b
	)
	goto :EOF
)

call :print-prolog "%CMDIZE_ENGINE% //nologo" "<!-- :" ": -->" "" "?.wsf"
type "%~f1"
goto :EOF

:: ========================================================================

::G># Hybridization internals
::G>
::G>This section discovers all guts of the hybridization.
::G>

:: ========================================================================

::G>## `:print-extension-list`
::G>
::G>Prints the list of supported extensions. It is invoked by the `/L` option.
::G>
:print-extension-list
for /f "tokens=1,* delims=." %%x in ( 'findstr /i /r "^:cmdize[.][0-9a-z_][0-9a-z_]*\>" "%~f0"' ) do echo:.%%~y
goto :EOF

:: ========================================================================

::G>## `:print-prolog`
::G>
::G>This internal subroutine is a real workhorse. It creates prologs. Depending on the passed arguments it produces different prologs.
::G>
::G>Arguments
::G>
::G>* `%1` - engine (the executable invoking the script)
::G>* `%2` - opening tag (used to hide batch commands wrapping them within tags)
::G>* `%3` - closing tag (ditto)
::G>* `%4` - prefix (used to hide batch commands in place)
::G>* `%5` - pattern `f0` or `dpn0.extension` if `%4` == `@`; `?.wsf` for WSF-files only
::G>
::G>Common case (tagged)
::G>
::G>    call :print-prolog engine
::G>    call :print-prolog engine tag1 tag2
::G>
::G>Both `tag1` and `tag2` are optional:
::G>
::G>    tag1
::G>    @echo off
::G>    engine %~f0 %*
::G>    goto :EOF
::G>    tag2
::G>
::G>Common case (prefixed)
::G>
::G>    call :print-prolog engine "" "" prefix
::G>
::G>The above invocation produces the prolog similar to the pseudo-code (the space after the prefix is here for readability reasons only):
::G>
::G>    prefix @echo off
::G>    prefix engine %~f0 %*
::G>    prefix goto :EOF
::G>
::G>Special case (`.wsf`)
::G>
::G>    call :print-prolog engine tag1 tag2 "" "?.wsf"
::G>
::G>It's almost the same as tagged common case:
::G>
::G>    tag1
::G>    @echo off
::G>    engine %~f0?.wsf %*
::G>    goto :EOF
::G>    tag2
::G>
::G>Special case (prefix = `@`)
::G>
::G>    call :print-prolog engine "" "" @ pattern
::G>
::G>It has higher priority and is processed prior others producing a code similar to:
::G>
::G>    @engine pattern %* & @goto :EOF
::G>
:print-prolog
if "%~4" == "@" (
	echo:@%~1 "%%~%~5" %%* ^& @goto :EOF
	goto :EOF
)

setlocal

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

endlocal
goto :EOF

:: ========================================================================

::G>## `:print-script-wsf`
::G>
::G>The companion for `:print-script-wsf-bat`. It prints the original file surrounded with WSF markup.
::G>
::G>Arguments
::G>
::G>* `%1` - filename
::G>* `%2` - language
::G>
:print-script-wsf
echo:^<?xml version="1.0" ?^>
echo:^<package^>^<job id="cmdized"^>^<script language="%~2"^>^<^![CDATA[
type "%~f1"
echo:]]^>^</script^>^</job^>^</package^>
goto :EOF

:: ========================================================================

::G>## `:print-script-wsf-bat`
::G>
::G>The purpose of this subroutine is to unify hybridizing a particular file as a WSF-file. It creates a temporary WSF-file with the content of the original file within and then hybridizes it.
::G>
::G>To this moment it is used only once - for VBScript.
::G>
::G>Arguments
::G>
::G>* `%1` - filename
::G>* `%2` - language
::G>
:print-script-wsf-bat
for %%f in ( "%TEMP%\%~n1.wsf" ) do (
	call :print-script-wsf "%~f1" %~2 >"%%~ff"
	call :cmdize.wsf "%%~ff"
	del /f /q "%%~ff"
)
goto :EOF

:: ========================================================================

::G>## `:print-usage`
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
::G>* `UH`    - to print help (the `/HELP` option)
::G>* `UHD`   - to print help in details (the `/HELP-MORE` option)
::G>* `UHDG`  - to print full help including internals (the `/HELP-DEVEL` option)
::G>* `UHDGR` - to print a text for a README file (the `/HELP-README` option)
::G>
:print-usage
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
::H>Ildar Shaimordanov is the main author maintaining the tool since 2014. First steps in this direction were made in 2009, when he created the `js2bat` script. Some stuff is invented by him, other is collected from different sources in the Internet.
::H>
::H>leo-liar (https://github.com/leo-liar) pointed on and provided the fix for the potential problem when some users who have UNIX tools in their PATH might call a different FIND.EXE which will break this script.
::H>
::H>greg zakharov (https://forum.script-coding.com/profile.php?id=27367) disputes and throws interesting ideas time to time.
::H>
::H>Residents of the forum https://www.dostips.com/forum/ with whom the author has opportunity to discuss many aspects of batch scripting.
::H>
::H># SEE ALSO
::H>
::H>Find this text and more details following by this link below.
::H>
::H>https://github.com/ildar-shaimordanov/my-scripts/blob/master/cmd/cmdize/README.md
::H>
::H>Tests are here:
::H>
::H>https://github.com/ildar-shaimordanov/my-scripts/tree/master/cmd/cmdize/t
::H>

:: ========================================================================

::R># ABOUT THIS PAGE
::R>
::R>This document is the part of the script and generated using the following command:
::R>
::R>    cmdize /help-readme | git-md-toc -cut > README.md
::R>
::R>Any changes in the script are supposed to be replicated to this document file.
::R>
::R>`git-md-toc` is the Perl script hosted here:
::R>
::R>https://github.com/ildar-shaimordanov/git-markdown-toc
::R>

:: ========================================================================

:: EOF
