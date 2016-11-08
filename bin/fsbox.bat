@echo off

goto :sandbox-main

:: ========================================================================

::PIE-BEGIN	HELP
Create sandbox for UNIX like filesystem structure

-p PATH       set a directory where the sandbox will be installed
-d DISK       set a virtual drive to which a path will be assigned
-n NAME       set a name of the sandbox
-f DIRS       set a list of directories whcih will be created

--install     start installation
--persistent  install persistent virtual drive
--readonly    set read only attribute over all installed files

--help        display this help and exit
--version     display version information and exit
::PIE-END	STOP

:: ========================================================================

::PIE-BEGIN	RELEASE-NOTES
RELEASE NOTES

2016

Version 0.7.2 Beta
Reorder checking for pie-commands.

Version 0.7.1 Beta
Fix bug with pie-createfile.

Version 0.7 Beta
Improve pie-comments; add support for pie-codes; simplify the code.

Version 0.6 beta
Introduce PIE (the Plain, Impressive and Executable documentation format).

Version 0.5 Beta
Improve handling empty options.
Added generating of the file etc\sandbox-installed.log.

Version 0.4 Beta
Improve installation of mandatory files.
Improve logging.

Version 0.3 Beta
Rework installation of mandatory files.

Version 0.2 Beta
It is implemented as the command line tool.


2009-2010

