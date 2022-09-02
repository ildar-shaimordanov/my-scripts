@echo off

if "%~1" == "/?" goto :help
if "%~1" == "-?" goto :help

if /i "%~1" == "/h" goto :help
if /i "%~1" == "-h" goto :help

if "%~1" == "" (
	doskey /MACROS
) else (
	doskey %*
)

goto :EOF

:help
echo:Associates the name with the commands specified by the text.
echo:For more details, see DOSKEY /?
echo:
echo:Usage: alias [name=text]
echo:
echo:$T     Command separator. Allows multiple commands in a macro.
echo:$1-$9  Batch parameters. Equivalent to %%1-%%9 in batch programs.
echo:$*     Symbol replaced by everything following macro name on command line.
