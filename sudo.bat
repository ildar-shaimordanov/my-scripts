::NAME
::
::    sudo - check privileges or run a command with the elevated privileges
::
::SYNOPSIS
::
::Check privileges
::    sudo /c
::
::Run a command with the elevated privileges
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
::Based on the solutions suggested in these threads:
::https://www.dostips.com/forum/viewtopic.php?f=3&t=9212
::https://stackoverflow.com/a/27717205/3627676
::https://stackoverflow.com/a/30921854/3627676
@echo off

if /i "%~1" == "/?" goto :print_usage
if /i "%~1" == "/h" goto :print_usage
if /i "%~1" == "/c" goto :check_priv

call :check_reqs reg.exe || goto :EOF

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
for %%p in ( "%~1" ) do if "%%~$PATH:p" == "" (
	echo:%%~p is required>&2
	exit /b 1
)
exit /b 0


rem 2.4.2.4 Well-Known SID Structures
rem https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
:check_priv
setlocal

set "S-1-16-0=untrusted"
set "S-1-16-4096=low"
set "S-1-16-8192=medium"
set "S-1-16-8448=medium-plus"
set "S-1-16-12288=high"
set "S-1-16-16384=system"
set "S-1-16-20480=protected"
set "S-1-16-28672=secure"

for /f "tokens=2" %%a in ( '
	call "%SystemRoot%\system32\whoami.exe" /groups /fo list ^| findstr /e S-1-16-[0-9]*
' ) do if defined %%~a (
	call echo:%%%%~a%%
	goto :EOF
)

echo:unknown
goto :EOF
