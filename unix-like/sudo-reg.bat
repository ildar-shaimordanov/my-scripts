::NAME
::
::    sudo - execute a command with the elevated privileges
::
::SYNOPSIS
::
::    sudo
::    sudo COMMAND [OPTIONS]
::
::DESCRIPTION
::
::sudo allows to run a command with optional arguments with the elevated
::privileges. By default, if no any options specified, it runs the
::command interpreter. The command can be any of binary executables,
::batch scripts or documents supposed to be open.
::
::Based on the solution suggested in this thread:
::https://www.dostips.com/forum/viewtopic.php?f=3&t=9212
@echo off

if /i "%~1" == "/?" goto :print_usage
if /i "%~1" == "/h" goto :print_usage

call :check_reqs || goto :EOF

type nul >"%TEMP%\%~n0.%USERNAME%.elevate"

reg add "HKCU\Software\Classes\.elevate\shell\runas\command" /ve /d "cmd.exe /c cd /d \"%%w\" & start \"%~n0\" %%*" /f >nul

"%TEMP%\%~n0.%USERNAME%.elevate" %*

reg delete "HKCU\Software\Classes\.elevate" /f >nul
del /q "%TEMP%\%~n0.%USERNAME%.elevate"

goto :EOF


:print_usage
for /f "tokens=* delims=:" %%s in ( 'findstr "^::" "%~f0"' ) do echo:%%s
goto :EOF


:check_reqs
for %%p in ( reg.exe ) do if "%%~$PATH:p" == "" (
	echo:%%~p is required>&2
	exit /b 1
)
exit /b 0
