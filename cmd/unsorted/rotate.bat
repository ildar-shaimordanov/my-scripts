@echo off

if    "%~1" == ""   goto help
if /i "%~1" == "/h" goto help

setlocal

if not "%~2" == "" set /a rotate_n=%~2 2>nul
if not defined rotate_n set rotate_n=5
if %rotate_n% lss 5 set rotate_n=5

:: set rotate_c=copy /y
set rotate_0=copy nul
set rotate_c=move /y

set rotate_i=%rotate_n%

:loop_redo
set /a rotate_i-=1
if %rotate_i% == 0 goto loop_break

if exist "%~1.%rotate_i%" %rotate_c% "%~1.%rotate_i%" "%~1.%rotate_n%"

set /a rotate_n-=1
goto loop_redo
:loop_break

%rotate_c% "%~1" "%~1.1" && %rotate_0% "%~1"

endlocal
goto :EOF

:help
echo.Usage:
echo.    %~n0 FILENAME [NUMBER]
goto :EOF

