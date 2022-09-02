@echo off


setlocal


:: Get options
set getoptions_autohelp=1
set getoptions_help=help
set getoptions_name=mktemp
call :getoptions %*
if defined getoptions_exit goto EOS


:: 1. Only one template
if %mktemp_count% gtr 1 (
    set mktemp_error=Too many templates
    goto error
)


:: 2. Set default path to %TEMP%
:: 3. Check the path existance
:: 4. Construct the target
call :tempname mktemp "%mktemp_1%" "%mktemp.p%"
if errorlevel 3 (
    set mktemp_error=The path "%mktemp.p%" not found
    goto error
)
if errorlevel 2 (
    set mktemp_error=Too few X's in template "%mktemp_1%"
    goto error
)
if errorlevel 1 (
    set mktemp_error=Illegal template format
    goto error
)


:: 5. Create temporary file or directory
if not defined mktemp.u (
    if defined mktemp.d (
        md "%mktemp%"
    ) else (
        copy /b /y nul "%mktemp%">nul
    )
)

:: 6. Print the name
if not errorlevel 1 (
    echo %mktemp%
)


:EOS
endlocal
goto :EOF


:error
echo.%~n0: %mktemp_error%.
echo.Try "%~n0 /h" for more informations.
endlocal
exit /b 1


:help
echo.Usage:
echo.    %~n0 [OPTIONS] [TEMPLATE]
echo.
echo.Creates a temporary file or directory and print it's name.
echo.If TEMPLATE is not specified, it uses XXXXXXXXXX.
echo.
echo.A template can be in two kinds:
echo.   - a name fully consists of X's with no an extension 
echo.   - any name with X's in an extension. 
echo.
echo.Only alfanumeric characters are enabled in a template.
echo.The minimal size of a template is 3 characters. 
echo.
echo.    /h      - display this help
echo.    /d      - create a directory, not a file
echo.    /u      - do not create anything; merely print a name
echo.    /p:DIR  - interpret TEMPLATE relative to DIR
goto :EOF

