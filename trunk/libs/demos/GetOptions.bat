@echo off

setlocal

:: Store in variables like myvar_XXX
set getoptions_name=myvar

:: Use the custom help output
set getoptions_help=myhelp

:: Automatical support for /h, /help and /man options
set getoptions_autohelp=1

:: Process command line options
call :getoptions %*

:: Perform a quick exit
if defined getoptions_exit goto EOS

:: Show resulting variables and exit
echo.
echo.The "%getoptions_name%_count" shows the number of unnamed options only.
echo.The "%getoptions_name%_total" shows the total number of all options.
echo.
set myvar

:EOS
endlocal
goto :EOF

:: The custom help output
:myhelp
echo.This is "GetOptions" demo.
echo.
echo.This script has been launched with the option "%~1".
echo.By default, it serves to display the help message.

goto :EOF

