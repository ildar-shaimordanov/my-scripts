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
if "%~1" == "" (
    exit /b 1
)

setlocal

set /a number_var=%~1 2>nul

if errorlevel 2 (
    endlocal
    exit /b 2
)

if %~1 neq %number_var% (
    endlocal
    exit /b 2
)

call :is_number "%~2"
if errorlevel 1 goto is_number_1
if %number_var% lss %~2 (
    endlocal
    exit /b 3
)
:is_number_1

call :is_number "%~3"
if errorlevel 1 goto is_number_2
if %number_var% gtr %~3 (
    endlocal
    exit /b 4
)
:is_number_2

endlocal
exit /b 0

