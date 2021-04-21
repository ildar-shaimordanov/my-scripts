0</*! ::

::HELP Redirects output of command line tools to GUI application.
::HELP
::HELP
::HELP USAGE
::HELP
::HELP ... | 2 [OPTIONS] [EXT[.ALT] [APP-OPTIONS]]
::HELP
::HELP
::HELP OPTIONS
::HELP
::HELP -d DIR     use DIR for storing temp files
::HELP -n NAME    use NAME as the name of temp file
::HELP -s DIRNAME save the file as DIRNAME (overrides all -d, -n and EXT)
::HELP --debug    turn on debug information
::HELP --check    don't invoke a command, display only
::HELP
::HELP
::HELP DESCRIPTION
::HELP
::HELP The script is flexible enough to enable many ways to invoke GUI
::HELP applications. Which GUI application would be invoked is defined by
::HELP the arguments. Depending on what is this, it will be called to
::HELP declare few specific environment variables.
::HELP
::HELP
::HELP INVOCATION
::HELP
::HELP ... | 2
::HELP
::HELP With no parameters runs an application for viewing text files:
::HELP either Notepad as a default application or any other one installed
::HELP and configured to working with ".txt" files.
::HELP
::HELP ... | 2 EXT
::HELP
::HELP "EXT" stands for the name of the application or the application
::HELP family supposed to be launched with this file, or (the more
::HELP relevant) the shorthand for ".EXT", the extension (without the
::HELP leading "." character).
::HELP
::HELP The script looks around for the file called as "2.EXT.bat". If
::HELP the file exists, invokes it to set the needful environment
::HELP variables. The script should declare few specific environment
::HELP variables (see the "ENVIRONMENT" section below).
::HELP
::HELP If there is no file "2.EXT.bat", the argument is assumed as
::HELP the extension (without the leading "." symbol), the script does
::HELP attempt to find an executable command (using "assoc" and "ftype")
::HELP and prepare invocation of the command found by these commands.
::HELP
::HELP ... | 2 EXT.ALT
::HELP
::HELP The same as above but ".ALT" overrides the early declared extension.
::HELP
::HELP
::HELP CONFIGURATION
::HELP
::HELP Using the file "2-settings.bat" located in the same directory
::HELP allows to configure the global environment variables of the main
::HELP script. It is good place for setting such kind of variables as
::HELP %pipetmpdir%, %pipetmpname% and %pipeslurp%.
::HELP
::HELP
::HELP ENVIRONMENT
::HELP
::HELP %pipecmd%
::HELP
::HELP (Mandatory)
::HELP Invocation string for the application. It could or could not
::HELP contain additional parameters supported by the application.
::HELP
::HELP %pipeext%
::HELP
::HELP (Optional, but recommended to set)
::HELP Extenstion (like ".txt" or ".html" etc). It can be useful in the
::HELP case if the application is able to handle different data files.
::HELP
::HELP %pipetmpdir%
::HELP
::HELP (Optional)
::HELP The directory for storing temporary file. Defaults to %TEMP%.
::HELP
::HELP %pipetmpname%
::HELP
::HELP (Optional)
::HELP The name for temporary file. Defaults to pipe.%RANDOM%.
::HELP
::HELP %pipeslurp%
::HELP
::HELP (Optional)
::HELP The command line tool used for capturing the output of commands and
::HELP redirecting to a resulting file. By default it is set as follows:
::HELP
::HELP set "pipeslurp=cscript //nologo //e:javascript "%~f0""
::HELP
::HELP You don't need to modify this variable, unless you need to specify
::HELP another tool to capture input.
::HELP
::HELP
::HELP SEE ALSO
::HELP
::HELP ASSOC /?
::HELP FTYPE /?
::HELP
::HELP
::HELP COPYRIGHT
::HELP Copyright (c) 2014-2021 Ildar Shaimordanov

:: ========================================================================

@echo off

timeout /t 0 >nul 2>&1 && (
	call :pipe-help
	goto :EOF
)

:: ========================================================================

setlocal

set "pipedebug="
set "pipecheck="

set "pipetmpdir=%TEMP%"
set "pipetmpname=pipe.%RANDOM%"
set "pipetmpfile="
set "pipesavfile="
set "pipeslurp=cscript //nologo //e:javascript "%~f0""

if exist "%~dpn0-settings.bat" call "%~dpn0-settings.bat"

set "pipecmd="
set "pipecmdopts="
set "pipetitle="
set "pipeext="

:: ========================================================================

:pipe-options-begin

if "%~1" == "" goto :pipe-options-end

if "%~1" == "-d" (
	set "pipetmpdir=%~2"
	shift /1
	shift /1
) else if "%~1" == "-n" (
	set "pipetmpname=%~2"
	shift /1
	shift /1
) else if "%~1" == "-s" (
	set "pipesavfile=%~2"
	shift /1
	shift /1
) else if "%~1" == "--debug" (
	set "pipedebug=1"
	shift /1
) else if "%~1" == "--check" (
	set "pipecheck=1"
	shift /1
) else (
	goto :pipe-options-end
)

goto :pipe-options-begin
:pipe-options-end

:: ========================================================================

if "%~1" == "" (

	rem ... | 2

	call :pipe-lookup txt

) else if exist "%~dpn0.%~n1.bat" (

	rem ... | 2 EXT[.ALT]

	call :pipe-configure "%~dpn0.%~n1.bat" "%~x1"

	set "pipetitle=[app = %~n1]"
	if not defined pipeext set "pipeext=.%~n1"
	if not "%~x1" == "" set "pipeext=%~x1"

	shift /1

) else (

	rem ... | 2 EXT[.ALT]

	call :pipe-lookup "%~1"

	shift /1

)

if defined pipedebug call :pipe-debug "After parsing options"

:: ========================================================================

if not defined pipecmd (
	>&2 echo:Bad invocation
	goto :EOF
)

:: ========================================================================

if not defined pipeext set "pipeext=.txt"
if not defined pipetitle set "pipetitle=[%pipeext%]"

for %%f in ( "%pipetmpdir%" ) do set "pipetmpfile=%%~ff\%pipetmpname%%pipeext%"

if defined pipesavfile set "pipetmpfile=%pipesavfile%"

:: ========================================================================

setlocal enabledelayedexpansion

set "pipecmdopt="

:pipe-app-options-begin
set pipecmdopt=%1
if not defined pipecmdopt goto :pipe-app-options-end

set "pipecmdopts=%pipecmdopts% %pipecmdopt%"
shift /1

goto :pipe-app-options-begin
:pipe-app-options-end

set "pipecmd=!pipecmd:%%1="%%1"!"
set "pipecmd=!pipecmd:""%%1""="%%1"!"
if "!pipecmd!" == "!pipecmd:%%1=!" set "pipecmd=!pipecmd! "%%1""
set "pipecmd=!pipecmd:%%1=%pipetmpfile%!"

endlocal & set "pipecmd=%pipecmd%" & set "pipecmdopts=%pipecmdopts%"

:: ========================================================================

if defined pipedebug call :pipe-debug "Before invocation"

call :pipe-invoke %pipecmdopts%

endlocal
goto :EOF

:: ========================================================================

:pipe-lookup
for /f "tokens=1,* delims==" %%a in ( '
	2^>nul assoc ".%~n1"
' ) do for /f "tokens=1,* delims==" %%c in ( '
	2^>nul ftype "%%b"
' ) do (

	set "pipecmd=%%d"
	set "pipetitle=[%%a = %%b]"
	set "pipeext=%%a"

)
if not "%~x1" == "" set "pipeext=%~x1"
goto :EOF

:: ========================================================================

:pipe-configure
setlocal
call "%~1" "%~2"
endlocal & set "pipecmd=%pipecmd%" & set "pipeext=%pipeext%" & set "pipeslurp=%pipeslurp%"
goto :EOF

:: ========================================================================

:pipe-invoke
if defined pipecheck (
	echo:Invocation ^(check^)
	echo:call %pipeslurp% ^> "%pipetmpfile%"
	echo:call start "Starting %pipetitle%" %pipecmd%
	goto :EOF
)

call %pipeslurp% > "%pipetmpfile%"
call start "Starting %pipetitle%" %pipecmd%
goto :EOF

:: ========================================================================

:pipe-help
for /f "tokens=1,* delims= " %%a in ( '
	findstr /b "::HELP" "%~f0"
' ) do (
	echo:%%~b
)
goto :EOF

:pipe-debug
echo:%~1...
set pipe
echo:
goto :EOF

*/0;

while ( ! WScript.StdIn.AtEndOfStream ) {
	WScript.StdOut.WriteLine(WScript.StdIn.ReadLine());
}

// ========================================================================

// EOF
