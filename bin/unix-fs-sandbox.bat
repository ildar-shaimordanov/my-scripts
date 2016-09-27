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
:: Version 0.2 Beta.
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
:: http://www.sevenforums.com/tutorials/65828-drive-icon-change.html
:: http://www.sevenforums.com/tutorials/66118-drive-rename.html

:: ========================================================================

@echo off

setlocal

set "sandbox-version=0.2 Beta"
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

if defined sandbox-error (
	call :sandbox-error "%sandbox-error%"
	exit /b 1
)

if errorlevel 1 exit /b 0

for %%f in ( "%sandbox-disk%\." ) do if not "%%~dpf" == "%%~ff" (
	call :sandbox-error "invalid disk name: %sandbox-disk%"
	exit /b 1
)

for %%f in ( "%sandbox-disk%" ) do set "sandbox-disk=%%~df"
for %%f in ( "%sandbox-path%" ) do set "sandbox-path=%%~ff"

:: ========================================================================

if not defined sandbox-install (
	call :sandbox-print-settings
	exit /b 0
)

:: ========================================================================

echo:Create sandbox "%sandbox-path%"
call :sandbox-mkdir "%sandbox-path%" || exit /b 1

echo:Create UNIX filesystem hierarchy
call :sandbox-mkdir-hier "%sandbox-dirs:;=" "%" || exit /b 1

echo:Create mandatory directories
call :sandbox-mkdir-hier "%sandbox-mandatory-dirs:;=" "%" || exit /b 1

echo:Install mandatory files
call :sandbox-write-file release "etc\sandbox-release" || exit /b 1
for %%f in (
	"etc\rc.bat"
	"etc\init.d\vdisk.bat"
	"etc\rc.d\rc.pause"
	"etc\rc.d\rc.start"
	"etc\rc.d\rc.stop"
) do (
	call :sandbox-write-file static "%%~f" || exit /b 1
)

set "sandbox-reg-device=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"