Initially it was GUI tool named "unix-sandbox-in-windows_install.hta" 
developed as the part of the another project "jsxt" hosted on GitHub 
https://github.com/ildar-shaimordanov/jsxt 
(former https://code.google.com/p/jsxt).

The latest changes was done in the commit 976a98f. 


2008

Most probably first release.
No information, if it was published at all.
::PIE-END	STOP

:: ========================================================================

::PIE-BEGIN	TODO
TODO

-- uninstalling feature

-- drive icon / label
   http://www.sevenforums.com/tutorials/65828-drive-icon-change.html
   http://www.sevenforums.com/tutorials/66118-drive-rename.html

-- options for creating user-specific or system-wide shortcuts to
   Desktop, Start Menu
::PIE-END	STOP

:: ========================================================================

:sandbox-main

setlocal

set "sandbox-version=0.7.2 Beta"
set "sandbox-copyright=Copyright (C) 2008-2010, 2016 Ildar Shaimordanov"

set "sandbox-path=C:\sandbox"
set "sandbox-disk=X:"
set "sandbox-name=UNIX Sandbox"
set "sandbox-dirs=bin;etc;home;lib;opt;tmp;usr;var"
set "sandbox-mandatory-dirs=etc\rc.d;etc\init.d"
set "sandbox-install="
set "sandbox-persistent="
set "sandbox-readonly="

set "sandbox-reg-device=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"

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

set "sandbox-common-header=This file is part of UNIX FS SANDBOX"

call :sandbox-log "Install mandatory files"
call :pie "WRITE-FILES" "%~f0" || exit /b 1

if defined sandbox-persistent (
	call :sandbox-log "Create the Registry entry"
	call :sandbox-log "[%sandbox-reg-device%]"
	call :sandbox-log "%sandbox-disk% = %sandbox-path%"
	reg add "%sandbox-reg-device%" /v "%sandbox-disk%" /t REG_SZ /d "\??\%sandbox-path%" /f
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
	echo:Usage: %~n0 OPTIONS
	echo:
	call :pie HELP "%~f0"
	exit /b 1
)

if "%~1" == "--version" (
	echo:%~n0 %sandbox-version%
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
echo:Run "%~n0 --help" to learn more about options
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

:sandbox-log-writefile
for /f "tokens=*" %%f in ( "%pie-filename%" ) do call :sandbox-mkdir "%%~dpf" || exit /b 1
call :sandbox-log "Write file: %pie-filename%"
goto :EOF

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

:pie
setlocal enabledelayedexpansion

set "pie-enabled="
set "pie-filename="
set "pie-openfile="
set "pie-comment="
set "pie-code="

for /f "delims=] tokens=1,*" %%r in ( '
	find /n /v "" "%~f2" 
' ) do for /f "tokens=1,2,*" %%a in (
	"LINE %%s"
) do if not defined pie-enabled (
	if "%%b %%~c" == "::PIE-BEGIN %~1" set "pie-enabled=1"
) else if "%%b" == "::PIE-END" (
	set "pie-enabled="
	set "pie-filename="
	set "pie-openfile="
	set "pie-comment="
	set "pie-code="
	if "%%~c" == "STOP" (
		endlocal
		goto :EOF
	)
) else if "%%b" == "::PIE-COMMENT-BEGIN" (
	set "pie-comment=1"
) else if "%%b" == "::PIE-COMMENT-END" (
	set "pie-comment="
) else if defined pie-comment (
	rem
) else if "%%b" == "::PIE-SETFILE" (
	call set "pie-filename=%%~c"
	set "pie-openfile="
) else if "%%b" == "::PIE-OPENFILE" (
	set "pie-openfile=1"
) else if "%%b" == "::PIE-CREATEFILE" (
	set "pie-openfile=1"
	type nul >"!pie-filename!" || exit /b 1
) else if "%%b" == "::PIE-CODE-BEGIN" (
	set "pie-code=1"
) else if "%%b" == "::PIE-CODE-END" (
	set "pie-code="
) else(
	if defined pie-openfile (
		>>"!pie-filename!" (
			setlocal disabledelayedexpansion
			if "%%b" == "::PIE-ECHO" (
				call echo:%%~c
			) else if "%%b" == "::PIE-CALL" (
				call %%c
			) else (
				echo:%%s
			)
			endlocal
		) || exit /b 1
	) else (
		(
			setlocal disabledelayedexpansion
			if "%%b" == "::PIE-ECHO" (
				call echo:%%~c
			) else if "%%b" == "::PIE-CALL" (
				call %%c
			) else (
				echo:%%s
			)
			endlocal
		) || exit /b 1
	)
)

endlocal
goto :EOF

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\rc.bat"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	:: %sandbox-common-header%
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
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\init.d\vdisk.bat"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	:: %sandbox-common-header%
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
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\sandbox-installed.log"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	:: %sandbox-common-header%
::
:: It was generated automatically while installing sandbox

::PIE-CALL	:sandbox-install-log-reg
::PIE-CALL	:sandbox-install-log-dirs
::PIE-CALL	:sandbox-install-log-files
::PIE-END

:sandbox-install-log-reg
if defined sandbox-persistent echo:REGISTRY %sandbox-disk% %sandbox-reg-device%
goto :EOF

:sandbox-install-log-dirs
for %%f in ( 
	"%sandbox-dirs:;=" "%" 
	"%sandbox-mandatory-dirs:;=" "%" 
) do if not "%%~f" == "" (
	echo:DIR %sandbox-path%\%%~f
)
goto :EOF

:sandbox-install-log-files
for /f "tokens=1,*" %%a in ( '
	findstr /b "::PIE-SETFILE" "%~f0"
' ) do (
	call echo:FILE %%~b
)
goto :EOF

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\rc.d\rc.pause"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	## %sandbox-common-header%
#
# To escape pausing, remove this file
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\rc.d\rc.list"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	## %sandbox-common-header%
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
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\rc.d\rc.start"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	## %sandbox-common-header%
#
# There is list of names of scripts from the directory "etc/init.d" to be 
# executed while starting the sandbox. One name is per one line. The order 
# of names corresponds to the order of their execution.
vdisk
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\rc.d\rc.stop"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	## %sandbox-common-header%
#
# There is list of names of scripts from the directory "etc/init.d" to be 
# executed while stopping the sandbox. One name is per one line. The order 
# of names corresponds to the order of their execution.
vdisk
::PIE-END

:: ========================================================================

::PIE-BEGIN	WRITE-FILES
::PIE-SETFILE	"%sandbox-path%\etc\sandbox-release"
::PIE-CALL	:sandbox-log-writefile
::PIE-CREATEFILE
::PIE-ECHO	## %sandbox-common-header%
#
# This file contains the detailed information regarding the current 
# sandbox. It consists of the following fields separated with semicolon:
# -- the virtual drive to which a path will be assigned;
# -- the directory where the sandbox is installed;
# -- the sandbox name.
::PIE-ECHO	%sandbox-disk%;%sandbox-path%;%sandbox-name%
::PIE-END

:: ========================================================================

:: EOF
