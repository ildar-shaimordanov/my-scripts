:: USAGE
::     cmdize name [...]
::
:: This tool converts a script into a batch file allowing to use the
:: script like regular programs and batch scripts without invoking an
:: executable engine explicitly and just typing the script name without
:: extension. The resulting batch file is placed next to the original
:: script.
::
:: The new file consist of the body of the script prepended with the
:: special header (or prolog) being the "polyglot" and having some tricks
:: to be a valid code both for a batch and wrapper code.
::
:: FEATURES
:: Use /L to display the list of supported extensions
::
:: The tool looks for the directive "Option Explicit" and comments it
:: out while creating the batch file.
::
:: "<?xml?>" declaration for wsf-files is required.
::
:: If "<?xml?>" is recognized as the first element of the file, it is
:: parsed and modified to avoid execution error.
::
:: Both "Option Explicit" and "<?xml?>" are supported as placed on a
:: single line only.
::
:: BOM (Byte Order Mark) are not supported at all.
::
:: JavaScript, VBScript and WSF defaults an engine to CSCRIPT. Another
:: engine can be specified with the /E option. For example WSCRIPT for
:: those above or NODE for JavaScript. /E DEFAULT is the special option
:: that resets any previously set engines to the default value.
::
:: /E CMDONLY is for Perl only. It creates the pure batch file without
:: merging with the original Perl script. It can be useful in some
:: cases. The original Perl script and the newly created batch file
:: should be placed together and visible via PATH.
::
:: /E SHORT is for Python only. It creates ascetic prolog which is
:: shorter and less flexible.
::
:: SEE ALSO
:: Proceed the following links to learn more the origins
::
:: .js
:: http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
:: http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
:: https://gist.github.com/ildar-shaimordanov/88d7a5544c0eeacaa3bc
::
:: .vbs
:: http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
:: http://www.dostips.com/forum/viewtopic.php?p=32485#p32485
::
:: .pl
:: For details and better support see "pl2bat.bat" from Perl distribution
::
:: .sh, .bash
:: http://forum.script-coding.com/viewtopic.php?id=11535
:: http://www.dostips.com/forum/viewtopic.php?f=3&t=7110#p46654
::
:: .ps1
:: http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
:: http://stackoverflow.com/a/2611487/3627676
::
:: .py
:: http://stackoverflow.com/a/29881143/3627676
:: http://stackoverflow.com/a/17468811/3627676
::
:: .rb
:: https://stackoverflow.com/questions/35094778
::
:: .hta and .html?
:: http://forum.script-coding.com/viewtopic.php?pid=79322#p79322
::
:: .wsf
:: http://www.dostips.com/forum/viewtopic.php?p=33963#p33963
::
:: .kix
::
:: .au3, .a3x
::
:: .ahk
::
:: .php
::
:: .jl
:: https://github.com/JuliaLang/julia/blob/master/doc/src/base/punctuation.md
::
:: COPYRIGHTS
:: Copyright (c) 2014-2021 Ildar Shaimordanov

@echo off

if "%~1" == "" (
	for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		echo:%%s
	)
	goto :EOF
)

if /i "%~1" == "/L" (
	for /f "tokens=2 delims=." %%x in ( 'findstr /r "^:cmdize[.][a-z0-9_]*$" "%~f0"' ) do echo:.%%~x
	goto :EOF
)

setlocal

:cmdize_loop_begin
if "%~1" == "" goto :cmdize_loop_end

set "CMDIZE_ENGINE="

if /i "%~1" == "/e" (
	if /i not "%~2" == "default" set "CMDIZE_ENGINE=%~2"
	shift /1
	shift /1
)

if not exist "%~f1" (
	echo:%~n0: File not found: "%~1">&2
	goto :cmdize_loop_continue
)

findstr /i /r /c:"^:cmdize%~x1$" "%~f0" >nul || (
	echo:%~n0: Unsupported extension: "%~1">&2
	goto :cmdize_loop_continue
)

call :cmdize%~x1 "%~1" >"%~dpn1.bat"

:cmdize_loop_continue

shift

goto :cmdize_loop_begin
:cmdize_loop_end

goto :EOF

:: ========================================================================

:: Convert the javascript file.
:: The environment variable %CMDIZE_ENGINE% allows to declare another
:: engine (cscript, wscript, node etc).
:: The default value is cscript.
:cmdize.js
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"
for %%d in ( cscript wscript ) do for %%e in ( "%CMDIZE_ENGINE%" ) do if /i "%%d" == "%%~ne" set "CMDIZE_ENGINE=%CMDIZE_ENGINE% //nologo //e:javascript"

call :print-prolog "%CMDIZE_ENGINE%" "0</*! ::" "*/0;"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the vbscript file.
:: The environment variable %CMDIZE_ENGINE% allows to declare another
:: engine (cscript or wscript).
:: The default value is cscript.
:cmdize.vbs
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

copy /y nul + nul /a "%TEMP%\%~n0.$$" /a 1>nul
for /f "usebackq" %%s in ( "%TEMP%\%~n0.$$" ) do (
	call :print-prolog "%CMDIZE_ENGINE% //nologo //e:vbscript" "" "" "::'%%~s"
)
del /q "%TEMP%\%~n0.$$"

