:: Generates a name of a temporary file (or directory)
::
:: @usage  call :tempname NAME [TEMPLATE] [PATH]
::
:: The following error levels are being returned:
:: 1 - Illegal template format
:: 2 - Too few X's in template "..."
:: 3 - The path "..." not found
::
:: @param  string
:: @param  string
:: @param  string
::
:: @return ERRORLEVEL
:tempname

set %~1=

setlocal enabledelayedexpansion

set tempname_p=%~3

rem 2. Set default path to %TEMP%
if not defined tempname_p (
    set tempname_p=%TEMP%
)

rem 3. Check the path existance
dir /ad "%tempname_p%">nul 2>nul
if errorlevel 1 (
    endlocal
    exit /b 3
)

rem 4. Construct the target

if "%~2" == "" (
    rem 4.1. Set the default template
    set mktemp_t=XXXXXXXXXX
) else (
    rem 4.2. No path's and drive's delimiters
    echo.%~2|find /v ":" | find /v "\" | find /v "/">nul
    if errorlevel 1 (
        endlocal
        exit /b 1
    )

    rem 4.3. Extract the pure template
    if not "%~x2" == "" (
        set mktemp_t=%~x2
        set mktemp_t=!mktemp_t:~1!
    ) else (
        set mktemp_t=%~n2
    )

    rem 4.4. Only X's are enabled
    echo.!mktemp_t!|findstr "[^X]">nul
    if not errorlevel 1 (
        endlocal
        exit /b 1
    )
)

rem 4.5. Not shorter than 3 chars
call :str_len mktemp_l "%mktemp_t%"
if %mktemp_l% lss 3 (
    endlocal
    exit /b 2
)

rem 4.6. Create a random string
call :str_rnd mktemp_t %mktemp_l%

if not "%~x2" == "" (
    set mktemp_t=%~n2.%mktemp_t%
)

rem 4.7. Compile the resulting string
endlocal && set %~1=%tempname_p%\%mktemp_t%
exit /b 0

