@echo off


setlocal


:: Get options
set getoptions_autohelp=1
set getoptions_help=help
call :getoptions %*
if defined getoptions_exit goto EOS


if %opts_count% gtr 1 (
	echo.%~n0: too many templates
	echo.Try "%~n0 /h" for more informations.
	goto EOS
)


call :parse_template "%opts_1%"


if defined opts_/u (
	echo echo %mktemp%
) else (
if defined opts_/d (
	echo md "%mktemp%"
) else (
	echo copy nul "%mktemp%"
))


:EOS
endlocal
goto :EOF


:parse_template
if "%~1" == "" (
	set mktemp_tmpl=XXXXXXXXXX
) else (
if "%~x1" == "" (
	set mktemp_tmpl=%~1
) else (
	set mktemp_tmpl=%~x1
))

echo %mktempl% | findstr "[^X]" >nul
set mktemp

goto :EOF


:help
echo.Usage:
echo.    %~n0 [OPTIONS] [TEMPLATE]
echo.Create a temporary file or directory and print its name.
echo.If TEMPLATE is not specified, use tmp.XXXXXXXXXX.
echo.
echo.    /d      - create a directory, not a file
echo.    /u      - do not create anything; merely print a name
echo.    /p:DIR  - interpret TEMPLATE relative to DIR
goto :EOF

