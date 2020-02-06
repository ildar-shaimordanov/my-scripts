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
::REQUIREMENTS
::
::The script requires PowerShell to be installed on the system.
@echo off

if /i "%~1" == "/?" goto :print_usage
if /i "%~1" == "/h" goto :print_usage

call :check_reqs || goto :EOF

setlocal

set "SUDO_HIDDEN="

if "%~1" == "" (
	call :sudo /s /k cd "%CD%"
	goto :EOF
)

for %%x in ( .bat .cmd ) do if /i "%~x1" == "%%x" (
	call :sudo /s /k cd "%CD%" "&&" %*
	goto :EOF
)

set "SUDO_HIDDEN=-WindowStyle Hidden"
call :sudo /c start /d "%CD%" %*

goto :EOF


:sudo
endlocal && powershell -Command Start-Process "cmd.exe" -Args '%*' %SUDO_HIDDEN% -Verb RunAs
goto :EOF


:print_usage
for /f "tokens=* delims=:" %%s in ( 'findstr "^::" "%~f0"' ) do echo:%%s
goto :EOF


:check_reqs
for %%p in ( powershell.exe ) do if "%%~$PATH:p" == "" (
	echo:%%~p is required>&2
	exit /b 1
)
goto :EOF
