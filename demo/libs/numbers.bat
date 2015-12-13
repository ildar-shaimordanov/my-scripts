@echo off

setlocal

set L=-10
set R=+10
call :is_number "%~1" %L% %R%

if errorlevel 4 (
    echo GREATER THAN %R%
    goto :EOF
)

if errorlevel 3 (
    echo LESS THAN %L%
    goto :EOF
)

if errorlevel 2 (
    echo ILLEGAL
    goto :EOF
)

if errorlevel 1 (
    echo EMPTY
    goto :EOF
)

echo %1

endlocal
goto :EOF

