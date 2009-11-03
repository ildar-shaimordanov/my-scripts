@echo off

call :is_number "%~1" -10 +10

if errorlevel 3 (
    echo OUT OF BOUNDS
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

goto :EOF