rem type "%~f1"
for /f "tokens=1,* delims=:" %%r in ( 'findstr /n /r "^" "%~f1"' ) do (
	rem Filtering and commenting "Option Explicit".
	rem This ugly code tries as much as it can to recognize and
	rem comment out this directive. It's flexible enough to find
	rem the directive even the string contains an arbitrary amount
	rem of whitespaces. It fails if both "Option" and "Explicit"
	rem are located on different lines. But it's too hard to imagine
	rem that someone practices such a strange coding style.
	for /f "usebackq tokens=1,2" %%a in ( '%%s' ) do if /i "%%~a" == "Option" for /f "usebackq tokens=1,* delims=:'" %%i in ( 'x%%b' ) do if /i "%%~i" == "xExplicit" (
		echo:%~n0: Commenting Option Explicit in "%~1">&2
		echo:rem To avoid compilation error due to embedding into a batch file,
		echo:rem the following line was commented out automatically.
		set /p "=rem " <nul
	)
	echo:%%s
)
goto :EOF

:: ========================================================================

:: Convert the perl file.
:cmdize.pl
if /i "%CMDIZE_ENGINE%" == "cmdonly" (
	echo:@echo off
	echo:perl -x -S "%%~dpn0.pl" %%*
	goto :EOF
)

call :print-prolog "perl -x -S" "@rem = '--*-Perl-*--" "@rem ';"
echo:#!perl
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert Bourne shell and Bash scripts.
:cmdize.sh
:cmdize.bash
call :print-prolog bash ": << '____CMD____'" "____CMD____"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the powershell file.
:cmdize.ps1
echo:^<# :
echo:@echo off
echo:setlocal
echo:set "PS1_ARGS=%%*"
echo:powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;if($a.length){$a=@($a|%%%%{$_.value -replace '^\"','' -replace '\"$',''})}else{$a=@()};$i=$input;iex $('$input=$i;$args=$a;rv i,a;'+(gc \"%%~f0\" -raw))"
echo:rem powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;if($a.length){$a=@($a|%%%%{$_.value -replace '^\"','' -replace '\"$',''})}else{$a=@()};$input|&{[ScriptBlock]::Create('rv a -scope script;'+(gc \"%%~f0\" -raw)).Invoke($a)}"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the python file.
:cmdize.py
if /i "%CMDIZE_ENGINE%" == "short" (
	echo:@python -x "%%~f0" %%* ^& @goto :EOF
	type "%~f1"
	goto :EOF
)
echo:0^<0# : ^^
echo:"""
call :print-prolog python
echo:"""
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the ruby file.
:cmdize.rb
echo:@break #^^
call :print-prolog ruby "=begin" "=end"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the html file.
:: Supportable file extensions are .hta, .htm and .html.
:cmdize.hta
:cmdize.htm
:cmdize.html
call :print-prolog "start "" mshta" "<!-- :" "-->"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the wsf file.
:: The environment variable %CMDIZE_ENGINE% allows to declare another
:: engine (cscript or wscript).
:: The default value is cscript.
:cmdize.wsf
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"

for /f "usebackq tokens=1,2,* delims=?" %%a in ( "%~f1" ) do for /f "tokens=1,*" %%d in ( "%%b" ) do (
	rem We use this code to transform the "<?xml?>" declaration
	rem located at the very beginning of the file to the "polyglot"
	rem form to do it acceptable by the batch file.
	echo:%%a?%%d :
	echo:: %%e ?^>^<!--

	rem Don't use "call :print-prolog" to keep "?.wsf" in place
	echo:@echo off
	echo:%CMDIZE_ENGINE% //nologo "%%~f0?.wsf" %%*
	echo:goto :EOF

	echo:: --%%c
	more +1 <"%~f1"
	goto :EOF
)

rem Don't use "call :print-prolog" to keep "?.wsf" in place
echo:^<!-- :
echo:@echo off
echo:%CMDIZE_ENGINE% //nologo "%%~f0?.wsf" %%*
echo:goto :EOF
echo:--^>
type "%~f1"
goto :EOF

:: ========================================================================

:: Comvert KiXtart file.
:cmdize.kix
call :print-prolog kix32 "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert AutoIt file.
:cmdize.au3
:cmdize.a3x
call :print-prolog AutoIt3 "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert AutoHotKey file.
:cmdize.ahk
call :print-prolog AutoHotKey "" "" ";"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert PHP file.
:: PHP is supposed to be used as a scripting language in Web. So to avoid
:: possible conflicts with paths to dynamic libraries and to suppress HTTP
:: headers, we use two options "-n" and "-q", respectively.
:cmdize.php
call :print-prolog "php -n -q" "<?php/* :" "*/ ?>"
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert Julia file.
:cmdize.jl
echo::"""
call :print-prolog julia
echo:"""
type "%~f1"
goto :EOF

:: ========================================================================

:: call :print-prolog engine
:: call :print-prolog engine tag1 tag2
:: call :print-prolog engine "" "" prefix
::
:: %1 - engine (the command to invoke the script)
:: %2 - opening tag (used to hide batch commands wrapping them within tags)
:: %3 - closing tag
:: %4 - prefix (used to hide batch commands in place)
:print-prolog
setlocal

set "tag=%~2"
if defined tag (
	setlocal enabledelayedexpansion
	echo:!tag!
	setlocal
)

echo:%~4@echo off
echo:%~4%~1 "%%~f0" %%*
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

:: EOF
