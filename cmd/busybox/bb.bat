: ; [ $# -gt 0 ] || exec sed -n "s/^:: \?//p" << '::::'
:: Simplify running scripts and commands with BusyBox
::
:: USAGE
::   Print BusyBox help pages
::     bb --help
::     bb --version
::     bb --list[-full]
::
::   Run a built-in BusyBox function
::     bb function [function-options]
::
::   Run an executable from $PATH or specified with DIR
::     bb [shell-options] [DIR]command [command-options]
::
::   Run a one-liner script
::     bb [shell-options] -c "script"
::
::   Download the latest 32-bit or 64-bit build of BusyBox
::     bb --download win32
::     bb --download win64
::
:: SEE ALSO
::   Learn more about BusyBox following these links:
::
::   https://busybox.net/
::   https://frippery.org/busybox/
::   https://github.com/rmyorston/busybox-w32
::::
: << '____CMD____'
@echo off

setlocal

set "BB_EXE="

:: First: look for the latest instance next to this script
if not defined BB_EXE for /f "tokens=*" %%f in ( '
	dir /b /o-n "%~dp0busybox*.exe" 2^>nul
' ) do if not defined BB_EXE if exist "%~dp0%%~f" set "BB_EXE=%~dp0%%~f"

:: Second: look for the instance in $PATH
for %%f in (
	busybox.exe
	busybox64.exe
) do if not defined BB_EXE if not "%%~$PATH:f" == "" set "BB_EXE=%%~$PATH:f"

:: Fail, if BusyBox not found and download not required
if not defined BB_EXE if /i not "%~1" == "--download" (
	call :error BusyBox binary not found. Run "%~n0 --download" first.
	exit /b 1
)

:: ========================================================================

:: Try to download
if /i "%~1" == "--download" (
	for %%p in ( "powershell.exe" ) do if "%%~$PATH:p" == "" (
		call :error %%p is required
		exit /b 1
	)

	set "BB_URL="
	set "BB_DST="

	if /i "%~2" == "win32" (
		set "BB_URL=https://frippery.org/files/busybox/busybox.exe"
		set "BB_DST=%~dp0busybox.exe"
	) else if /i "%~2" == "win64" (
		set "BB_URL=https://frippery.org/files/busybox/busybox64.exe"
		set "BB_DST=%~dp0busybox64.exe"
	) else (
		call :error win32 or win64 required
		exit /b 1
	)

	echo:Downloading started...
	set BB_URL
	set BB_DST

	powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
	"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
	"$w = New-Object System.Net.WebClient;" ^
	"$w.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials;" ^
	"$w.DownloadFile($Env:BB_URL, $Env:BB_DST);"

	echo:Downloading completed

	goto :EOF
)

:: ========================================================================

:: Locate the history file in the $TEMP directory
set "HISTFILE=%TEMP%\.ash_history"

:: Locate the history file next to Busybox executable
::set "HISTFILE=%~dp0.ash_history"

:: Another way to locate the history file is to set HOME dir
::for %%p in ( "%~dp0." ) do set "HOME=%%~fp"

:: ========================================================================

if defined BB_DEBUG call :warn + "%BB_EXE%" sh "%~f0" %*

"%BB_EXE%" sh "%~f0" %*
exit /b %ERRORLEVEL%

:: ========================================================================

:error
call :warn ERROR: %*
goto :EOF

:warn
>&2 echo:%*
goto :EOF

:: ========================================================================

____CMD____

case "$1" in
'' )
	# It's never reachable part - learn why at the top of the script
	exit
	;;
--help | --list | --list-full )
	busybox $1
	exit
	;;
--version )
	busybox --help | head -2
	exit
	;;
esac

# Add the BusyBox location to the $PATH
[[ ";$PATH;" =~ ";$( dirname "$0" );" ]] \
|| PATH="$( dirname "$0" );$PATH"

[ -z "$BB_DEBUG" ] || set -x

case "$1" in
-* | +* )
	sh "$@"
	;;
* )
	eval '"$@"'
	;;
esac

# =========================================================================

# EOF
