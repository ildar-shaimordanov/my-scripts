::HELP Create sandbox for UNIX like filesystem structure
::HELP
::HELP -p PATH       set a directory where the sandbox will be installed
::HELP -d DISK       set a virtual drive to which a path will be assigned
::HELP -n NAME       set a name of the sandbox
::HELP -f DIRS       set a list of directories whcih will be created
::HELP
::HELP --install     start installation
::HELP --persistent  install persistent virtual drive
::HELP --readonly    set read only attribute over all installed files
::HELP
::HELP --help        display this help and exit
::HELP --version     display version information and exit

:: ========================================================================

:: RELEASE NOTES
::
:: 2016
::
:: Version 0.5 Beta
:: Improve handling empty options.
::
:: Version 0.4 Beta
:: Improve installation of mandatory files.
:: Improve logging.
::
:: Version 0.3 Beta
:: Rework installation of mandatory files.
::
:: Version 0.2 Beta
:: It is implemented as the command line tool.
::
::
:: 2009-2010
::
:: Initially it was GUI tool named "unix-sandbox-in-windows_install.hta" 
:: developed as the part of the another project "jsxt" hosted on GitHub 
:: https://github.com/ildar-shaimordanov/jsxt 
:: (former https://code.google.com/p/jsxt).
::
:: The latest changes was done in the commit 976a98f. 
::
::
:: 2008
::
:: Most probably first release.
:: No information, if it was published at all.

:: ========================================================================

:: TODO
::
:: -- uninstalling feature
::
:: -- drive icon / label
::    http://www.sevenforums.com/tutorials/65828-drive-icon-change.html
::    http://www.sevenforums.com/tutorials/66118-drive-rename.html
::
:: -- options for creating user-specific or system-wide shortcuts to
::    Desktop, Start Menu

:: ========================================================================

@echo off

setlocal

set "sandbox-version=0.5 Beta"
set "sandbox-copyright=Copyright (C) 2008-2010, 2016 Ildar Shaimordanov"

set "sandbox-path=C:\sandbox"
set "sandbox-disk=X:"
set "sandbox-name=UNIX Sandbox"
set "sandbox-dirs=bin;etc;home;lib;opt;tmp;usr;var"
set "sandbox-mandatory-dirs=etc\rc.d;etc\init.d"
set "sandbox-install="
set "sandbox-persistent="
set "sandbox-readonly="

set "sandbox-error="

:: ========================================================================

call :sandbox-parse-opts %*

:: Bad option provided
if defined sandbox-error (
	call :sandbox-error "%sandbox-error%"
	exit /b 1
)

:: --help or --version provided
if errorlevel 1 exit /b 0

if not defined sandbox-disk (
	call :sandbox-error "Empty disk is not allowed"
	exit /b 1
)

if not defined sandbox-path (
	call :sandbox-error "Empty path is not allowed"
	exit /b 1
)

if not defined sandbox-dirs (
	call :sandbox-error "Empty dir list is not allowed"
	exit /b 1
)

:: Validate disk name
for %%f in ( "%sandbox-disk%\." ) do if not "%%~dpf" == "%%~ff" (
	call :sandbox-error "invalid disk name: %sandbox-disk%"
	exit /b 1
)

:: Canonicalize disk name and path
for %%f in ( "%sandbox-disk%" ) do set "sandbox-disk=%%~df"
for %%f in ( "%sandbox-path%" ) do set "sandbox-path=%%~ff"

:: ========================================================================

if not defined sandbox-install (
	call :sandbox-print-settings
	exit /b 0
)

echo:======================================================================
echo:
echo:Starting:
echo:%~n0 %*
echo:
echo:======================================================================
echo:

call :sandbox-log "Create sandbox: %sandbox-name%"
call :sandbox-mkdir "%sandbox-path%" || exit /b 1

call :sandbox-log "Create UNIX filesystem hierarchy"
call :sandbox-mkdir-hier "%sandbox-dirs:;=" "%" || exit /b 1

call :sandbox-log "Create mandatory directories"
call :sandbox-mkdir-hier "%sandbox-mandatory-dirs:;=" "%" || exit /b 1

call :sandbox-log "Install mandatory files"
call :sandbox-write-files "%~f0" || exit /b 1

set "sandbox-reg-device=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"

if defined sandbox-persistent (
	call :sandbox-log "Create the Registry entry"
	call :sandbox-log "%sandbox-reg-device%\%sandbox-disk%"
	reg add "%sandbox-reg-device%" /v "%sandbox-disk%" /t REG_SZ /d "\??\%sandbox-path%"
)

echo:
echo:======================================================================
echo:
echo:	Installation has been successfully finished.
echo:
echo:	Start and stop the sandbox as follows:
echo:	%sandbox-path%\etc\rc.bat start
echo:	%sandbox-path%\etc\rc.bat stop
echo:
echo:======================================================================

endlocal
exit /b 0

:: ========================================================================

:sandbox-parse-opts

:sandbox-parse-opts-start
if "%~1" == "" goto :sandbox-parse-opts-end

if "%~1" == "--help" (
	call :sandbox-help
	exit /b 1
)

if "%~1" == "--version" (
	call :sandbox-version
	exit /b 1
)

if "%~1" == "--install" (
	set "sandbox-install=1"
	shift /1
) else if "%~1" == "--persistent" (
	set "sandbox-persistent=1"
	shift /1
) else if "%~1" == "--readonly" (
	set "sandbox-readonly=1"
	shift /1
) else if "%~1" == "-p" (
	set "sandbox-path=%~2"
	shift /1
	shift /1
) else if "%~1" == "-d" (
	set "sandbox-disk=%~2"
	shift /1
	shift /1
) else if "%~1" == "-n" (
	set "sandbox-name=%~2"
	shift /1
	shift /1
) else if "%~1" == "-f" (
	set "sandbox-dirs=%~2"
	shift /1
	shift /1
) else (
	set "sandbox-error=Bad option: %~1"
	exit /b 1
)

goto :sandbox-parse-opts-start
:sandbox-parse-opts-end

goto :EOF

:: ========================================================================

:sandbox-help
echo:Usage: %~n0 OPTIONS
for /f "tokens=1,* delims= " %%a in ( '
	findstr /b "::HELP" "%~f0"
' ) do (
	echo:%%~b
)
goto :EOF

:sandbox-version
echo:%~n0 %sandbox-version%
goto :EOF

:sandbox-error
>&2 echo:%~n0: %~1
>&2 echo:Try "%~n0 --help" for details.
goto :EOF

:sandbox-log
echo:%DATE% %TIME%: %~1
goto :EOF

:: ========================================================================

:sandbox-print-settings-option
set /p "=%~1 = " < nul
if     defined %~2 echo:Yes
if not defined %~2 echo:No
goto :EOF

:sandbox-print-settings
echo:Settings for installation ^(with "--install" option^)
echo:

echo:Name  = %sandbox-name%
echo:Drive = %sandbox-disk%
echo:Path  = %sandbox-path%
echo:

echo:Options
call :sandbox-print-settings-option "Persistent Drive" "sandbox-persistent"
call :sandbox-print-settings-option "Read-Only Mode  " "sandbox-readonly"
echo:

echo:File system hierarchy
for %%f in ( "%sandbox-dirs:;=" "%" ) do (
	echo:    %sandbox-path%\%%~f
)

goto :EOF

:: ========================================================================

:sandbox-mkdir
call :sandbox-log "Make dir: %~1"
md "%~1"
dir /ad "%~1" >nul 2>nul
goto :EOF

:sandbox-mkdir-hier
for %%f in ( %* ) do if not "%%~f" == "" (
	call :sandbox-mkdir "%sandbox-path%\%%~f" || exit /b 1
)
goto :EOF

:: ========================================================================

:sandbox-write-files
setlocal enabledelayedexpansion

set "sandbox-filename="

for /f "delims=] tokens=1,*" %%r in ( '
	find /n /v "" "%~1"
' ) do for /f "tokens=1,2,*" %%a in ( 
	"LINE %%~s" 
) do if "%%~b" == "::FILE-BEGIN" (
	set "sandbox-filename=%sandbox-path%\%%~c"
	call :sandbox-log "Write file: !sandbox-filename!"
	for /f "tokens=*" %%f in ( "!sandbox-filename!" ) do call :sandbox-mkdir "%%~dpf" || exit /b 1
	type nul > "!sandbox-filename!" || exit /b 1
) else if "%%~b" == "::FILE-END" (
	if defined sandbox-readonly attrib +r "!sandbox-filename!"
	set "sandbox-filename="
) else if defined sandbox-filename (
	>>"!sandbox-filename!" (
		setlocal disabledelayedexpansion
		if "%%~b" == "::FILE-CALL" (
			call %%~c
		) else (
			echo:%%~s
		)
		endlocal
	) || exit /b 1
)

endlocal
goto :EOF

:: ========================================================================

:: The following part of the file represents the contents of files that 
:: will be installed as the part of the sandbox. The beginning of each 
:: file is marked with "::FILE-BEGIN filename" and the end of the file is 
:: marked with "::FILE-END". The special marker "::FILE-CALL command" is 
:: used to put the result of execution of the specified command to the 
:: result file.

:: ========================================================================

::FILE-BEGIN etc\rc.bat
:: This file is part of UNIX FS SANDBOX
@echo off


setlocal


set "rc-etc=%~dp0rc.d"
set "rc-list="
set "rc-skip-pause="


if "%~1" == "skip-pause" (
	set "rc-skip-pause=1"
	shift /1
)


if "%~1" == "" (
	>&2 echo:Usage: %~n0 {start^|stop}
	goto :EOS
)


rem
rem Looking for run-lists
rem
dir /a-d "%rc-etc%\rc.list" >nul 2>&1
if not errorlevel 1 (
	echo:Run-list "%rc-etc%\rc.list" found. Continue...
	for /f "usebackq eol=#" %%a in ( "%rc-etc%\rc.list" ) do (
		if "%~1" == "start" call :rc-list-append  "%%~a"
		if "%~1" == "stop"  call :rc-list-prepend "%%~a"
	)
) else (
	dir /a-d "%rc-etc%\rc.%~1" >nul 2>&1
	if errorlevel 1 (
		>&2 echo:Run-list "%rc-etc%\rc.%~1" not found. Exit...
		goto :EOS
	)
	echo Processing "%rc-etc%\rc.%~1".
	for /f "usebackq eol=#" %%a in ( "%rc-etc%\rc.%~1" ) do (
		call :rc-list-append  "%%~a"
	)
)


rem
rem Execute start/stop commands
rem
if not defined rc-list (
	>&2 echo:Empty run-list. Nothing to execute...
	goto :EOS
)


for %%a in ( 
	"%rc-list:;=" "%" 
) do if not "%%~a" == "" if not exist "%rc-etc%\..\init.d\%%~a.bat" (
	>&2 echo:%%~a not found
) else (
	echo:%DATE% %TIME%: Executing "%%~a"...
	call "%rc-etc%\..\init.d\%%~a.bat" "%~1"
)


rem
rem Make a pause (if it needs) and finish
rem

:EOS
if not defined rc-skip-pause if exist "%rc-etc%\rc.pause" (
	echo:To escape pausing remove the following file:
	echo:"%rc-etc%\rc.pause".
	pause
)


endlocal
goto :EOF


:rc-list-prepend
set "rc-list=%~1;%rc-list%"
goto :EOF


:rc-list-append
set "rc-list=%rc-list%;%~1"
goto :EOF
::FILE-END


::FILE-BEGIN etc\init.d\vdisk.bat
:: This file is part of UNIX FS SANDBOX
@echo off


setlocal


if not exist "%~dp0..\sandbox-release" (
	>&2 echo:"%~dp0..\sandbox-release" not found
	goto :EOS
)

for /f "usebackq eol=# delims=; tokens=1,2,*" %%a in (
	"%~dp0..\sandbox-release"
) do (
	set "sandbox-disk=%%~a"
	set "sandbox-path=%%~b"
	set "sandbox-name=%%~c"
)

if not defined sandbox-disk (
	>&2 echo:Sandbox disk not defined
	goto :EOS
)

if not defined sandbox-path (
	>&2 echo:Sandbox path not defined
	goto :EOS
)


if "%~1" == "start" (
	echo:Mapping vdisk %sandbox-disk% =^> %sandbox-path%
	subst %sandbox-disk% "%sandbox-path%"
	goto :EOS
)


if "%~1" == "stop" (
	echo:Release vdisk %sandbox-disk% =^> %sandbox-path%
	subst %sandbox-disk% /D
	goto :EOS
)


if "%~1" == "status" (
	subst | findstr /i /b "%sandbox-disk%"
	goto :EOS
)


>&2 echo:Usage: %~n0 {start^|stop^|status}


:EOS
endlocal
goto :EOF
::FILE-END


::FILE-BEGIN etc\rc.d\rc.pause
## This file is part of UNIX FS SANDBOX
#
# To escape pausing, remove this file
::FILE-END


::FILE-BEGIN etc\rc.d\rc.list
## This file is part of UNIX FS SANDBOX
#
# There is list of names of scripts from the directory "etc/init.d" to be 
# executed while starting and stopping the sandbox. One name is per one 
# line. The order of the script execution depends on the current mode. 
# Wjhile starting, this list is assumed from top to bottom. 
# While stopping, this list is assumed from bottom to top. 
#
# If you need to change the order of execution, use two separate 
# corresponding lists:
# -- "etc/rc.d/rc.start" for starting
# -- "etc/rc.d/rc.stop" for stopping
vdisk
::FILE-END


::FILE-BEGIN etc\rc.d\rc.start
## This file is part of UNIX FS SANDBOX
#
# There is list of names of scripts from the directory "etc/init.d" to be 
# executed while starting the sandbox. One name is per one line. The order 
# of names corresponds to the order of their execution.
vdisk
::FILE-END


::FILE-BEGIN etc\rc.d\rc.stop
## This file is part of UNIX FS SANDBOX
#
# There is list of names of scripts from the directory "etc/init.d" to be 
# executed while stopping the sandbox. One name is per one line. The order 
# of names corresponds to the order of their execution.
vdisk
::FILE-END


::FILE-BEGIN etc\sandbox-release
## This file is part of UNIX FS SANDBOX
#
# This file contains the detailedd information regarding the current 
# sandbox. It consists of the following fields separated with semicolon:
# -- the virtual drive to which a path will be assigned;
# -- the directory where the sandbox is installed;
# -- the sandbox name.
::FILE-CALL echo:%sandbox-disk%;%sandbox-path%;%sandbox-name%
::FILE-END

:: ========================================================================

:: EOF
