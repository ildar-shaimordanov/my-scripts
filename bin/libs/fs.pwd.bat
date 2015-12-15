:: Populates the variable NAME with the the current working directory.
:: If NAME is not specified the current direcory will be printed.
::
:: @usage  call :tempname NAME
::
:: @param  string
:pwd
setlocal

if "%CD:~-1%" == "\" (
    set pwd=%CD%
) else (
    set pwd=%CD%\
)

if "%~1" == "" (
    echo.%pwd%
    endlocal
    goto :EOF
)

endlocal && set %~1=%pwd%
goto :EOF

