:: USAGE
::     cmdize name [...]
::
:: This tool converts a supported code into a batch file that can be 
:: executed without explicit invoking the executable engine. The script 
:: creates new file and places it under the same directory as the original 
:: one with the same name, replacing the original extension with ".bat". 
:: The content of the new file consists of the original file and the 
:: special header that being the "polyglot" and having some tricks to be a 
:: valid code in batch file and the wrapped code at the same time. 
::
:: FEATURES
:: It does comment on "Option Explicit" in VBScript.
:: "<?xml?>" declaration for wsf-files is expected.
:: "Option Explicit" and "<?xml?>" in a single line only are supported.
:: BOM is not supported at all.
::
:: It is possible to select an engine for JavaScript, VBScript and WSF via 
:: the command line options /E. If it is not pointed especially, CSCRIPT 
:: is used as the default engine for all JavaScript, VBScript and WSF 
:: files. Another valid engine is WSCRIPT. Additionally for JavaScript 
:: files it is possible to set another engine such as NodeJS, Rhino etc. 
:: The predefined option /E DEFAULT resets any previously set engines to 
:: the default value. 
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

setlocal

:cmdize.loop.begin
if "%~1" == "" goto :cmdize.loop.end

set "CMDIZE_ENGINE="

if /i "%~1" == "/e" (
	if /i not "%~2" == "default" set "CMDIZE_ENGINE=%~2"
	shift /1
	shift /1
)

if not exist "%~f1" (
	echo:%~n0: File not found: "%~1">&2
	goto :cmdize.loop.continue
)

findstr /i /r /c:"^:cmdize%~x1$" "%~f0" >nul || (
	echo:%~n0: Unsupported extension: "%~1">&2
	goto :cmdize.loop.continue
)

call :cmdize%~x1 "%~1" >"%~dpn1.bat"

:cmdize.loop.continue

shift

goto :cmdize.loop.begin
:cmdize.loop.end

goto :EOF

:: ========================================================================

:: Convert the javascript file. 
:: The environment variable %CMDIZE_ENGINE% allows to declare another 
:: engine (cscript, wscript, node etc). 
:: The default value is cscript.
:cmdize.js
if not defined CMDIZE_ENGINE set "CMDIZE_ENGINE=cscript"
set "CMDIZE_ENGINE_OPTS="
for %%e in ( "%CMDIZE_ENGINE%" ) do (
	if /i "%%~ne" == "cscript" set "CMDIZE_ENGINE_OPTS=//nologo //e:javascript"
	if /i "%%~ne" == "wscript" set "CMDIZE_ENGINE_OPTS=//nologo //e:javascript"
)

echo:0^</*! ::
echo:@echo off
echo:%CMDIZE_ENGINE% %CMDIZE_ENGINE_OPTS% "%%~f0" %%*
echo:goto :EOF */0;
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
	echo:::'%%~s@echo off
	echo:::'%%~scscript //nologo //e:vbscript "%%~f0" %%*
	echo:::'%%~sgoto :EOF
)
del /q "%TEMP%\%~n0.$$"

rem type "%~f1"
for /f "tokens=1,* delims=]" %%r in ( 'find /n /v "" ^<"%~f1"' ) do (
	rem Filtering and commenting "Option Explicit". 
	rem This ugly code tries as much as possible to recognize and 
	rem comment this directive. It fails if "Option" and "Explicit" 
	rem are located on two neighbor lines, consecutively, one by one. 
	rem But it is too hard to imagine that there is someone who 
	rem practices such a strange coding style. 
	for /f "usebackq tokens=1,2" %%a in ( '%%s' ) do if /i "%%~a" == "Option" for /f "usebackq tokens=1,* delims=:'" %%i in ( 'x%%b' ) do if /i "%%~i" == "xExplicit" (
		echo:%~n0: Commenting Option Explicit in "%~1">&2
		echo:rem To prevent compilation error due to embedding into a batch file, 
		echo:rem the following line was commented automatically.
		set /p "=rem " <nul
	)
	echo:%%s
)
goto :EOF

:: ========================================================================

:: Convert the perl file.
:cmdize.pl
if /i "%CMDIZE_ENGINE%" == "cmd" (
	echo:@echo off
	echo:perl -x -S "%%~dpn0.pl" %%*
	goto :EOF
)

echo:@rem = '--*-Perl-*--
echo:@echo off
echo:perl -x -S "%%~f0" %%*
echo:goto :EOF
echo:@rem ';
echo:#!perl
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert Bourne shell and Bash scripts. 
:cmdize.sh
:cmdize.bash
echo:: ^<^< '____CMD____'
echo:@echo off
echo:bash "%%~f0" %%*
echo:goto :eof
echo:____CMD____
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the powershell file. 
:cmdize.ps1
echo:^<# :
echo:@echo off
echo:setlocal
echo:set "PS1_ARGS=%%*"
echo:powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches.Value|%%%%{$_ -Replace '^\"','' -Replace '\"$',''};$i=$input;iex $('$input=$i;$args=$a;rv i,a;'+(gc \"%%~f0\"|Out-String))"
echo:rem powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches.Value|%%%%{$_ -Replace '^\"','' -Replace '\"$',''};$input|&{[ScriptBlock]::Create((gc \"%%~f0\"|Out-String)).Invoke($a)}"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the python file.
:cmdize.py
:: Ascetic way is shorter but less flexible
:: Uncomment the following 3 lines if it is more preferrable
:: echo:@python -x "%%~f0" %%* ^& @goto :EOF
:: type "%~f1"
:: goto :EOF
echo:0^<0# : ^^
echo:"""
echo:@echo off
echo:python "%%~f0" %%*
echo:goto :EOF
echo:"""
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the ruby file.
:cmdize.rb
echo:@break #^^
echo:=begin
echo:@echo off
echo:ruby "%%~f0" %%*
echo:goto :EOF
echo:=end
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert the html file. 
:: Supportable file extensions are .hta, .htm and .html. 
:cmdize.hta
:cmdize.htm
:cmdize.html
echo:^<!-- :
echo:@echo off
echo:start "" mshta "%%~f0" %%*
echo:goto :EOF
echo:--^>
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
	echo:@echo off
	echo:%CMDIZE_ENGINE% //nologo "%%~f0?.wsf" %%*
	echo:goto :EOF
	echo:: --%%c
	more +1 <"%~f1"
	goto :EOF
)
goto :EOF

:: ========================================================================

:: Comvert KiXtart file.
:cmdize.kix
echo:;@echo off
echo:;kix32 "%%~f0" %%*
echo:;goto :EOF
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert AutoIt file.
:cmdize.au3
:cmdize.a3x
echo:;@echo off
echo:;AutoIt3 "%%~f0" %%*
echo:;goto :EOF
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert AutoHotKey file.
:cmdize.ahk
echo:;@echo off
echo:;AutoHotKey "%%~f0" %%*
echo:;goto :EOF
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert PHP file.
:: PHP is supposed to be used as a scripting language in Web. So to avoid
:: possible conflicts with paths to dynamic libraries and to suppress HTTP
:: headers, we use two options "-n" and "-q", respectively.
:cmdize.php
echo:^<^?php/* :
echo:@echo off
echo:php -n -q "%%~f0" %%*
echo:goto :EOF
echo:*/ ?^>
type "%~f1"
goto :EOF

:: ========================================================================

:: Convert Julia file.
:cmdize.jl
echo::"""
echo:@echo off
echo:julia "%%~f0" %%*
echo:goto :EOF
echo:"""
type "%~f1"
goto :EOF

:: ========================================================================

:: EOF
