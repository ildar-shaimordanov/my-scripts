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
:: SEE ALSO
:: Proceed the following links to learn more the origins
::
:: .js
:: http://forum.script-coding.com/viewtopic.php?pid=79210#p79210
:: http://www.dostips.com/forum/viewtopic.php?p=33879#p33879
::
:: .vbs
:: http://www.dostips.com/forum/viewtopic.php?p=33882#p33882
:: http://www.dostips.com/forum/viewtopic.php?p=32485#p32485
::
:: .pl
:: For details and better support see "pl2bat.bat" from Perl distribution
::
:: .ps1
:: http://blogs.msdn.com/b/jaybaz_ms/archive/2007/04/26/powershell-polyglot.aspx
:: http://stackoverflow.com/a/2611487/3627676
::
:: .hta and .html?
:: http://forum.script-coding.com/viewtopic.php?pid=79322#p79322
::
:: .wsf
:: http://www.dostips.com/forum/viewtopic.php?p=33963#p33963
::
:: COPYRIGHTS
:: Copyright (c) 2014 Ildar Shaimordanov

@echo off

if "%~1" == "" (
	for %%p in ( powershell.exe ) do if not "%%~$PATH:p" == "" (
		"%%~$PATH:p" -NoProfile -NoLogo -Command "cat '%~f0' | where { $_ -match '^::' } | %% { $_ -replace '::', '' }"
		goto :EOF
	)
	for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		echo:%%s
	)
	goto :EOF
)

:cmdize.loop.begin
if "%~1" == "" goto :cmdize.loop.end

if not exist "%~f1" (
	echo:%~n0: File not found: "%~1">&2
	goto :cmdize.loop.continue
)

for %%x in ( .js .vbs .pl .ps1 .hta .htm .html .wsf ) do (
	if /i "%~x1" == "%%~x" (
		call :cmdize%%~x "%~1" >"%~dpn1.bat"
		goto :cmdize.loop.continue
	)
)

echo:%~n0: Unsupported extension: "%~1">&2

:cmdize.loop.continue

shift

goto :cmdize.loop.begin
:cmdize.loop.end

goto :EOF


:cmdize.js
echo:@if ^(true == false^) @end /*!
echo:@echo off
echo:"%%windir%%\System32\cscript.exe" //nologo //e:javascript "%%~f0" %%*
echo:goto :EOF */
type "%~f1"
goto :EOF


:cmdize.vbs.h
set /p "=::'" <nul
type "%TEMP%\%~n0.$$"
echo:%*
goto :EOF


:cmdize.vbs
copy /y nul + nul /a "%TEMP%\%~n0.$$" /a 1>nul

call :cmdize.vbs.h @echo off
call :cmdize.vbs.h "%%%%windir%%%%\System32\cscript.exe" //nologo //e:vbscript "%%%%~f0" %%%%*
call :cmdize.vbs.h goto :EOF

del /q "%TEMP%\%~n0.$$"
rem type "%~f1"
for /f "tokens=1,* delims=]" %%r in ( ' call "%windir%\System32\find.exe" /n /v "" ^<"%~f1" ' ) do (
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


:cmdize.pl
echo:@rem = '--*-Perl-*--
echo:@echo off
echo:perl -x -S "%%~f0" %%*
echo:goto :EOF
echo:@rem ';
echo:#!perl
type "%~f1"
goto :EOF


:cmdize.ps1
echo:^<# :
echo:@echo off
echo:setlocal
echo:set "POWERSHELL_BAT_ARGS=%%*"
echo:if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%%POWERSHELL_BAT_ARGS:"=\"%%"
echo:endlocal ^& powershell -Command "Invoke-Expression $( '$args = @( &{ $args } %%POWERSHELL_BAT_ARGS%% );' + [String]::Join( [char]10, $( Get-Content \"%%~f0\" ) ) )"
echo:goto :EOF
echo:#^>
type "%~f1"
goto :EOF


:cmdize.hta
:cmdize.htm
:cmdize.html
echo:^<!-- :
echo:@echo off
echo:start "" "%%windir%%\System32\mshta.exe" "%%~f0" %%*
echo:goto :EOF
echo:--^>
type "%~f1"
goto :EOF


:cmdize.wsf
for /f "usebackq tokens=1,2,* delims=?" %%a in ( "%~f1" ) do for /f "tokens=1,*" %%d in ( "%%b" ) do (
	rem We use this code to transform the "<?xml?>" declaration 
	rem located at the very beginning of the file to the "polyglot" 
	rem form to do it acceptable by the batch file.
	echo:%%a?%%d :
	echo:: %%e ?^>^<!--
	echo:@echo off
	echo:"%%windir%%\System32\cscript.exe" //nologo "%%~f0?.wsf" %%*
	echo:goto :EOF
	echo:: --%%c
	more +1 <"%~f1"
	goto :EOF
)
goto :EOF


rem EOF
