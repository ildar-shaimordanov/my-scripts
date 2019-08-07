@echo off

if "%~1" == "" goto :help

if "%~1" == "/?" goto :help
if "%~1" == "-?" goto :help

if /i "%~1" == "/h" goto :help
if /i "%~1" == "-h" goto :help

if /i "%~1" == "/a" goto :unalias.all
if /i "%~1" == "-a" goto :unalias.all

for %%m in ( %* ) do doskey %%m=
goto :EOF

:unalias.all
for /f "tokens=1 delims==" %%m in ( 'doskey /macros' ) do doskey %%m=
goto :EOF

:help
echo:Removes the associated names from the list of defined macros.
echo:For more details, see DOSKEY /?
echo:
echo:Usage: unalias [-a] name [name ...]
echo:
echo:    -a Remove all aliases
