::Displays or unsets a search path for executable files.
::
::UNPATH [[/S|/L] path] ...
::UNPATH PATH
::
::Type UNPATH PATH to clear all search-path settings and direct cmd.exe to
::search only in the current directory. It is similar to PATH ;.
::
::Type UNPATH without parameters to display the current path.
::
::Type a set of directories to be removed from the PATH. Use switches to
::modify behavior of the command:
::    /S - Tells to remove all entries starting with the path
::    /L - Tells to remove the exact match of the path (by default)
@echo off

if "%~1" == "/?" (
	for /f "tokens=* delims=:" %%a in ( 'findstr /b "::" "%~f0"' ) do echo:%%a
	goto :EOF
)

if "%~1" == "" (
	path
	goto :EOF
)

if /i "%~1" == "path" (
	path ;
	goto :EOF
)

setlocal

set "unpath_subdir="
for %%a in ( %* ) do call :unpath_arg "%%~a"

if defined PATH set "PATH=%PATH:~1%"

endlocal & set "PATH=%PATH%"
goto :EOF


:unpath_arg
if "%~1" == "" goto :EOF

if /i "%~1" == "/S" (
	set "unpath_subdir=1"
	goto :EOF
)

if /i "%~1" == "/L" (
	set "unpath_subdir="
	goto :EOF
)

for /f "tokens=*" %%s in ( "%PATH:;=" "%" ) do (
	set "PATH="
	for %%p in ( "%%s" ) do call :unpath_entry "%%~p" "%~1"
)
goto :EOF


:unpath_entry
if "%~1" == "" goto :EOF
if /i "%~1" == "%~2" goto :EOF

set "unpath_entry=%~1"
call set "unpath_entry=%%unpath_entry:%~2=%%"

if /i "%~1" == "%~2%unpath_entry%" if "%unpath_entry:~0,1%." == "\." if defined unpath_subdir goto :EOF

set "PATH=%PATH%;%~1"
goto :EOF

