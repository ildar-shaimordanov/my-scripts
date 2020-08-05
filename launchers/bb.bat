:: BusyBox launcher
::
:: bb [-l | -c "script" | options]
::
::   -l           Run shell in interactive mode
::   -c "script"  Run shell and pass a script
::
:: Run "bb --help" for the options usage details.
::
:: Learn more about BusyBox following these links:
::
:: https://busybox.net/
:: https://frippery.org/busybox/
:: https://github.com/rmyorston/busybox-w32
@echo off

if /i "%~1" == "" (
	"%~f0" sed -n "/^::/!q; s/^:: \?//p" "%~f0"
	goto :EOF
)

:: ========================================================================

setlocal

:: Locate the history file next to Busybox executable or under TEMP dir
::set "HISTFILE=%~dp0.ash_history"
set "HISTFILE=%TEMP%\.ash_history"

:: Another possible way to locate the history file is to set HOME dir
::for %%p in ( "%~dp0." ) do set "HOME=%%~fp"

:: ========================================================================

for %%n in ( "-l" "-c" ) do if "%~1" == "%%~n" (
	"%~dp0busybox64.exe" sh %*
	goto :EOF
)

"%~dp0busybox64.exe" %*
goto :EOF

:: ========================================================================

:: EOF
