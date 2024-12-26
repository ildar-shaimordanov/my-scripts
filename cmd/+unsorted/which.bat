:: USAGE:
::     which [-a] [--] name [...]
::
:: -a  Print all available matchings accordingly the description below.
::
:: For each of the names the script looks for and displays a doskey macro, 
:: the internal command information or the full path to the executable 
:: file in this order. The script doesn't mimic of the Unix command having 
:: the same name. It assumes specifics of the Windows command prompt. 
::
:: First of all, it looks for doskey macros because they have the higher 
:: priority in the prompt. The next step is a looking for internal 
:: commands from the known list of the commands. If the command is 
:: identified as internal the searching is stopped. 
::
:: If nothing has been found previously, the script continues searching of 
:: external commands in the current directory and the directories from the 
:: PATH environment. If no extension is specified, the PATHEXT variable is 
:: used for attempts to find the nearest filename corresponding the 
:: provided name. 
::
:: ENVIRONMENT:
::     PATH, PATHEXT
::
:: SEE ALSO:
::     DOSKEY /?
::     HELP /?
::     http://ss64.com/nt/
::
:: COPYRIGHTS
:: Copyright (c) 2010, 2014, 2024 Ildar Shaimordanov

@echo off

if "%~1" == "" (
	for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		echo:%%s
	)
	goto :EOF
)

:: ========================================================================

setlocal

set "which_doskey=%windir%\System32\doskey.exe"
if not exist "%which_doskey%" set "which_doskey="

set "which_find_all="

:which_opt_begin
set "which_opt=%~1"
if not defined which_opt goto :which_opt_end
if not "%which_opt:~0,1%" == "-" goto :which_opt_end
if "%~1" == "--" goto :which_opt_end

if /i "%~1" == "-a" set which_find_all=1
shift

goto :which_opt_begin
:which_opt_end

:: ========================================================================

:which_arg_begin
if "%~1" == "" goto :which_arg_end

for /f "delims=:\*?;/" %%a in ( "%~1" ) do if not "%%~a" == "%~1" (
	echo:%~n0: Name should not consist of drive, paths or wildcards>&2
	goto :which_arg_continue
)

:: Check for doskey macros
:: - doskey binary expected

if defined which_doskey for /f "tokens=1,* delims==" %%a in ( '
	"%which_doskey%" /MACROS
' ) do if /i "%~1" == "%%a" (
	echo:macro: %%a=%%b
	if not defined which_find_all goto :which_arg_continue
)

:: Check for cmd builtins
:: - the list of builtins checked with output of help binary and ss64 site

for %%b in ( 
	ASSOC CALL CD CHDIR CLS COLOR COPY DATE DEL DIR ECHO 
	ENDLOCAL ERASE EXIT FOR FTYPE GOTO IF MD MKDIR MKLINK MOVE 
	PATH PAUSE POPD PROMPT PUSHD RD REM REN RENAME RMDIR SET 
	SETLOCAL SHIFT START TIME TITLE TYPE VER VERIFY VOL 
) do if /i "%~1" == "%%~b" (
	echo:internal: %~1
	if not defined which_find_all goto :which_arg_continue
)

:: Check for binaries
:: - use the list of predefined file extensions in PATHEXT
:: - consider the case when a user specified both name and extension
:: - start looking for from the current directory first
:: - then continue from PATH

for %%x in ( "%PATHEXT:;=" "%" "" ) do ^
for %%p in ( "." "%PATH:;=" "%" ) do ^
if exist "%%~fp\%~1%%~x" (
	echo:%%~p\%~1%%~x
	if not defined which_find_all goto :which_arg_continue
)

:which_arg_continue

shift

goto :which_arg_begin
:which_arg_end

endlocal
goto :EOF

:: ========================================================================

:: EOF
