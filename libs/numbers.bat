:: Validates the numeric value and returns errorlevel code
:: There is summary of non-zero errorlevels
::     1 - the empty value has been provided
::     2 - this is non-numeric or illegal value
::     3 - a number is less than the lower limit
::     4 - a number is greater than the upper limit
::
:: @param  string
:: @param  number  the lower limit, optional
:: @param  number  the upper limit, optional
::
:: @return ERRORLEVEL
:is_number
setlocal

if "%~1" == "" (
    endlocal
    exit /b 1
)

set /a number_var=%~1 2>nul

if errorlevel 2 (
    endlocal
    exit /b 2
)

if %~1 neq %number_var% (
    endlocal
    exit /b 2
)

if "%~2" == "" goto is_number_1
if %number_var% lss %~2 (
    endlocal
    exit /b 3
)

if "%~3" == "" goto is_number_1
if %number_var% gtr %~3 (
    endlocal
    exit /b 4
)

:is_number_1
endlocal
goto :EOF