if defined sandbox-persistent (
	echo:Create the Registry entry
	echo:%sandbox-reg-device%\%sandbox-disk%
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
echo:Make dir: "%~1"
md "%~1"
dir /ad "%~1" >nul 2>nul
goto :EOF

:sandbox-mkdir-hier
for %%f in ( %* ) do if not "%%~f" == "" (
	call :sandbox-mkdir "%sandbox-path%\%%~f" || exit /b 1
)
goto :EOF

:: ========================================================================

:sandbox-write-file-static
for /f "tokens=1,* delims= " %%a in ( '
	findstr /l /b "::%~1" "%~f0" 
' ) do (
	echo:%%~b
)
goto :EOF

:sandbox-write-file-release
call :sandbox-write-file-static "%~1"
echo:%sandbox-disk%;%sandbox-path%;%sandbox-name%
goto :EOF

:sandbox-write-file
echo:Write file: "%sandbox-path%\%~2"
call :sandbox-write-file-%~1 "%~2" > "%sandbox-path%\%~2"
if errorlevel 1 exit /b 1
if defined sandbox-readonly attrib +r "%sandbox-path%\%~2"
goto :EOF

:: ========================================================================

:: The following part of the file represents the contents of files that 
:: will be installed as the part of the sandbox. The beginning of each 
:: file is marked with "::FILE-BEGIN filename" and the end of the file is 
:: marked with "::FILE-END". 

:: ========================================================================

::FILE-BEGIN etc\rc.bat
::etc\rc.bat :: This file is part of UNIX FS SANDBOX
::etc\rc.bat @echo off
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat setlocal
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat set "rc-etc=%~dp0rc.d"
::etc\rc.bat set "rc-list="
::etc\rc.bat set "rc-skip-pause="
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat if "%~1" == "skip-pause" (
::etc\rc.bat 	set "rc-skip-pause=1"
::etc\rc.bat 	shift /1
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat if "%~1" == "" (
::etc\rc.bat 	>&2 echo:Usage: %~n0 {start^|stop}
::etc\rc.bat 	goto :EOS
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat rem
::etc\rc.bat rem Looking for run-lists
::etc\rc.bat rem
::etc\rc.bat dir /a-d "%rc-etc%\rc.list" >nul 2>&1
::etc\rc.bat if not errorlevel 1 (
::etc\rc.bat 	echo:Run-list "%rc-etc%\rc.list" found. Continue...
::etc\rc.bat 	for /f "usebackq eol=#" %%a in ( "%rc-etc%\rc.list" ) do (
::etc\rc.bat 		if "%~1" == "start" call :rc-list-append  "%%~a"
::etc\rc.bat 		if "%~1" == "stop"  call :rc-list-prepend "%%~a"
::etc\rc.bat 	)
::etc\rc.bat ) else (
::etc\rc.bat 	dir /a-d "%rc-etc%\rc.%~1" >nul 2>&1
::etc\rc.bat 	if errorlevel 1 (
::etc\rc.bat 		>&2 echo:Run-list "%rc-etc%\rc.%~1" not found. Exit...
::etc\rc.bat 		goto :EOS
::etc\rc.bat 	)
::etc\rc.bat 	echo Processing "%rc-etc%\rc.%~1".
::etc\rc.bat 	for /f "usebackq eol=#" %%a in ( "%rc-etc%\rc.%~1" ) do (
::etc\rc.bat 		call :rc-list-append  "%%~a"
::etc\rc.bat 	)
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat rem
::etc\rc.bat rem Execute start/stop commands
::etc\rc.bat rem
::etc\rc.bat if not defined rc-list (
::etc\rc.bat 	>&2 echo:Empty run-list. Nothing to execute...
::etc\rc.bat 	goto :EOS
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat for %%a in ( 
::etc\rc.bat 	"%rc-list:;=" "%" 
::etc\rc.bat ) do if not "%%~a" == "" if not exist "%rc-etc%\..\init.d\%%~a.bat" (
::etc\rc.bat 	>&2 echo:%%~a not found
::etc\rc.bat ) else (
::etc\rc.bat 	echo:%DATE% %TIME%: Executing "%%~a"...
::etc\rc.bat 	call "%rc-etc%\..\init.d\%%~a.bat" "%~1"
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat rem
::etc\rc.bat rem Make a pause (if it needs) and finish
::etc\rc.bat rem
::etc\rc.bat
::etc\rc.bat :EOS
::etc\rc.bat if not defined rc-skip-pause if exist "%rc-etc%\rc.pause" (
::etc\rc.bat 	echo:To escape pausing remove the following file:
::etc\rc.bat 	echo:"%rc-etc%\rc.pause".
::etc\rc.bat 	pause
::etc\rc.bat )
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat endlocal
::etc\rc.bat goto :EOF
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat :rc-list-prepend
::etc\rc.bat set "rc-list=%~1;%rc-list%"
::etc\rc.bat goto :EOF
::etc\rc.bat
::etc\rc.bat
::etc\rc.bat :rc-list-append
::etc\rc.bat set "rc-list=%rc-list%;%~1"
::etc\rc.bat goto :EOF
::FILE-END


::FILE-BEGIN etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat :: This file is part of UNIX FS SANDBOX
::etc\init.d\vdisk.bat @echo off
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat setlocal
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if not exist "%~dp0..\sandbox-release" (
::etc\init.d\vdisk.bat 	>&2 echo:"%~dp0..\sandbox-release" not found
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat for /f "usebackq eol=# delims=; tokens=1,2,*" %%a in (
::etc\init.d\vdisk.bat 	"%~dp0..\sandbox-release"
::etc\init.d\vdisk.bat ) do (
::etc\init.d\vdisk.bat 	set "sandbox-disk=%%~a"
::etc\init.d\vdisk.bat 	set "sandbox-path=%%~b"
::etc\init.d\vdisk.bat 	set "sandbox-name=%%~c"
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if not defined sandbox-disk (
::etc\init.d\vdisk.bat 	>&2 echo:Sandbox disk not defined
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if not defined sandbox-path (
::etc\init.d\vdisk.bat 	>&2 echo:Sandbox path not defined
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if "%~1" == "start" (
::etc\init.d\vdisk.bat 	echo:Mapping vdisk %sandbox-disk% =^> %sandbox-path%
::etc\init.d\vdisk.bat 	subst %sandbox-disk% "%sandbox-path%"
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if "%~1" == "stop" (
::etc\init.d\vdisk.bat 	echo:Release vdisk %sandbox-disk% =^> %sandbox-path%
::etc\init.d\vdisk.bat 	subst %sandbox-disk% /D
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat if "%~1" == "status" (
::etc\init.d\vdisk.bat 	subst | findstr /i /b "%sandbox-disk%"
::etc\init.d\vdisk.bat 	goto :EOS
::etc\init.d\vdisk.bat )
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat >&2 echo:Usage: %~n0 {start^|stop^|status}
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat
::etc\init.d\vdisk.bat :EOS
::etc\init.d\vdisk.bat endlocal
::etc\init.d\vdisk.bat goto :EOF
::FILE-END


::FILE-BEGIN etc\rc.d\rc.pause
::etc\rc.d\rc.pause # This file is part of UNIX FS SANDBOX
::etc\rc.d\rc.pause #
::etc\rc.d\rc.pause # To escape pausing, remove this file
::FILE-END


::FILE-BEGIN etc\rc.d\rc.list
::etc\rc.d\rc.list # This file is part of UNIX FS SANDBOX
::etc\rc.d\rc.list #
::etc\rc.d\rc.list # There is list of names of scripts from the directory "etc/init.d" to be 
::etc\rc.d\rc.list # executed while starting and stopping the sandbox. One name is per one 
::etc\rc.d\rc.list # line. The order of the script execution depends on the current mode. 
::etc\rc.d\rc.list # Wjhile starting, this list is assumed from top to bottom. 
::etc\rc.d\rc.list # While stopping, this list is assumed from bottom to top. 
::etc\rc.d\rc.list #
::etc\rc.d\rc.list # If you need to change the order of execution, use two separate 
::etc\rc.d\rc.list # corresponding lists:
::etc\rc.d\rc.list # -- "etc/rc.d/rc.start" for starting
::etc\rc.d\rc.list # -- "etc/rc.d/rc.stop" for stopping
::etc\rc.d\rc.list vdisk
::FILE-END


::FILE-BEGIN etc\rc.d\rc.start
::etc\rc.d\rc.start # This file is part of UNIX FS SANDBOX
::etc\rc.d\rc.start #
::etc\rc.d\rc.start # There is list of names of scripts from the directory "etc/init.d" to be 
::etc\rc.d\rc.start # executed while starting the sandbox. One name is per one line. The order 
::etc\rc.d\rc.start # of names corresponds to the order of their execution.
::etc\rc.d\rc.start vdisk
::FILE-END


::FILE-BEGIN etc\rc.d\rc.stop
::etc\rc.d\rc.stop # This file is part of UNIX FS SANDBOX
::etc\rc.d\rc.stop #
::etc\rc.d\rc.stop # There is list of names of scripts from the directory "etc/init.d" to be 
::etc\rc.d\rc.stop # executed while stopping the sandbox. One name is per one line. The order 
::etc\rc.d\rc.stop # of names corresponds to the order of their execution.
::etc\rc.d\rc.stop vdisk
::FILE-END


::FILE-BEGIN etc\sandbox-release
::etc\sandbox-release # This file is part of UNIX FS SANDBOX
::etc\sandbox-release #
::etc\sandbox-release # This file contains the detailedd information regarding the current 
::etc\sandbox-release # sandbox. It consists of the following fields separated with semicolon:
::etc\sandbox-release # -- the virtual drive to which a path will be assigned;
::etc\sandbox-release # -- the directory where the sandbox is installed;
::etc\sandbox-release # -- the sandbox name.
::FILE-END

:: ========================================================================

:: EOF
