@echo off

:: ========================================================================

if "%~1" == "" (
	call :error "Command not specified"
	goto :EOF
)

:: ========================================================================

if /i "%~1" == "help" goto :help

:: ========================================================================

if /i "%~1" == "list" (
	for /f "tokens=1,* delims=-" %%p in ( ' dir /b "%~dpn0-*.txt" 2^>nul ' ) do echo:%%~nq
	goto :EOF
)

:: ========================================================================

setlocal

:: ========================================================================

if /i "%~1" == "run" (
	set "syncup.nocopy="
) else if /i "%~1" == "test" (
	set "syncup.nocopy=-nocopy"
) else (
	call :error "Unknown command: "%~1""
	goto EOS
)

:: ========================================================================

if     "%~2" == ""   goto :configure.bare
if     "%~2" == "-d" goto :configure.disk
if not "%~2" == ""   goto :configure.task

:: ========================================================================

:configure.bare
set "syncup.mode=bare"
set "syncup.drive=%cd:~0,2%"

if not exist "%syncup.drive%\.sync\." (
	call :error "Unable to recognize a target"
	goto :EOS
)

set "syncup.rootdir=%syncup.drive%\.sync\bin"
set "syncup.logfile=%syncup.rootdir%\..\sync.log"
set "syncup.cfgfile=%syncup.rootdir%\..\sync.cfg"
set "syncup.lnkfile=%TEMP%\%~n0-%syncup.mode%-%syncup.drive::=%-links.txt"
goto :starting

:: ========================================================================

:configure.disk
if "%~3" == "" (
	call :error "Target drive not specified"
	goto :EOS
)

set "syncup.mode=disk"
set "syncup.drive="

for /f "skip=1" %%d in ( 'wmic LogicalDisk GET Caption' ) do if /i "%~3" == "%%~d" set "syncup.drive=%%~d"
if not defined syncup.drive (
	call :error "Bad target drive "%~3""
	goto :EOS
)

set "syncup.rootdir=%syncup.drive%\.sync\bin"
set "syncup.logfile=%syncup.rootdir%\..\sync.log"
set "syncup.cfgfile=%syncup.rootdir%\..\sync.cfg"
set "syncup.lnkfile=%syncup.rootdir%\..\%~n0-%syncup.mode%-%syncup.drive::=%-links.txt"
goto :starting

:: ========================================================================

:configure.task
if not exist "%~dpn0-%~2.txt" (
	call :error "Task not found "%~2""
	goto EOS
)

set "syncup.mode=task"
set "syncup.cfgfile=%~dpn0-%~2.txt"

set "syncup.drive="

if exist "%syncup.cfgfile%" for /f "tokens=1,*" %%c in ( ' findstr "^-o " "%syncup.cfgfile%" ' ) do set "syncup.drive=%%~d"
if not defined syncup.drive for /f "skip=1 tokens=1,2" %%d in ( 'wmic LogicalDisk GET Caption^,Size' ) do for %%s in ( %%~e ) do if exist "%%~d\.sync\%~2" set "syncup.drive=%%~d"
if not defined syncup.drive (
	call :error "Target drive not found for task "%~2""
	goto :EOF
)

set "syncup.rootdir=%~dp0..\opt\nnBackup"
set "syncup.logfile=%syncup.drive%\.sync\%~2.log"
set "syncup.lnkfile=%syncup.drive%\.sync\%~2-links.txt"
goto :starting

:: ========================================================================

:starting

echo:
echo:==============================
echo:
echo:Starting: %~f0 %*
echo:
echo:==============================
echo:
set syncup
echo:
echo:==============================

:: ========================================================================

call :log 1.link "Creating the list of symbolic links"
call :search.links "%syncup.cfgfile%" > "%syncup.lnkfile%"

:: ========================================================================

call :log 2.bkup "Backing up"
"%syncup.rootdir%\nnbackup.exe" -f "%syncup.cfgfile%" -x "@%syncup.lnkfile%" -dx "@%syncup.lnkfile%" %syncup.nocopy% -o "%syncup.drive%\." -log "%syncup.logfile%"

:: ========================================================================

call :log 3.stop "Exit code = %ERRORLEVEL%"

echo:
echo:==============================
echo:
echo:Stopping: %~f0 %*
echo:
echo:==============================
echo:
set syncup.time
echo:
echo:==============================

:: ========================================================================

:EOS
endlocal
goto :EOF

:: ========================================================================

:search.links
for /f "tokens=1,*" %%1 in ( ' 
	findstr "^-i " "%~1" 
' ) do for /f "tokens=*" %%f in (  ' 
	dir /al /b /s "%%~2" 2^>nul
' ) do call :remove.basedir "%%~f" "%%~2"
goto :EOF

:remove.basedir
setlocal
set "fullpath=%~1"
call echo:%%fullpath:%~2\=%%
endlocal
goto :EOF

:: ========================================================================

:error
>&2 (
	echo:%~1
	echo:
	echo:Run "%~n0 help" for the help.
)
goto :EOF

:: ========================================================================

:log
set "syncup.time.%~1=%DATE: =0% %TIME: =0%"
echo:
echo:%DATE: =0% %TIME: =0% %~2
echo:
goto :EOF

:: ========================================================================

:help
echo:USAGE
echo:
echo:%~n0 help
echo:%~n0 list
echo:%~n0 test [task ^| -d drive]
echo:%~n0 run  [task ^| -d drive]
echo:
echo:
echo:COMMANDS
echo:
echo:help	print this help
echo:list	print the list of all tasks
echo:test	test sync up (emulating)
echo:run	run sync up
echo:
echo:
echo:OPTIONS
echo:
echo:Option may be the empty value, the task name or the drive name.
echo:
echo:Task name is the name of task configured in the configuration file 
echo:named as "%~n0-task.txt" that is assumed to be located under the same 
echo:directory, next to this script. 
echo:
echo:If the task is specified the script assumes that one of the drives 
echo:contains the file "drive:\.task".
echo:
echo:If the task is not specified it is assumed that a configuration file 
echo:is located under the "drive:\.sync" directory.
echo:
echo:If target is specified as "-d drive", it means to work directly with 
echo:the specified drive. In this case the script looks for "drive:\.sync" 
echo:firectory and works similar to the previous case.
goto :EOF

:: ========================================================================

:: EOF
