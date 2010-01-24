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
if not defined mktemp_/p (
    set mktemp_/p=%TEMP%
)


:: 3. Check the path existance
dir /ad "%mktemp_/p%">nul 2>nul
if errorlevel 1 (
    set mktemp_error=The path "%mktemp_/p%" not found
    goto error
)


:: 4. Construct the target
call :parse_template "%mktemp_1%"
if errorlevel 2 (
    set mktemp_error=Too few X's in template "%mktemp_1%"
    goto error
)
if errorlevel 1 (
    set mktemp_error=Illegal template format
    goto error
)


:: 5. Create temporary file or directory
if not defined mktemp_/u (
    if defined mktemp_/d (
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


:parse_template
set mktemp=

setlocal enabledelayedexpansion

if "%~1" == "" (
    rem 4.1. Set the default template
    set mktemp_t=XXXXXXXXXX
) else (
    rem 4.2. No path's and drive's delimiters
    echo.%mktemp_1%|find /v ":" | find /v "\" | find /v "/">nul
    if errorlevel 1 (
        exit /b 1
    )

    rem 4.3. Extract the pure template
    if not "%~x1" == "" (
        set mktemp_t=%~x1
        set mktemp_t=!mktemp_t:~1!
    ) else (
        set mktemp_t=%~n1
    )

    rem 4.4. Only X's are enabled
    echo.!mktemp_t!|findstr "[^X]">nul
    if not errorlevel 1 (
        exit /b 1
    )
)

rem 4.5. Not shorter than 3 chars
call :str_len mktemp_l "%mktemp_t%"
if %mktemp_l% lss 3 (
    exit /b 2
)

rem 4.6. Create a random string
call :str_rnd mktemp_t %mktemp_l%

if not "%~x1" == "" (
    set mktemp_t=%~n1.%mktemp_t%
)

rem 4.7. Compile the resulting string
endlocal && set mktemp=%mktemp_/p%\%mktemp_t%
exit /b 0


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

